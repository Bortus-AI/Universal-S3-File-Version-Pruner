#!/bin/bash

CONFIG_FILE="$HOME/.s3cleanupconfig"
UNATTENDED=false
DRY_RUN=true

# Custom error handling function
handle_error() {
  local error_message="$1"
  local exit_code="${2:-1}"
  echo "Error: $error_message" >&2
  exit "$exit_code"
}

# Function to validate required parameters in unattended mode
validate_required_parameters_unattended() {
  local missing_params=()
  [ -z "$BUCKET" ] && missing_params+=("bucket")
  [ -z "$ENDPOINT_URL" ] && missing_params+=("endpoint-url")
  [ ${#missing_params[@]} -gt 0 ] && handle_error "Missing required parameters in unattended mode: ${missing_params[*]}."

  # Default MAX_KEYS if not provided
  MAX_KEYS=${MAX_KEYS:-1000}
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --unattended) UNATTENDED=true ;;
    --no-dry-run) DRY_RUN=false ;;
    --bucket) BUCKET="$2"; shift ;;
    --prefix) PREFIX="$2"; shift ;;
    --endpoint-url) ENDPOINT_URL="$2"; shift ;;
    --max-keys) MAX_KEYS="$2"; shift ;;
    *) handle_error "Unknown parameter passed: $1" ;;
  esac
  shift
done

# If unattended, validate parameters without loading the previous configuration
if [ "$UNATTENDED" = true ]; then
  validate_required_parameters_unattended
else
  # Load previous configuration if it exists
  [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

  # Prompt for user input for each configuration item
  read -r -p "Enter your bucket name [$BUCKET]: " input
  BUCKET=${input:-$BUCKET}

  read -r -p "Enter your prefix (or hit enter for none) [$PREFIX]: " input
  PREFIX=${input:-$PREFIX}

  read -r -p "Enter your endpoint URL [$ENDPOINT_URL]: " input
  ENDPOINT_URL=${input:-$ENDPOINT_URL}

  read -r -p "Enter max keys to delete per batch (default 1000) [$MAX_KEYS]: " input
  MAX_KEYS=${input:-${MAX_KEYS:-1000}}

  # Prompt for dry run mode with default value set to "y"
  read -r -p "Enable dry run mode? (y/n) [y]: " DRY_RUN_INPUT
  DRY_RUN=$([[ -z "$DRY_RUN_INPUT" || "$DRY_RUN_INPUT" =~ ^[yY]$ ]] && echo true || echo false)
fi

# Normalize PREFIX to ensure it does not start with a slash and ends with one if not empty
PREFIX="${PREFIX#/}"   # Remove leading slashes
PREFIX="${PREFIX%/}"   # Remove trailing slashes, if present
[ -n "$PREFIX" ] && PREFIX="$PREFIX/"

# Save the current configuration if not in unattended mode
if [ "$UNATTENDED" = false ]; then
  {
    echo "BUCKET='$BUCKET'"
    echo "PREFIX='$PREFIX'"
    echo "ENDPOINT_URL='$ENDPOINT_URL'"
    echo "MAX_KEYS=$MAX_KEYS"
    echo "DRY_RUN=$DRY_RUN"
  } > "$CONFIG_FILE"
fi

# Check for dependencies
command -v aws &>/dev/null || handle_error "aws CLI is not installed. Please install it following the instructions at https://aws.amazon.com/cli/."
command -v jq &>/dev/null || handle_error "jq is not installed. Please install it following the instructions at https://stedolan.github.io/jq/download/."

# Validate configuration parameters
[ -z "$BUCKET" ] && handle_error "Bucket name cannot be empty."
[[ "$ENDPOINT_URL" =~ ^https?:// ]] || handle_error "Invalid endpoint URL. It should start with http:// or https://."
[[ "$MAX_KEYS" =~ ^[0-9]+$ ]] || handle_error "Max keys should be a positive integer."

# Function to delete a batch of versions
delete_batch() {
  local delete_payload
  delete_payload=$(echo "$1" | jq '{Objects: ., Quiet: true}')
  local delete_payload_file
  delete_payload_file=$(mktemp)
  echo "$delete_payload" >"$delete_payload_file"

  if [ "$DRY_RUN" = false ]; then
    aws s3api delete-objects --bucket "$BUCKET" --delete "file://$delete_payload_file" --endpoint-url "$ENDPOINT_URL" || handle_error "Failed to delete objects."
  else
    echo "Dry run: Would delete objects: $(cat "$delete_payload_file")"
  fi

  rm "$delete_payload_file"
}

# Function to process deletion or dry run
process_deletion() {
  local versions
  versions=$(aws s3api list-object-versions --bucket "$BUCKET" --prefix "$PREFIX" --endpoint-url "$ENDPOINT_URL") || handle_error "Failed to list object versions."

  local versions_to_delete
  versions_to_delete=$(echo "$versions" | jq -c '[.Versions[]? | select(.IsLatest | not) | {Key:.Key, VersionId:.VersionId}]') || handle_error "Invalid JSON data from AWS or no versions available for prefix '$PREFIX'."

  local num_versions
  num_versions=$(echo "$versions_to_delete" | jq -r 'length')
  if [ -z "$versions_to_delete" ] || [ "$num_versions" -eq 0 ]; then
    echo "No old versions to delete for prefix '$PREFIX'."
    exit 0
  fi

  for ((i = 0; i < num_versions; i += MAX_KEYS)); do
    local batch
    batch=$(echo "$versions_to_delete" | jq ".[$i:$((i + MAX_KEYS))]")
    delete_batch "$batch"
  done

  if [ "$DRY_RUN" = true ]; then
    echo "Dry run: Would delete $num_versions old versions."
  else
    echo "Deleted $num_versions old versions."
  fi
}

# Execute the script with dry run logic
process_deletion

# If dry run is enabled, notify the user
[ "$DRY_RUN" = true ] && echo "Dry run enabled. No objects were actually deleted."
