### Task: Configuring IAM Group Permissions (CLI Method)

*This task demonstrates how to attach an AWS-managed policy to an IAM Group, which is the standard way to grant permissions to multiple users at once and simplify access management.*

This report details the process of attaching the `AmazonEC2FullAccess` policy to the `cmtr-zdv1y551-iam-g-group-developers` IAM group using the AWS Command Line Interface (CLI) to achieve the maximum possible score.

#### Step 1: Task Analysis & Strategy

The primary objective was to grant full EC2 access to all users within the `cmtr-zdv1y551-iam-g-group-developers` group. Based on the sandbox scoring system, using the AWS CLI is required to earn a 100% score. Therefore, the chosen strategy was to use the `aws iam attach-group-policy` command instead of the AWS Management Console.

#### Step 2: Execution via AWS CLI

1.  **CLI Configuration:** The AWS CLI environment was first configured with the provided sandbox credentials (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) and set to the `us-east-1` region.

2.  **Attaching the Policy:** The following command was executed in the terminal. This single action attaches the required AWS-managed policy to the user group, fulfilling the task's core requirement.

    ```bash
    aws iam attach-group-policy \
      --group-name cmtr-zdv1y551-iam-g-group-developers \
      --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
    ```

#### Step 3: Verification

Although the action was performed via the CLI, verification was completed through the console to ensure the changes took effect correctly:
1.  A console password was created for user `cmtr-zdv1y551-iam-g-user-dev-0` via the main administrative account's IAM service to facilitate the verification login.
2.  Signed out of the current session and logged back in as this user.
3.  Navigated to the EC2 service dashboard and confirmed full access to all resources without any permission errors, thus verifying that the CLI command was successful.

---

### Task: Configuration of Role Chaining in AWS (CLI Method)

*This task teaches a core security pattern: configuring one IAM role to assume another. This "role chaining" is fundamental for delegating permissions securely without sharing long-term credentials.*

This report outlines the CLI-based solution for configuring a role chain, where one role (`AssumeRole`) is used to assume another (`ReadOnlyRole`), adhering to the principle of least privilege.

#### Step 1: Task Analysis & Strategy

The task requires setting up a two-step role assumption process. The configuration involves three distinct actions:
1.  Granting `AssumeRole` the permission to assume `ReadOnlyRole`.
2.  Granting `ReadOnlyRole` read-only permissions across AWS services.
3.  Establishing a trust relationship from `ReadOnlyRole` back to `AssumeRole`.

To ensure the highest score and automation, all steps were performed using the AWS CLI. The solution uses AWS-managed policies where appropriate and creates a specific, inline policy for the assumption permission.

#### Step 2: Execution via AWS CLI

The following commands configure the role chain using the specific role names from the lab environment. The AWS Account ID is `180503893306`.

1.  **Allow `AssumeRole` to Assume `ReadOnlyRole` (Permissions Policy)**

    An inline policy was created and attached to `cmtr-zdv1y551-iam-ar-iam_role-assume`. This policy grants only the specific `sts:AssumeRole` action on the `cmtr-zdv1y551-iam-ar-iam_role-readonly` resource.

    *Policy JSON (`policy.json`):*
    ```json
    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::180503893306:role/cmtr-zdv1y551-iam-ar-iam_role-readonly"
        }
    }
    ```

    *CLI Command:*
    ```bash
    aws iam put-role-policy \
      --role-name cmtr-zdv1y551-iam-ar-iam_role-assume \
      --policy-name AssumeReadOnlyRolePolicy \
      --policy-document file://policy.json
    ```

2.  **Grant `ReadOnlyRole` Read-Only Access (Permissions Policy)**

    The AWS-managed `ReadOnlyAccess` policy was attached to `cmtr-zdv1y551-iam-ar-iam_role-readonly` to provide it with broad, non-destructive read permissions.

    *CLI Command:*
    ```bash
    aws iam attach-role-policy \
      --role-name cmtr-zdv1y551-iam-ar-iam_role-readonly \
      --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
    ```

3.  **Configure `ReadOnlyRole` to Trust `AssumeRole` (Trust Policy)**

    The trust policy of `cmtr-zdv1y551-iam-ar-iam_role-readonly` was updated to allow `cmtr-zdv1y551-iam-ar-iam_role-assume` to assume it.

    *Trust Policy JSON (`trust-policy.json`):*
    ```json
    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::180503893306:role/cmtr-zdv1y551-iam-ar-iam_role-assume"
            },
            "Action": "sts:AssumeRole"
        }
    }
    ```

    *CLI Command:*
    ```bash
    aws iam update-assume-role-policy \
      --role-name cmtr-zdv1y551-iam-ar-iam_role-readonly \
      --policy-document file://trust-policy.json
    ```

#### Step 3: Verification

Verification was performed using the CLI to simulate the full user experience:
1.  First, assumed the `cmtr-zdv1y551-iam-ar-iam_role-assume` to get temporary credentials.
2.  Using these credentials, a second assumption was made to the `cmtr-zdv1y551-iam-ar-iam_role-readonly`.
3.  With the final set of credentials, a read-only command (e.g., `aws iam list-users`) was executed and succeeded.
4.  A write command (e.g., `aws iam create-user --user-name test`) was attempted and failed with a "permission denied" error, confirming the read-only restriction was effective.

---

### Task: Using AWS Managed Policies for IAM Resources (CLI Method)

*This task covers the essential skill of attaching AWS's own pre-configured managed policies to an IAM role, which is the quickest way to grant standard permission sets like "read-only" or "administrator."*

This report documents the process of attaching predefined, AWS-managed policies to two separate IAM roles to grant them specific levels of access.

#### Step 1: Task Analysis & Strategy

The objective is to configure two roles using AWS-managed policies in two distinct "moves":
1.  Grant read-only access to the `cmtr-zdv1y551-iam-mp-iam_role-readonly` role. The appropriate AWS-managed policy is `ReadOnlyAccess`.
2.  Grant administrative access to the `cmtr-zdv1y551-iam-mp-iam_role-administrator` role. The appropriate AWS-managed policy is `AdministratorAccess`.

The AWS CLI command `aws iam attach-role-policy` is the correct tool for this task.

#### Step 2: Execution via AWS CLI

First, the CLI was configured with the new credentials for this specific task. Then, the following two commands were executed.

1.  **Attach Read-Only Policy:**
    ```bash
    aws iam attach-role-policy \
      --role-name cmtr-zdv1y551-iam-mp-iam_role-readonly \
      --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
    ```

2.  **Attach Administrator Policy:**
    ```bash
    aws iam attach-role-policy \
      --role-name cmtr-zdv1y551-iam-mp-iam_role-administrator \
      --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
    ```

#### Step 3: Verification

A quick visual check was performed using the AWS Management Console to ensure the policies were attached correctly before final validation:
1.  Navigated to the **IAM -> Roles** section in the AWS Console.
2.  Selected the `cmtr-zdv1y551-iam-mp-iam_role-readonly` role and confirmed under its "Permissions" tab that the `ReadOnlyAccess` policy was present.
3.  Selected the `cmtr-zdv1y551-iam-mp-iam_role-administrator` role and confirmed that the `AdministratorAccess` policy was attached.

This visual confirmation ensured the CLI commands were successful.

---

### Task: Configuring IAM Policies with Conditions (CLI Method)

*This task focuses on using the `Condition` element in IAM policies to create fine-grained, context-aware permissions. This is a critical skill for implementing robust security controls based on factors like source IP or requested region.*

This report details the steps to attach two conditional, inline policies to an IAM role using the AWS CLI.

#### Step 1: Task Analysis & Strategy

The objective is to add two specific `Deny` policies to the `cmtr-zdv1y551-iam-c-iam_role` role. Since these policies are unique to this role, creating them as **inline policies** using the `aws iam put-role-policy` command is the correct approach.

1.  **Deny S3 Access by IP:** Create an inline policy named `deny-s3-policy` that denies `s3:Get*` and `s3:List*` actions when the request's source IP matches the EC2 instance's public IP.
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Deny",
                "Action": [
                    "s3:Get*",
                    "s3:List*"
                ],
                "Resource": "*",
                "Condition": {
                    "IpAddress": {
                        "aws:SourceIp": "<EC2_PUBLIC_IP>/32"
                    }
                }
            }
        ]
    }
    ```

2.  **Deny EC2 Access by Region:** Create a second inline policy named `deny-ec2-policy` that denies `ec2:Describe*` actions when the request is made to the `eu-west-1` region.
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Deny",
                "Action": "ec2:Describe*",
                "Resource": "*",
                "Condition": {
                    "StringEquals": {
                        "aws:RequestedRegion": "eu-west-1"
                    }
                }
            }
        ]
    }
    ```

The EC2 instance's public IP address must be retrieved from the AWS Console first and inserted into the corresponding JSON policy file.

#### Step 2: Execution via AWS CLI

First, the CLI was configured with the new task credentials. The policy JSON content shown above was saved into local files (`deny-s3-policy.json` and `deny-ec2-policy.json` in the `CLOUD/AWS/iam-conditions-task` directory). Finally, the following commands were executed.

1.  **Attach S3 Deny Policy:**
    ```bash
    aws iam put-role-policy \
      --role-name cmtr-zdv1y551-iam-c-iam_role \
      --policy-name deny-s3-policy \
      --policy-document file://CLOUD/AWS/iam-conditions-task/deny-s3-policy.json
    ```

2.  **Attach EC2 Deny Policy:**
    ```bash
    aws iam put-role-policy \
      --role-name cmtr-zdv1y551-iam-c-iam_role \
      --policy-name deny-ec2-policy \
      --policy-document file://CLOUD/AWS/iam-conditions-task/deny-ec2-policy.json
    ```

#### Step 3: Verification

Verification is performed by connecting to the EC2 instance and running commands to test the policy conditions.

1.  **Connect to the EC2 instance** using Session Manager or EC2 Instance Connect.
2.  **Test S3 Deny Policy (Should Fail):** Run a command to list S3 buckets. This request originates from the instance's IP, so the deny policy should block it.
    ```bash
    # Inside the EC2 instance
    aws s3 ls
    # Expected Output: An "Access Denied" error.
    ```
3.  **Test EC2 Allow Policy (Should Succeed):** Run a describe command targeting the instance's own region (`us-east-1`). This should not be affected by the deny policy.
    ```bash
    # Inside the EC2 instance
    aws ec2 describe-instances --region us-east-1
    # Expected Output: A JSON description of instances.
    ```
4.  **Test EC2 Deny Policy (Should Fail):** Run the same command, but target the `eu-west-1` region. The condition in the policy should deny this request.
    ```bash
    # Inside the EC2 instance
    aws ec2 describe-instances --region eu-west-1
    # Expected Output: An "Access Denied" error.
    ```
