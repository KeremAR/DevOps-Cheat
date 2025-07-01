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

---

# AWS Networking and Content Delivery

## What is a VPC (Virtual Private Cloud)?

A **VPC** is your own logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. It is the foundational building block for almost anything you do in AWS.

-   **Analogy:** Think of it as your own private data center within AWS's massive global infrastructure.
-   **Key Features:**
    -   **Logical Isolation:** Your VPC's resources are completely isolated from all other virtual networks in the AWS Cloud.
    -   **Full Control:** You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways.
    -   **Security:** You can use multiple layers of security, including security groups and network access control lists (NACLs), to help control access to Amazon EC2 instances in each subnet.

### Core VPC Components

-   **CIDR Block (Classless Inter-Domain Routing):** The IP address range for your VPC (e.g., `10.0.0.0/16`). This defines the private network space available for your resources.
-   **Subnets:** A range of IP addresses in your VPC. Subnets are used to partition the network and isolate resources. They must reside in a single Availability Zone.
    -   **Important Note:** In any subnet, AWS reserves the **first four** IP addresses and the **last one** for its own use (network address, VPC router, DNS, future use, broadcast). You cannot assign these 5 IPs to your instances.
-   **Route Tables:** A set of rules, called **routes**, that are used to determine where network traffic from your subnet or gateway is directed. Each subnet must be associated with a route table. Every route table contains a default `local` route that allows all resources within the VPC to communicate with each other.
-   **Internet Gateway (IGW):** A horizontally scaled, redundant, and highly available VPC component that allows communication between your VPC and the internet. It serves two purposes: to provide a target in your VPC route tables for internet-routable traffic, and to perform network address translation (NAT) for instances that have been assigned public IPv4 addresses.
-   **Security Groups:** Acts as a virtual **stateful firewall** for your EC2 instances to control inbound and outbound traffic at the instance level. By default, they deny all inbound traffic and allow all outbound traffic.
-   **NACLs (Network Access Control Lists):** An optional layer of security for your VPC that acts as a **stateless firewall** for controlling traffic in and out of one or more subnets. Because they are stateless, you must create rules for both inbound and outbound traffic.

### Default vs. Custom VPC

| Feature                 | Default VPC                                                  | Custom VPC                                                   |
| ----------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Creation**            | Automatically created in each region when you create your AWS account. | You create it manually from scratch.                         |
| **Configuration**       | "Ready to use." Comes with a pre-configured CIDR, a public subnet in each AZ, an internet gateway, and a main route table. | **Empty canvas.** You must configure everything: CIDR block, subnets, route tables, gateways, etc. |
| **Use Case**            | Good for beginners, quick tests, or launching simple public-facing resources without network configuration hassle. | **Production standard.** Required for any serious application to ensure security, proper network segmentation, and control. |

### IP Addressing in a VPC

AWS provides several types of IP addresses.

| IP Type             | Description                                                  | Behavior on Stop/Start                                       | Behavior on Reboot |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------ |
| **Private IPv4**    | A private IP from the subnet's CIDR range. Used for internal communication. Every instance *must* have one. | **Stays the same.**                                          | Stays the same.    |
| **Public IPv4**     | A public IP from Amazon's pool, automatically assigned.      | **Lost and replaced** with a new one upon start.             | Stays the same.    |
| **Elastic IP (EIP)**| A static, public IP you allocate to your account. You can manually attach/detach it from instances. | **Persists.** It remains attached to the instance unless you manually detach it. | Stays the same.    |

### Elastic Network Interfaces (ENIs)
An ENI is a virtual network card that you can attach to an EC2 instance.
- **Can you assign multiple IP addresses?** Yes, by using multiple ENIs or by assigning multiple private IPs to a single ENI. This allows an instance to have a network presence in different subnets or to host multiple applications that require separate IPs.

### Bastion Host (or Jump Host)
A Bastion Host is a special-purpose EC2 instance that is designed to be the **only** point of entry from the internet to your private subnets.
- **How it works:** You place it in a public subnet and harden its security. You connect (e.g., via SSH or RDP) to the bastion host first, and from there, you "jump" to the other instances in your private subnets. This prevents your private instances from being exposed to the internet.

## Key Networking Concepts for Interviews

### Public vs. Private Subnet

This is a fundamental VPC design concept.

| Feature                      | Public Subnet                                                | Private Subnet                                               |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Internet Access**          | Has a route to an Internet Gateway (`0.0.0.0/0 -> igw-id`).    | Does **not** have a direct route to the Internet Gateway.      |
| **Public IP Address**        | Instances launched here can be assigned a public IP address, making them reachable from the internet. | Instances here only have a private IP address.               |
| **Common Use Case**          | Web servers, load balancers, bastion hosts.                  | Application servers, databases, internal microservices.      |
| **How it gets Internet?**    | Through the attached Internet Gateway.                       | To access the internet for updates, it needs a **NAT Gateway** located in a public subnet. |

### NAT Gateway vs. NAT Instance

Both allow instances in private subnets to access the internet, but the managed NAT Gateway is almost always preferred.

| Feature                 | NAT Gateway (Managed Service)                                | NAT Instance (Self-Managed)                                  |
| ----------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Management**          | **Managed by AWS.** Highly available and redundant within an AZ by default. | **You manage it.** It's just an EC2 instance running a specific AMI. You are responsible for patching, scaling, and failover. |
| **Performance**         | **High performance.** Bursts up to 45 Gbps.                  | Limited by the instance type's network bandwidth.            |
| **Availability**        | **High.** AWS handles failover within the AZ. For cross-AZ redundancy, you must create a NAT Gateway in each AZ and configure routes. | **Single point of failure.** If the instance fails, private instances lose internet access until you fix it. You need to build custom scripts for failover. |
| **Cost**                | Pay per hour and for data processed. Can be more expensive for low traffic. | Pay for the EC2 instance and its data transfer. Can be cheaper for very low traffic, but management overhead is high. |
| **Security**            | Does not have a security group.                              | Requires a security group. You must disable the "Source/Destination Check" attribute on the instance. |

### Security Groups vs. Network ACLs (NACLs)

<img src="/Media/sg.png" alt="sg" width="500"/>

This is a critical security concept. Both are virtual firewalls, but they operate at different levels.

| Feature                 | Security Group (SG)                                          | Network ACL (NACL)                                           |
| ----------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Scope**               | **Instance Level:** Operates on the Elastic Network Interface (ENI) of an EC2 instance. | **Subnet Level:** Operates at the boundary of a subnet. Applies to all instances within it. |
| **State**               | **Stateful:** If you allow inbound traffic, the return (outbound) traffic is automatically allowed, regardless of outbound rules. | **Stateless:** You must explicitly define rules for both inbound AND outbound traffic. Return traffic must be explicitly allowed. |
| **Rules**               | **Allow only:** You cannot create "deny" rules. By default, all traffic is denied. | **Allow and Deny:** You can create both allow and deny rules.      |
| **Rule Processing**     | All rules are evaluated before making a decision.            | Rules are processed in **numerical order**, starting with the lowest number. The first matching rule is applied. |
| **Typical Use Case**    | The primary firewall for your instances. Used for fine-grained control (e.g., allow web traffic on port 80 to web servers). | An optional, secondary layer of defense. Used for broad rules like blocking a specific malicious IP address at the subnet level. |

**Evaluation Order:** When traffic enters a subnet, the **Network ACL** rules are evaluated first. If the traffic is allowed by the NACL, the **Security Group** rules for the specific instance are then evaluated. Both must allow the traffic for it to reach the instance.

### VPC Peering vs. Transit Gateway

Both services connect VPCs, but they solve different problems at different scales.

| Feature                 | VPC Peering                                                  | Transit Gateway (TGW)                                        |
| ----------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Model**               | **1-to-1 Connection:** A direct, non-transitive link between two VPCs. | **Hub-and-Spoke:** A central "cloud router" that connects many VPCs, VPNs, and Direct Connect gateways. |
| **Complexity**          | **Simple for few VPCs.** Becomes a complex "mesh" network as the number of VPCs grows (N*(N-1)/2 connections). | **Simple at scale.** Each VPC just connects to the central TGW once. |
| **Transitivity**        | **No:** If VPC A is peered with B, and B is peered with C, A cannot talk to C through B. | **Yes:** All VPCs attached to the TGW can (if routes allow) communicate with each other through the TGW. |
| **Use Case**            | Good for connecting a small number of VPCs, especially if they are managed by different teams or accounts. | The standard for connecting many VPCs. Simplifies network management and is the foundation for hybrid connectivity. |
| **Other Connections**   | VPCs only.                                                   | Connects VPCs, on-premises networks (via VPN/Direct Connect), and can be peered with TGWs in other regions. |

### VPC Endpoints (AWS PrivateLink)

VPC Endpoints allow you to privately and securely connect your VPC to supported AWS services without needing an Internet Gateway, NAT Gateway, or VPN. Traffic never leaves the Amazon network.

#### 1. Gateway Endpoints

-   **How it works:** A gateway that you specify as a target for a route in your VPC's route table.
-   **Analogy:** It's like adding a special doorway from your VPC directly to the service's front door.
-   **Supported Services:** Only **S3** and **DynamoDB**.
-   **Cost:** Free.

#### 2. Interface Endpoints

-   **How it works:** An **Elastic Network Interface (ENI)** with a private IP address from your subnet's IP range. It acts as the entry point for traffic going to the service.
-   **Analogy:** The service gets its own private office (the ENI) inside your VPC's building.
-   **Supported Services:** Most AWS services (SQS, SNS, Kinesis, etc.) and services hosted by other customers/partners.
-   **Cost:** Charged per hour plus data processing fees.

### What is Route 53?

Amazon Route 53 is AWS's highly available and scalable **Domain Name System (DNS)** web service.

-   **Core Functions:**
    1.  **Domain Registration:** You can buy and manage domain names like `example.com`.
    2.  **DNS Routing:** It translates human-friendly domain names into IP addresses that computers use. This is its primary function.
    3.  **Health Checking:** It can monitor the health of your endpoints (e.g., web servers) and only route traffic to healthy ones.

-   **Key Concept: Routing Policies**
    This is how Route 53 decides which IP address to return in response to a DNS query. This is a classic interview topic.
    -   **Simple:** The standard. Returns one or more IPs. If multiple, a random one is chosen by the client.
    -   **Failover:** Used for active-passive setups. Provides a primary and secondary IP. Routes to the secondary if the primary fails its health check.
    -   **Geolocation:** Routes traffic based on the geographic location of the user (e.g., users from Europe go to a European server).
    -   **Latency-based:** Routes traffic to the AWS region that provides the lowest network latency for the user.
    -   **Weighted:** Routes traffic to multiple resources in proportions that you specify (e.g., 80% to server A, 20% to server B). Useful for A/B testing.

-   **Key Concept: Alias Record**
    An **Alias record** is an AWS-specific type of DNS record.
    -   **Function:** It lets you map a domain name (like `www.example.com`) to an AWS resource (like a Load Balancer, CloudFront distribution, or S3 bucket).
    -   **Advantage over CNAME:** You can create an Alias record for your **root domain** (e.g., `example.com`), which you **cannot** do with a CNAME. This is its main benefit. It's also free and resolves faster.

### Monitoring and Pricing

- **How can you monitor network traffic?** **VPC Flow Logs** is a feature that captures information about the IP traffic going to and from network interfaces in your VPC. You can publish this data to Amazon S3 or CloudWatch Logs to troubleshoot connectivity issues or analyze traffic patterns.
- **Do you pay for VPC?** Creating and using the VPC itself is free. However, you pay for the components you use, such as EC2 instances, NAT Gateways, and VPC Endpoints.
- **How many Elastic IPs can you have?** By default, the limit is **5 EIPs per region** per account. This is a "soft limit" and can be increased by requesting a limit increase through AWS Support. This is an example of a **Service Quota**.

