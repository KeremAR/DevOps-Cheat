# AWS Cloud Fundamentals: An Interview-Oriented Overview

This section provides a high-level summary of core AWS concepts, designed for quick review before a technical interview.

---

## What is AWS?

Amazon Web Services (AWS) is a comprehensive cloud platform offering over 200 services from global data centers. It allows businesses to rent computing power, storage, and other IT infrastructure on a pay-as-you-go basis, eliminating the need for large upfront hardware investments.

---

## The AWS Well-Architected Framework

This framework is a set of best practices for building secure, high-performing, resilient, and efficient infrastructure on AWS. It is built on six pillars:

1.  **Operational Excellence:** Running and monitoring systems to deliver business value and continually improving processes.
2.  **Security:** Protecting information, systems, and assets while delivering business value through risk assessments and mitigation strategies.
3.  **Reliability:** Ensuring a workload performs its intended function correctly and consistently. It includes the ability to operate and test the workload through its total lifecycle.
4.  **Performance Efficiency:** Using computing resources efficiently to meet system requirements, and maintaining that efficiency as demand changes and technologies evolve.
5.  **Cost Optimization:** Avoiding or eliminating unneeded cost or suboptimal resources.
6.  **Sustainability:** Minimizing the environmental impacts of running cloud workloads.

---

## The Shared Responsibility Model

This is a critical security concept that defines who is responsible for what.

-   **AWS is responsible for "Security OF the Cloud":** They secure the physical infrastructure, the hardware, software, networking, and facilities that run all AWS services.
-   **You (the Customer) are responsible for "Security IN the Cloud":** Your responsibility depends on the service. For IaaS like EC2, you manage the guest OS, security patches, applications, and firewall rules (Security Groups). For managed services like S3, you are responsible for managing your data (e.g., encryption), classifying assets, and configuring permissions (IAM policies, bucket policies).

---

## Core Service Domains

AWS services can be grouped into several core domains:

-   **Compute:** Virtual servers (`EC2`), serverless execution (`Lambda`), and container orchestration (`ECS`, `EKS`).
-   **Storage:** Scalable object storage (`S3`), file systems (`EFS`), and block storage for EC2 (`EBS`).
-   **Databases:** Relational (`RDS`, `Aurora`), NoSQL (`DynamoDB`), and in-memory caching (`ElastiCache`).
-   **Networking & Content Delivery:** Isolated cloud networks (`VPC`), load balancing (`ELB`), DNS (`Route 53`), and a global content delivery network (`CloudFront`).
-   **Security, Identity & Compliance:** User and permission management (`IAM`), key management (`KMS`), and threat detection (`GuardDuty`).

---

## Foundational Governance Concepts

-   **Tagging:** Assigning key-value metadata to resources to organize, manage costs, and automate tasks. A consistent tagging strategy is crucial for managing any non-trivial AWS environment.
-   **Cost Management:** Using tools like `AWS Cost Explorer` to visualize costs, `AWS Budgets` to set spending alerts, and `Savings Plans` to commit to usage for lower prices.
-   **Service Quotas (Limits):** Every AWS account has default limits on the number of resources you can create per region (e.g., number of VPCs, EC2 instances). These can be increased via a support request.

---

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

**Crucial Point:** An explicit **`Deny`** in any applicable policy **always overrides** any **`Allow`**. This is the single most important rule in IAM.

The complete evaluation logic follows a specific order:
1.  **Organization SCPs:** First, AWS checks for any Service Control Policies. If an SCP explicitly denies the action, the request is **denied**, and evaluation stops.
2.  **Identity-Based Policies:** All policies attached to the user/role are evaluated.
3.  **Resource-Based Policies:** Any policy attached to the resource being accessed (e.g., an S3 bucket policy) is evaluated.
4.  **Permissions Boundary:** If a permissions boundary is applied to the user/role, it's checked.
5.  **Final Decision:** A request is only **allowed** if there is an `Allow` statement in the relevant policies (identity, resource, etc.) AND there is no `Deny` statement in any policy (SCP, identity, resource, etc.).

### What are Service Control Policies (SCPs)?

SCPs are a feature of **AWS Organizations** that offer central control over permissions for all accounts in an organization.
-   **Function:** They act as a **guardrail**, defining the *maximum* permissions available for an account.
-   **How they work:** An SCP can restrict which AWS services, resources, and actions the users and roles in an account can access.
-   **Impact on IAM:** Even if an administrator grants `Allow *:*` (full admin access) to a user via an IAM policy, if an SCP at the organizational level denies access to a service (e.g., `Deny ec2:*`), that user will **not** be able to use EC2. The SCP `Deny` always takes precedence.
-   **Use Case:** Enforcing compliance rules across an entire organization, such as disabling services in certain regions or preventing users from deactivating security logging services.

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