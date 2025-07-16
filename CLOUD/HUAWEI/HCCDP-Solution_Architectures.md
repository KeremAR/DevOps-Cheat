# Lecture Notes 1: Typical Service Implementation Solutions on the Cloud
This document explains how an application is built on the cloud, which application architectures are used, and how this architecture is optimized and evolved over time using Huawei Cloud services.

## 1. Core Concepts and Architectures

**Application:** A logical set of one or more independent and complete functions that are closely related and have specific business features. Each application has only one owner and one vendor.

**Application Instance:** An independent operating environment for an application. It is the minimum unit for migrating an application to the cloud. The relationship between an application and its instances is 1:N.

**Typical Application Architectures:**

*   **3-Layer Architecture:** The most basic architecture, consisting of:
    *   **User Interface Layer (Web):** The layer that the user sees and interacts with.
    *   **Business Logic Layer (Service):** Processes the system's service logic.
    *   **Data Access Layer (DAL):** Communicates directly with the database for operations like adding, deleting, and querying data.

*   **4-Layer Architecture:** Formed by adding a General Processing Layer (Manager Layer) to the 3-layer architecture to prevent bloating in the business logic layer. This layer provides common capabilities for the service layer, such as caching solutions and middleware processing.

*   **MVC Architecture (Model-View-Controller):** A pattern that separates an application into three main logical components.
    *   **Model:** Carries data and is responsible for processing application data logic, such as accessing databases.
    *   **View:** Provides a GUI for users and displays data from the Model.
    *   **Controller:** Forwards a user request to a corresponding Model for processing and returns the result to the user via a View.

*   **Microservice Architecture:** This architecture breaks down applications into a group of small services called microservices. Each microservice can be deployed separately, and is designed, developed, and tested by an independent team.

## 2. Architecture Optimization and Evolution (12 Steps)
These are the evolutionary steps for an application, from a simple single-node setup to a highly available (HA), scalable, and resilient architecture. Each step aims to address the weaknesses of the previous one.

### Step 1: Single-Node Deployment

*   **Problem:** The application and database run on a single server, which can lead to resource contention issues.
*   **Huawei Service:** ECS.

### Step 2: Separation of Applications and Data

*   **Problem:** A single application server cannot handle increasing traffic and may become a single point of failure (SPOF).
*   **Solution:** The application server and database server are separated onto different machines.
*   **Huawei Services:** ECS (for applications) + ECS (for self-managed databases) or $ECS+RDS$.

### Step 3: Application Server Clusters in Load Balancing Mode

*   **Problem:** The performance of a single server is limited, and the SPOF risk remains.
*   **Solution:** Use Elastic Load Balance (ELB) to distribute incoming traffic across multiple application servers.
*   **Huawei Services:** $ECS+RDS+ELB$.

### Step 4: Isolating Read & Write Databases

*   **Problem:** As access traffic increases, the database load also increases.
*   **Solution:** Use primary/standby database replication for read/write isolation. Write operations go to the primary database, and read operations are moved to the standby database.
*   **Huawei Services:** ECS + RDS (primary/standby) + ELB.

### Step 5: Reducing Database Read Pressure with Cache

*   **Problem:** Constantly accessing the database for frequently read but rarely updated data is inefficient.
*   **Solution:** A cache layer is introduced to store this "hot" data, reducing database access pressure.
*   **Huawei Services:** $ECS+RDS$ (primary/standby) + ELB + Distributed Cache Service (DCS).

### Step 6: Improving Read Efficiency Through a Search Engine

*   **Problem:** Text searches using SQL LIKE are costly and often inaccurate.
*   **Solution:** Integrate a search engine that uses an inverted index to complete searches, greatly improving speed and accuracy.
*   **Huawei Services:** ECS + RDS (primary/standby) + ELB + DCS + Elasticsearch (ES).

### Step 7: Database Sharding

*   **Problem:** As data volumes grow rapidly, performance bottlenecks in a single database become more obvious.
*   **Solution:** The database is partitioned either vertically or horizontally.
    *   **Vertical Partitioning:** Splits the database by function (e.g., user database, product database).
    *   **Horizontal Partitioning:** Splits the data in a single table across two or more databases.
*   **Huawei Services:** Previous services plus Distributed Database Middleware (DDM).

### Step 8: Introducing the NoSQL Database

*   **Problem:** Relational databases are not suitable for all scenarios, such as storing unstructured data, key-value pairs, or handling full-text retrieval.
*   **Solution:** Introduce specific NoSQL solutions for these scenarios, like MRS HDFS for massive files or MRS HBase for key-value data.
*   **Huawei Services:** MapReduce Service (MRS), Data Warehouse Service (DWS), Document Database Service (DDS).

### Step 9: Asynchronous Decoupling with Message-oriented Middleware

*   **Problem:** Systems become complex and tightly coupled, making development and maintenance difficult.
*   **Solution:** Use message queues for reliable and asynchronous communication between distributed applications, which decouples the systems.
*   **Huawei Service:** Distributed Message Service (DMS).

### Step 10: Nearby Access and Content Decoupling with CDN

*   **Problem:** Users who are far away from the central data center experience high latency and poor user experience.
*   **Solution:** Static resources (images, CSS, JS files) are cached on CDN (Content Delivery Network) nodes, allowing users to obtain them from the nearest equipment room.
*   **Huawei Service:** Content Delivery Network (CDN).

### Step 11: Multi-site and Multi-active for Improved DR Capabilities

*   **Problem:** A system deployed in a single site cannot handle large-scale access and is vulnerable to regional disasters.
*   **Solution:** Deploy the system in an active-active configuration across multiple sites (data centers) to improve concurrency and availability.
*   **Huawei Services:** ELB, CBR (Cloud Backup and Recovery), RDS (primary/standby).

### Step 12: Microservice

*   **Problem:** Monolithic applications are difficult to upgrade and iterate.
*   **Solution:** The application is broken down into small, independently deployable microservices. 

Containerization and 

Service Meshes  are key technologies in this transformation.
*   **Huawei Services:** FusionStage (microservice development framework) , CCE (Cloud Container Engine), CCI (Cloud Container Instance) , ASM (Application Service Mesh).

## 3. Key Services and Acronyms for the Exam

**ECS (Elastic Cloud Server):** A basic computing component consisting of vCPUs, memory, OS, and EVS disks.

**VPC (Virtual Private Cloud):** Enables you to provision logically isolated, private virtual networks for cloud resources.

**ELB (Elastic Load Balance):** Distributes traffic across multiple servers based on a configured algorithm.

**RDS (Relational Database Service):** A reliable, scalable, and easy-to-manage cloud-based relational database service.

**OBS (Object Storage Service):** A cloud storage service optimized for storing massive amounts of data.

**DCS (Distributed Cache Service):** A managed cache service that reduces read/write I/O and speeds up system responses.

**CDN (Content Delivery Network):** A service that caches static resources on nodes close to users to speed up access.

**IAM (Identity and Access Management):** A basic service that provides permissions management to securely control access to your cloud services.

**CTS (Cloud Trace Service):** Records operations on the cloud resources in your account for security analysis and auditing.

**CES (Cloud Eye):** A multi-dimensional monitoring platform that monitors resources like ECSs and bandwidth. 

---

# Lecture Notes 2: Cloud Compute Solution Design
This document covers the features and selection criteria for Huawei Cloud's core compute services, including Elastic Cloud Server (ECS), Bare Metal Server (BMS), and Dedicated Host (DeH). It also discusses storage solutions and applies the five principles of architecture design to compute solutions.


## 1. Huawei Cloud Compute Services
Huawei Cloud offers a range of compute services, including VMs (ECS), physical servers (BMS, DeH), and containers (CCE, CCI).


### Elastic Cloud Server (ECS)

**Definition:** An ECS is a scalable, on-demand computing cloud server designed for secure, flexible, and efficient applications. It treats servers as elastic compute resources.

#### Instance Flavor Naming (e.g., C6.8xLarge.4):

*   **Instance Type:** A letter indicating the primary use case (e.g., `c` for computing, `m` for memory-optimized).
*   **Instance Generation:** A number indicating the hardware generation (e.g., 6 for sixth-generation). A larger number is generally newer and more cost-effective.
*   **Instance Specifications:** The number of vCPUs (e.g., `8xlarge`).
*   **Memory/vCPU Ratio:** A digit representing the ratio of memory to vCPUs (e.g., `4` means 4 GiB of memory per vCPU).

#### Instance Selection:

*   Select an instance type based on the features of the components running on it, not the industry.
*   For elasticity and smaller blast radius, using multiple low-specification servers is often better than a few high-specification ones.
*   You can easily change an instance type or purchase a new ECS if the initial selection is inappropriate.
*   Continuously monitor resource usage to find opportunities for optimization.

#### ECS Initialization: 
There are two main methods to initialize an ECS.

##### 1. Using an Image (IMS):
An image is a template containing an OS and other configurations to create identical ECSs.

###### Image Types:

*   **Public Image:** Standard, thoroughly tested images provided and maintained by Huawei Cloud.
*   **Private Image:** Created from your own ECS, allowing for custom software installation. You are responsible for its security.
*   **Shared Image:** Private images shared by another user. You must trust the sharer, as they are responsible for the image's security.
*   **Marketplace Image:** Third-party images with pre-installed applications, available in KooGallery.

##### 2. Using Scripts (User Data):
*   You can inject user-defined data (scripts) in formats like Bash or PowerShell to initialize a server.
*   The script executes only once when the server is first started. Modifying the script on a started server has no effect.
*   The maximum script size is 32 KB; for larger scripts, store them in OBS and download them to run.

#### Images vs. Scripts:

*   **Private Images:** Are fast to start up but are slow to update and incur storage costs.
*   **Initialization Scripts:** Are flexible and easy to update but can be slow for complex initializations and require higher technical skill to write.
*   **Best Practice:** Use a combination. Use images for stable, infrequently changed components, and use scripts to inject dynamic content.

### Storage Options for Compute

*   **Local Disks:** Provide ultra-low latency and very high IOPS but have lower data reliability. They are suitable for temporary data that can be restored, such as swap files or caches.

#### Comparison of EVS, SFS, and OBS:

*   **Working Model:** EVS is block storage (used as disks); SFS is file storage (accessed via network); OBS is object storage (accessed via APIs).
*   **Reliability:** EVS offers 99.9999999% reliability; SFS offers 99.99999999%; OBS offers 99.9999999999%.
*   **Use Case:** EVS is for workloads on traditional disks; SFS is for file sharing and content management; OBS is for large-scale data storage, big data sources, and data distribution.

### Dedicated Host (DeH)

**Definition:** A physical server fully dedicated to a single user, providing a single-tenant environment. It ensures performance and security by keeping compute resources isolated.

#### Features:

*   **Exclusive:** Hosts only your ECSs, ensuring high performance and stability.
*   **Flexible:** Allows you to scale up ECSs on the DeH to improve resource utilization.
*   **Cost-effective:** Allows you to use existing server-bound software licenses (BYOL) to keep costs down.

### Bare Metal Server (BMS)

**Definition:** A dedicated physical server in a single-tenant environment that has no virtualization overhead. It combines the scalability of ECSs with the stability of physical servers.

#### Features: 
Can be provisioned within 5 minutes, can communicate with ECSs in the same VPC, and supports shared EVS disks via SDI technology for applications like Oracle RAC.

#### Application Scenarios: 
Core databases, high-performance computing (HPC), big data, and services requiring high security like government and finance applications.

## 2. Five Principles of Compute Solution Design

### Security:

*   **Access Control:** Use key pairs for login (Recommended) instead of passwords.
*   **Data Security:** Encrypt data at rest with EVS encryption and data in transit with HTTPS.
*   **Network Security:** Control traffic using VPCs and security groups. Use Host Security Service (HSS) to defend against DDoS attacks.
*   **Auditing:** Use Log Tank Service (LTS) for log collection and management.

### Reliability:

*   Because an individual ECS is on a single node, solution-level reliability is essential.
*   Deploy servers in a cluster across different Availability Zones (AZs).
*   Use Elastic Load Balance (ELB) to distribute traffic to ECSs across AZs.
*   Use ECS group anti-affinity to ensure ECSs are deployed on different physical hosts.

### Performance:

*   Match the instance type to the feature of the component running on it.
*   Be aware that network latency within an AZ is different from (and lower than) latency across AZs.
*   Use Cloud Eye to monitor server performance.

### Cost-Effectiveness:

*   Choose the appropriate instance type and scale.
*   Select the correct billing mode (e.g., pay-per-use, yearly/monthly).
*   Use Auto Scaling to dynamically adjust the number of servers based on traffic.
*   Stop ECSs when not in use, but remember that attached EVS disks and EIPs will continue to be billed.
*   Continuously monitor resource usage to optimize costs.

### Maintainability (O&M):

*   O&M responsibilities include ECS management, applying operating system patches, upgrading application software, and performing data and host backups. 

---

# Lecture Notes 3: Cloud Storage Solution Design
This document provides an overview of Huawei Cloud's storage services, focusing on Object Storage Service (OBS), Elastic Volume Service (EVS), and Scalable File Service (SFS). It details their features and explains how to design storage solutions using the five architectural principles.

## 1. Huawei Cloud Storage Services Overview
### Object Storage Service (OBS)
OBS is a secure, highly reliable, and cost-effective cloud storage service for storing massive amounts of unstructured data, such as documents, images, and videos.

#### Core Concepts:

*   It is a fully managed service accessible over the Internet via REST APIs.
*   **Bucket:** The basic management unit in OBS where objects are stored.
*   **Object:** The logical unit of storage. An object consists of a **Key** (a unique name within the bucket), **Metadata** (descriptive key-value pairs), and **Data** (the content itself).

#### Reliability & Availability:

*   OBS provides 99.9999999999% (12 nines) data reliability and up to 99.995% service availability.
*   This is achieved through mechanisms like erasure codes, multi-AZ deployment, and cross-region replication.

#### Key Features:

##### Permission Control: 
By default, all OBS buckets and objects are private. Access can be granted using:

*   **Bucket Policies:** Specify which operations a specified user can perform on buckets and objects.
*   **ACLs (Access Control Lists):** Grant basic read/write permissions at the account level.
*   **Signed URLs:** Grant temporary access to private objects for a specified validity period.

##### Versioning:

*   When enabled, OBS automatically creates a unique version ID for each uploaded object, protecting against accidental deletions or overwrites.
*   When a versioned object is deleted, OBS inserts a "delete marker" instead of permanently removing it, allowing for recovery.

##### Storage Classes & Lifecycle Management:

*   **Standard:** For frequently accessed data. It offers flexible access but is the highest-priced tier.
*   **Infrequent Access:** For data that is not accessed frequently, such as backups and active archives. It is less expensive than Standard storage.
*   **Archive:** The least expensive class, designed for long-term data that is seldom accessed. Data must be restored before it can be retrieved.
*   **Lifecycle Policies:** Can be configured to automatically transition objects to more cost-effective storage classes over time (e.g., from Standard to Archive).

##### Cross-Region Replication: 
Allows for automatic, asynchronous replication of data between buckets in different regions, which is useful for disaster recovery and regulatory compliance.

##### Static Website Hosting: 
OBS can be used to host a static website.

### Elastic Volume Service (EVS)

**Definition:** EVS provides persistent, high-performance, and scalable block storage that functions as disks for ECS and BMS.

*   **Reliability:** Achieves 99.9999999% (9 nines) reliability through a single-AZ, three-copy redundancy mechanism.
*   **Disk Types:** EVS offers multiple disk types to balance performance and cost.
    *   **Extreme SSD:** For workloads demanding ultra-high bandwidth and ultra-low latency, like heavy-loaded databases.
    *   **Ultra-high I/O:** For I/O-intensive applications and high-performance system disks.
    *   **General Purpose SSD:** A cost-effective option suitable for most enterprise workloads.
    *   **High I/O:** An entry-level option suitable for workloads with unstable pressure, such as boot disks.

### Scalable File Service (SFS)

**Definition:** SFS provides a fully hosted, shared file storage that can be accessed by multiple ECSs, BMSs, and containers simultaneously.

*   **Protocols:** Supports standard NFS and CIFS protocols.
*   **SFS Turbo:** An enhanced edition that provides higher performance for demanding workloads. Use cases include AI training, gene analysis, and video rendering.

## 2. Five Principles of Storage Solution Design
### Security:

*   **Data Protection:** Use server-side or client-side encryption for data at rest and secure transfers (HTTPS) for data in transit.
*   **Access Control:** Manage permissions using ACLs and bucket policies.
*   **Auditing:** Enable bucket logging to track and analyze access records.

### Reliability:

*   Enable versioning for OBS buckets to protect against accidental data loss.
*   Create regular backups of EVS and SFS data.
*   Use OBS cross-region replication for disaster recovery.
*   Choose services with appropriate availability SLAs (e.g., EVS and SFS at 99.95%, OBS tri-AZs at 99.995%).

### Performance:

*   For OBS, avoid performance bottlenecks ("hot partitions") by using random prefixes for object names instead of sequential ones (e.g., timestamps).
*   For EVS and SFS, select the disk or file system type that matches the workload's IOPS, throughput, and latency requirements.

### Cost-Effectiveness:

*   Select the proper OBS storage class based on data access frequency (Standard, Infrequent Access, or Archive).
*   Use OBS lifecycle policies to automatically move data to cheaper storage tiers as it ages.
*   Avoid unnecessary API calls to OBS to reduce request costs.
*   Remember that for OBS, inbound traffic is free, but you are billed for storage usage, outbound traffic, requests, and data retrieval.

### Maintainability:

*   Services like OBS are fully managed, requiring little maintenance from the user.
*   Key maintenance tasks include managing historical versions if versioning is enabled and regularly reviewing access logs and permissions. 

---

# Lecture Notes 4: Cloud Network Solution Design
This document details Huawei Cloud's network services and explains how to design solutions for various communication scenarios, including within VPCs, between VPCs, between cloud and on-premises networks, across regions, and to the Internet.

## 1. VPC and Subnet Design (Intra-VPC Communication)
### Virtual Private Cloud (VPC):

*   **Definition:** A VPC is a logically isolated, configurable, and manageable virtual network on Huawei Cloud. It acts as a private, software-defined network for your resources.
*   **VPC Planning:**
    *   **Number of VPCs:** Use a single VPC for simple applications with small teams and service volume. Use multiple VPCs to isolate different services, environments (e.g., production and test), or for different teams/organizations.
    *   **Region:** Select the region that is nearest to your users to minimize latency. VPCs are region-specific.
    *   **CIDR Block:** Choose a CIDR block from private IP ranges (e.g., 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16). Ensure the block is large enough for future expansion and does not conflict with on-premises or other connected VPCs.

### Subnets:

*   **Definition:** A subnet is a range of IP addresses within your VPC where resources must be deployed.
*   **Subnet Planning:**
    *   The CIDR blocks of subnets within a single VPC cannot overlap.
    *   Five IP addresses in each subnet are reserved by the system for functions like the network address, gateway, and broadcast address.
    *   It's a best practice to deploy nodes with the same function in the same subnet for better management.

### Route Tables:
A route table contains rules that determine where network traffic from your subnets is directed. Each subnet must be associated with one route table.

## 2. Connectivity Scenarios and Solutions
### Cloud-to-Internet Communication

*   **Elastic IP (EIP):** A public IPv4 address that can be bound to an ECS, load balancer, or NAT gateway to enable Internet access.
*   **NAT Gateway:** Provides Network Address Translation, allowing multiple servers in a VPC to share an EIP to access the Internet or provide services to the Internet.
    *   **SNAT (Source NAT):** Allows servers in a VPC to initiate outbound connections to the Internet without exposing their private IP addresses.
    *   **DNAT (Destination NAT):** Maps an EIP and port to a private server IP and port, allowing a specific internal service to be securely exposed to the Internet.
*   **Domain Name Service (DNS):** A highly available service that translates domain names into IP addresses.
    *   **Public DNS:** Translates public domain names for routing traffic over the Internet.
    *   **Private DNS:** Maps domain names to private IP addresses for use within one or more VPCs, which helps to reduce service coupling.

### Cloud-to-On-Premises Communication (Hybrid Cloud)

*   **Virtual Private Network (VPN):** Establishes an encrypted IPsec tunnel over the public Internet to connect an on-premises data center to a VPC. It is easy to configure and can be used out-of-the-box.
*   **Direct Connect:** Provides a stable, reliable, and dedicated physical connection between your on-premises data center and Huawei Cloud. It offers higher performance and lower latency than VPN but requires more time to provision.

### Across-VPC Communication (Single Region)

*   **VPC Peering:** Connects two VPCs in the same region, allowing them to communicate using private IP addresses as if they were in the same network. The CIDR blocks of the two VPCs cannot overlap.
*   **VPC Endpoint (VPCEP):** Provides a secure and private channel to connect a VPC to a specific endpoint service (e.g., OBS, or a service in another VPC) without exposing the entire network. Unlike peering, VPCEP allows CIDR blocks to overlap and provides more granular, one-way access control.
*   **Enterprise Router:** A cloud router that connects multiple VPCs and on-premises networks. It uses BGP to learn routes dynamically, which simplifies network topology and maintenance compared to managing multiple VPC peering connections.

### Across-Region Communication

*   **Cloud Connect:** A service that builds high-speed, high-quality private networks between VPCs in different regions. It leverages Huawei's global network infrastructure for low-latency, compliant, and secure data transmission.

## 3. Five Principles of Network Architecture
### Security:

*   Use security groups and network ACLs to implement the principle of minimal network openness.
*   Encrypt dynamic data in transit using protocols like TLS and IPsec.
*   Use LTS to collect VPC flow logs for auditing.

### Reliability:

*   Key components like NAT gateways and VPN gateways have built-in high availability or can be deployed across multiple AZs.
*   For maximum reliability between on-premises and the cloud, you can combine Direct Connect and VPN connections for an active/standby setup.

### Performance:

*   Monitoring is key to understanding network performance.
*   Latency and bandwidth are the two main factors to consider in cloud network performance.
*   While the VPC itself is not a bottleneck, services like NAT gateways and VPN gateways have performance limitations that must be considered.

### Cost-Effectiveness:

*   Core VPC components are free, but gateways (VPN, NAT) and endpoints are charged.
*   Bandwidth expenditures should be carefully evaluated.
*   Optimize traffic costs by using services like CDN and planning Direct Connect bandwidth carefully.

### Maintainability:

*   Plan network addresses carefully to avoid IP address conflicts, which create connectivity challenges.
*   Use automatic deployment tools and scripts to reduce errors and check for configuration changes.
*   Use VPC flow logs to help track access status and troubleshoot issues. 

---

# Lecture Notes 5: Cloud Database Solution Design
This document provides an overview of Huawei Cloud's database services, data caching strategies, and the key principles for designing robust, scalable, and cost-effective database solutions.

## 1. Database Fundamentals and Selection

### Database Selection: 
Choosing the right database depends on the data structure (structured vs. unstructured) and application requirements (consistency, scalability, transactions).

#### Relational (SQL) vs. Non-Relational (NoSQL):

*   **Relational (SQL):** Best for structured data requiring strong consistency and transaction support. It primarily uses vertical scaling (scaling up). Examples include MySQL and PostgreSQL.
*   **Non-Relational (NoSQL):** Best for semi-structured or unstructured data, focusing on high-performance reads and writes. It excels at horizontal scaling (scaling out) using clusters. Consistency is often eventual but can be configured. Examples include MongoDB and Redis.

**Deployment Evolution:** Moving to the cloud shifts responsibilities from the user to the provider. A cloud-native database deployment (like RDS) handles everything from physical maintenance to patching, allowing users to focus on database optimization and development.

## 2. Huawei Cloud Database Services
### Relational Database Services

*   **Relational Database Service (RDS):** A managed online database service that supports MySQL, PostgreSQL, and SQL Server engines. It can be deployed in a single or primary/standby configuration for high availability (HA) and provides features like backup, restoration, and elastic scaling.
    *   **High Availability (HA):** RDS instances can be deployed in a primary/standby configuration, either within a single Availability Zone (AZ) or across different AZs for greater fault tolerance.
    *   **Read Replicas:** To handle high read traffic, you can add read replicas to an RDS instance, scaling out the read capability of the database.
*   **GaussDB:** An enterprise-grade distributed relational database developed by Huawei. It features a hybrid transactional/analytical processing (HTAP) architecture and supports petabytes of storage with high performance and strong consistency.

### Non-Relational (NoSQL) Database Services

*   **Document Database Service (DDS):** A managed database service that is 100% compatible with the MongoDB protocol. It can be deployed as a single node, a replica set (for HA), or a cluster (for HA and scalability).
*   **GeminiDB:** A distributed, multi-model NoSQL service built on a cloud-native architecture with decoupled compute and storage.
    *   It is compatible with multiple APIs, including Redis, MongoDB, Cassandra, and InfluxDB.
    *   Its decoupled architecture allows for flexible online scaling of compute and storage resources without service interruptions.

### Database Scalability and Replication

*   **Scaling Challenges:** A single-node database architecture faces challenges in scaling storage, scaling compute, and ensuring reliability.
*   **Distributed Database Middleware (DDM):** A MySQL-compatible middleware service that solves distributed database scaling challenges. It provides capabilities like automatic database/table sharding and read/write splitting, making a complex distributed architecture appear as a single database to the application.
*   **Data Replication Service (DRS):** Enables database migration to the cloud with minimal downtime. It supports both real-time migration and continuous data synchronization for homogeneous and heterogeneous databases.
*   **UGO (Database and Application Migration):** A tool that specializes in heterogeneous database migration by evaluating and converting database schemas and application SQL syntax.

## 3. Data Caching

**Purpose of Caching:** Caching is used to speed up data access and reduce the load on backend systems by storing frequently accessed data in a faster, temporary storage layer.

### Caching Services:

*   **Content Delivery Network (CDN):** Caches static content (e.g., images, videos) at edge locations (PoPs) closer to users.
*   **Distributed Cache Service (DCS):** A managed, online, distributed in-memory cache service compatible with Redis.
*   **GeminiDB Redis API:** A cloud-native, distributed cache service that is fully compatible with Redis and offers enterprise features like enhanced reliability and flexible scaling.

### Caching Patterns:

*   **Write-Through:** The application writes to the cache and the database simultaneously. This keeps data consistent but adds latency to writes.
*   **Lazy Loading (Cache-Aside):** The application reads from the cache; if there is a cache miss, it reads from the database and then writes the result to the cache. This can lead to stale data but only required data is cached.
*   **Handling Stale Data:** You can configure an appropriate Time To Live (TTL) for cached items to minimize the duration of data inconsistency.

## 4. Database Solution Design Principles

*   **Security:** Encrypt data at rest and in transit. Use VPCs to control network security and enable only necessary ports. Avoid storing database passwords in plaintext.
*   **Reliability:** Choose a cluster or primary/standby deployment based on requirements. Configure a proper backup policy and test the recovery plan.
*   **Performance:** Monitor performance to identify bottlenecks. Use caching to fundamentally improve performance. For NoSQL databases, design keys carefully to avoid "hot keys" or "hot partitions".
*   **Cost-Effectiveness:** Evaluate the unit price and performance of different database engines. Stop unnecessary instances (like read replicas) to reduce costs. Optimize the architecture by using caches and adjusting data design.
*   **Maintainability:** Use cloud-native database services to reduce maintenance complexity. Use primary/standby deployment to minimize downtime during maintenance. 

---

# Lecture Notes 6: Cloud Security Solution Design
This document provides a comprehensive overview of Huawei Cloud's security services and model. It explains how to design a secure solution by layering protections across the access, application, and data layers, as well as implementing robust access control and auditing.

## 1. Security Model and Principles
*   **Shared Responsibility Model:** Security is a shared responsibility. Huawei Cloud is responsible for the security *of* the cloud (e.g., physical infrastructure, virtualization), while the customer is responsible for security *in* the cloud (e.g., data encryption, IAM configurations, application security, OS patching).
*   **Systematic Security Design:** A holistic security design involves multiple layers and areas of focus, including network and application security, access control, data security, audit and tracking, and incident response.

## 2. Access Layer Network Security
This layer focuses on protecting the network perimeter from external threats.

### VPC Access Control:

*   **Security Groups:** Act as a stateful virtual firewall for resources like ECSs. By default, they deny all inbound traffic and allow all outbound traffic. It is a best practice to use different security groups for different application layers (e.g., web, application, database).
*   **Network ACLs:** An optional, stateless firewall layer for subnets that controls traffic in and out of them. Rules are evaluated by priority, and by default, all traffic is denied.

### DDoS Protection:

*   **Anti-DDoS (Basic):** Provides free, automatic protection against network- and transport-layer DDoS attacks for all Huawei Cloud users. It works by detecting and scrubbing attack traffic before it reaches your resources.
*   **Advanced Anti-DDoS (AAD):** A premium service that uses high-defense IP addresses to proxy and protect origin servers from large-scale DDoS attacks.

### Web Application Firewall (WAF):

*   **Definition:** Protects web applications by inspecting HTTP/HTTPS traffic and filtering out malicious requests like SQL injections, cross-site scripting (XSS), and CC attacks.
*   **WAF + AAD:** For comprehensive protection, AAD and WAF should be used together. Traffic first goes to AAD to scrub DDoS attacks (Layers 3/4), and the clean traffic is then sent to WAF to filter web application attacks (Layer 7).

## 3. Application Security
### Host Security Service (HSS):

*   **Definition:** A service designed to protect server workloads by providing asset management, vulnerability detection, intrusion detection, and web tamper protection.
*   **Functions:** Detects vulnerabilities in real-time, checks for unsafe configurations, identifies intrusions like brute-force attacks and ransomware, scans container images, and protects web pages from being tampered with.

## 4. Access Control Security
This layer ensures that only authorized users and services can access resources.

### Identity and Access Management (IAM):

*   **Definition:** Provides centralized permissions management to securely control access to cloud services and resources.
*   **Best Practices:**
    *   Do not use the root account for routine tasks; instead, create individual IAM users.
    *   Organize users into groups for easier permission management.
    *   Apply the principle of least privilege (POLP).
    *   Enable login protection (MFA) for all accounts.
*   **Agency:** Enables you to delegate permissions to other Huawei Cloud accounts or services without using long-term static credentials like Access Keys (AK/SK). This is the recommended way to grant permissions to applications running on an ECS.

### Cloud Bastion Host (CBH):

*   **Definition:** A centralized O&M security service that provides unified asset management, access control, and operation auditing for servers, databases, and network devices.
*   **Use Cases:** Manages assets with role-based permissions, monitors O&M behavior in real-time, and logs all commands for auditing to meet compliance requirements.

## 5. Data Layer Security
This layer focuses on protecting data both at rest and in transit.

### Data Encryption Workshop (DEW):

*   **Key Management Service (KMS):** Uses envelope encryption to protect data. A Data Encryption Key (DEK) encrypts the data, and a Customer Master Key (CMK) encrypts the DEK. CMKs are managed within DEW and never leave the service unencrypted.
*   **Cloud Secret Management Service (CSMS):** Provides centralized storage for secrets like database passwords. It can be integrated with IAM agencies to create a "keyless architecture" where applications retrieve secrets programmatically instead of storing them in configuration files.
*   **Cloud Certificate Manager (CCM):** Provides one-stop lifecycle management of SSL certificates to enable secure HTTPS data transmission.
*   **Database Security Service (DBSS):** An intelligent security service that audits databases, detects SQL injection attacks, and identifies high-risk database operations.

## 6. Audit, Tracking, and Incident Response

*   **Cloud Trace Service (CTS):** Records API calls and operations on cloud resources, providing a trail for auditing, security analysis, and fault diagnosis.
*   **SecMaster:** A cloud-native security operations platform that integrates data from various security services to provide centralized asset management, security situation awareness, threat analysis, and automated security orchestration and response (SOAR). 

---

# Lecture Notes 7: Cloud O&M Solution Design
This document describes how to build and optimize a cloud Operations and Maintenance (O&M) system using Huawei Cloud's multi-dimensional O&M solution. It focuses on key services like Cloud Eye, APM, AOM, and LTS, and introduces concepts for automated O&M.

## 1. O&M Challenges and Huawei Cloud's Approach

*   **O&M Pain Points:** Traditional O&M for cloud environments is challenging due to complex service systems, insufficient automation, and low system observability, which leads to slow fault response times.
*   **Huawei Cloud O&M Panorama:** Huawei Cloud provides a one-stop, multi-dimensional O&M solution that monitors everything from infrastructure (like CPU usage) to application performance and business-layer data. The core of this solution is the combination of Cloud Eye, Application Performance Management (APM), Application Operations Management (AOM), and Log Tank Service (LTS).

## 2. Key O&M Services
### Cloud Eye

*   **Definition:** A multi-dimensional resource monitoring service used to monitor resources, set alarm rules, identify exceptions, and respond to resource changes.
*   **How it Works:** Cloud Eye automatically collects metrics from cloud resources (ECS, EVS, VPC). An agent can be installed for deeper OS-level monitoring. Based on alarm rules, it can trigger notifications via Simple Message Notification (SMN) or actions like Auto Scaling.
*   **Scenarios:** Used for monitoring cloud services, servers, and websites. It enables alarm-based O&M for identifying performance issues and triggering capacity expansion.

### Application Performance Management (APM)

*   **Definition:** APM helps detect and diagnose performance problems in distributed microservice architectures to improve user experience.
*   **Key Capabilities:**
    *   **Full-link Topology:** Displays application call and dependency relationships visually.
    *   **Tracing:** Monitors response times, call counts, and errors to locate performance bottlenecks and faults.
    *   **Transaction Analysis:** Analyzes real-time service flows and KPIs like throughput and latency.
*   **How it Works:** APM uses non-intrusive agents (for Java, PHP, .NET, etc.) that are deployed on servers to automatically discover application call relationships and collect performance data without code modification.
*   **Scenarios:** Diagnosing application exceptions by reproducing problems and locating root causes in code; and managing application experience by analyzing performance KPIs.

### Log Tank Service (LTS)

*   **Definition:** A service that collects, analyzes, and processes massive log volumes from hosts and cloud services in real-time.
*   **Functions:** Provides log search (keyword and SQL), visualization, real-time analysis, and intelligent log clustering. Logs can be transferred (dumped) to OBS for long-term storage.
*   **LTS vs. CTS:** LTS focuses on centralized log management for performance analysis and troubleshooting. Cloud Trace Service (CTS) focuses on auditing and compliance of cloud resource operations.

### Application Operations Management (AOM)

*   **Definition:** A one-stop O&M platform that monitors resources, applications, and user experience from multiple dimensions. It provides a more comprehensive view by integrating infrastructure and application monitoring.
*   **Architecture:** AOM provides a unified O&M model covering the infrastructure layer (VMs, Networks), platform layer (Databases, Containers), and application layer (Microservices, Processes). It offers a unified dashboard, alarm management, log analysis, and automation capabilities.
*   **Scenarios:**
    *   **Inspection and Problem Demarcation:** Centrally monitors distributed applications that involve multiple cloud services.
    *   **Multi-Dimensional O&M:** Associates resource metrics with application performance data and logs for in-depth fault diagnosis.

## 3. O&M Automation

*   **Challenge:** With increasingly complex systems, manual O&M is costly and inefficient.
*   **Solution:** Automation is needed for tasks like batch password changes, patch installation, and inspections.
*   **Resource Formation Service (RFS):** An Infrastructure as Code (IaC) service that allows you to define and provision cloud resources automatically using templates (in HCL syntax). RFS enables you to create, manage, and upgrade cloud resources efficiently, securely, and consistently. 

---

# Lecture Notes 8: Distributed Architecture Design
This document describes the design of distributed architectures on Huawei Cloud. It covers fundamental concepts, key distributed services, and the application of the five design principles to distributed systems.

## 1. Distributed Architecture Fundamentals

### Why Distributed?: 
As application traffic increases, a single server may become a bottleneck. A distributed architecture is needed to handle higher loads, improve fault tolerance, and reduce dependencies between components.

#### Benefits of Distributed Deployment:

*   Access to a massive resource pool for improved performance.
*   Robust load balancing for stable performance.
*   Better fault recovery when errors occur.

### Loose Coupling: 
A key goal of distributed design is to create a loosely coupled system where components are independent. This avoids a tightly coupled model where every frontend device is connected to every backend device, making the system brittle and hard to manage. Common patterns for loose coupling include:

*   **Using an EIP:** An Elastic IP can hide the private IP of a backend server, allowing requests to be easily redirected to a healthy server if the original one fails.
*   **Message Pub/Sub Model:** Services like Simple Message Notification (SMN) allow components to communicate asynchronously. Publishers and subscribers do not need to know about each other, creating strong decoupling.

## 2. Huawei Cloud Distributed Services
### Elastic Load Balance (ELB)

**Definition:** ELB automatically distributes incoming traffic across multiple backend servers based on configured rules, expanding service capabilities and eliminating single points of failure (SPOFs).

#### Key Concepts:

*   **Stateless Servers:** ELB works best with stateless backend servers. While sticky sessions are an option, they don't fully solve the problems associated with stateful applications.
*   **Health Checks:** ELB performs health checks on backend servers and will stop routing traffic to any server that is determined to be unhealthy.
*   **Load Balancing Algorithms:** ELB supports several algorithms, including:
    *   Weighted round robin
    *   Weighted least connections
    *   Source IP hash
*   **Application Scenarios:** ELB is ideal for heavy-traffic applications, achieving zero SPOFs, and enabling cross-AZ load balancing for high availability.

### Domain Name Service (DNS)

*   **Role in Distributed Systems:** While ELB handles load balancing within a region, DNS is used to achieve load balancing across regions.
*   **Cross-Region Policies:** DNS provides several resolution policies to direct global traffic effectively:
    *   **Weighted Routing:** Distributes traffic to different endpoints based on configured weights.
    *   **Geographic Routing:** Directs users to the nearest access point based on their geographic location, which reduces latency and is critical for disaster recovery designs.

### Distributed Message Service (DMS)

**Definition:** DMS is a fully-managed, high-throughput message queuing service essential for building asynchronous, loosely coupled distributed systems.

*   **Open-Source Compatibility:** DMS is compatible with popular open-source message queues like Kafka, RabbitMQ, and RocketMQ.
*   **DMS Offerings:**
    *   **DMS for Kafka:** Used for high-concurrency, real-time data transmission and stream processing.
    *   **DMS for RabbitMQ:** Used for scenarios like flash sales, message routing, and system decoupling.
    *   **DMS for RocketMQ:** Supports advanced features like ordered messages and transactional messages.
*   **Engine Comparison:** Kafka offers the highest performance (QPS), while RocketMQ provides stronger data consistency using the Raft protocol.

## 3. Five Principles of Distributed Solution Design

*   **Security:** Use VPCs and security groups to control network access and open only necessary ports. Data consistency becomes a critical security consideration in distributed architectures.
*   **Reliability:** While a distributed architecture improves reliability, you must still check for single points of failure. For services like DNS that do not have a built-in health check, you should use an external service like Cloud Eye's website monitoring to perform health checks and trigger switchovers.
*   **Performance:** A distributed architecture has no theoretical capacity limits. However, complex coordination mechanisms and locks can turn a parallel system into a serial one, hurting performance.
*   **Cost-Effectiveness:** A distributed system does not necessarily mean higher costs, as the key is whether the nodes are being utilized effectively. Be sure to delete unused resources like load balancers to manage costs.
*   **Maintainability:** The increased number of nodes in a distributed system requires automated maintenance to reduce pressure and errors. It is critical to monitor the health status of all components and regularly practice recovery plans. 

---

# Lecture Notes 9: Highly Scalable System Design
This document describes how to design and deploy a highly scalable system on Huawei Cloud. It covers the core concepts of scalability, the key enabling services, and the application of the five design principles to a scalable architecture.

## 1. Scalable System Fundamentals

### Why is Scalability Important?: 
Application traffic is rarely constant; it often has predictable daily cycles and unpredictable spikes (e.g., during promotions).

*   A system with fixed resources is wasteful during low-traffic periods and can be overwhelmed during peak traffic, leading to poor user experience or system crashes.
*   Scalability allows you to adjust resources as demand changes to reduce costs and to automatically replace faulty servers to ensure high reliability.

### The AKF Scale Cube: 
A model that defines three axes for scaling a system:

*   **X-axis (Horizontal Duplication):** Cloning instances and data to share and balance traffic. This is achieved with load balancing and data replication.
*   **Y-axis (Functional Decomposition):** Decoupling a system into microservices, allowing individual functions to be scaled independently.
*   **Z-axis (Data Partitioning):** Partitioning services and data based on criteria like region or user lookup.

### Scale-Up vs. Scale-Out:

*   **Scale-up (Vertical Scaling):** Adding more resources (CPUs, memory, etc.) to a single server.
*   **Scale-out (Horizontal Scaling):** Adding more nodes (servers) to a system to process requests.

## 2. Scalable System Design on Huawei Cloud
Achieving scalability involves two key steps: knowing when to scale and then scaling immediately. Huawei Cloud provides dedicated services for each step.

### Perceivable (Knowing when to scale):

*   **Cloud Eye:** This is the monitoring service that perceives changes in the system. It tracks metrics like CPU usage, memory, and network traffic, and can trigger alarms when thresholds are met. These alarms are the signals that initiate scaling actions.

### Scalable (Executing the scaling action):

*   **Auto Scaling (AS):** This service automatically adds or removes resources based on pre-configured policies.
    *   **Key AS Features:**
        *   It can launch or stop ECS instances and adjust EIP bandwidth.
        *   It can detect and automatically replace unhealthy ECSs.
        *   It works with Elastic Load Balance (ELB) to distribute traffic across the healthy ECSs in a scaling group.
        *   It can be deployed across multiple Availability Zones (AZs) to improve availability.
    *   **Scaling Policies:** AS supports multiple policy types to handle different scenarios:
        *   **Alarm-based Policy:** Reactive scaling triggered when a Cloud Eye metric (e.g., CPU usage) crosses a defined threshold.
        *   **Scheduled Policy:** Proactive scaling that performs a one-time action at a specific future time.
        *   **Periodic Policy:** Proactive scaling that performs actions at scheduled intervals or within a recurring time range.
    *   **AS Components:**
        *   **Scaling Group:** A collection of ECS instances that are managed as a logical unit for scaling purposes.
        *   **Scaling Configuration:** A template that defines the specifications (image, flavor, disk, etc.) for new instances that are added to the group.
        *   **Instance Removal Policy:** A set of rules that determines which instances are removed first during a scale-in action (e.g., oldest instances, newest instances).
        *   **Instance Protection:** A setting that can be enabled on specific instances to protect them from being removed during an automatic scale-in.

## 3. Five Aspects of Scalable System Design

*   **Security:** In a scalable system, resource management becomes dynamic. Access logs become the primary way to backtrack changes, and security groups act as identities for dynamically created applications.
*   **Reliability:** Requires cross-AZ deployment and proper health check settings to immediately detect and replace unhealthy nodes.
*   **Performance:** Not all resources can be scaled. A good underlying architecture (e.g., microservices) is critical for performance, and system monitoring is key to tracking it.
*   **Cost-Effectiveness:** Scalability is key to cost efficiency. Configure scaling to automatically add and remove resources based on demand. Continuously monitor resource usage to optimize scaling settings and avoid waste.
*   **Maintainability:** Automation is essential for maintaining a dynamic number of nodes. Nodes should be designed to be stateless to make maintenance and replacement easier. 

---

# Lecture Notes 10: Disaster Recovery System Design
This document describes the fundamentals of High Availability (HA) and Disaster Recovery (DR), outlines different DR solution architectures on Huawei Cloud, and reviews the design principles for creating a robust and resilient system.

## 1. Disaster Recovery Fundamentals
### Core DR Metrics: 
A DR system is measured by two key objectives:

*   **RTO (Recovery Time Objective):** How much time does it take to recover from a disaster? This measures the speed of recovery.
*   **RPO (Recovery Point Objective):** To which point in time can data be recovered? This measures the maximum acceptable amount of data loss.

### HA vs. Fault Tolerance:

*   **High Availability (HA):** The ability of a system to be recovered within a certain period after a disaster, often without manual intervention.
*   **Fault Tolerance:** The ability of a system to continue normal operation from the user's perspective, even when a component fails.
*   **Availability:** Calculated as `Availability = MTBF / (MTBF + MTTR)`.
    *   **MTBF (Mean Time Between Failure):** A measure of reliability.
    *   **MTTR (Mean Time To Recover):** A measure of maintainability.
*   High availability requires both high reliability (high MTBF) and high maintainability (low MTTR).

### Chaos Engineering: 
The discipline of experimenting on a system to build confidence in its ability to withstand turbulent conditions. This involves performing DR drills and fault injection tests in a controlled manner to identify and fix weaknesses before they cause real outages. The "blast radius" of these tests must be controlled to minimize potential impact.

## 2. Disaster Recovery Solution Architectures
### Solution 1: Cold Standby DR

*   **Setup:** A DR site is on the cloud, but the web/app servers are created but not running. The database runs in standby mode with continuous data synchronization. All traffic normally goes to the production site.
*   **Switchover:** If the production site fails, the DR site is started, and DNS is manually or automatically changed to direct traffic to the DR site.
*   **RTO/RPO:** Both RTO and RPO are in the order of minutes. This is an economical DR solution suitable for customers who do not require a very low RTO.

### Solution 2: Hot Standby DR

*   **Setup:** Similar to cold standby, but the web/app servers at the DR site are always running, though they do not serve traffic normally.
*   **Switchover:** Faster than cold standby because servers do not need to be started.
*   **RTO/RPO:** RPO is in minutes, but RTO is lower (almost zero) because the servers are already running.
*   **Use Case:** Suitable for customers who have a high requirement for RTO.

### Solution 3: Application Active-Active DR (Hybrid Cloud)

*   **Setup:** Both the on-premises production site and the cloud DR site are active and serve traffic simultaneously. Intelligent DNS distributes traffic between the two sites.
*   **Switchover:** If one site fails, DNS redirects 100% of the traffic to the healthy site.
*   **RTO/RPO:** RPO is in minutes; RTO is almost zero.
*   **Use Case:** Suitable for customers who demand high reliability and high resource utilization.

### Solution 4: On-Cloud Intra-Region Active-Active DR

*   **Setup:** The entire application is deployed across two AZs in the same region. ELB distributes traffic between the AZs, and RDS is deployed in a multi-AZ configuration.
*   **Switchover:** Fully automatic. ELB health checks detect an AZ failure and redirect all traffic to the healthy AZ.
*   **RTO/RPO:** RPO is zero with synchronous database replication. RTO is in seconds, based on ELB health check timing.
*   **Use Case:** Suitable for customers requiring on-cloud, intra-city DR with zero RPO.

### Solution 5: On-Cloud Two-City Three-Center DR

*   **Setup:** The highest level of DR. It combines an intra-region active-active deployment in a production region with a standby DR center in a second, remote region.
*   **Switchover:** Intra-region failure is handled automatically by ELB. Cross-region DR switchover is triggered via DNS.
*   **RTO/RPO:** RPO is zero for intra-region failures. Cross-region DR has an RPO in minutes and an RTO dependent on DNS propagation.
*   **Use Case:** Guarantees continuity of mission-critical services even in the event of a regional disaster.

## 3. Five Aspects of DR Architecture Design

*   **Security:** Manage and secure backup data, both at rest and in transit. Ensure the DR site itself does not become a security weak point.
*   **Reliability:** Use highly reliable backup plans. Use point-in-time recovery to prevent the replication of errors. Test the monitoring and recovery systems regularly.
*   **Performance:** The core performance metrics are RTO and RPO. The design should be based on business requirements, not just achieving the highest possible performance.
*   **Cost-Effectiveness:** Evaluate the costs of different DR solutions across all phases (normal operation, switchover, post-switchover). Minimize resources that are prepared only for incidents by using scalable services.
*   **Maintainability:** Use the cloud's multi-AZ infrastructure to simplify DR construction. Manage backup data through its lifecycle. Practice the recovery plan. 

---

# Lecture Notes 11: Automated Deployment
This document describes the background, features, and usage of Huawei Cloud's Resource Formation Service (RFS), which enables automated deployment of cloud infrastructure.

## 1. About Automated Deployment

### Deployment Challenges: 
Manually deploying cloud services via the console or command line can lead to several challenges, including exhausting repetition, uncertain reliability, inconsistent documentation, and complex version control.

### Infrastructure as Code (IaC):

*   **Definition:** IaC is the practice of managing and configuring infrastructure by writing code rather than performing manual operations. It uses descriptive text files (e.g., JSON or YAML) that, when processed by tools, create the expected application environment.
*   **Benefits:** IaC leads to less human error, lower costs, rapid deployment, better traceability, consistency across environments, and repeatability.

## 2. Resource Formation Service (RFS)

**Definition:** RFS is Huawei Cloud's service for automated deployment, functioning as a final-state Infrastructure as Code (IaC) engine. It allows you to efficiently, securely, and consistently create, manage, and upgrade cloud service resources in batches.

*   **Technology:** RFS fully supports the industry-standard Terraform, using HashiCorp Configuration Language (HCL) syntax and the Huawei Cloud Provider plug-in.
*   **Core Concepts & How it Works:**
    *   **Template:** A text file (in .tf, .tf.json, or .zip format) written using HCL syntax that describes the desired cloud resources and their dependencies.
    *   **Stack:** A collection of cloud resources managed as a single unit. A stack is created by RFS based on a provided template.
    *   **Process:** A user uploads a template to RFS. The RFS engine reads the template and automatically provisions and configures the specified cloud resources in the correct sequence according to the dependencies defined in the template.

### RFS Templates
#### Obtaining Templates:

*   **Manual Writing:** You can write templates in any text editor, though this can be inefficient.
*   **From Others:** You can use templates shared by others.
*   **Visual Designer:** A graphical tool on the Huawei Cloud console that allows you to create and modify templates by dragging and dropping resource elements onto a canvas. The tool then automatically generates the template code.

#### Key Template Fields:

*   **Provider:** Declares the service provider (e.g., `huaweicloud`) that Terraform will interact with.
*   **Resource:** The most important element, used to declare a resource to be created, such as a VPC (`huaweicloud_vpc`) or an ECS instance (`huaweicloud_compute_instance`).
*   **Data:** A special resource used to query the attributes of existing resources.
*   **Variable:** Defines input parameters, making templates reusable and configurable without modifying the source code.

## 3. Automated Deployment Demo
### Using the Visual Designer
1.  Access the Visual Designer from the RFS console.
2.  Drag resources (e.g., VPC, ECS, EVS) from the resource pane to the design console.
3.  Connect the resources to define dependencies (e.g., drag an ECS into a VPC, or bind an EVS disk to an ECS).
4.  Select each resource and configure its parameters in the attribute panel.
5.  Save the template or click **Create Stack** to deploy the resources.

### Using a TF Script
1.  Access the RFS console and navigate to the template creation page.
2.  Choose to create a template by importing or uploading an existing TF script.
3.  Save the imported template.
4.  Create a stack from the saved template to deploy the resources. 

---

# Lecture Notes 12: Containers and Agility
This document describes Huawei Cloud's container services, the evolution of application architectures toward microservices and serverless, and the agile and DevOps methodologies that enable rapid and reliable software delivery.

## 1. Huawei Cloud Container Services
### Cloud Container Engine (CCE):

*   **Definition:** A high-performance container orchestration and scheduling service that is based on and compatible with Kubernetes and Docker.
*   **Key Features:**
    *   Supports heterogeneous compute infrastructure, including x86, Kunpeng, GPU, and Ascend processors.
    *   Provides high-performance cloud-native networking and comprehensive security features, including a security-hardened container runtime and image scanning.
    *   Can manage large-scale clusters of up to 10,000 nodes.

### Cloud Container Instance (CCI):

*   **Definition:** A serverless container engine that allows you to run containers without creating or managing server clusters.
*   **Key Features:** You focus on your containerized applications while CCI handles the underlying server management. It features per-second billing and fast, second-level elasticity.

### SoftWare Repository for Container (SWR):

*   **Definition:** A service that provides easy, secure, and reliable management of container images throughout their lifecycle.
*   **How it Works:** You can push, pull, and manage Docker images using the SWR console or Docker CLI. SWR works with CCE and CCI to deploy containerized applications.

## 2. Serverless Computing

**Definition:** A cloud computing model where the cloud platform is responsible for managing the infrastructure, allowing developers to focus only on their code (functions). The platform automatically handles scaling based on events and requests.

### Classifications:

*   **Backend-as-a-Service (BaaS):** API-based third-party services that replace core functions in applications.
*   **Function-as-a-Service (FaaS):** An event-driven model where developers deploy small units of code that are triggered by events or HTTP requests.

### FunctionGraph:

*   **Definition:** Huawei Cloud's FaaS platform. It is a serverless function service that allows you to run code without provisioning or managing servers.
*   **Benefits:** Offers extremely low cost with pay-per-use billing, automatic scaling, and event-driven orchestration, simplifying the implementation of microservices.

## 3. Application Architectures & Agile Methodologies
### Architecture Evolution:

*   **Monolithic:** The traditional approach where an application is built as a single, tightly coupled unit. A single change affects the entire system.
*   **Microservices:** An architectural style that structures an application as a collection of small, independently deployable services built around business capabilities. These services communicate over lightweight mechanisms like REST APIs.

### Agile vs. Waterfall:

*   **Waterfall Model:** A rigid, sequential software development process where each phase must be completed before the next begins. It is inflexible and makes responding to change costly.
*   **Agile Development:** A value-driven approach that prioritizes individuals, working software, customer collaboration, and responding to change over rigid processes and documentation.

### DevOps:

*   **Definition:** A culture and practice that emphasizes collaboration and communication between development (Dev) and operations (Ops) teams, combined with automation of the software delivery process.
*   **Lifecycle:** The DevOps lifecycle is a continuous loop of planning, coding, building, testing, releasing, deploying, and O&M, supported by continuous integration and continuous delivery (CI/CD).
*   **Huawei Cloud CodeArts:**
    *   **Definition:** A one-stop DevSecOps platform that provides cloud services covering the entire software lifecycle, from requirements management to deployment and testing.
*   **Gray Release:** A deployment strategy where a new version of an application is first released to a small group of users (a "gray environment") to test its stability and performance before being rolled out to everyone. This minimizes the risk and impact of a potentially faulty release. 

---

# Lecture Notes 13: Huawei Cloud Advanced Services
This document provides a high-level overview of Huawei Cloud's advanced services, focusing on the Big Data, Artificial Intelligence (AI), and Media service portfolios.

## 1. Big Data Services
Huawei Cloud provides a suite of services to handle the entire data lifecycle, from ingestion and storage to processing and visualization.

### MapReduce Service (MRS):

*   **Definition:** An all-in-one big data platform that provides enterprise-grade, Hadoop-based components like Spark, Flink, Kafka, and HBase.
*   **Use Cases:** Suitable for large-scale batch data analysis, real-time stream processing, and large-scale data storage where fast queries are needed.

### Data Lake Insight (DLI):

*   **Definition:** A serverless stream processing, batch processing, and interactive analysis service.
*   **Key Features:** It is fully compatible with Apache Spark, Flink, and Presto. Its serverless nature means users can analyze data using standard SQL without managing any underlying infrastructure.

### GaussDB (DWS):

*   **Definition:** An online Data Warehouse Service (DWS) that is scalable, fully-managed, and out-of-the-box.
*   **Key Features:** It offers high performance, capable of responding to queries on trillions of data records within seconds. It is easy to use and provides high reliability with support for ACID transactions.

### DataArts Studio:

*   **Definition:** A one-stop data development and operations platform for managing the entire data lifecycle.
*   **Functions:** Provides tools for data integration, development, governance (data quality, security, etc.), and data services, helping enterprises quickly build data operations capabilities.

## 2. Artificial Intelligence (AI) Services
### ModelArts:

*   **Definition:** A one-stop AI development platform designed for developers and data scientists of all skill levels.
*   **Key Features:** It enables users to rapidly build, train, and deploy models anywhere, from the cloud to the edge, and manage the full-lifecycle AI workflow. It supports both mainstream engines like TensorFlow and PyTorch and Huawei-developed engines like MindSpore.
*   **Lifecycle Management:** ModelArts provides tools for every step of the AI development process, including data management (auto-labeling), algorithm development (Notebooks), model training (distributed training), and model deployment (real-time and batch services).
*   **Pangu Models:** Large-scale, pre-trained AI models offered by Huawei Cloud for a variety of tasks, including CV (Computer Vision), NLP (Natural Language Processing), and multimodal applications.

## 3. Media Services
### Huawei Cloud Workspace:

*   **Definition:** A cloud office solution that provides secure, flexible, and easily managed cloud desktops and application streaming.
*   **Advantages:** It enhances data security by keeping data on the cloud instead of on-premises devices, allows employees to work conveniently from anywhere, and provides flexible resources that can be scaled on demand.

### Huawei Cloud Meeting:

*   **Definition:** A professional cloud conferencing service for digital collaboration, combining Huawei's expertise in audio and video technology.
*   **Use Cases:** Supports a wide range of scenarios, from routine office meetings to large administrative conferences, enterprise training, and industry applications like telemedicine.

### Huawei Cloud Live:

*   **Definition:** An end-to-end livestreaming solution that provides functions for stream ingestion, transcoding, recording, and low-latency distribution for high-concurrency scenarios.

### MetaStudio:

*   **Definition:** A platform with a scenario-specific production pipeline for creating 3D digital content.
*   **Core Services:** Offers four main services: Modeling, Asset Management, Editing (via cloud workstations), and Rendering (real-time cloud-native rendering).
*   **Production Pipelines:** Supports the production of virtual humans, virtual livestreaming, 3D enterprise spaces, and virtual-physical integration content. 