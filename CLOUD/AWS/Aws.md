# AWS Identity and Access Management (IAM)

## What is IAM and Why is it Important?

**IAM** is a global AWS service that allows you to securely manage access to AWS services and resources. It's the central nervous system for all permissions within an AWS account.

-   **What problem does it solve?** It answers the fundamental question: **"Who can do what on which resources?"**
-   **Core Features:**
    -   **Centralized Control:** Manage all users, roles, and permissions from one place.
    -   **Fine-Grained Permissions:** Grant specific permissions for specific actions on specific resources (Principle of Least Privilege).
    -   **Temporary Access:** Grant temporary credentials using roles, which is much more secure than sharing long-term keys.
-   **Key Point:** IAM is a free service. You are only charged for the usage of other AWS services by your IAM identities.

---

## IAM Identities (The "Who")

IAM Identities represent the users, services, or applications that perform actions in AWS. There are three types:

### 1. IAM Users

-   **What is it?** An entity representing a person or an application. It has long-term credentials:
    -   A password for AWS Management Console access.
    -   Up to two Access Keys (Access Key ID & Secret Access Key) for programmatic access (CLI/SDK).
-   **When to use it?** For individuals who need permanent access to the AWS account (e.g., administrators, developers).
-   **Best Practice:** Avoid using IAM users for applications or AWS services. Use IAM Roles instead.

### 2. IAM User Groups

-   **What is it?** A collection of IAM users. It's not a true identity, but a way to manage permissions for multiple users at once.
-   **How it works:** You attach permission policies to the group, and all users within that group inherit those permissions.
-   **When to use it?** To simplify permission management. Instead of attaching policies to hundreds of users individually, you add them to a group (e.g., `Developers`, `Testers`, `Admins`).

### 3. IAM Roles

-   **What is it?** An identity with specific permissions that can be **temporarily assumed** by a trusted entity.
-   **Key Difference:** A role **does not** have its own long-term credentials like a password or access keys. It provides temporary credentials that expire.
-   **Who can assume a role?**
    -   An IAM User in the same or another AWS account.
    -   An AWS service (e.g., an EC2 instance, Lambda function).
    -   Users from an external identity provider (Federation).
-   **When to use it?** This is the **preferred way** to grant permissions for most scenarios, especially for applications.
    -   **Example:** Granting an EC2 instance permission to read files from an S3 bucket without storing access keys on the instance.

---

## IAM Policies (The "What")

An IAM Policy is a JSON document that explicitly defines permissions. It dictates what actions are allowed or denied.

### Managed vs. Inline Policies

This is a fundamental distinction in how policies are applied:

-   **Managed Policies:**
    -   Standalone policies in your AWS account that you can attach to multiple users, groups, and roles.
    -   **AWS Managed:** Created and managed by AWS for common use cases (e.g., `AdministratorAccess`, `AmazonS3ReadOnlyAccess`). You cannot edit these.
    -   **Customer Managed:** Created and managed by you. They give you more precise control and are reusable. This is the **recommended approach for most custom permissions**.
-   **Inline Policies:**
    -   Policies that are embedded directly into a single user, group, or role.
    -   They have a strict one-to-one relationship with the identity. If you delete the identity, the inline policy is deleted with it.
    -   **Use Case:** Best for situations where you are certain a policy should never be attached to any other entity.
    -   **Limitation:** There are size limits for inline policies (e.g., a role's total inline policies cannot exceed 10,240 characters), making them unsuitable for complex permissions.

### Core Policy Elements

-   **`Version`**: The policy language version (always `"2012-10-17"`).
-   **`Statement`**: The main container for one or more individual permission statements.
-   **`Sid` (Statement ID)**: An optional identifier for the statement.
-   **`Effect`**: The effect of the statement, which can be **`Allow`** or **`Deny`**.
-   **`Principal`**: (Required in Resource-Based Policies) The user, account, or service that is allowed or denied access.
    -   **Identity vs. Principal:** An **Identity** is a user or role created and managed within IAM. A **Principal** is the entity specified in a policy that can make a request. Every Identity is a Principal, but not every Principal is an Identity (e.g., a Principal can also be an entire AWS Account or an AWS Service like `ec2.amazonaws.com`).
-   **`Action`**: The specific API action that is allowed or denied (e.g., `s3:GetObject`, `ec2:StartInstances`).
-   **`Resource`**: The specific AWS resource(s) the action applies to, identified by their ARN (Amazon Resource Name).
-   **`Condition`**: (Optional) Conditions under which the policy is in effect (e.g., restrict access to a certain IP range, enforce MFA).

### Policy Types: Identity-based vs. Resource-based

| Feature                     | Identity-Based Policies                                      | Resource-Based Policies                                      |
| --------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Attached To**             | An IAM User, Group, or Role.                                 | An AWS resource (e.g., S3 Bucket, SQS Queue).                |
| **Question it Answers**     | "What can **this identity** do?"                             | "Who can **access this resource**?"                          |
| **`Principal` Element**     | Not specified (the principal is the identity it's attached to). | **Required.** Specifies which principal(s) the policy applies to. |
| **Example Use Case**        | Giving a developer `Allow ec2:*` permissions.              | Allowing an external AWS account to `PutObject` into my S3 bucket. |

### Policy Evaluation Logic

**Crucial Point:** An explicit **`Deny`** in any applicable policy **always overrides** any **`Allow`**. This rule applies regardless of where the policies are attached (user, group, resource, etc.).
-   If there is no `Allow`, access is denied by default.
-   If there is an `Allow` but also a `Deny`, access is **denied**.
-   If there is only an `Allow` and no `Deny`, access is allowed.

---

## Key IAM Concepts for Interviews

### Assuming a Role (`sts:AssumeRole`) vs. Passing a Role (`iam:PassRole`)

This is a classic advanced IAM topic.

#### `sts:AssumeRole` (To "Become" a Role)

-   **Analogy:** You are putting on a different hat.
-   **What it is:** The action of **temporarily swapping** your current permissions for the permissions of the role. You receive temporary security credentials (access key, secret key, session token).
-   **Who needs the permission?** The user or role that wants to **become** the target role needs the `sts:AssumeRole` permission in its own identity policy, targeting the role it wants to assume.
-   **Example:** A developer in Account A assumes a `ReadOnly` role in Account B to view its resources.

#### `iam:PassRole` (To "Give" a Role to a Service)

-   **Analogy:** You are giving a hat to someone (or something) else to wear.
-   **What it is:** The permission to **assign an IAM role** to an AWS service or resource.
-   **Who needs the permission?** The user who is configuring the service needs the `iam:PassRole` permission.
-   **Why is it needed?** It's a security mechanism. It prevents a user from "passing" a role with more permissions than they themselves have to a service, thereby escalating their own privileges.
-   **Example:** A developer needs to launch an EC2 instance. That instance needs permission to access an S3 bucket. The developer "passes" the `S3-Access-Role` to the EC2 service during instance creation. To do this, the developer must have the `iam:PassRole` permission for `S3-Access-Role`.

---

## Programmatic Access & Credential Precedence

When using the AWS CLI or SDKs, AWS looks for credentials in a specific order. The first place it finds them, it stops looking. The top 3 are:
1.  **Command Line Options:** Flags like `--profile`, `--region`, and `--output` provided directly with the command.
2.  **Environment Variables:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`.
3.  **CLI Credentials File:** The `[default]` or named profile in `~/.aws/credentials`.

---

## IAM Best Practices (Crucial for any Role)

1.  **Never use your Root User account** for daily tasks. Create an IAM user with administrative privileges for yourself.
2.  **Enforce the Principle of Least Privilege:** Grant only the permissions required to perform a task. Start with a minimum set of permissions and grant additional permissions as necessary.
3.  **Use IAM Roles for Applications:** Never hardcode access keys in your application code. Use roles for AWS services like EC2, ECS, and Lambda to grant them temporary credentials automatically.
4.  **Enable MFA (Multi-Factor Authentication):** Especially for privileged users (like administrators) and the root user.
5.  **Rotate Credentials Regularly:** Regularly rotate access keys and passwords.
6.  **Use Policy Conditions:** Use condition keys for extra security, such as requiring requests to come from specific IP addresses.
7.  **Monitor Activity:** Use AWS CloudTrail to log and monitor all API calls (`read`, `write`, and `management` events) made in your account.
8.  **Use IAM Access Analyzer:** Regularly run the IAM Access Analyzer to identify resources that are shared with external entities.
9.  **Use the IAM Policy Simulator:** Test and troubleshoot policies before applying them to avoid unintended consequences. 