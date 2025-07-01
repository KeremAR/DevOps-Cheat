# AWS Cloud Fundamentals (Interview Quick Sheet)

### ☁️ 1. What is AWS?
- **Amazon Web Services (AWS):** A cloud platform offering on-demand IT resources (computing, storage, databases, etc.) over the internet with pay-as-you-go pricing.

### 🏛️ 2. Well-Architected Framework
- A set of best practices for building on AWS, based on six pillars:
    1.  Operational Excellence
    2.  Security
    3.  Reliability
    4.  Performance Efficiency
    5.  Cost Optimization
    6.  Sustainability

### 🤝 3. Shared Responsibility Model
- A key security concept that defines who is responsible for what.
    -   **AWS (Security OF the Cloud):** Responsible for the physical infrastructure: hardware, software, networking, and facilities that run AWS services.
    -   **Customer (Security IN the Cloud):** Responsible for what you put *in* the cloud, like your data, applications, and configuring security (IAM, Security Groups, Encryption).

### 🗂️ 4. Core Service Domains
-   **Compute:** `EC2` (Virtual Servers), `Lambda` (Serverless)
-   **Storage:** `S3` (Object), `EBS` (Block for EC2), `EFS` (File)
-   **Databases:** `RDS` (Relational), `DynamoDB` (NoSQL)
-   **Networking:** `VPC` (Virtual Network), `Route 53` (DNS)
-   **Security:** `IAM` (Permissions), `KMS` (Encryption Keys)

### 🏛️ 5. Foundational Governance
-   **Tagging:** Applying key-value labels to resources for organization, cost tracking, and automation.
-   **Service Quotas (Limits):** Default limits on the number of resources per region (e.g., 5 Elastic IPs). Can be increased via a support request.
-   **Cost Management:** Using tools like `AWS Cost Explorer` and `Budgets` to monitor and control spending.

---

# AWS Identity and Access Management (IAM) (Interview Quick Sheet)

This summary is designed for quick review and direct answers during a technical interview.

### 👤 1. What is IAM?

-   **IAM (Identity and Access Management):** A global AWS service that lets you manage access to AWS services and resources securely. It answers the question: **"Who can do what on which resources?"**

### 🔑 2. IAM Identities (The "Who")

-   **IAM User:** An entity for a person or application with **long-term credentials** (password or access keys).
-   **IAM Group:** A collection of IAM Users. Used to simplify permission management for multiple users.
-   **IAM Role:** An identity with permissions that can be **temporarily assumed** by a trusted entity (a user, an application, or an AWS service). This is the **preferred and most secure way** to grant permissions, especially to applications.

### 📜 3. IAM Policies (The "What")

-   **Policy:** A JSON document that explicitly defines `Allow` or `Deny` permissions for actions and resources.
-   **Core Policy Elements:**
    -   `Effect`: The outcome (`Allow` or `Deny`).
    -   `Principal`: The "who" that is allowed/denied access (user, role, service). Required in Resource-based policies.
    -   `Action`: The specific operation allowed/denied (e.g., `s3:GetObject`).
    -   `Resource`: The AWS entity the action applies to, identified by its ARN.
    -   `Condition`: (Optional) Conditions for the policy to be in effect (e.g., restrict by IP address).
    -   `Sid`: (Optional) A statement ID to differentiate between statements.
-   **Managed Policy:** A standalone, reusable policy you can attach to multiple identities. **This is the best practice for most use cases.**
    -   **AWS-Managed:** Created and managed by AWS for common use cases (e.g., `AdministratorAccess`). You cannot edit them.
    -   **Customer-Managed:** Created and managed by you for specific permissions within your organization.
-   **Inline Policy:** A policy that is embedded directly into a single identity (user, group, or role). Use it for permissions that should never be reused.

### ⚖️ 4. Policy Evaluation Logic

-   **The Golden Rule:** An explicit **`Deny`** in any applicable policy **always overrides** any `Allow`.
-   **Evaluation Order:** The request is only allowed if there is **no `Deny`** and at least one `Allow` in the chain.
    1.  **Organizations SCP:** A `Deny` here blocks the request immediately.
    2.  **Resource-Based Policy:** (e.g., an S3 bucket policy).
    3.  **Identity-Based Policy:** (Attached to the user/role).
    4.  **Permissions Boundary:** An advanced feature to set the maximum permissions an identity can have.

### 🎩 5. AssumeRole vs. PassRole

A classic interview question about delegating permissions.

| Feature         | `sts:AssumeRole`                                    | `iam:PassRole`                                               |
| --------------- | --------------------------------------------------- | ------------------------------------------------------------ |
| **Analogy**     | To **become** a role (put on a different hat).      | To **give** a role to a service (give a hat to someone else).  |
| **Purpose**     | To get temporary credentials to act as the role.    | To grant an AWS service (like EC2) permission to use a role. |
| **Who Needs It?** | The user/role wanting to **become** the target role. | The user **configuring** the service (e.g., launching the EC2 instance). |

### 🏆 6. IAM Best Practices

1.  **Don't use the Root User:** Create an admin IAM user for daily tasks and lock the root user away with MFA.
2.  **Enforce Least Privilege:** Grant only the permissions required to perform a task. Start with nothing and add permissions as needed.
3.  **Use IAM Roles for Applications:** Never hardcode credentials in application code. Use roles for EC2, Lambda, ECS, etc., to grant them permissions automatically and securely.
4.  **Enable MFA:** Enforce Multi-Factor Authentication, especially for privileged users.
5.  **Rotate Credentials Regularly:** Implement a policy to rotate access keys and passwords.
6.  **Use Policy Conditions:** Use condition keys (like `aws:SourceIp`) for extra security.
7.  **Monitor Activity:** Use AWS CloudTrail to log and monitor all API calls.

---

# AWS Networking (Interview Quick Sheet)

This summary is designed for quick review and direct answers during a technical interview.

### 🌐 1. VPC & Subnets

-   **VPC (Virtual Private Cloud):** is your own logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual 
network that you define. You define the IP range **using a CIDR block** (e.g., `10.0.0.0/16`). This defines the private network space available for your resources.
-   **Subnet:** A segment of your VPC's IP range, tied to a single Availability Zone (AZ).
    -   **Public Subnet:** Has a route to an Internet Gateway. Used for internet-facing resources (e.g., Load Balancers).
    -   **Private Subnet:** Does NOT have a direct route to the internet (but can use a NAT Gateway for outbound traffic). Used for backend resources (e.g., Databases, Application Servers).
-   **Reserved IPs:** AWS reserves 5 IP addresses in every subnet (the first four and the last one).

### ↔️ 2. VPC Connectivity & Routing

-   **Route Table:** A set of rules that determines where network traffic is directed. Every subnet is associated with one route table. The `local` route allows all resources within the VPC to communicate.
-   **Internet Gateway (IGW):** Allows **two-way** (inbound/outbound) internet traffic for **public subnets**. Must be attached to the VPC.
-   **NAT Gateway:** Allows instances in **private subnets** to initiate **outbound-only** internet traffic (e.g., for software updates). It must be placed in a public subnet and have an Elastic IP.
-   **VPC Peering:** Connects two VPCs privately. It's a 1-to-1 connection and is **not transitive** (if A is peered with B, and B with C, A cannot talk to C).
-   **Transit Gateway (TGW):** A central "cloud router" (hub-and-spoke model) that simplifies connecting many VPCs and on-premises networks. It is **transitive**.
-   **VPC Endpoints:** Enables private connections to AWS services (like S3) without using the internet.
    -   **Gateway Endpoint:** A route target in your route table. Free. (S3 & DynamoDB only).
    -   **Interface Endpoint:** An ENI with a private IP in your subnet. Costs money. (Most other services).

### 📜 3. DNS

-   **Route 53:** AWS's scalable Domain Name System (DNS). It translates domain names to IP addresses and can route traffic based on different policies (Latency, Geolocation, Failover, etc.).
    -   **Alias Record:** A smart DNS record, specific to AWS. Lets you map a domain (including the root domain like `example.com`) directly to an AWS resource like a Load Balancer. Use this over CNAME when possible.

### 🛡️ 4. Network Security

-   **Security Groups (SGs):** A **stateful firewall** at the **instance level**.
    -   **Stateful:** If inbound traffic is allowed, the outbound return traffic is automatically allowed.
    -   You can only create `Allow` rules.
-   **Network ACLs (NACLs):** A **stateless firewall** at the **subnet level**.
    -   **Stateless:** You must create rules for both inbound and outbound traffic explicitly.
    -   You can create both `Allow` and `Deny` rules. Rules are processed in number order.
-   **Evaluation Order:** Traffic first hits the **NACL**. If allowed, it then hits the **Security Group**. Both must allow the traffic.
-   **Bastion Host (Jump Host):** A hardened EC2 instance in a public subnet that you connect to first, in order to "jump" into and manage instances in your private subnets securely.

### 📦 5. IPs & Interfaces

-   **Private IP:** Assigned from the subnet's range. Stays with the instance on stop/start/reboot.
-   **Public IP:** Assigned from AWS's pool. **Changes** if you stop and start the instance.
-   **Elastic IP (EIP):** A static public IP you own. **Persists** through stop/start cycles. Default limit is 5 per region.
-   **Elastic Network Interface (ENI):** A virtual network card. You can attach multiple ENIs to an instance to give it a presence in multiple subnets.

### 📊 6. Monitoring & Pricing

-   **VPC Flow Logs:** Captures information about IP traffic going to and from network interfaces in your VPC. Use it to troubleshoot connectivity or for security analysis.
-   **VPC Pricing:** The VPC itself is free. You pay for the components you launch inside it (EC2, NAT Gateways, Endpoints, etc.).

### 🏆 7. Networking Best Practices

1.  **Use Custom VPCs for Production:** Never use the Default VPC for production workloads. Always design a custom VPC to have full control over your network's architecture and security.
2.  **Prioritize Private Subnets:** Apply the principle of least privilege. Place resources in private subnets by default. Only use public subnets for resources that must be directly accessible from the internet, like load balancers or bastion hosts.
3.  **Design for High Availability:** Create subnets in multiple Availability Zones (AZs) and distribute your resources across them. For critical services like NAT Gateways, deploy one in each AZ to avoid a single point of failure.
4.  **Use Security Layers:** Don't rely on just one firewall. Use Network ACLs for broad, stateless rules at the subnet level (e.g., blocking malicious IPs) and Security Groups for specific, stateful rules at the instance level.
5.  **Prefer Managed Services:** Use a NAT Gateway over a self-managed NAT Instance. Use a Transit Gateway over a complex VPC Peering mesh. Let AWS handle the management, scaling, and availability.
6.  **Secure Traffic to AWS Services:** Whenever possible, use VPC Endpoints to access services like S3, DynamoDB, or SQS. This keeps traffic within the AWS private network and avoids the public internet, which is more secure and can be faster.
7.  **Monitor Your Network:** Enable VPC Flow Logs on critical VPCs. The logs are invaluable for troubleshooting connectivity issues, performing security analysis, and understanding traffic patterns.

