# Universal S3 File Version Pruner Script

The purpose of this script is to streamline the management of your S3-compatible storage buckets by automating the cleanup of non-current (older) versions of files. Specifically targeting files with a designated prefix, it is an essential tool for optimizing storage space and reducing costs—particularly useful for services like Backblaze B2, where version control cannot be fully disabled. By purging outdated file versions, the script ensures a more efficient and cost-effective data storage solution.


### **Disclaimer: Always test scripts like this in a safe environment before running them on production data to prevent accidental data loss.**


## Prerequisites

- AWS CLI v2 installed and configured (for S3-compatible services)
- `jq` installed (for parsing JSON)


## S3 Compatibility

This script has been tested with Backblaze B2, an S3-compatible storage service. While it is specifically designed for Backblaze B2, it should work with other S3-compatible storage services as well. However, compatibility with other services has not been tested.

> **Note:** If you are using this script with a storage service other than Backblaze B2 and encounter any issues, please report them as an issue in the repository.


## AWS CLI Compatibility

This script has been tested with AWS CLI version 2 used with Backblaze B2. While it may work with AWS CLI version 1, we encourage users to utilize AWS CLI v2 to ensure compatibility with the script and to take advantage of the latest features and improvements offered by the AWS CLI.

> **Warning:** If you encounter any issues with AWS CLI version 1, consider upgrading to version 2. If upgrading is not possible and you face compatibility issues, please report them as an issue in the repository.


## Usage

1. Set the `BUCKET` variable to the name of your S3-compatible bucket.
2. Set the `PREFIX` variable to the prefix where your objects are located.
3. Set the `ENDPOINT_URL` to the endpoint URL of your S3-compatible service (for testing, this example uses Backblaze B2).
4. (Optional) Adjust the `MAX_KEYS` variable to the maximum number of keys you want to process in a single batch.

To run the script, simply execute it in your terminal:

```shell
chmod +x s3prune.sh
./s3prune.sh
```


## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".


## LICENSE

Distributed under the Apache 2.0 License. See [LICENSE](LICENSE) for more information.

