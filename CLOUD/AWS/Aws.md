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

### 🌍 2.5. Global Infrastructure (Regions & AZs)
- **Region:** A physical location in the world where AWS has multiple Availability Zones (e.g., `us-east-1` in North Virginia). Most services are Region-scoped.
- **Availability Zone (AZ):** One or more discrete data centers with redundant power, networking, and connectivity within a Region. They are isolated from each other to prevent an issue in one AZ from affecting others.
- **High Availability:** By deploying applications across multiple AZs (e.g., running EC2 instances in two different AZs behind a Load Balancer), you can ensure your application remains available even if one entire data center fails.

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
network that you define. You define the IP range using a CIDR block. The size can be between `/16` (max 65,536 IPs) and `/28` (min 16 IPs).
-   **Subnet:** A segment of your VPC's IP range, tied to a single Availability Zone (AZ).
    -   **Public Subnet:** Has a route to an Internet Gateway. Used for internet-facing resources (e.g., Load Balancers).
    -   **Private Subnet:** Does NOT have a direct route to the internet (but can use a NAT Gateway for outbound traffic). Used for backend resources (e.g., Databases, Application Servers).
-   **Reserved IPs:** AWS reserves 5 IP addresses in every subnet (the first four and the last one).

### ↔️ 2. VPC Connectivity & Routing

-   **Route Table:** A set of rules that determines where network traffic is directed. Each rule specifies a **destination (CIDR block)** and a **target** to send the traffic to (e.g., `igw-` for internet, `nat-` for NAT, or `local` for traffic within the VPC).
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
    -   **Common Rule:** A typical rule allows inbound traffic on **Port 22 (SSH)** for Linux or **Port 3389 (RDP)** for Windows from a specific, trusted IP address for management. It should never be open to the world (`0.0.0.0/0`).
-   **Network ACLs (NACLs):** A **stateless firewall** at the **subnet level**.
    -   **Stateless:** You must create rules for both inbound and outbound traffic explicitly. **Example:** If you allow inbound traffic on port 80 (HTTP), you must *also* create an outbound rule to allow traffic on high-numbered ports (1024-65535) for the response packets to leave the subnet.
    -   You can create both `Allow` and `Deny` rules. Rules are processed in number order.
-   **Evaluation Order:** Traffic first hits the **NACL**. If allowed, it then hits the **Security Group**. Both must allow the traffic.
-   **Bastion Host (Jump Host):** A hardened EC2 instance in a public subnet that you connect to first, in order to "jump" into and manage instances in your private subnets securely.

### 📦 5. IPs & Interfaces

-   **Private IP:** Assigned from the subnet's range. Stays with the instance on stop/start/reboot.
-   **Public IP:** Assigned from AWS's pool. **Changes** if you stop and start the instance.
-   **Elastic IP (EIP):** A static public IP you own. **Persists** through stop/start cycles. Default limit is 5 per region.
-   **Elastic Network Interface (ENI):** A **virtual network card** in your VPC. An EC2 instance can have multiple ENIs, allowing it to have a network presence in different subnets.


### 🌍 6. Edge & Hybrid Connectivity

-   **CloudFront:** AWS's **Content Delivery Network (CDN)**. It caches your content (videos, images, APIs) in edge locations around the world, closer to your users, which significantly reduces latency.
    -   **Geo-restriction:** A CloudFront feature that allows you to block or allow users from specific countries from accessing your content.
-   **AWS Direct Connect:** A dedicated, private physical network connection between your on--premises data center and AWS. It provides higher bandwidth, a more consistent network experience, and increased security compared to a standard VPN connection over the internet.

### 📊 7. Monitoring & Pricing

-   **VPC Flow Logs:** Captures information about IP traffic going to and from network interfaces in your VPC. Use it to troubleshoot connectivity or for security analysis.
-   **VPC Pricing:** The VPC itself is free. You pay for the components you launch inside it (EC2, NAT Gateways, Endpoints, etc.).

### 🏆 8. Networking Best Practices

1.  **Use Custom VPCs for Production:** Never use the Default VPC for production workloads. Always design a custom VPC to have full control over your network's architecture and security.
2.  **Prioritize Private Subnets:** Apply the principle of least privilege. Place resources in private subnets by default. Only use public subnets for resources that must be directly accessible from the internet, like load balancers or bastion hosts.
3.  **Design for High Availability:** Create subnets in multiple Availability Zones (AZs) and distribute your resources across them. For critical services like NAT Gateways, deploy one in each AZ to avoid a single point of failure.
4.  **Use Security Layers:** Don't rely on just one firewall. Use Network ACLs for broad, stateless rules at the subnet level (e.g., blocking malicious IPs) and Security Groups for specific, stateful rules at the instance level.
5.  **Prefer Managed Services:** Use a NAT Gateway over a self-managed NAT Instance. Use a Transit Gateway over a complex VPC Peering mesh. Let AWS handle the management, scaling, and availability.
6.  **Secure Traffic to AWS Services:** Whenever possible, use VPC Endpoints to access services like S3, DynamoDB, or SQS. This keeps traffic within the AWS private network and avoids the public internet, which is more secure and can be faster.
7.  **Monitor Your Network:** Enable VPC Flow Logs on critical VPCs. The logs are invaluable for troubleshooting connectivity issues, performing security analysis, and understanding traffic patterns.

---

# AWS EC2 (Elastic Compute Cloud)

---

## Part 1: The Building Blocks of an Instance

*This section covers the fundamental components required to create and manage a single EC2 instance.*

### 🖥️ 1. What is EC2?
-   **EC2 (Elastic Compute Cloud):** A core AWS service that provides scalable computing capacity—essentially, virtual servers called **instances**—that you can rent in the cloud.
-   **Analogy:** Instead of buying and managing physical servers, you rent virtual ones from AWS, allowing you to scale up or down on demand.
-   **Instance:** A single virtual machine running on the AWS infrastructure. You choose its OS (Linux, Windows), CPU, memory, and storage.

### 🖼️ 2. AMI (Amazon Machine Image)
-   An AMI is a template used to **launch** an instance. It contains the operating system, an application server, and applications. You can use pre-built AMIs or create your own. It's the blueprint for the instance's root volume.

### ⚙️ 3. Instance Types
-   AWS offers various instance families optimized for different workloads. The naming convention is `family.generation.size` (e.g., `t2.micro`).

| Category                | Use Case                                                    | Description                                                                                             |
| ----------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **General Purpose** (T, M) | Web servers, small-to-mid-size databases, dev/test envs.      | Balanced mix of CPU, memory, and networking.                                                          |
| **Compute Optimized** (C)  | High-performance computing (HPC), video encoding, scientific modeling. | High CPU-to-memory ratio. Ideal for compute-intensive tasks.                                          |
| **Memory Optimized** (R, X)  | In-memory databases (like Redis), large-scale data processing (like Spark). | High memory-to-CPU ratio. Ideal for workloads that process large datasets in memory.                  |
| **Storage Optimized** (I, D) | Big data analytics, data warehousing, large NoSQL databases. | Optimized for high, sequential read/write access to very large datasets on local storage.               |
-   **Burstable Instances (T-family):** These instances provide a baseline level of CPU performance with the ability to "burst" to a higher level when needed. They accumulate **CPU credits** when idle and use them during bursts. Cost-effective for workloads with occasional traffic spikes.

### 💾 4. Storage
-   **Instance Store:** Temporary, block-level storage physically attached to the host computer. Data is **lost** if the instance is stopped or terminated.
-   **EBS (Elastic Block Store):** A persistent, network-attached block storage volume.
    -   **Persistence:** Data **persists** independently of the instance's lifecycle. Think of it as a "virtual hard drive."
    -   **EBS Volume Types:**
        -   **General Purpose (gp2/gp3):** Balanced price/performance for a wide variety of workloads (boot volumes, web servers). `gp3` is the latest generation, offering better performance and cost.
        -   **Provisioned IOPS (io1/io2):** High-performance SSDs for mission-critical, I/O-intensive databases. You specify the IOPS rate you need.
        -   **Throughput Optimized (st1):** Low-cost HDD for frequently accessed, throughput-intensive workloads (Big Data).
        -   **Cold HDD (sc1):** Lowest-cost HDD for less frequently accessed data.
    -   **Sizing & Multi-Attach:** You can increase an EBS volume's size, but you **cannot decrease it**. A specific feature (`EBS Multi-Attach`) for `io1/io2` volumes allows a single volume to be attached to multiple instances in the same AZ.
-   **EBS Snapshot:** A point-in-time backup of an **EBS volume**. It's used for backup/disaster recovery or to create a new EBS volume. It only contains the data from a single volume.
-   **Data Lifecycle Manager (DLM):** An automation service to create, copy, and delete EBS snapshots and AMIs. It allows you to define policies (e.g., "create a snapshot every 12 hours and retain for 7 days") and apply them to instances or volumes using tags, ensuring a consistent and automated backup strategy.

### 🔒 5. Security & Access
-   **Security Groups:**
    -   Act as a virtual firewall for your instances to control inbound and outbound traffic. They are **stateful** (if you allow inbound traffic, the corresponding outbound traffic is automatically allowed).
    -   The best practice is to follow the principle of least privilege: only open the ports you need (e.g., 80/443 for web servers) to specific source IPs. Never open SSH (22) or RDP (3389) to the world (`0.0.0.0/0`).
-   **IAM Roles vs. Security Groups:** A common point of confusion.
    -   **IAM Role:** Answers **"What can this EC2 instance do?"**. It grants the instance permissions to call AWS APIs (e.g., allow it to read/write to an S3 bucket).
    -   **Security Group:** Answers **"Who can talk to this EC2 instance?"**. It's a firewall that controls inbound/outbound network traffic to the instance (e.g., allow inbound HTTPS traffic from the internet).
-   **Key Pair:**
    -   A set of security credentials used to prove your identity when connecting to an instance. It consists of a **public key** (stored by AWS on the instance) and a **private key** (which you store securely). It's a more secure alternative to passwords.
-   **Connecting to an Instance:**
    -   **Linux:** Use SSH with your private key (`ssh -i key.pem ec2-user@public-ip`).
    -   **Windows:** Use RDP with your private key to retrieve the administrator password.

### 🔄 6. Instance Lifecycle
-   **Key States:** `pending`, `running`, `stopping`, `stopped`, `shutting-down`, and `terminated`.
-   **Reboot:** Similar to rebooting a physical computer. The instance stays on the same physical host, and its Public IP, Private IP, and EBS volumes remain attached.
-   **Stop/Start:** The instance is shut down and can be moved to a different physical host upon start. The **Public IP address is lost** (unless it's an Elastic IP). EBS volumes remain attached, but data on temporary **Instance Store volumes is lost**.

---

## Part 2: Automating a Single Instance

*This section explains how to automate the configuration of an instance when it first launches.*

### 📜 1. User Data
-   A script that runs **automatically** the very first time an instance starts.
-   It's used to perform initial configuration tasks, such as installing software, running updates, or downloading files.
-   This is the fundamental method for automating instance setup (bootstrapping).

### 🏷️ 2. Instance Metadata Service
-   A service available on every EC2 instance at a special, non-routable IP address: `http://169.254.169.254/`.
-   It allows code running inside the instance to find out details about itself, such as its own instance ID, public IP, AZ, or IAM role.
-   This is crucial for User Data scripts that need to be self-aware to configure applications correctly.

---

## Part 3: Scaling and High Availability

*This section covers the services and concepts used to run and manage applications across multiple EC2 instances for reliability and performance.*

-   **Horizontal Scaling (Scaling Out):** The primary way to scale on the cloud. It means adding more instances to handle increased load.
-   **Vertical Scaling (Scaling Up):** Increasing the size and power of a single instance (e.g., from `t2.micro` to `m5.large`). Use this when an application cannot be distributed across multiple instances.

### 📋 1. Launch Templates
-   A configuration template that specifies all the parameters needed to launch an instance: AMI ID, instance type, key pair, security groups, **User Data**, and more.
-   It simplifies and standardizes the launch process, especially for Auto Scaling.
-   **AMI vs. Snapshot vs. Launch Template:**
    -   **AMI:** A template for the **root volume** (OS, software). Used to launch a new instance.
    -   **Snapshot:** A backup of an **EBS volume**. Used for backup or to create a new volume.
    -   **Launch Template:** A template of **launch parameters**. Does not contain data but tells AWS *how* to launch an instance, including which AMI to use.

### ⚙️ 2. EC2 Auto Scaling
-   **Purpose:** Automatically adjusts the number of EC2 instances in a group to meet current demand and to maintain a desired number of running instances.
-   **Components:**
    -   **Launch Template/Configuration:** Defines **what** to launch. **Launch Templates are newer and recommended.**
    -   **Auto Scaling Group (ASG):** Defines **where** to launch (VPC, subnets) and sets the boundaries (`Min`, `Max`, `Desired` capacity). It spans multiple AZs for high availability.
    -   **Scaling Policy:** Defines **when** to scale (e.g., based on CPU utilization, a schedule, etc.).

### ⚖️ 3. Elastic Load Balancing (ELB)
-   **Purpose:** Automatically distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones. This increases availability and fault tolerance.

 **Architectural Note: Multi-Tier Architectures**
 Modern cloud applications are often designed in a multi-tier structure instead of on a single server. The primary goal is to increase high availability, scalability, and security.

 *   **Web Tier:** This is the user-facing tier managed by an Application Load Balancer (ALB). The ALB intelligently distributes incoming HTTP requests to the relevant web servers based on paths like `/customers` or `/orders`.
 *   **Application/Backend Tier:** This tier runs behind the web tier and can be managed by a Network Load Balancer (NLB). It contains the business logic servers. The NLB forwards raw TCP/UDP requests from the web servers to these backend services at the highest speed.

 This layered structure prevents an issue in one tier from affecting others and allows each tier to be scaled independently.

-   **Key ELB Components:**
    -   **Listener:** Checks for connection requests from clients, using a configured protocol and port.
    -   **Rule:** A listener rule determines how to route requests to a target group.
    -   **Target Group:** A group of targets (EC2 instances, Lambda functions, etc.) that receive traffic. The ELB performs **health checks** on targets and only sends traffic to healthy ones.

-   **Types of Load Balancers:**

| Feature           | Application Load Balancer (ALB)                                   | Network Load Balancer (NLB)                                     | Gateway Load Balancer (GWLB)                               |
| ----------------- | ----------------------------------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------- |
| **Layer**         | Layer 7 (HTTP/HTTPS)                                              | Layer 4 (TCP/UDP)                                               | Layer 3 & 4 (IP, TCP/UDP)                                  |
| **Use Case**      | Web applications, microservices, container-based apps.             | High-performance, low-latency applications requiring TCP pass-through. | Integrating third-party virtual network appliances (firewalls, IDS). |
| **Routing**       | **Content-based:** `Host`, `Path`, HTTP headers. (e.g., `example.com/api` -> api-tg) | **Flow-based:** Routes TCP connections based on a flow hash algorithm. Ultra-low latency. | Routes traffic to a fleet of virtual appliances.           |
| **Source IP**     | Preserved in `X-Forwarded-For` header.                             | **Preserved** for the backend target.                            | Preserved.                                                 |
| **Targets**       | EC2, IP, Lambda.                                                  | EC2, IP, ALB.                                                   | EC2, IP.                                                   |

---

## Part 4: Overarching Concepts

*This section covers topics that apply to the entire EC2 service.*

### 💰 1. EC2 Pricing Models
-   **On-Demand:** Pay for compute capacity by the hour or second with no long-term commitments. Ideal for applications with short-term, spiky, or unpredictable workloads.
-   **Reserved Instances (RIs):** Provides a significant discount (up to 72%) compared to On-Demand pricing in exchange for a 1- or 3-year commitment.
-   **Savings Plans:** A flexible pricing model offering lower prices in exchange for a commitment to a consistent amount of usage (measured in $/hour) for a 1- or 3-year term. More flexible than RIs.
-   **Spot Instances:** Request spare EC2 computing capacity for up to 90% off the On-Demand price. AWS can reclaim the instance with a 2-minute warning. Ideal for fault-tolerant, flexible workloads like batch jobs or data analysis.
-   **Dedicated Hosts:** A physical server with EC2 instance capacity fully dedicated for your use. Helps you address compliance requirements and use existing server-bound software licenses.

### 🏆 2. EC2 Best Practices
1.  **Design for your Workload:** Choose the right instance type (don't overprovision). For resilient applications, build a **multi-tier architecture** using Auto Scaling and Load Balancers across multiple Availability Zones.
2.  **Implement Layered Security:** Apply the principle of **least privilege**. Use **IAM Roles** for permissions (what the instance *can do*) and fine-grained **Security Groups** for traffic (who can *talk to* the instance). Never expose management ports (SSH/RDP) to the world.
3.  **Automate and Standardize:** Use **User Data** and **Launch Templates** to automate instance setup. Create custom **AMIs** from your configured instances to ensure consistency and speed up deployment for your Auto Scaling Groups.
4.  **Optimize for Cost and Performance:** Mix **pricing models** (Reserved/Savings Plans for baseline, Spot for fault-tolerant workloads) to dramatically reduce costs. **Monitor everything** with CloudWatch to find performance bottlenecks and right-size your instances.


---

# AWS Storage (Interview Quick Sheet)

This summary covers the main storage services beyond EBS, which is tightly coupled with EC2.

### 🗄️ 1. Storage Types Overview

| Type          | Analogy                       | AWS Service                               | Use Case                                                              |
|---------------|-------------------------------|-------------------------------------------|-----------------------------------------------------------------------|
| **Object**    | Dropbox, Google Drive         | **S3 (Simple Storage Service)**           | Storing files, backups, data lakes, static website hosting.           |
| **Block**     | Virtual Hard Drive            | **EBS (Elastic Block Store)**             | Boot volumes, databases, high-performance storage for a single instance. |
| **File**      | Shared Network Drive          | **EFS (Elastic File System)**, **FSx**    | Shared content, web serving, when multiple instances need access.      |

### 📦 2. S3 (Simple Storage Service)

-   **What is S3?** A highly scalable, durable, and secure object storage service. You can store and retrieve any amount of data from anywhere on the web. It is **not a file system**.
-   **Core Concepts:**
    -   **Object:** The data you store (e.g., a file) and its metadata.
    -   **Bucket:** A container for objects with a **globally unique name**.

-   **Key Features & Concepts:**
    -   **Storage Classes:** A range of tiers to optimize cost based on access patterns (e.g., `S3 Standard` for frequent access, `S3 Glacier` for long-term archive).
    -   **Versioning:** Automatically keeps multiple variants of an object. Protects against accidental overwrites and deletes. When you "delete" a versioned object, it just adds a **delete marker**, making the object invisible. The object can be fully restored by **deleting this marker**.
    -   **Replication (CRR & SRR):** Automatically copies objects to another bucket in the same (SRR) or a different (CRR) region for disaster recovery or reduced latency.
    -   **Static Website Hosting:** S3 can be configured to serve a static website directly from a bucket.
    -   **Lifecycle Policies:** A powerful automation tool to manage object cost and retention. Rules can be configured to:
        -   Transition **current versions** of objects to cheaper storage classes over time (e.g., move to S3-IA after 30 days).
        -   Transition or permanently delete **noncurrent (old) versions** of objects to save costs (e.g., move noncurrent versions to Glacier after 60 days and delete them after a year).
        -   Clean up incomplete multipart uploads.
    -   **Event Notifications:** A feature that allows S3 to send a notification message to a destination (like **SQS**, **SNS**, or **Lambda**) when a specific event occurs in a bucket (e.g., an object is created `s3:ObjectCreated:*` or deleted). This is a cornerstone of event-driven architectures.

### 📁 3. EFS (Elastic File System)

-   **What is EFS?** A fully managed, scalable network file system (NFS) for **Linux-based** workloads.
-   **Core Use Case:** To provide a **shared file system** that can be mounted and accessed by **multiple EC2 instances** simultaneously. It scales automatically as you add or remove files.
-   **How it Works:** You mount an EFS file system on your EC2 instances using the standard NFSv4.1 protocol. It works across multiple AZs within a region for high availability.

### 🗃️ 4. Amazon FSx

-   **What is FSx?** A service that provides fully managed **third-party file systems** with native compatibility and feature sets.
-   **Core Use Case:** Use it when you need specific file systems like **FSx for Windows File Server** (for Windows applications) or **FSx for Lustre** (for high-performance computing). It's the go-to when EFS doesn't fit the workload's requirements.

### 🏆 5. Storage Best Practices

1.  **Use the Right Tool for the Job:**
    -   **S3:** For object storage, backups, data lakes, and static content.
    -   **EBS:** For high-performance block storage for a single EC2 instance (e.g., databases, boot volumes).
    -   **EFS:** For shared file storage across multiple Linux EC2 instances.
    -   **FSx:** For specialized file system needs (Windows, Lustre).
2.  **Optimize S3 Costs with Lifecycle Policies:** Automatically move objects between storage classes (e.g., Standard -> Infrequent Access -> Glacier) based on age to save money. Use them to also clean up old/noncurrent versions.
3.  **Secure Your Data:**
    -   **In S3:** Use Bucket Policies and IAM to enforce least privilege. Block all public access by default. Enable server-side encryption.
    -   **In EBS/EFS:** Leverage IAM and Security Groups to control access. Enable encryption at rest.
4.  **Plan for Durability and Availability:**
    -   Use **S3 Versioning and Replication** to protect against data loss.
    -   For EBS, take regular **snapshots**.
    -   Deploy EFS and Multi-AZ FSx across multiple Availability Zones.

---

# AWS CloudFormation

### 🏗️ 1. What is CloudFormation?
-   **AWS CloudFormation:** An Infrastructure as Code (IaC) service that lets you model, provision, and manage AWS and third-party resources using template files (YAML or JSON).
-   **Analogy:** It's like a blueprint for your AWS environment. You write down everything you need (servers, databases, networks), and CloudFormation builds it for you automatically and repeatably.

### 🧩 2. Core Concepts
-   **Template:** A YAML or JSON file that declares the AWS resources you want to create and configure. This is your blueprint.
-   **Stack:** A single unit of deployment created from a template. It's a collection of related AWS resources that you can manage as a single entity.
-   **Change Set:** A preview of the changes CloudFormation will make to your stack. It allows you to see how proposed changes might impact your resources before you execute them, preventing unexpected modifications.
-   **StackSet:** A feature that lets you create, update, or delete stacks across multiple AWS accounts and Regions with a single template.

### 📜 3. Template Anatomy (Key Sections)
-   **Resources (Required):** The core of the template. This is where you declare the AWS resources to be created (e.g., EC2 instances, S3 buckets).
-   **Parameters:** (Optional) Inputs that allow you to customize your template at runtime (e.g., passing in an instance type or an environment name like "dev" or "prod"). This makes templates reusable.
-   **Mappings:** (Optional) A fixed dictionary of key-value pairs. Useful for selecting values based on a condition, like the Region (e.g., mapping a Region to a specific AMI ID).
-   **Outputs:** (Optional) Declares output values that you can view after stack creation or import into other stacks (e.g., the URL of a load balancer).
-   **Conditions:** (Optional) Defines conditions to control whether certain resources are created or properties are assigned (e.g., create a resource only if the environment is "prod").

### 🔄 4. Advanced Features
-   **Modules:** Reusable building blocks that encapsulate one or more resources. They can be published to the CloudFormation registry and used across different templates to standardize resource configurations.
-   **Registry:** A central location to manage public and private extensions, including resources, modules, and hooks.
-   **Helper Scripts (cfn-init, cfn-signal):** Scripts you can use in your template's User Data to perform configuration tasks inside an EC2 instance, such as installing packages or starting services. `cfn-signal` is used to signal back to CloudFormation whether the configuration was successful.

### 🛡️ 5. Resource Deletion Policy
-   **DeletionPolicy Attribute:** A critical attribute you can set on any resource in your template to control what happens to the physical resource when the CloudFormation stack is deleted.
-   **Key Options:**
    -   `Delete` (Default): The resource is deleted along with the stack. Use this for easily replaceable resources.
    -   `Retain`: CloudFormation deletes its reference to the resource, but **leaves the physical resource intact**. Use this for critical resources you cannot afford to lose accidentally, like databases or S3 buckets with important data.
    -   `Snapshot`: Before deleting the resource, CloudFormation creates a snapshot. This applies only to services that support snapshots, like `AWS::EC2::Volume` and `AWS::RDS::DBInstance`.

### 🏆 6. CloudFormation Best Practices
1.  **Use IaC Principles:** Treat your templates like application code. Store them in version control (like Git) to track changes and collaborate.
2.  **Use Change Sets for Updates:** Always preview changes with a change set before updating a production stack to avoid unintended consequences.
3.  **Make Templates Reusable:** Use **Parameters** and **Mappings** to create generic templates that can be adapted for different environments (dev, test, prod) instead of hardcoding values.
4.  **Modularize with StackSets and Modules:** For large-scale deployments, use **StackSets** to manage resources across accounts/regions. Use **Modules** to create reusable, standardized components (e.g., a standard S3 bucket configuration).
5.  **Don't Manage Everything in One Stack:** Split complex architectures into multiple, smaller, loosely-coupled stacks. Use **Outputs** and **Imports** (`Fn::ImportValue`) to share information between them.

---

# AWS Systems Manager (SSM)

### 🛠️ 1. What is Systems Manager (SSM)?
-   **AWS Systems Manager (SSM):** A secure, end-to-end management service for your resources on AWS and in hybrid environments. It provides a unified interface for operational tasks like patching, configuration management, and automation.
-   **Analogy:** Think of it as a Swiss Army knife for managing your fleet of servers (EC2 and on-premises). It helps you automate operational tasks, maintain security, and gain visibility without needing to SSH into every machine.
-   **Managed Instance:** Any machine (EC2, on-prem server, VM) configured with the **SSM Agent**. The agent is what allows SSM to communicate with and manage the machine.

### 🧰 2. Key Capabilities & Use Cases

| Category | Capability | Use Case |
|---|---|---|
| **Operations Management** | `OpsCenter` | Central hub to view, investigate, and resolve operational issues from various AWS services. |
| **Application Management** | `Parameter Store` | A secure, hierarchical store for configuration data and secrets. Can store values as plain text or encrypted text (using KMS). |
| | `Secrets Manager` | A dedicated service for secrets management. Provides automatic rotation, IAM-based access control, and integration with other services. **Prefer this over Parameter Store for secrets.** |
| **Change Management** | `Automation` | Create automated workflows (runbooks) to simplify common maintenance and deployment tasks (e.g., patching an AMI). |
| | `Change Manager` | A central place to manage, approve, and track operational changes to your application configuration and infrastructure. |
| | `Maintenance Windows` | Define recurring windows of time to run administrative tasks (like patching) across your instances to minimize disruption. |
| **Node Management** | `Run Command` | Remotely and securely execute commands (e.g., shell scripts, PowerShell commands) on a fleet of managed instances at scale. **Eliminates the need for bastion hosts or direct SSH/RDP access for many tasks.** |
| | `Session Manager` | Provides secure, interactive, browser-based shell or CLI access to your instances without needing to open inbound ports, manage SSH keys, or use a bastion host. **This is the modern, secure way to get a shell.** |
| | `Patch Manager` | Automates the process of patching managed instances with both security-related and other types of updates. |
| | `Inventory` | Automatically collects software inventory and configuration data from your managed instances. |

### 🔐 3. Parameter Store vs. Secrets Manager
-   A common interview question. While both can store sensitive data, `Secrets Manager` is the purpose-built service for secrets.

| Feature | `Parameter Store` | `Secrets Manager` |
|---|---|---|
| **Primary Use** | Configuration data, feature flags, non-rotating secrets. | **Secrets.** Especially those requiring rotation. |
| **Cost** | **Cheaper.** Standard parameters are free. Advanced are pay-per-parameter. API calls are extra. | **More expensive.** Pay per secret per month and per API call. |
| **Secret Rotation** | **No built-in rotation.** Must be implemented with a custom Lambda function. | **Built-in, automated rotation** with Lambda integration. |
| **Cross-Account Access** | Possible, but more complex to set up. | Easy to share secrets with other accounts using resource-based policies. |

### 🏆 4. SSM Best Practices
1.  **Use Session Manager, Not SSH:** For administrative access to instances, prioritize **Session Manager**. It's more secure (no open ports, IAM-based access control, full logging) and easier to manage than SSH keys and bastion hosts.
2.  **Centralize Configuration with Parameter Store:** Store application configuration data (endpoints, feature flags) in Parameter Store instead of hardcoding it in your application or User Data scripts. This separates config from code.
3.  **Use Secrets Manager for All Secrets:** For any credentials (database passwords, API keys), use **Secrets Manager**. Leverage its automatic rotation capabilities to enhance your security posture.
4.  **Automate Patching with Patch Manager:** Set up patch baselines and maintenance windows to ensure your fleet of instances is consistently and automatically kept up-to-date with security patches.
5.  **Leverage IAM for Granular Control:** Use fine-grained IAM policies to control who can use SSM and what actions they can perform on which instances. For example, grant a developer `start-session` access only to specific instances they manage, identified by tags.

---

# AWS Database Services

## Database Types Overview

| Type | Analogy | AWS Service | Use Case |
|---|---|---|---|
| **Relational (SQL)** | A structured spreadsheet with predefined columns. | **RDS, Aurora** | Applications with a fixed schema, like CRM, e-commerce, ERP systems. |
| **Key-Value (NoSQL)** | A massive dictionary or filing cabinet. | **DynamoDB** | High-traffic web apps, gaming leaderboards, session stores. Flexible schema. |
| **Document (NoSQL)** | Storing flexible JSON-like documents. | **DocumentDB** | Content management systems, user profiles, catalogs where each item can have a different structure. |
| **In-Memory** | A super-fast, short-term memory board. | **ElastiCache, MemoryDB** | Caching frequently accessed data to reduce latency for databases. Real-time applications. |
| **Graph** | A social network map. | **Neptune** | Fraud detection, recommendation engines, social networking apps. |
| **Time Series** | A logbook for measurements over time. | **Timestream** | IoT sensor data, application monitoring, DevOps metrics. |


## Amazon RDS (Relational Database Service)
**Amazon RDS:** A managed service that simplifies setting up, operating, and scaling a relational database (like MySQL, PostgreSQL) in the cloud.
- **Analogy:** It's like renting a fully-managed database server instead of managing one yourself. AWS handles patching, backups, and recovery.
- **Core Use Case:** Powering traditional applications like e-commerce sites, CRM systems, and mobile apps that require a relational data structure.
- **Key Features:**
    - **Multiple Engines:** Supports familiar engines like MySQL, PostgreSQL, MariaDB, Oracle, and SQL Server.
    - **Automated Backups:** Manages backups and point-in-time recovery for you.

### 🏗️ Multi-AZ Deployment
**Multi-AZ:** Provides high availability by maintaining a synchronous standby replica in a different Availability Zone. Primary purpose is fault tolerance, not performance.
- **Automatic Failover:** If the primary instance fails, RDS automatically fails over to the standby (typically 1-2 minutes).
- **Zero Downtime Maintenance:** Maintenance is performed on the standby first, then they switch roles.
- **Single Endpoint:** Applications connect to the same DNS endpoint; failover is transparent.

### 📖 Read Replicas
**Read Replicas:** Asynchronous copies of your database that handle read-only queries. Primary purpose is performance scaling, not high availability.
- **Cross-Region Support:** Can be created in different regions for disaster recovery.
- **Multiple Read Replicas:** Up to 5 read replicas per source database.
- **Separate Endpoint:** Each read replica has its own DNS endpoint; applications must be configured to use it.
- **Promotion:** A read replica can be promoted to become a standalone database.

### RDS Best Practices
1. **Enable Multi-AZ:** For production databases to ensure high availability.
2. **Use Read Replicas:** To scale read-heavy workloads and reduce load on the primary instance.
3. **Monitor Performance:** Use CloudWatch metrics (like `CPUUtilization`, `FreeableMemory`) to right-size your instance and detect issues.
4. **Encrypt Data:** Enable encryption at rest and in transit to protect sensitive data.
5. **Use IAM Database Authentication:** Avoid managing database passwords manually by using IAM for authentication.

## Amazon DynamoDB
**Amazon DynamoDB:** A fully managed, highly scalable NoSQL key-value and document database that delivers single-digit millisecond performance at any scale.
- **Analogy:** Think of a massive, infinitely scalable filing cabinet where you can store and retrieve data (items) using a unique key, without worrying about servers.
- **Core Use Case:** High-traffic applications needing fast, flexible data access, like gaming leaderboards, shopping carts, and IoT data ingestion.
- **Key Concepts:**
    - **Table, Items, Attributes:** A table contains items (like rows), and each item is a collection of attributes (like columns). The schema is flexible.
    - **Read/Write Capacity Modes:**
        - **On-Demand:** Pay-per-request. Perfect for unpredictable workloads.
        - **Provisioned:** Specify the throughput you need in advance. Cheaper for predictable traffic.
    - **Consistency Models:**
        - **Strongly Consistent Read:** Returns the most up-to-date data, but has higher latency.
        - **Eventually Consistent Read (Default):** Returns data that might be slightly stale, but has the lowest latency.
    - **DynamoDB Accelerator (DAX):** An in-memory cache for DynamoDB that delivers microsecond read performance for read-heavy workloads.

### 🔍 Global Secondary Indexes (GSI)
**GSI:** An index with a partition key and sort key that can be different from the table's keys. Enables querying on non-key attributes.
- **Separate Provisioned Throughput:** GSI has its own read/write capacity settings, independent of the base table.
- **Eventually Consistent:** GSI updates are asynchronous and eventually consistent.
- **Sparse Index:** Only items with GSI key attributes are projected to the index.

### 🕒 Point-in-Time Recovery (PITR)
**PITR:** Provides continuous backups of your DynamoDB table for up to 35 days. Enables restore to any point in time within that window.
- **Automatic Backup:** Once enabled, DynamoDB continuously backs up your table data.
- **Granular Recovery:** Restore to any specific second within the retention period.
- **Zero Impact:** Backup operations don't affect table performance or availability.

### DynamoDB Best Practices
1. **Choose the Right Partition Key:** A well-distributed partition key is critical for performance and avoiding "hot" partitions.
2. **Use Secondary Indexes:** Create Global Secondary Indexes (GSIs) to support additional query patterns beyond the primary key.
3. **Optimize Costs:** Use On-Demand capacity for unpredictable workloads and Provisioned for predictable ones. Use TTL to automatically delete old items.
4. **Leverage DAX:** For read-heavy applications that need microsecond latency, use DynamoDB Accelerator (DAX).
5. **Monitor Throttling:** Set CloudWatch alarms for `ReadThrottleEvents` and `WriteThrottleEvents` to know when you are exceeding your provisioned throughput.
6. **Enable PITR:** For production tables, enable Point-in-Time Recovery for data protection.

## Amazon ElastiCache
**Amazon ElastiCache:** A managed in-memory caching service used to accelerate application and database performance.
- **Analogy:** It's like adding a super-fast short-term memory layer in front of your database to store frequently accessed data, so you don't have to query the slower database every time.
- **Core Use Case:** Caching database query results, user sessions, and real-time application data like gaming leaderboards.
- **Supported Engines:**
    - **Redis:** A more advanced key-value store with support for complex data structures (lists, hashes), replication (high availability), and persistence.
    - **Memcached:** A simpler, multi-threaded key-value store. Best for caching simple objects at high scale when you don't need advanced features.

### ElastiCache Best Practices
1. **Choose the Right Engine:** Use **Redis** for advanced data structures, high availability (replication), and persistence. Use **Memcached** for simpler object caching at scale.
2. **Cache Sparingly:** Cache frequently read, infrequently updated data. Don't cache everything.
3. **Implement Lazy Loading/Cache-Aside:** Load data into the cache only when it's requested and not found (a "cache miss"). This avoids filling the cache with unused data.
4. **Set a TTL (Time-to-Live):** Give cached items an expiration time to avoid serving stale data.
5. **Secure Your Cache:** Launch your ElastiCache cluster within a VPC and use security groups to restrict access to only the application servers that need it.

---

# AWS Data Warehousing

## Amazon Redshift
**Amazon Redshift:** A fully managed, petabyte-scale data warehouse service designed for large-scale data analytics and business intelligence.
- **Analogy:** It's like a massive, specialized library optimized for complex analytical queries on huge historical datasets, whereas RDS is a library for fast, everyday transactions (OLTP vs. OLAP).
- **Core Use Case:** Running complex analytical queries (SQL) against petabytes of structured data for business intelligence (BI) dashboards, reporting, and data analysis.
- **Key Concepts:**
    - **Columnar Storage:** Stores data in columns instead of rows, which dramatically speeds up analytical queries that only read a few columns from a wide table.
    - **Massive Parallel Processing (MPP):** Distributes data and query load across a cluster of nodes to execute complex queries very quickly.
    - **Redshift Spectrum:** Allows you to run queries directly against exabytes of data stored in its native format in Amazon S3, without having to load the data into Redshift tables.

### Redshift Best Practices
1. **Use the `COPY` Command:** Load data in bulk from S3 using the `COPY` command. It's the most efficient way to ingest data.
2. **Choose Proper Distribution Keys (DISTKEY):** A good distribution key spreads data evenly across nodes to maximize parallel processing and minimize data movement during queries.
3. **Define Sort Keys (SORTKEY):** Sort keys act like an index, allowing Redshift to quickly find the data it needs for range-filtered queries (e.g., querying by date).
4. **Leverage Workload Management (WLM):** Configure WLM to prioritize critical queries and manage concurrency, ensuring that short, fast queries don't get stuck behind long-running ones.
5. **Analyze and Vacuum Tables:** Regularly run `ANALYZE` to update table statistics and `VACUUM` to reclaim space and re-sort rows. This is critical for maintaining query performance.

---

# AWS Database Migration Service (DMS)

### 🔄 1. What is AWS DMS?
**AWS DMS:** A cloud service that migrates your data to and from most widely used commercial and open-source databases. It enables heterogeneous migrations between different database engines.
- **Analogy:** It's like a universal translator for databases, moving data from one format to another while keeping applications running.
- **Core Use Case:** Migrating databases to AWS with minimal downtime, including schema conversion (Oracle to PostgreSQL, MySQL to DynamoDB).
- **Key Components:**
    - **Replication Instance:** The compute resource that runs the migration task.
    - **Source/Target Endpoints:** Connection information for source and target databases.
    - **Migration Task:** The actual migration job with transformation rules.
    - **Table Mappings:** JSON rules that define data transformation and filtering.

### 🎯 2. Migration Types
- **Full Load:** One-time migration of all data from source to target.
- **Change Data Capture (CDC):** Continuous replication of ongoing changes.
- **Full Load + CDC:** Initial full migration followed by ongoing replication.

### 📊 3. Schema Conversion Tool (SCT)
**AWS SCT:** Converts database schemas and code from one database engine to another. Required for heterogeneous migrations (different database types).
- **Use Case:** Converting Oracle stored procedures to PostgreSQL functions, or relational schemas to NoSQL patterns.

### 🏆 4. DMS Best Practices
1. **Size Your Replication Instance Appropriately:** Choose instance type based on data volume and complexity.
2. **Use Table Mappings for Data Transformation:** Filter and transform data during migration using JSON mapping rules.
3. **Enable Multi-AZ for Production:** Deploy replication instance across multiple AZs for high availability.
4. **Monitor with CloudWatch:** Track migration progress and performance metrics.
5. **Test with Sample Data:** Always test migration logic with a subset before full migration.

---

# AWS Backup Service

### 💾 1. What is AWS Backup?
**AWS Backup:** A centralized backup service that automates and centralizes backup across AWS services. It provides a single place to configure backup policies and monitor backup activity.
- **Analogy:** It's like having a universal backup system that works across all your AWS resources with a single control panel.
- **Core Use Case:** Centralized backup management for EC2, RDS, DynamoDB, EFS, and other AWS services with compliance and governance.
- **Key Components:**
    - **Backup Vault:** A container that stores backup files with access policies.
    - **Backup Plan:** A policy that defines when and how to back up resources.
    - **Resource Assignment:** Specifies which resources to include in the backup plan.

### 🔐 2. Backup Vault Features
- **Encryption:** All backups are encrypted at rest and in transit.
- **Access Control:** IAM policies control who can access backups.
- **Cross-Region Copy:** Automatically copy backups to other regions for disaster recovery.

### 🏆 3. AWS Backup Best Practices
1. **Use Backup Plans for Consistency:** Define standardized backup policies across resources.
2. **Implement Cross-Region Backup:** Copy critical backups to different regions for disaster recovery.
3. **Set Proper Retention Policies:** Balance compliance requirements with storage costs.
4. **Monitor Backup Jobs:** Set up CloudWatch alarms for backup failures.
5. **Test Restore Procedures:** Regularly test backup restoration to ensure data recovery works.

---

# AWS Graph Databases

## Amazon Neptune
**Amazon Neptune:** A fast, reliable, and fully managed graph database service that makes it easy to build and run applications that work with highly connected datasets.
- **Analogy:** It's like a dynamic relationship map or a social network graph, optimized for exploring connections between data points, rather than just the data points themselves.
- **Core Use Case:** Building recommendation engines, fraud detection systems, knowledge graphs, and social networking applications where understanding relationships is key.
- **Key Concepts:**
    - **Graph Data Model:** Stores information as a graph with three main components: **Nodes** (data entities like a person), **Edges** (the relationships between nodes, like "friends with"), and **Properties** (attributes for nodes or edges).
    - **Query Languages:** Supports two popular open-source graph query languages:
        - **Apache TinkerPop Gremlin:** Used for property graphs, which is common for social and fraud detection use cases.
        - **SPARQL:** Used for RDF (Resource Description Framework) data models, often found in knowledge graphs.

### Neptune Best Practices
1.  **Choose the Right Data Model and Query Language:** Decide between a Property Graph (queried with Gremlin) or RDF (queried with SPARQL) based on your use case before you start modeling.
2.  **Model for Your Queries:** Design your graph schema (the structure of nodes, edges, and properties) based on the questions your application will ask. Efficient queries depend on an efficient model.
3.  **Use the Bulk Loader:** For ingesting large amounts of data, use the Neptune Bulk Loader to load data directly from S3. It is significantly faster than writing data with individual queries.
4.  **Right-Size Your Instances:** Graph database queries can be memory-intensive. Monitor `CPUUtilization` and memory usage in CloudWatch to choose the correct instance size for your workload.
5.  **Secure Your Cluster:** Always run Neptune clusters within a VPC. Use Security Groups to restrict access and leverage IAM for authentication and authorization to the database.

---

# AWS Container Services (Interview Quick Sheet)

### 📦 1. What are AWS Container Services?
-   **A suite of services** to store, manage, and run containerized applications. They remove the need to manage the underlying infrastructure, allowing you to focus on your application code.
-   **Core Services:**
    -   `ECR`: Stores your container images.
    -   `ECS`: Runs your containers (AWS's orchestrator).
    -   `EKS`: Runs your containers (Managed Kubernetes).

---

### 🐳 ECR (Elastic Container Registry)
-   **What is it?** A fully-managed Docker container registry.
-   **Analogy:** It's your private, secure **Docker Hub** hosted on AWS.
-   **Key Features:**
    -   **Lifecycle Policies:** Automatically cleans up old or unused images to save storage costs.
    -   **Image Scanning:** Scans your container images for software vulnerabilities.
    -   **Replication:** Replicates images across regions for disaster recovery or lower latency.

---

### ⛵ ECS (Elastic Container Service)
-   **What is it?** A highly scalable, high-performance container orchestration service to run Docker containers.
-   **Analogy:** It's **AWS's own simplified container orchestrator**. It's easier to use than Kubernetes but is proprietary to AWS.
-   **Core Concepts:**
    -   **Task Definition:** A JSON blueprint that describes how to launch a container (or group of containers). It specifies the image, CPU/memory, networking mode, IAM role, etc.
    -   **Task:** A running instance of a Task Definition. It's the actual container(s) running.
    -   **Service:** A scheduler that maintains a desired number of tasks. It can automatically restart failed tasks and integrate with a Load Balancer.
    -   **Cluster:** A logical grouping of resources (EC2 instances or Fargate) where your tasks are placed.

---

### ☸️ EKS (Elastic Kubernetes Service)
-   **What is it?** A managed service to run **Kubernetes** on AWS without needing to install, operate, and maintain your own Kubernetes control plane.
-   **Analogy:** You get the full power of **open-source Kubernetes**, but AWS manages the complicated control plane for you (updates, patching, availability).
-   **Why use it?**
    -   You want to use standard Kubernetes tooling and plugins.
    -   You are migrating an existing Kubernetes application to AWS.
    -   You want to avoid vendor lock-in and have a portable solution.

---

### 🤔 2. Core Decisions: ECS vs. EKS & Fargate vs. EC2

#### ECS vs. EKS
| Aspect            | Amazon ECS                                | Amazon EKS                                          |
|-------------------|-------------------------------------------|-----------------------------------------------------|
| **Simplicity**    | **Simpler.** Easier learning curve, deeply integrated with AWS. | **More Complex.** Requires Kubernetes knowledge.    |
| **Control**       | Less control, more opinionated.           | Full control over Kubernetes configuration.         |
| **Ecosystem**     | AWS ecosystem.                            | Huge, open-source community and tooling.            |
| **When to Use?**  | You are all-in on AWS and want simplicity.  | You need the power of Kubernetes or want portability. |

#### Fargate vs. EC2 Launch Type
| Feature           | AWS Fargate (Serverless)                  | Amazon EC2 (Server-based)                           |
|-------------------|-------------------------------------------|-----------------------------------------------------|
| **Analogy**       | Renting a container.                      | Renting a server to run containers on.              |
| **Management**    | **No server management.** AWS handles everything. | **You manage the EC2 instances** (patching, scaling, security). |
| **Control**       | Less control over the underlying environment. | Full control over the instance type, OS, networking. |
| **Use Case**      | Short-running tasks, unpredictable workloads, microservices where you just want to run a container. | Long-running workloads, apps needing specific instance configurations or high performance. |

---

### 🏆 3. Container Services Best Practices
1.  **Secure Your Images:** Use **ECR Image Scanning** to find vulnerabilities before deploying. Use **IAM permissions** to control who can push/pull images.
2.  **Use IAM Roles for Tasks:** Instead of hardcoding credentials in your containers, assign an **IAM Role** directly to your ECS Task or Kubernetes Pod. This is the most secure way to grant AWS permissions.
3.  **Choose the Right Compute:** Use **Fargate** for a serverless experience to eliminate operational overhead. Use **EC2** when you need more control or have sustained workloads that can be optimized with Reserved Instances or Spot.
4.  **Isolate with Networking:** Run containers in a **VPC** and use **Security Groups** to control traffic between containers and other resources.
5.  **Monitor Everything:** Use **CloudWatch Logs** and **Container Insights** to get detailed performance metrics and logs from your containers, tasks, and services to troubleshoot issues quickly.

---

# AWS Serverless (Interview Quick Sheet)

-   **What is Serverless?** A cloud computing model that lets you build and run applications without thinking about servers. AWS manages the infrastructure for you, so you can focus on your code.
-   **Analogy:** Instead of renting a whole server, it's like paying only for the time a function is actually running. You don't pay for idle.
-   **Core Services:** `Lambda` (Compute), `API Gateway` (API Frontend), `SNS` (Notifications), `SQS` (Queues), `DynamoDB` (Database), `S3` (Storage).

### 1. API Gateway
-   **What is it?** A fully managed service that acts as a "front door" for your backend services, like Lambda. It lets you create, publish, and secure APIs.
-   **Analogy:** It's the receptionist for your backend services. It accepts incoming requests, checks their identity, and routes them to the right place.
-   **Core Concepts:**
    -   **API Types:** `REST APIs` (standard web requests), `HTTP APIs` (a lighter, faster, cheaper version of REST), and `WebSocket APIs` (for real-time, two-way communication).
    -   **Integration:** Connects to backend services like `Lambda`, `EC2`, or any public HTTP endpoint.
    -   **Security:** Provides authorization and access control using `IAM`, `Cognito`, and `Lambda Authorizers`.
    -   **Throttling & Usage Plans:** Protects your backend from traffic spikes by setting rate limits and quotas for API keys.
    -   **Pricing:** Pay-per-request model. You are charged for API calls received and data transferred out.

#### Key Architectural Concepts
-   **Integration:** The "glue" that connects an API route to a backend service like Lambda. You must create this connection.
-   **Route:** A rule that defines which path and HTTP method (e.g., `GET /contacts`) maps to which integration.
-   **Stage:** A snapshot of your API's configuration that is deployed to a specific URL (e.g., `dev`, `prod`). If a stage is named (not `$default`), its name **must be included in the invocation URL** (e.g., `.../prod/contacts`). Changes are not live until deployed to a stage.

### 2. AWS Lambda
-   **What is it?** A serverless, event-driven compute service that lets you run code without provisioning or managing servers.
-   **Analogy:** It's a piece of code that waits for a specific event to happen, does its job, and then disappears.
-   **Core Concepts:**
    -   **Function:** Your code, packaged up with its dependencies. It's triggered by an **Event** (e.g., an API call) and receives `event` and `context` objects as parameters.
    -   **Runtimes:** Supports popular languages like Node.js, Python, Java, Go, and allows for custom runtimes.
    -   **Runtime Limit:** Maximum execution time is **15 minutes**.
    -   **Stateless:** Each invocation is independent. Don't store persistent data in the function itself; use a database like DynamoDB or S3.
    -   **Configuration:** You control the `Memory` (which also determines CPU power) and `Timeout`.
    -   **Pricing:** Priced on the number of **requests** and **duration** (in GB-seconds). A generous free tier is included.
    -   **Function URL:** A built-in HTTPS endpoint for your Lambda function. Ideal for simple webhooks or single-function microservices where API Gateway might be overkill.

#### Key Interview Concepts for Lambda

-   **Invocation Types (Sync vs. Async):**
    -   **Synchronous:** The caller waits for the function to complete and gets a response back immediately. Used by API Gateway. This is a blocking call.
    -   **Asynchronous:** The caller hands off the event to Lambda and doesn't wait for a response. Lambda queues the event and handles retries on failure. Used by S3 and SNS. This is a non-blocking call.

-   **Permissions Model (IAM Role vs. Resource-Based Policy):**
    -   **IAM Role (Execution Role):** Defines what the Lambda function **is allowed to do** (e.g., publish to an SNS topic, write to an S3 bucket). This is the "outgoing" permission.
    -   **Resource-Based Policy:** Defines which services **are allowed to invoke** the Lambda function. This is the "incoming" permission (e.g., allowing API Gateway or S3 to trigger the function).

-   **Concurrency & Scaling:**
    -   **Concurrency:** The number of requests your function is serving at any given time. AWS automatically scales this up to a default limit per region.
    -   **Provisioned Concurrency:** Pre-warming a specific number of function instances to ensure they are always ready to respond immediately, eliminating "cold starts" for predictable high-traffic loads.

-   **Execution Context (Cold vs. Warm Starts):**
    -   **Cold Start:** The first time a function is invoked (or after a long period of inactivity), AWS creates a new execution environment (downloads code, starts runtime). This adds latency.
    -   **Warm Start:** For subsequent calls, AWS reuses the existing execution environment, which is much faster.
    -   **How to Prepare:** To optimize for warm starts, initialize expensive setup code (like database connections or large library imports) *outside* of your main handler function. This way, it's done only once per execution context, not on every single invocation.

### 3. API Gateway + Lambda: The Classic Serverless Pattern
-   **How it Works:** This is the most common serverless pattern.
    1.  A client sends an HTTP request to an **API Gateway** endpoint.
    2.  API Gateway receives the request and **triggers a Lambda function**, passing the request data as an event.
    3.  The **Lambda function** executes your business logic.
    4.  The function returns a response to API Gateway, which then sends it back to the client.
-   **Use Case:** Building scalable, cost-effective backends for web and mobile apps without managing any servers.

### 4. AWS SAM (Serverless Application Model)
-   **What is it?** An open-source Infrastructure as Code (IaC) framework built on top of CloudFormation specifically for defining and deploying serverless applications.
-   **Analogy:** It's like a shortcut or macro for CloudFormation. It lets you define a complex serverless app (API, functions, database) with just a few lines of YAML.
-   **Why Use It?**
    -   **Simplified Syntax:** Expresses common serverless resources (functions, APIs, tables) concisely.
    -   **Local Testing:** The **SAM CLI** lets you build, test, and debug your serverless applications locally in a Lambda-like environment before deploying.

### 5. Serverless Best Practices
1.  **Use the Right Service:** Use **Lambda** for event-driven logic, **API Gateway** for the API frontend, and a managed database like **DynamoDB** for state management. For decoupled, fan-out patterns, use **SNS** and **SQS**.
2.  **Keep Functions Small and Single-Purpose:** Design your Lambda functions to do one thing well. This makes them easier to test, debug, and maintain.
3.  **Don't Hardcode Credentials:** Use **IAM Roles** to grant your Lambda function the exact permissions it needs to access other AWS services.
4.  **Separate Config from Code:** Use **Environment Variables** to pass configuration details like database names or SNS topic ARNs to your Lambda function.
5.  **Use the AWS SDK:** Inside your Lambda code, use the appropriate AWS SDK (e.g., Boto3 for Python) to interact with other AWS services programmatically.
6.  **Manage Dependencies:** Package your function's dependencies in the deployment package, or use **Lambda Layers** to share common libraries across multiple functions.
7.  **Monitor and Optimize:** Use **CloudWatch** to monitor invocations, duration, and errors. If a function is too slow, increase its memory to give it more CPU power.
8.  **Test Locally and in the Cloud:** Use tools like the **SAM CLI** for local testing and the **Test Event** feature in the Lambda console to debug your function in the cloud.

