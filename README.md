# S3 Version Cleanup Script

This script is designed to clean up non-current (older) versions of objects within a specific prefix in an S3 bucket. This can be helpful if you're using versioning in your S3 bucket and want to remove outdated versions of files to save on storage costs.

## Prerequisites

- AWS CLI v2 installed and configured
- jq installed (for parsing JSON)

## AWS CLI Compatibility

This script has been tested with AWS CLI version 2. While it may work with AWS CLI version 1, we encourage users to utilize AWS CLI version 2 to ensure compatibility with the script and to take advantage of the latest features and improvements offered by the AWS CLI.

If you encounter any issues with AWS CLI version 1, consider upgrading to version 2. If upgrading is not possible and you face compatibility issues, please report them as an issue in the repository.

## Usage

1. Set the `BUCKET` variable to the name of your S3 bucket.
2. Set the `PREFIX` variable to the prefix where your S3 objects are located.
3. Set the `ENDPOINT_URL` to the endpoint URL of your S3 service (this example uses Backblaze B2).
4. (Optional) Adjust the `MAX_KEYS` variable to the maximum number of keys you want to process in a single batch.

To run the script, simply execute it in your terminal:

```bash
chmod +x s3_cleanup_script.sh
./s3_cleanup_script.sh
