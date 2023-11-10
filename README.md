Certainly! Here's the revised structure for your README with the suggested changes:

---

# Universal S3 File Version Pruner

This script is designed to automate the deletion of outdated file versions in S3-compatible storage buckets, streamlining storage space optimization and cost reduction.

### Contents
1. [Introduction](#1-introduction)
2. [Disclaimer](#2-disclaimer)
3. [Prerequisites / Setup](#3-prerequisites--setup)
4. [Usage Instructions](#4-usage-instructions)
5. [S3 Service Compatibility](#5-s3-service-compatibility)
6. [Contributing](#6-contributing)
7. [License](#7-license)

## 1. Introduction
Optimize your S3-compatible storage buckets efficiently by automating the pruning of non-current file versions, particularly beneficial for services like Backblaze B2.

## 2. Disclaimer
**Ensure you test the script in a safe environment to avoid any accidental data loss.**

## 3. Prerequisites / Setup
Before running the script, ensure the following tools are installed and configured:

**Install and Configure AWS CLI v2**
For users of AWS CLI v1, it is recommended to upgrade to v2 to avoid issues.
```sh
# For Linux:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
Run `aws configure` and follow the prompts to enter your credentials.

**Install `jq`**
```sh
# For Ubuntu/Debian:
sudo apt-get install jq

# For Fedora/RHEL/CentOS:
sudo yum install jq
```

**Verify Installation**
Check the installations with `aws --version` and `jq --version`.

## 4. Usage Instructions
After setting up the prerequisites, configure script variables `BUCKET`, `PREFIX`, `ENDPOINT_URL`, and optionally `MAX_KEYS`. Execute the script in your terminal:
```shell
chmod +x s3prune.sh
./s3prune.sh
```

## 5. S3 Service Compatibility
The script is tested with Backblaze B2 but should work with other S3-compatible services.
> **Note:** If issues arise with other services, please raise them in the repo.

## 6. Contributing
Contributions are welcome! Feel free to fork the repo, open a pull request, or tag an issue with "enhancement".

## 7. License
This project is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for the full license text.

---

With this structure, you're guiding the user through a logical sequence of understanding what the script does, preparing their environment, using the script, and then learning about compatibility and how they can contribute. The AWS CLI v2 details are integrated into the setup section to streamline the process.
