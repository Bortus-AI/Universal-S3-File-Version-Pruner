# Universal S3 File Version Pruner

## Introduction

This utility script manages and deletes old versions of objects in an S3-compatible bucket. It is specifically designed for situations where versioning control cannot be disabled, such as with Backblaze B2. This script helps you delete versions more frequently than the default settings, aiding in better management of your storage space.

## Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [**Disclaimer**](#disclaimer)
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

## **Disclaimer**

**IMPORTANT: Ensure you test the script in a safe environment to avoid any accidental data loss. Use the dry run mode initially to simulate the deletion process without actually removing any files. This feature helps you understand what the script will do before any changes affect your data.**

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

On Fedora/RHEL/CentOS:

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

### Scheduling with Cron

To schedule the script with cron, for example, to run at 2 AM daily:

```cron
0 2 * * * /path/to/s3prune.sh --unattended --no-dry-run --bucket "your-bucket" --prefix "your-prefix" --endpoint-url "your-endpoint-url" --max-keys 1000
```

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please submit pull requests with enhancements or fixes.

## Support

For assistance or to report issues, please open an issue on the GitHub repository page.
