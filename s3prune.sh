#!/bin/bash
set -e

# Configuration variables
BUCKET="your-bucket-name"
PREFIX="your-prefix/" # Adjust this to your specific prefix. Can handle '/your-prefix', 'your-prefix/' or 'your-prefix'
ENDPOINT_URL="your-endpoint-url"
MAX_KEYS=1000 # Adjust the max keys as needed
DRY_RUN=false

# Check for dependencies
if ! command -v aws &>/dev/null; then
    echo "Error: aws CLI is not installed." >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed." >&2
    exit 1
fi

# Normalize PREFIX to ensure it ends with a '/' but does not start with one
PREFIX=$(echo "$PREFIX" | sed 's:^/*::;s:/*$:/:')

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

# Parse arguments for dry run
for arg in "$@"; do
    case $arg in
    --dry-run)
        DRY_RUN=true
        ;;
    esac
done

# Execute the script with dry run logic
process_deletion

# If dry run is enabled, notify the user
if [ "$DRY_RUN" = true ]; then
    echo "Dry run complete. No objects were actually deleted."
fi