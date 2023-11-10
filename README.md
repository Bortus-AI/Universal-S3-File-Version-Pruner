# Universal S3 File Version Pruner

## Introduction

A utility script for managing and deleting old versions of objects in an S3-compatible bucket, specifically designed and tested with Backblaze B2 and AWS CLI v2, but should work with any S3-compatible service.

## Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Disclaimer](#disclaimer)
- [Installing AWS CLI v2](#installing-aws-cli-v2)
- [Installing jq](#installing-jq)
- [Downloading the Script](#downloading-the-script)
- [Usage](#usage)
  - [Interactive Mode](#interactive-mode)
  - [Unattended Mode](#unattended-mode)
  - [Scheduling with Cron](#scheduling-with-cron)
- [License](#license)
- [Contributing](#contributing)
- [Support](#support)

## Disclaimer
**Ensure you test the script in a safe environment to avoid any accidental data loss.**
## Prerequisites

Before running the script, ensure you have AWS CLI v2 and jq installed on your system.

### Installing AWS CLI v2

Follow the official AWS guide to install AWS CLI v2 on your system or use the commands bellow:

[AWS CLI v2 Installation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
```sh
# For Linux:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
Configure your AWS credentials to allow the script to interact with your S3-compatible service:

```bash
aws configure
```
Enter your AWS Access Key, Secret Key, and the default region when prompted.

### Installing jq

Install jq using your system's package manager. For example, on Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install jq
```

On Fedora/RHEL/CentOS:

```bash
sudo yum install jq
```

**Verify Installation**
Check the installations with `aws --version` and `jq --version`.

## Downloading the Script

To download the script, use the following `wget` command:

```bash
wget https://raw.githubusercontent.com/navyfighter12/S3Prune-UniversalFileVersionTool/main/s3prune.sh
chmod +x s3prune.sh
```

## Usage

### Interactive Mode

Run the script without arguments to enter interactive mode:

```bash
./s3prune.sh
```

You will be prompted to enter:

- Bucket name: The name of the S3 bucket.
- Prefix: The prefix for the S3 objects (optional).
- Endpoint URL: The endpoint URL for the S3 API.
- Max keys: The maximum number of keys to delete per batch (default is 1000).
- Dry run mode: Choose whether to perform a dry run (default is 'y').

Settings are saved in a configuration file for future runs.

### Unattended Mode

Run the script in unattended mode using the `--unattended` flag with the necessary parameters:

```bash
./s3prune.sh --unattended --bucket "your-bucket" --prefix "your-prefix" --endpoint-url "your-endpoint-url" --max-keys 1000
```

To disable dry run mode in unattended mode, use the `--no-dry-run` flag:

```bash
./s3prune.sh --unattended --no-dry-run --bucket "your-bucket" --prefix "your-prefix" --endpoint-url "your-endpoint-url" --max-keys 1000
```

### Scheduling with Cron

Schedule the script to run automatically with cron. For example, to run at 2 AM daily:

```cron
0 2 * * * /path/to/s3prune.sh --unattended --no-dry-run --bucket "your-bucket" --prefix "your-prefix" --endpoint-url "your-endpoint-url" --max-keys 1000
```

Provide the full path to the script and adjust parameters as necessary.

## License
This project is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for the full license text.

## Contributing

Feel free to submit pull requests with enhancements or fixes.

## Support

For issues or assistance, please open an issue on the GitHub repository page.
