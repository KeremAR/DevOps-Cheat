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

