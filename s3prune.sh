#!/bin/bash

set -e

CONFIG_FILE="$HOME/.s3cleanupconfig"
UNATTENDED=false
DRY_RUN=true

# Custom error function
error_exit() {
  echo "$1" >&2
  exit 1
}

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
    error_exit "Error: Missing required parameters in unattended mode: ${missing_params[*]}."
  fi
  MAX_KEYS=${MAX_KEYS:-1000} # Default MAX_KEYS if not provided
}

# Function to check for dependencies
check_dependency() {
  if ! command -v "$1" &>/dev/null; then
    error_exit "Error: $1 is not installed. Please install it."
  fi
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
    *) error_exit "Unknown parameter passed: $1"; exit 1 ;;
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
  echo "Please enter your configuration details:"
  read -r -p "Bucket name (previous: $BUCKET): " input
  BUCKET=${input:-$BUCKET}
  
  read -r -p "Prefix (leave empty for none, previous: $PREFIX): " input
  PREFIX=${input:-$PREFIX}
  
  read -r -p "Endpoint URL (previous: $ENDPOINT_URL): " input
  ENDPOINT_URL=${input:-$ENDPOINT_URL}
  
  read -r -p "Max keys to delete per batch (default 1000, previous: $MAX_KEYS): " input
  MAX_KEYS=${input:-${MAX_KEYS:-1000}}
  
  # Prompt for dry run mode with default value set to "y"
  read -r -p "Enable dry run mode? (y/n, default: y): " DRY_RUN_INPUT
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
  echo "Configuration saved for future use."
fi

# Check for dependencies
check_dependency "aws"
check_dependency "jq"

# Validate configuration parameters
if [ -z "$BUCKET" ]; then
  error_exit "Error: Bucket name cannot be empty."
fi

if ! [[ "$ENDPOINT_URL" =~ ^https?:// ]]; then
  error_exit "Error: Invalid endpoint URL. It should start with http:// or https://."
fi

if ! [[ "$MAX_KEYS" =~ ^[0-9]+$ ]]; then
  error_exit "Error: Max keys should be a positive integer."
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
    error_exit "Error: Failed to list object versions."
  fi

  if ! versions_to_delete=$(echo "$versions" | jq -c '[.Versions[]? | select(.IsLatest | not) | {Key:.Key, VersionId:.VersionId}]'); then
    error_exit "Error: Invalid JSON data from AWS or no versions available for prefix '$PREFIX'."
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

  if [ "$DRY_RUN" = true ]; then
    echo "Dry run: Would delete $num_versions old versions."
  else
    echo "Deleted $num_versions old versions."
  fi
}

# Execute the script with dry run logic
process_deletion

# If dry run is enabled, notify the user
if [ "$DRY_RUN" = true ]; then
  echo "Dry run enabled. No objects were actually deleted."
fi
