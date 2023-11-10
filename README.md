# Universal S3 File Version Pruner 

[![License](https://img.shields.io/github/license/navyfighter12/S3Prune-UniversalFileVersionTool?label=license&style=flat-square)](LICENSE)

## Introduction

This utility script manages and deletes old versions of objects in an S3-compatible bucket. It is specifically designed for situations where versioning control cannot be disabled, such as with Backblaze B2. This script helps you delete versions more frequently than the default settings, aiding in better management of your storage space.

## Table of Contents

- [Introduction](#introduction)
- [Benefits](#benefits)
- [Disclaimer](#disclaimer)
- [Prerequisites](#prerequisites)
  - [Installing AWS CLI v2](#installing-aws-cli-v2)
  - [Installing jq](#installing-jq)
- [Downloading the Script](#downloading-the-script)
- [Usage](#usage)
  - [Configuration](#configuration)
  - [Interactive Mode](#interactive-mode)
  - [Unattended Mode](#unattended-mode)
  - [Filtering](#filtering)
  - [Scheduling with Cron](#scheduling-with-cron)
  - [Example Usage](#example-usage)
- [License](#license)
- [Contributing](#contributing)
- [Support](#support)

## Benefits

- Automatically deletes old versions based on configurable filters
- Can target specific subsets of objects by prefix  
- Easy to customize schedule with cron jobs
- Saves time compared to manually deleting old versions
- Helps reduce storage costs by pruning unused old versions

## **Disclaimer**

**IMPORTANT: Ensure you test the script in a safe environment to avoid any accidental data loss.**

## Prerequisites

Before running the script, ensure you have AWS CLI v2 and jq installed on your system, and they are the latest versions or the versions compatible with the script.

### Installing AWS CLI v2

Follow the official AWS guide to install AWS CLI v2 on your system or use the commands below:

[AWS CLI v2 Installation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

```sh
# For Linux:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Installing jq

Install jq using your system's package manager. For example, on Ubuntu/Debian:

```sh
sudo apt-get update
sudo apt-get install jq
```

And for Fedora/RHEL/CentOS:

```sh
sudo yum install jq
```

**Verify Installation**

Check the installations with:

```sh
aws --version
jq --version
```

## Downloading the Script

To download the script, use the following `wget` command:

```sh
wget https://raw.githubusercontent.com/navyfighter12/S3Prune-UniversalFileVersionTool/main/s3prune.sh
chmod +x s3prune.sh
```

## Usage

The script supports various configuration options to control its behavior, and it can be run in interactive or unattended modes. Use the `--prefix` option to target a subset of objects within the bucket.

### Configuration

Customize the script's operation with command-line flags:

```
./s3prune.sh [--unattended] [--no-dry-run] [--bucket BUCKET] [--prefix PREFIX]
            [--endpoint-url URL] [--max-keys MAXKEYS] 
```

### Interactive Mode

Run the script without arguments to enter interactive mode:

```sh
./s3prune.sh
```

### Unattended Mode

For unattended mode, pass the `--unattended` flag along with necessary parameters:

```sh
./s3prune.sh --unattended --bucket "your-bucket" --prefix "your-prefix" --endpoint-url "your-endpoint-url" --max-keys 1000
```

To disable dry run mode in unattended mode, use the `--no-dry-run` flag:

```sh
./s3prune.sh --unattended --no-dry-run --bucket "your-bucket" --prefix "your-prefix" --endpoint-url "your-endpoint-url" --max-keys 1000
```

### Filtering

Use the `--prefix` option to target a subset of objects in the bucket, e.g.:

```
--prefix folder1/subfolder/
```

The script deletes all old non-current object versions that match the prefix.

### Scheduling with Cron

To schedule the script with cron, for example, to run at 2 AM daily:

```cron
0 2 * * * /path/to/s3prune.sh --unattended --no-dry-run --bucket "your-bucket" --prefix "your-prefix" --endpoint-url "your-endpoint-url" --max-keys 1000
```

### Example Usage

An example of the script running in interactive mode with a dry run:

```sh
debian@vps-xxx:~$ ./s3prune.sh 
Enter your bucket name [default-bucket]: 
Enter your prefix (or hit enter for none) [default-prefix]: 
Enter your endpoint URL [https://s3.default-endpoint.com]: 
Enter max keys to delete per batch (default 1000) [1000]: 
Enable dry run mode? (y/n) [y]: 
Dry run: Would delete objects: {
  "Objects": [
    {
      "Key": "example-folder/example-file.nfo",
      "VersionId": "4_zxxxxxxxxxxxxxxx_fxxxxxxxxxxxxxxxb6_d2023xxxx_mxxxxxx_c005_vxxxxxxx_txxxx_u0xxxxxxxxxxx"
    },
    {
      "Key": "another-folder/another-file.nfo",
      "VersionId": "4_zxxxxxxxxxxxxxxx_fxxxxxxxxxxxxxxxd3_d2023xxxx_mxxxxxx_c005_vxxxxxxx_txxxx_u0xxxxxxxxxxx"
    }
  ],
  "Quiet": true
}
Deleted 2 old versions.
Dry run

 enabled. No objects were actually deleted.
```

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please submit pull requests with enhancements or fixes.

## Support

For assistance or to report issues, please open an issue on the GitHub repository page.
