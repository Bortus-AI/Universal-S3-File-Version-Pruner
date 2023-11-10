# Universal S3 File Version Pruner

This script is designed to automate the deletion of outdated file versions in S3-compatible storage buckets, streamlining storage space optimization and cost reduction.

### Contents
1. [Introduction](#1-introduction)
2. [Disclaimer](#2-disclaimer)
3. [Prerequisites / Setup](#3-prerequisites--setup)
4. [S3 Service Compatibility](#4-s3-service-compatibility)
5. [AWS CLI v2](#5-aws-cli-v2)
6. [Usage Instructions](#6-usage-instructions)
7. [Contributing](#7-contributing)
8. [License](#8-license)

## 1. Introduction
Optimize your S3-compatible storage buckets efficiently by automating the pruning of non-current file versions, particularly beneficial for services like Backblaze B2.

## 2. Disclaimer
**Ensure you test the script in a safe environment to avoid any accidental data loss.**

## 3. Prerequisites / Setup
Before running the script, ensure the following tools are installed and configured:

### Install AWS CLI v2
**For Linux:**
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Configure AWS CLI
Run `aws configure` and follow the prompts to enter your credentials.

### Install `jq`
**For Ubuntu/Debian:**
```sh
sudo apt-get install jq
```
**For Fedora/RHEL/CentOS:**
```sh
sudo yum install jq
```

### Verify Installation
Check the installations with `aws --version` and `jq --version`.

## 4. S3 Service Compatibility
The script is tested with Backblaze B2 but should work with other S3-compatible services.

> **Note:** If issues arise with other services, please raise them in the repo.

## 5. AWS CLI v2
The script supports AWS CLI v2; users of v1 should upgrade to avoid issues.

> **Warning:** Report any v1 related issues in the repo.

## 6. Usage Instructions
Configure script variables `BUCKET`, `PREFIX`, `ENDPOINT_URL`, and optionally `MAX_KEYS`. Execute the script in your terminal:

```shell
chmod +x s3prune.sh
./s3prune.sh
```

## 7. Contributing
Contributions are welcome! Feel free to fork the repo, open a pull request, or tag an issue with "enhancement".

## 8. License
This project is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for the full license text.

---

Each section now has a heading with a corresponding link for easy navigation.
