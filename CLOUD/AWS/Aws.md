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

