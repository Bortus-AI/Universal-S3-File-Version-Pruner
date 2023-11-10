#!/bin/bash

CONFIG_FILE="$HOME/.s3cleanupconfig"
UNATTENDED=false
DRY_RUN=true

# Function to validate required parameters in unattended mode
validate_required_parameters_unattended() {
  local missing_params=()
  if [ -z "$BUCKET" ]; then
    missing_params+=("bucket")
  fi
  if [ -z "$ENDPOINT_URL" ]; then
    missing_params+=("endpoint-url")
  fi
  if [ ${#missing_params[@]} -gt 0 ]; then
    echo "Error: Missing required parameters in unattended mode: ${missing_params[*]}." >&2
    exit 1
  fi
  MAX_KEYS=${MAX_KEYS:-1000} # Default MAX_KEYS if not provided
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
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# If unattended, validate parameters without loading the previous configuration
if [ "$UNATTENDED" = true ]; then
  validate_required_parameters_unattended
else
  # Load previous configuration if it exists
  if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
  fi
  
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
if [ -n "$PREFIX" ]; then
  PREFIX="$PREFIX/"
fi

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
if ! command -v aws &>/dev/null; then
  echo "Error: aws CLI is not installed." >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed." >&2
  exit 1
fi

# Function to delete a batch of versions
delete_batch() {
  delete_payload=$(echo "$1" | jq '{Objects: ., Quiet: true}')
  delete_payload_file=$(mktemp)
  echo "$delete_payload" >"$delete_payload_file"

  if [ "$DRY_RUN" = false ]; then
    if ! aws s3api delete-objects --bucket "$BUCKET" --delete "file://$delete_payload_file" --endpoint-url "$ENDPOINT_URL"; then
      echo "Error: Failed to delete objects." >&2
      rm "$delete_payload_file"
      exit 1
    fi
  else
    echo "Dry run: Would delete objects: $(cat "$delete_payload_file")"
  fi

  rm "$delete_payload_file"
}

# Function to process deletion or dry run
process_deletion() {
  if ! versions=$(aws s3api list-object-versions --bucket "$BUCKET" --prefix "$PREFIX" --endpoint-url "$ENDPOINT_URL"); then
    echo "Error: Failed to list object versions." >&2
    exit 1
  fi

  if ! versions_to_delete=$(echo "$versions" | jq -c '[.Versions[]? | select(.IsLatest | not) | {Key:.Key, VersionId:.VersionId}]'); then
    echo "Error: Invalid JSON data from AWS or no versions available for prefix '$PREFIX'." >&2
    exit 1
  fi

  num_versions=$(echo "$versions_to_delete" | jq -r 'length')
  if [ -z "$versions_to_delete" ] || [ "$num_versions" -eq 0 ]; then
    echo "No old versions to delete for prefix '$PREFIX'."
    exit 0
  fi

  for ((i = 0; i < num_versions; i += MAX_KEYS)); do
    batch=$(echo "$versions_to_delete" | jq ".[$i:$((i + MAX_KEYS))]")
    delete_batch "$batch"
  done

  echo "Deleted $num_versions old versions."
}

# Execute the script with dry run logic
process_deletion

# If dry run is enabled, notify the user
if [ "$DRY_RUN" = true ]; then
  echo "Dry run enabled. No objects were actually deleted."
fi