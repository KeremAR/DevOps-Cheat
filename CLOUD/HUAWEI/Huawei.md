# Huawei Cloud Study Notes 1: Core Concepts & Introduction

These notes summarize the fundamental concepts of cloud computing and provide an introduction to Huawei Cloud, based on the "Diving into Huawei Cloud" presentation.

## 1. Challenges of Traditional IT and the Evolution to Cloud

Traditional Information Technology (IT) infrastructures present several key challenges:

*   **Slow Service Rollout:** The process of hardware purchasing, software installation, and workload commissioning can take weeks or even months.
*   **Low Resource Utilization and High TCO:** Hardware resources are often tightly coupled with specific service software, leading to inflexible resource allocation and inefficiency.
*   **Complex Scaling:** Adapting to unpredictable business changes and adjusting budgets accordingly is difficult.
*   **Challenging Operations & Maintenance (O&M):** Managing geographically dispersed infrastructure and performing time-consuming service recovery is a significant challenge.

To overcome these issues, IT architecture has evolved from Traditional IT to Virtualization Architecture, and finally to Cloud-based IT Architecture.

## 2. Core Concepts and Values of Cloud Computing

### What Is Cloud Computing?
It is a model where resources are obtained and scheduled over the Internet using Application Programming Interfaces (APIs). This makes them available to users on an "as needed" basis, and users only pay for the resources they consume.

### Values of Cloud Computing:
*   Less investment in fixed assets
*   Abundant and quickly acquired resources
*   No need to guess required capacity
*   Operations across geographical locations
*   New O&M methods

### What Are Cloud Services?
They are an on-demand and measurable IT service model underpinned by cloud computing architecture.

## 3. Cloud Service and Deployment Models

### Cloud Deployment Models:
*   **Public Cloud:** Owned and managed by a third-party cloud service provider and shared with multiple organizations over the Internet.
*   **Private Cloud:** Owned and managed for the exclusive use of a single organization.
*   **Hybrid Cloud:** A combination of public and private clouds that is viewed as a single cloud externally.

### Cloud Service Models:
*   **IaaS (Infrastructure as a Service):** Provides infrastructure services like computers, storage, and networks. It is intended for enterprises or individual users.
*   **PaaS (Platform as a Service):** Intended for developers, offering services such as database middleware and development platforms.
*   **SaaS (Software as a Service):** Intended for enterprise or individual end-users, offering application services like email and instant messaging.

## 4. Huawei Cloud Infrastructure Architecture

### Global Presence
Huawei Cloud operates in 27 Regions and 70 Availability Zones (AZs), covering over 170 countries and regions with more than 2,800 CDN PoPs.

### Region and AZ (Availability Zone)
A **Region** is a specific geographical location. The network between Regions is logically interconnected.

An **AZ** consists of one or more data centers within a Region. Each AZ has independent power and network supplies to ensure that a disaster in one AZ does not impact others. There is private network communication (LAN) between AZs in the same Region.

### Distributed Cloud
Huawei Cloud's infrastructure extends from central regions to the edge, including Dedicated Regions and Intelligent EdgeCloud (IEC), to provide a consistent experience across all scenarios.

## 5. Huawei Cloud Core Services

*   **Computing:** Elastic Cloud Server (ECS), Image Management Service (IMS), Auto Scaling (AS).
*   **Container:** Cloud Container Engine (CCE), Cloud Container Instance (CCI), SoftWare Repository for Container (SWR).
*   **Storage:** Elastic Volume Service (EVS), Object Storage Service (OBS), Scalable File Service (SFS).
*   **Networking:** Virtual Private Cloud (VPC), Elastic Load Balance (ELB), Elastic IP Address (EIP), NAT Gateway.
*   **Database:** Relational Database Service (RDS), GaussDB, GeminiDB.
*   **Security and Management:** Identity & Access Management (IAM), Data encryption Workshop (DEW), Cloud Trace Service (CTS).

## 6. Huawei Cloud Ecosystem

The Huawei Cloud ecosystem is built on a framework that supports developers and partners, centered around the KooGallery marketplace.

### Developers
Aims to build the best-in-class development platform for millions of developers. It provides the Huawei Cloud Developer Institute for learning resources and talent cultivation. It supports innovation and monetization through development pipelines like CodeArts and ModelArts.

### Partners
Features a unified partner network with two collaboration frameworks: GoCloud (to identify and upskill partners) and GrowCloud (to guide partner transformation).

### Huawei Cloud KooGallery
A marketplace that connects partners and customers, providing high-quality cloud products and services. It acts as a one-stop shop for customers and enables one-stop operations for sellers.

# Huawei Cloud Study Notes 2: Compute Services
This guide covers Huawei Cloud's core compute services, including Elastic Cloud Server (ECS), Dedicated Host (DeH), Bare Metal Server (BMS), and Image Management Service (IMS).

## 1. Overview of Compute Services
Huawei Cloud offers a wide range of compute services to fit different needs. Key services include:

*   **Elastic Cloud Server (ECS):** Virtual machines that provide scalable compute capacity.
    *   **AWS Equivalent:** Amazon EC2 (Elastic Compute Cloud).
*   **Bare Metal Server (BMS):** Provides dedicated physical servers without a virtualization layer.
    *   **AWS Equivalent:** Amazon EC2 Bare Metal instances (e.g., .metal types).
*   **Dedicated Host (DeH):** A physical server dedicated to a single user, where you can launch multiple ECS instances.
    *   **AWS Equivalent:** Amazon EC2 Dedicated Hosts.
*   **Cloud Container Engine (CCE):** A managed Kubernetes service.
    *   **AWS Equivalent:** Amazon EKS (Elastic Kubernetes Service).
*   **Cloud Container Instance (CCI):** A serverless container service.
    *   **AWS Equivalent:** AWS Fargate.
*   **FunctionGraph:** A serverless computing service for running code in response to events.
    *   **AWS Equivalent:** AWS Lambda.

## 2. Elastic Cloud Server (ECS)
ECS is a foundational compute service that allows you to adjust resources on-demand.

### Key Features
*   You can use an ECS just like a traditional server and have full permissions.
*   You are responsible for managing the OS and upper-layer components.
*   You only pay for the resources you use.
*   ECSs can be treated as disposable resources, created and deleted as needed.

### ECS Purchase and Configuration
The process involves several configuration steps: Basic Settings, Network Settings, and Advanced Settings.

#### A. Billing Modes
*   **Pay-per-use:** Billed based on on-demand usage, suitable for elastic or temporary workloads.
    *   **AWS Equivalent:** On-Demand Instances.
*   **Yearly/Monthly:** A subscription model with stable discounts, suitable for long-term, stable workloads.
    *   **AWS Equivalent:** Savings Plans or Standard Reserved Instances.
*   **Reserved instances:** Provides stable discounts for a long-term commitment.
    *   **AWS Equivalent:** Convertible Reserved Instances.
*   **Spot pricing:** A demand-based, dynamic pricing model with occasional high discounts. Resources may be reclaimed by the cloud provider.
    *   **AWS Equivalent:** Spot Instances.

#### B. Region Selection
When selecting a region, you should consider four main factors:
*   **Compliance:** Data sovereignty and legal requirements.
*   **User Experience:** Choose a region close to your end-users to reduce latency.
*   **Functions:** Some functions or services may be region-specific.
*   **Cost:** Pricing can vary between regions.

#### C. Instance Types
*   **Naming Convention:** An instance name like `c6.8xlarge.4` provides details about the instance:
    *   `c`: Instance family (e.g., 'c' for general computing-plus).
    *   `6`: Instance generation.
    *   `8xlarge`: Instance size, which implies the vCPU count.
    *   `4`: Ratio of memory (in GiB) to vCPUs.
*   **Calculation Example (`c6.8xlarge.4`):**
    *   The `8xlarge` size typically corresponds to **32 vCPUs**.
    *   The ratio `4` means there are 4 GiB of RAM for every 1 vCPU.
    *   Total Memory = 32 vCPUs * 4 = **128 GiB RAM**.
*   **Selection Tips:** You can change the instance type if you pick the wrong one. It's recommended to optimize the instance type based on monitoring data to ensure resources are not wasted.

#### D. Network Configuration
You must configure network settings, including selecting a VPC, subnet, and security group for the ECS.

### ECS Lifecycle
An ECS moves through several states:
`Creating` -> `Running` -> `Stopping` -> `Stopped` -> `Deleted`. It can also be restarted from the `Running` state.

## 3. Dedicated Host (DeH)

**Definition:** A DeH is a physical server that is fully dedicated for your use in a single-tenant environment.
*   **AWS Equivalent:** Amazon EC2 Dedicated Hosts.

**Features:**
*   The physical resources are not shared with other tenants, ensuring performance isolation.
*   Meets compliance requirements that demand exclusive use of physical hardware.
*   Helps satisfy software license requirements that are tied to specific hardware specifications.
*   You can monitor the resource usage of the host and adjust the distribution of ECSs on it.

## 4. Bare Metal Server (BMS)

**Definition:** A BMS is a physical server dedicated to a single user, providing direct access to the hardware with no virtualization layer.
*   **AWS Equivalent:** Amazon EC2 Bare Metal instances (e.g., i3.metal, m5.metal).

**Features:**
*   Offers high performance and stability required by mission-critical applications.
*   There is no virtualization overhead or performance loss.
*   Provides dedicated computing and storage resources.
*   Uses VPCs and security groups for network isolation, just like an ECS.

## 5. Image Management Service (IMS)

**Definition:** An image is a template for an ECS environment, which contains an operating system and can be used to initialize or restore an ECS.
*   **AWS Equivalent:** Amazon Machine Image (AMI).

### Image Types
*   **Public Images:** Provided and thoroughly tested by Huawei Cloud. They contain pre-installed operating systems (Linux and Windows) and are periodically updated.
*   **Private Images:** Images you create from your own ECSs. You are responsible for the security and contents of these images.
*   **Shared Images:** Private images that a user shares with other Huawei Cloud users. You should only use shared images from trusted sources.
*   **KooGallery Images:** Third-party images with pre-installed applications, available in the KooGallery marketplace. These images are tested by Huawei Cloud before being published.

# Huawei Cloud Study Notes 3: Storage Services

## 1. Overview of Storage Services
Huawei Cloud offers a variety of storage services to meet different data needs, from large-scale object storage to high-performance block and file storage. The main services covered are:

*   Object Storage Service (OBS)
*   Elastic Volume Service (EVS)
*   Scalable File Service (SFS)
*   ECS Local Disks

## 2. Object Storage Service (OBS)
**AWS Equivalent:** Amazon S3 (Simple Storage Service)

OBS is a fully managed, web-accessible object storage service designed for massive amounts of data.

### Key Concepts
*   **Bucket:** A container for storing objects and serves as a management unit for OBS. To use OBS, you must first create a bucket.
*   **Object:** The fundamental entity stored in OBS, consisting of the data itself and metadata describing it. Each object is uniquely identified by its name within a bucket.
*   **Endpoint/URL:** Every object has a unique access path (URL) that can be made accessible over the internet. The URL format includes the bucket name and the object name (key).

### Features
*   **Scalability:** Offers unlimited storage capacity, with a single object able to be as large as 48 TB.
*   **Durability:** Provides extremely high data durability of 99.9999999999% (12 nines).
*   **Access Control:** Permissions can be managed using Access Control Lists (ACLs) and more granular bucket policies.
*   **Versioning:** When enabled, versioning keeps a history of an object's versions, protecting against accidental deletions or overwrites. A delete marker is placed on the latest version when an object is deleted, but previous versions are preserved.

### Storage Classes & Lifecycle Management
OBS provides different storage classes to optimize costs based on data access frequency, similar to AWS S3 storage classes.

*   **Standard:** For frequently accessed data ("hot" data) with the highest unit price but freest access.
*   **Infrequent Access:** For less frequently accessed data, with a lower storage price but higher cost for access requests.
*   **Archive:** The lowest-cost option, designed for long-term data archiving. Data must be "restored" before it can be accessed.
*   **Lifecycle Management:** You can set rules to automatically transition objects between these classes over time (e.g., move data from Standard to Archive after 90 days).

### Use Cases
*   Data backup and archiving.
*   Hosting static websites.
*   Serving as a data distribution source, especially when paired with a CDN.
*   Core storage for big data and data lakes.

## 3. Elastic Volume Service (EVS) & Local Disks

### Elastic Volume Service (EVS)
**AWS Equivalent:** Amazon EBS (Elastic Block Store)

EVS provides persistent block-level storage volumes (disks) for use with Elastic Cloud Servers (ECSs).

#### Features & Reliability
*   **Persistence:** EVS volumes exist independently of the ECS instance lifecycle.
*   **Performance:** Offers a balance of cost and performance with various disk specifications.
*   **Durability:** Achieves 99.9999999% (9 nines) durability through a three-copy redundancy mechanism within a single Availability Zone (AZ).
*   **Data Protection:**
    *   **Backups:** You can create backups of EVS disks, which are stored in OBS for cross-AZ protection against hardware/software faults or accidental deletions.
    *   **Snapshots:** Snapshots provide a point-in-time copy of a disk and are the method for quickly restoring data lost due to misoperations, viruses, or other attacks. You can create a new disk from a snapshot or restore a disk to a previous state.

#### Use Cases
*   System disks for ECSs requiring high I/O.
*   Persistent storage for databases.
*   Storage for sensitive enterprise applications, with support for EVS encryption.

#### Billing
*   Billed based on the **allocated disk size**, regardless of how much space is actually used.
*   Available in both yearly/monthly and pay-per-use models.

### ECS Local Disks
**AWS Equivalent:** Instance Store

Local disks are physically attached to the host server of an ECS instance and are only available for specific instance types (e.g., i3).

*   **Performance:** Delivers extremely low access latency and very high IOPS.
*   **Key Characteristic:** This storage is ephemeral. Data is lost if the ECS instance is stopped or if the underlying hardware fails.
*   **Cost:** There are no extra fees for local disks; the cost is included in the price of the instance.

## 4. Scalable File Service (SFS)
**AWS Equivalent:** Amazon EFS (Elastic File System)

SFS is a fully managed, shared file storage service that can be mounted by multiple ECS instances simultaneously.

### Features
*   **Shared Access:** Ideal for scenarios requiring a common data source for multiple servers, such as content management or web serving.
*   **Protocols:** Supports the NFS protocol and partially supports the CIFS protocol.
*   **Network Access:** An SFS file system can only be accessed by ECSs within the same Virtual Private Cloud (VPC).
*   **Durability:** Provides 99.99999999% (10 nines) durability.
*   **Scalability:** File system capacity can be scaled elastically, and performance scales linearly.

### Use Cases
*   High-performance computing (HPC).
*   Media processing and file sharing.
*   Content management and web services.

## 5. Storage Services Comparison Summary

| Attribute | EVS | Local Disk | OBS | SFS |
|---|---|---|---|---|
| **AWS Equivalent** | Amazon EBS | Instance Store | Amazon S3 | Amazon EFS |
| **Working Model** | Block storage | Block storage (on host) | Object storage (API access) | File storage (network mount) |
| **Durability** | 99.9999999% (9 nines) | Ephemeral (data lost on stop) | 99.9999999999% (12 nines) | 99.99999999% (10 nines) |
| **Performance** | High IOPS, low latency | Very high IOPS, very low latency | High throughput | High bandwidth, scales linearly |
| **Storage Limit** | Up to 64 TiB | Depends on instance type | Unlimited (48 TB/object) | Unlimited |
| **Internet Access** | No (via EC2) | No | Yes | No (VPC only) |
| **Cost** | High | Included with instance | Low | Moderate |

# Huawei Cloud Database Services Study Notes

This document summarizes Huawei Cloud's database services based on the "05 Database Services.pdf" file.

## 1. Introduction to Database Concepts
Huawei Cloud offers a range of database services designed to handle different types of data.

### Data Types and Corresponding Services
*   **Structured Data:** Highly organized data that fits into a fixed schema, like tables in a relational database.
    *   **Huawei Cloud Service:** Relational Database Service (RDS).
*   **Semi-structured Data:** Data that does not conform to a strict tabular structure but contains tags or markers to separate semantic elements, such as JSON or XML.
    *   **Huawei Cloud Service:** Document Database Service (DDS).
*   **Unstructured Data:** Data with no predefined data model, such as audio, video, and compressed files.
    *   **Huawei Cloud Service:** Object Storage Service (OBS).

### Relational vs. Non-Relational Databases
| Feature | Relational Database (e.g., RDS) | Non-Relational Database (e.g., DDS) |
|---|---|---|
| **Application Model** | Best for traditional applications needing complex queries, transactions, and strong data integrity. | Best for modern internet applications needing to store massive data and handle high concurrency. |
| **Data Types** | Fully structured. | Semi-structured (documents, key-value pairs). |
| **Scalability** | Primarily scales vertically (increasing instance size). Horizontal scaling is done via read replicas. | Scales horizontally by adding more nodes to a cluster. |
| **Consistency** | Strong consistency. | Can be configured for strong or eventual consistency. |

### Advantages of Cloud Native Databases
Compared to traditional on-premises or self-built databases on cloud servers, cloud-native database services like RDS reduce your operational burden. Huawei Cloud manages the physical infrastructure, OS, patching, and database engine management, allowing you to focus on database development and optimization.

## 2. Relational Database Services
### Relational Database Service (RDS)
**AWS Equivalent:** Amazon RDS

RDS is a managed service that simplifies setting up, operating, and scaling a relational database in the cloud.

*   **Compatible Engines:** Supports mainstream engines like MySQL, PostgreSQL, and SQL Server.
*   **High Availability (HA):** Supports primary/standby deployments both within a single Availability Zone (AZ) and across different AZs for disaster recovery. Failover to the standby instance occurs within seconds if the primary fails.
*   **Backup and Restoration:**
    *   Features automated backups and allows manual backups, which are stored securely in OBS.
    *   Supports Point-in-Time Recovery (PITR) by using binlog backups, which are taken frequently (e.g., every 5 minutes).
*   **Read/Write Splitting:**
    *   Provides a single read/write splitting address (proxy) that automatically directs write requests to the primary instance and distributes read requests among read replicas.
    *   This is transparent to the application and improves read performance for read-heavy workloads.
    *   You can add or remove read replicas as needed, with a DB instance supporting up to 10 read replicas.

### TaurusDB
**AWS Equivalent:** Amazon Aurora

TaurusDB is a Huawei-developed, cloud-native relational database that is compatible with MySQL clients.

*   **Architecture:** It uses a decoupled storage and compute architecture, where compute nodes (primary and read replicas) share a distributed storage layer. This design eliminates I/O bottlenecks and improves performance significantly over open-source MySQL.
*   **Scalability:**
    *   Storage can scale up to 128 TB per instance.
    *   Compute can scale up to one primary node and 15 read replicas.
*   **Reliability:** The storage layer automatically stores three copies of the data to ensure high reliability.

### GaussDB (Relational)
**AWS Equivalent:** Conceptually similar to Amazon Aurora for cloud-native scale, but with a different architecture. The "shared-nothing" aspect is similar to Amazon Redshift (for analytics).

GaussDB is a distributed relational database developed by Huawei.

*   **Architecture:** It uses a Shared-Nothing (Sharding) architecture, where each node has its own independent CPU, memory, and disk. This allows for massive horizontal scaling to over 1,000 nodes and petabytes of storage.

## 3. Non-Relational Database Services
### GeminiDB
**AWS Equivalents:**
*   **MongoDB API:** Amazon DocumentDB (with MongoDB compatibility)
*   **Redis API:** Amazon ElastiCache for Redis
*   **Cassandra API:** Amazon Keyspaces (for Apache Cassandra)

GeminiDB is a Huawei-developed, distributed, multi-model NoSQL database service.

*   **Architecture:** Like TaurusDB, it uses a decoupled storage and compute architecture with a shared distributed storage pool. Compute nodes are stateless and can be scaled quickly.
*   **API Compatibility:** It is compatible with APIs for many popular NoSQL databases, including MongoDB, Redis, Cassandra, InfluxDB, and HBase.
*   **High Availability:** If a compute node fails, workloads can be switched over within seconds. The storage layer maintains three copies of the data for fault tolerance.

### Document Database Service (DDS)
**AWS Equivalent:** Amazon DocumentDB (with MongoDB compatibility)

DDS is a non-relational database service that specifically uses the MongoDB engine. It is designed for storing semi-structured document data.

## 4. Database Management Tools
### Data Admin Service (DAS)
**AWS Equivalents:** Functionality is similar to a combination of Amazon RDS Query Editor and Amazon RDS Performance Insights.

DAS is a web-based, one-stop platform for managing your Huawei Cloud databases without needing a client.

*   **For Developers:** Allows for creating databases and tables and executing SQL statements directly from the web console.
*   **For DBAs and O&M:** Provides powerful O&M functions, including performance data analysis, real-time performance diagnosis, and analysis of slow SQL statements.

# Huawei Cloud Study Notes 4: Networking Services

## 1. Virtual Private Cloud (VPC)
**AWS Equivalent:** Amazon Virtual Private Cloud (Amazon VPC)

A VPC allows you to create a logically isolated, private network space on Huawei Cloud for your resources. It functions like a virtual Local Area Network (LAN) on the cloud. Resources within the same VPC can communicate with each other, while they are isolated from other VPCs by default.

### VPC Components
*   **Private CIDR Block:** You must define a private IP address range (e.g., 192.168.0.0/16) for your VPC.
*   **Subnets:**
    *   **AWS Equivalent:** AWS Subnet.
    *   A VPC is divided into one or more subnets.
    *   All cloud resources, like ECSs, must be created within a subnet.
    *   Subnets allow for more refined network management and traffic control.
*   **Route Tables:**
    *   **AWS Equivalent:** AWS Route Table.
    *   Each VPC has a default route table that ensures all subnets within it can communicate.
    *   Route tables contain rules (routes) that determine where network traffic from your subnets is directed.
    *   Each subnet must be associated with a single route table.

### Network Security (Access Control)
VPC provides two main features for securing your network resources.

#### Security Groups
*   **AWS Equivalent:** AWS Security Group.
*   **Function:** Acts as a stateful firewall at the instance level.
*   **How it works:** You define inbound and outbound rules to control traffic allowed to reach or leave the instances associated with the security group. For example, you can create a rule to allow all instances within the same security group to communicate with each other.

#### Network ACLs (Access Control Lists)
*   **AWS Equivalent:** AWS Network ACL (NACL).
*   **Function:** Acts as a stateless firewall at the subnet level. It provides an optional layer of security.
*   **How it works:** By default, a Network ACL denies all traffic until you add explicit "allow" rules. It checks traffic that crosses subnet boundaries. A subnet can only be associated with one Network ACL at a time.

## 2. Cloud Network Connectivity

### Connecting VPCs: VPC Peering Connection
*   **AWS Equivalent:** VPC Peering Connection.
*   This service creates a direct network connection between two VPCs in the same region, allowing them to communicate using private IP addresses as if they were in the same network.
*   **Configuration:** After creating the connection, you must add routes to the route tables of both the local and peer VPCs to enable traffic flow.
*   **Cost:** VPC Peering Connections are free to use.

### Internet Access for Single Instances: Elastic IP (EIP)
*   **AWS Equivalent:** Elastic IP (EIP).
*   An EIP is a static, public IP address designed to allow cloud resources like ECSs to communicate with the internet.
*   **Flexibility:** An EIP can be bound to and unbound from different cloud resources, but can only be attached to one at a time. Bandwidth can be flexibly adjusted.
*   **Billing:** Supports multiple billing modes, including pay-per-use (by bandwidth or traffic) and yearly/monthly subscriptions.

### Shared Internet Access: NAT Gateway
*   **AWS Equivalent:** NAT Gateway.
*   A NAT Gateway allows multiple ECS instances in a private subnet to share one or more EIPs to access the internet, without exposing the instances directly. It can be shared across subnets and AZs.
*   **SNAT (Source NAT):** Enables multiple servers within a VPC to initiate outbound connections to the internet by sharing an EIP. The gateway translates the private source IP to its public IP.
*   **DNAT (Destination NAT):** Enables servers to provide services accessible from the internet. It maps a public IP address and port (the EIP) to a private IP address and port of an ECS instance, forwarding incoming traffic.

# Huawei Cloud Security Services Study Notes

## 1. The Shared Responsibility Model
Security and compliance are a shared responsibility between Huawei Cloud and the customer.

*   **Huawei Cloud's Responsibility (Security of the Cloud):** Huawei Cloud is responsible for protecting the underlying infrastructure that runs all of the services offered. This includes the security of the physical infrastructure (regions, AZs, hardware), compute, storage, networking, and database services at a fundamental level.
*   **Customer's Responsibility (Security in the Cloud):** The customer is responsible for managing and securing everything they put on the cloud. This includes:
    *   **Data Security:** Implementing client-side encryption and ensuring data integrity.
    *   **Application Security:** Securing the applications deployed on the cloud.
    *   **Platform & Configuration:** Properly configuring virtual networks, access controls (like IAM), identity management, and key management.

## 2. Identity and Access Management (IAM)
**AWS Equivalent:** AWS Identity and Access Management (IAM)

IAM provides fine-grained permissions management, allowing you to securely control access to your Huawei Cloud services and resources. Its major functions are identity authentication and access management.

### IAM Concepts
*   **IAM User & User Group:** An IAM user is an identity you create to represent a person or application. Users can be organized into User Groups for easier permission management.
*   **Authentication:**
    *   **Console Login:** Users can log in to the Huawei Cloud console using their IAM username and password.
    *   **Programmatic Access:** Applications use an Access Key (AK/SK) pair for API access to verify identity.
*   **Permissions & Policies:**
    *   Permissions are defined in JSON documents called policies.
    *   **System Policies** are maintained by Huawei Cloud, while **Custom Policies** are created and maintained by users.
    *   These policies are attached to users, groups, or agencies to grant permissions.
*   **Agency (Role):**
    *   **AWS Equivalent:** IAM Role.
    *   An IAM agency is a temporary security credential that allows you to delegate permissions to other Huawei Cloud accounts, cloud services, or third-party identity providers.
    *   Agencies are the recommended way to grant applications running on an ECS access to other cloud services (like OBS) without hardcoding credentials like AK/SK. You associate the agency with the ECS, and the application inherits the agency's permissions.

## 3. Data Encryption Workshop (DEW)
DEW is a comprehensive service for data encryption and secrets management. It consists of Key Management Service (KMS) and Credentials Store Management Service (CSMS).

### Key Management Service (KMS)
**AWS Equivalent:** AWS Key Management Service (KMS)

KMS provides secure and reliable management of your encryption keys. It uses **envelope encryption** to protect your data.

*   **Envelope Encryption:** This method uses two types of keys:
    *   **Data Encryption Key (DEK):** This key is used to directly encrypt your raw data.
    *   **Customer Master Key (CMK):** This key is used to encrypt the DEK.
*   **How it Works:** Your CMKs never leave the KMS service in plaintext. You use the KMS API to ask the service to generate a data key. KMS returns both a plaintext version of the data key (for you to encrypt your data) and an encrypted version of the data key (which you store alongside your encrypted data). To decrypt, you send the encrypted data key back to KMS, which decrypts it using the CMK and returns the plaintext data key.

### Credentials Store Management Service (CSMS)
**AWS Equivalent:** AWS Secrets Manager

CSMS allows you to centrally and securely store and manage secrets, such as database passwords and server credentials, eliminating the need to hardcode them in your application code or configuration files. You can then use IAM agencies to grant your applications permission to retrieve these secrets at runtime.

## 4. Cloud Trace Service (CTS)
**AWS Equivalent:** AWS CloudTrail

CTS records all operations (API calls) made on your Huawei Cloud resources, providing a detailed history for auditing, security analysis, and troubleshooting.

*   **Function:** If a resource is deleted or modified, you can use CTS to identify which IAM user performed the action and when.
*   **Log Management:**
    *   You can query traces from the last seven days directly in the CTS console.
    *   For long-term storage, traces can be transferred to an **Object Storage Service (OBS) bucket**.
    *   For real-time analysis, traces can be sent to **Log Tank Service (LTS)**.

# Course Notes: Elastic Cloud Services for Distributed Deployment (HCCDA)
This module focuses on how to build scalable and reliable applications on Huawei Cloud by automatically adjusting resources to meet fluctuating demand.

## 1. Why is Scalability Important?
*   **Problem:** Application traffic is rarely constant; it fluctuates based on time of day, promotions, or other events.
*   **Traditional Approach (Ideal Resource Plan):** Provisioning resources for peak traffic leads to significant waste during normal or low-traffic periods. Scalable applications can save over 70% of daily resource costs.
*   **Goal:** Build systems that enhance service stability, improve response speed, and optimize resource utilization by adjusting resources dynamically.

## 2. Methods of Scaling
There are two primary methods to handle increased load:

### Scaling Up (Vertical Scaling)
*   **What it is:** Increasing the resources (e.g., vCPUs, RAM) of a single server.
*   **Pros:** Simple to implement.
*   **Cons:** Can lead to performance bottlenecks and has physical or virtual limits.

### Scaling Out (Horizontal Scaling)
*   **What it is:** Adding more servers to a resource pool to share the load. This is the foundation of distributed deployment.
*   **Pros:** Offers potentially unlimited scalability and higher availability by eliminating single points of failure.
*   **Cons:** Requires more complex technological coordination and is best suited for stateless applications.

## 3. Core Huawei Cloud Services for Scalability
Building a scalable system on Huawei Cloud involves three key steps and services:

1.  **Distribute Traffic:** Use Elastic Load Balance (ELB).
2.  **Monitor Resources:** Use Cloud Eye to know when to scale.
3.  **Adjust Resources:** Use Auto Scaling (AS) to add or remove servers.

### Step 1: Elastic Load Balance (ELB)
**AWS Equivalent:** AWS Elastic Load Balancing (ELB)
ELB automatically distributes incoming traffic across multiple backend servers, improving application availability.

#### Key Functions:
*   Distributes requests to backend servers based on configured rules.
*   Supports load balancing at both Layer 4 (TCP/UDP) and Layer 7 (HTTP/HTTPS).
*   Performs health checks to ensure traffic is only sent to healthy backend servers.
*   Works with Auto Scaling to handle a massive number of concurrent requests.

#### Components:
*   **Load Balancer:** The entry point for traffic.
*   **Listener:** Defines the protocol (e.g., HTTPS) and port (e.g., 443) for incoming connections and routes requests based on forwarding policies.
    *   **AWS Equivalent:** Listener
*   **Backend Server Group:** A group of servers (like ECS instances) that will receive the traffic. You configure the load balancing algorithm (e.g., Weighted Round Robin, Weighted Least Connections) and health checks here.
    *   **AWS Equivalent:** Target Group

### Step 2: Cloud Eye
**AWS Equivalent:** Amazon CloudWatch
Cloud Eye is a monitoring service that tracks resource metrics, sets alarms, and helps you understand when to scale.

#### Key Functions:
*   Collects real-time metrics for cloud resources, such as CPU usage, memory usage, and disk usage.
*   Allows users to configure alarm rules based on specific metric thresholds.
*   When an alarm is triggered, it can send notifications (SMS, email) or trigger automated actions in other services (like Auto Scaling).

### Step 3: Auto Scaling (AS)
**AWS Equivalent:** AWS Auto Scaling
Auto Scaling automatically adjusts the number of resources (specifically, Elastic Cloud Servers - ECS) based on pre-configured policies.

#### Key Functions:
*   Adds ECS instances (**AWS Equivalent:** EC2) to handle load increases and removes them to save costs when demand is low.
*   Automatically identifies and replaces unhealthy instances to maintain performance and reliability.
*   Integrates with ELB to automatically register new instances to the load balancer.

#### Scaling Policies:
*   **Dynamic Scaling:** Adjusts resources based on real-time performance metrics monitored by Cloud Eye (e.g., "add 2 instances if average CPU usage is over 70% for 5 minutes").
*   **Scheduled Scaling:** Adjusts resources at specific times, for predictable traffic patterns (e.g., "increase instances to 10 every weekday at 9 AM").
    *   **AWS Equivalent for both:** Dynamic and Scheduled Scaling policies.

#### Configuration Process:
1.  **Create a Scaling Template:** Defines the specifications for the new ECS instances (image, specs, etc.).
    *   **AWS Equivalent:** Launch Template.
2.  **Create a Scaling Group:** Sets the min/max number of instances, associates the scaling template, and links to the ELB.
    *   **AWS Equivalent:** Auto Scaling Group (ASG).
3.  **Create a Scaling Policy:** Defines the triggers for scaling (either alarm-based or scheduled).

## 4. Typical Architecture & Application Scenarios
*   **Architecture:** A typical scalable website uses ELB to distribute traffic to a group of ECS instances managed by an Auto Scaling group. Cloud Eye monitors the ECS instances and triggers AS policies to scale out or in as needed.
*   **Scenarios:**
    *   **Heavy-Traffic Forums:** Where traffic is unpredictable, dynamic scaling based on CPU or memory usage is ideal.
    *   **Livestreaming:** For a daily popular show, scheduled scaling can proactively add resources before the show starts and remove them after.
    *   **E-commerce:** During big promotions, Auto Scaling can rapidly add resources to handle the surge in traffic, ensuring a smooth customer experience.
