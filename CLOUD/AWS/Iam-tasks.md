### Task: Configuring IAM Group Permissions (CLI Method)

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
