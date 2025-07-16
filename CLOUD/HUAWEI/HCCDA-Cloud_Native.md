# Lecture Notes 1: Overview of Cloud Native Architectures

This document covers the history and definition of cloud native, its core technologies and principles, and an overview of the Huawei Cloud Native solution.

## 1. The Development and Definition of Cloud Native

**Evolution of Cloud Computing:** Cloud technology has evolved from non-virtualized hardware (2000) through virtualization (VMware, 2001), IaaS (AWS, 2006), PaaS (Heroku, 2009), open-source IaaS/PaaS (OpenStack, Cloud Foundry), and finally to containers (Docker, 2013) and the formal concept of cloud native (2015).

### Pivotal's Definition of Cloud Native:

Matt Stine of Pivotal first proposed the concept in 2013. His initial (2015) definition included five key characteristics: Twelve-Factor Apps, Microservices, Self-service agile infrastructure, API-based collaboration, and Antifragility.

Pivotal's current view defines cloud native as an approach to developing and running applications that uses modern architectures (microservices, serverless), embraces DevOps and CI/CD, and leverages core technologies like containers and Kubernetes. It's about how applications are created and deployed, not where.

### CNCF's Definition of Cloud Native:

The Cloud Native Computing Foundation (CNCF) was founded in 2015. Its initial definition focused on a stack that was containerized, microservices-oriented, and dynamically orchestrated.

The current (2018) CNCF definition states: "Cloud native technologies empower organizations to build and run scalable applications in modern, dynamic environments such as public, private, and hybrid clouds." Key technologies that exemplify this approach include containers, service meshes, microservices, immutable infrastructure, and declarative APIs.

## 2. Core Cloud Native Technologies

**Containers:** Package an application and its dependencies, allowing it to be encapsulated once and run anywhere. This provides portability, agility (fast startup), and higher productivity.

**Kubernetes Declarative APIs:** Kubernetes uses declarative APIs where users declare the desired state of the system, and Kubernetes works to achieve that state. This is a new language for describing distributed architectures.

**Service Mesh:** A dedicated infrastructure layer that provides non-intrusive management of communications between applications. It separates service code from the distributed framework, allowing for fine-grained traffic governance (e.g., grayscale releases) and observability.

**Microservices:** An architectural style where applications are broken down into a suite of small, independent, and loosely coupled services built around business capabilities. This makes applications easier to deploy and maintain.

**DevOps:** A culture and practice that emphasizes collaboration between Development (Dev) and Operations (Ops) teams. It integrates the software lifecycle into a continuous cycle of planning, coding, building, testing, releasing, deploying, and monitoring.

## 3. Cloud Native Applications

**Definition:** Cloud native applications are built specifically for the cloud model to leverage its benefits. They are typically containerized, use a microservices architecture, and are delivered via a DevOps and CI/CD toolchain.

**12-Factor App:** A methodology for building SaaS applications that are reliable, scalable, and easy to maintain on cloud platforms. Key principles include storing configuration in environment variables, treating backing services as attached resources, and minimizing divergence between development and production environments.

## 4. Principles of Cloud Native Architectures
Cloud native architectures evolve based on five key principles:

**Elasticity:** Services are designed to be stateless, allowing for on-demand resource usage and automatic horizontal scaling.

**Distribution:** Service logic is decoupled from data and sessions, allowing data to be distributed and deployed across AZs.

**High Availability (HA):** Systems are designed to be "anti-fragile," with no single points of failure, and can automatically identify, isolate, and restore failed instances.

**Automation:** System deployment, upgrades, scaling, monitoring, and self-healing are all automated.

**Self-service:** Services can be discovered, obtained, used, and managed by other applications or developers.

## 5. Huawei Cloud Native Solution

**Community Contribution:** Huawei is a founding member of the CNCF and has contributed key projects like KubeEdge (edge computing), Volcano (batch computing), and Karmada (multi-cloud orchestration).

**Service Portfolio:** Huawei Cloud provides a full stack of cloud native services, including:

*   **Infrastructure:** Cloud Container Engine (CCE), Cloud Container Instance (CCI), SoftWare Repository for Container (SWR).
*   **Application Development:** CodeArts (DevSecOps platform).
*   **Application Governance:** ServiceStage, Application Service Mesh (ASM).
*   **Application O&M:** AOM, APM, and LTS.

## 6. Cloud Native Trends

**Unified Kubernetes Orchestration:** Kubernetes has become the industry standard for container orchestration, with a 63% adoption rate in a 2020 survey.

**Service Mesh Growth:** The use of service meshes is growing significantly as they help decouple service governance from application logic.

**Serverless is the Future:** Serverless architectures are becoming increasingly popular as they further unleash the potential of cloud computing by abstracting away server management.

**Multi-Cloud/Hybrid Cloud is Mainstream:** A 2020 survey showed that 74% of users are using or plan to use multi-cloud or hybrid cloud architectures to meet security, cost, and compliance needs.

# Lecture Notes 2: Cloud Native Infrastructure – Containers
This document covers the history of containers, their core concepts and underlying technologies, and the practical use of Docker for building and managing containerized applications.

## 1. Container History and Concepts
**Enterprise IT Transformation:** Enterprises are moving from traditional on-premises physical servers to more agile cloud models. This evolution includes migrating to IaaS platforms (P2V/V2V) and adopting cloud-native approaches like containerization and microservices for new applications.

**What Is a Container?:** A container is a lightweight, portable, and self-contained unit that packages an application along with all its dependencies (like binaries and libraries). This allows an application to be encapsulated once and run consistently across different environments, from a developer's laptop to production servers.

**Containers vs. VMs:**

*   **Virtualization Layer:** VMs virtualize the hardware, meaning each VM has its own complete guest OS. Containers, on the other hand, virtualize the operating system, sharing the host OS kernel.
*   **Efficiency:** Because they share the host OS kernel, containers are much more lightweight and have a faster startup speed (seconds or even milliseconds) compared to VMs.
*   **Isolation:** VMs provide strong, system-level resource isolation, while containers provide more lightweight, process-level isolation.
*   **Density:** A single host can run many more containers than VMs.

## 2. Core Container Technologies

**Open Container Initiative (OCI):** To ensure compatibility between different container technologies, vendors like Docker and CoreOS formed the OCI. The OCI creates open industry standards for container runtime specs and image format specs.

**Container Runtimes:** The low-level software that works with the OS kernel to run containers. Common runtimes include runC (from Docker), rkt, and Kata Containers.

**Container Management Tools:** High-level tools that provide interfaces (like a CLI) for users to interact with container runtimes. The most popular example is the Docker Engine.

**Registries:** A service used to store and distribute container images. Registries can be public (e.g., Docker Hub) or private.

## 3. Docker

**Definition:** Docker is an open-source engine that provides a simple way to create, manage, and run lightweight, portable containers. It is the most popular container technology.

**Docker Architecture:**

*   **Docker Daemon:** A background process (dockerd) that manages Docker objects like images, containers, networks, and volumes.
*   **Docker Client:** A command-line tool (docker) that allows users to interact with the Docker daemon.
*   **Docker Objects:** Key objects include Images, Containers, and Repositories.

**How Docker Works:** Docker uses two core Linux kernel technologies to achieve containerization:

*   **Namespaces:** Provide process isolation. Docker creates a set of namespaces for each container (e.g., PID, NET, MNT) so that the container's processes are isolated from the host and other containers.
*   **Control Groups (cgroups):** Limit and manage the system resources (CPU, memory, I/O) that a container can use.

## 4. Container Images

**Definition:** An image is a read-only template used to create a Docker container. It encapsulates the application and all its dependencies.

**Image Layers:** Images are built in layers. Each command in a Dockerfile creates a new, read-only layer.

**Container Layer:** When a container is started from an image, a thin, writable "container layer" is added on top of the read-only image layers. All changes made to the running container, such as writing new files, are stored in this writable layer.

**Union File System (UnionFS):** A storage driver (like Overlay2) that merges the multiple read-only image layers and the single writable container layer into a unified, coherent filesystem for the container.

**Dockerfile:** A text document that contains a set of commands (e.g., FROM, RUN, COPY, CMD) used to assemble an image layer by layer.

**Image Naming:** Images are named using the format repository:tag. The tag specifies the image version (e.g., httpd:v8.6).

## 5. Common Container Commands

*   `docker build`: Builds an image from a Dockerfile.
*   `docker run`: Creates and starts a new container from an image.
*   `docker ps`: Lists running containers. `docker ps -a` lists all containers (running and stopped).
*   `docker stop`: Stops a running container.
*   `docker start`: Starts a stopped container.
*   `docker rm`: Deletes one or more containers.
*   `docker exec`: Executes a command inside a running container.
*   `docker cp`: Copies files between a container and the host filesystem.
*   `docker images`: Lists all images on the host.
*   `docker pull`: Pulls an image from a registry.
*   `docker push`: Pushes an image to a registry.

# Lecture Notes 3: Cloud Native Infrastructure - Kubernetes
This document explains the role of container orchestration, the architecture and core concepts of Kubernetes, and how it is used to manage containerized applications, services, and storage.

## 1. The Need for Container Orchestration

**Challenge:** While tools like Docker manage containers on a single host, enterprises need a way to handle large-scale deployment, including efficient management, cross-host scheduling, and robust storage and networking capabilities.

**Solution: Kubernetes:** Kubernetes is an open-source container cluster management tool that has become the industry's unified framework for container orchestration. It was originally developed by Google based on their internal Borg project and is now maintained by the Cloud Native Computing Foundation (CNCF). Container orchestration automates the deployment, management, and scaling of containerized applications.

## 2. Kubernetes Architecture and Core Concepts
A Kubernetes cluster consists of master nodes and worker nodes.

**Master Node Components (Control Plane):** The master node makes global decisions about the cluster, such as scheduling.

*   **kube-apiserver:** The front-end of the control plane that exposes the Kubernetes API.
*   **etcd:** A consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data.
*   **kube-scheduler:** Watches for newly created pods and selects a node for them to run on.
*   **kube-controller-manager:** Runs controller processes that regulate the state of the cluster.

**Worker Node Components:** A worker node is where containerized applications run.

*   **kubelet:** An agent that runs on each node and ensures that containers are running in a Pod as expected.
*   **kube-proxy:** A network proxy that runs on each node, maintaining network rules and enabling communication for Services.
*   **Container Runtime:** The software responsible for running containers (e.g., Docker).

**Core Concepts (Objects):**

*   **Pod:** The smallest and most basic deployable unit in Kubernetes. A Pod encapsulates one or more containers, which share storage and a network namespace (i.e., the same IP address).
*   **Labels:** Key-value pairs attached to objects like Pods. They are used to organize resources and allow controllers to select objects.
*   **Namespace:** A way to create virtual clusters within a physical cluster, used to isolate resources between different teams or projects.

## 3. Kubernetes Application Orchestration and Management

**Workloads (Controllers):** Kubernetes uses controllers to manage sets of pods. The main workload types are:

*   **Deployment:** Manages stateless applications. It ensures a specified number of replica pods are running and handles rolling updates to deploy new versions with zero downtime.
*   **StatefulSet:** Manages stateful applications (e.g., databases). It provides each Pod with a stable network identifier and stable, persistent storage.
*   **DaemonSet:** Ensures that a copy of a Pod runs on all (or a specific set of) nodes in the cluster, which is useful for log collectors or monitoring agents.
*   **Job & CronJob:** A Job creates Pods to perform a one-time task and ensures they run to completion. A CronJob manages Jobs that run on a repeating schedule.

**Management with kubectl:** kubectl is the command-line tool for managing Kubernetes clusters. It can be used in two ways:

*   **Imperative:** Using commands like `kubectl create deployment...`.
*   **Declarative:** Defining the desired state in a YAML file and applying it with `kubectl apply -f <filename>`.

## 4. Kubernetes Service Release

**Service:** Since Pods are ephemeral and their IP addresses change, a Service provides a stable endpoint to access a logical set of Pods. It has its own stable IP address and acts as a load balancer for the pods it targets.

**Service Types:**

*   **ClusterIP:** Exposes the service on an internal IP in the cluster. This is the default type.
*   **NodePort:** Exposes the service on each Node’s IP at a static port.
*   **LoadBalancer:** Exposes the service externally using a cloud provider's load balancer.
*   **Ingress:** An API object that manages external access to services, typically for HTTP and HTTPS traffic. It can provide Layer-7 load balancing, SSL termination, and name-based virtual hosting.

## 5. Kubernetes Storage Management

**Volume:** A directory accessible to the containers in a Pod. Kubernetes supports many volume types, including:

*   **emptyDir:** A temporary volume that is created when a Pod is assigned to a node and exists only as long as the Pod is running.
*   **hostPath:** Mounts a file or directory from the host node’s filesystem into a Pod.
*   **ConfigMap / Secret:** Used to inject configuration data or sensitive information (like passwords) into containers.

**Persistent Storage:**

*   **PersistentVolume (PV):** A piece of storage in the cluster that has been provisioned by an administrator.
*   **PersistentVolumeClaim (PVC):** A request for storage by a user, which is then bound to an available PV.
*   **StorageClass:** Describes a "class" of storage (e.g., "fast-ssd" or "slow-hdd") and allows for the dynamic provisioning of PVs when a user creates a PVC.

# Lecture Notes 4: Huawei Cloud Container Services
This document provides a detailed look at Huawei Cloud's container infrastructure services—Cloud Container Engine (CCE), Cloud Container Instance (CCI), and SoftWare Repository for Container (SWR)—and how they enable modern, container-based solutions.

## 1. Huawei Cloud Container Infrastructure Services
### Cloud Container Engine (CCE)

**Definition:** CCE is a hosted Kubernetes service that simplifies the deployment, management, and scaling of containerized applications on Huawei Cloud.

**Key Advantages over On-premises Kubernetes:**

*   **Ease of Use:** CCE allows you to create Kubernetes clusters with one click, and it manages the master nodes for you.
*   **High Performance:** CCE is deeply integrated with underlying cloud infrastructure, offering high-performance networking and storage solutions.
*   **Enhanced Security:** Provides multi-tenant management, fine-grained authorization, and encryption for sensitive data like secrets.
*   **Maintenance:** CCE handles cluster upgrades and provides expert technical support, reducing the O&M burden.

**Cluster Creation:** Key parameters include:

*   **Basic Settings:** Kubernetes version, cluster scale (maximum number of nodes), and deploying master nodes across multiple AZs for high availability.
*   **Network Settings:** Choosing a network model (VPC network or tunnel network) and defining CIDR blocks for containers and services.
*   **Add-ons:** CCE installs mandatory add-ons like CoreDNS (for service discovery) and Everest (the CSI driver for cloud storage).

**Nodes and Node Pools:**

A CCE worker node can be an Elastic Cloud Server (ECS) or a Bare Metal Server (BMS).

A **node pool** is a group of nodes with identical configurations. Node pools are essential for enabling cluster auto-scaling.

**CCE Turbo:** A flagship container engine built on Huawei's QingTian architecture, offering superior performance through hardware-software synergy, including accelerated computing, networking, and scheduling.

### Cloud Container Instance (CCI)

**Definition:** CCI is a serverless container engine that allows you to run containers without managing the underlying servers or clusters.

**Key Features:**

*   **Serverless:** You focus on your containerized applications; CCI manages all server infrastructure.
*   **Per-Second Billing:** You pay only for the resources consumed by your workloads, billed by the second.
*   **Heterogeneous Computing:** CCI supports heterogeneous containers, including those requiring GPUs and Ascend chips for AI and big data workloads.
*   **Secure Containers:** Supports Kata Containers, which provide strong, VM-level security isolation for each container by giving it its own micro-VM and kernel.

**CCE vs. CCI:**

*   **Management:** With CCE, you manage the worker nodes; with CCI, you do not manage any nodes.
*   **Use Cases:** CCE is generally used for large-scale, long-term stable applications. CCI is ideal for batch computing, bursty workloads, and CI/CD tasks where resources are needed only for short periods.

### SoftWare Repository for Container (SWR)

**Definition:** SWR is a fully-managed service for storing and distributing container images throughout their lifecycle.

**Core Concepts:**

*   **Repository:** A central location for storing different versions (tags) of a container image. Repositories can be public or private.
*   **Organization:** A logical grouping used to isolate image repositories, typically by company or department, to facilitate centralized management and permission control.

**How to Use:** The typical workflow is to create an organization, build and push an image to a repository in that organization, and then deploy the image to CCE or CCI.

## 2. Container-based Cloud Migration Solutions
Huawei Cloud's container services enable several advanced solutions:

*   **Auto Scaling:** CCE clusters can automatically scale based on service requirements and preset policies to handle traffic fluctuations.
*   **Traffic Management:** By using Application Service Mesh (ASM) with CCE, you can implement advanced traffic management strategies like grayscale releases without modifying application code.
*   **Hybrid Cloud:** CCE can manage container clusters across both on-premises data centers and the cloud, facilitating seamless resource scheduling and disaster recovery.
*   **DevOps:** CCE integrates with SWR and CI/CD tools to automate the entire software delivery pipeline, from code compilation to image building and deployment.

# Lecture Notes 5: Microservice Architecture
This document covers the evolution of enterprise application architectures, focusing on the principles and components of microservices, the popular Spring Cloud framework, and how Huawei Cloud's ServiceStage and Cloud Service Engine (CSE) provide a managed platform for microservice applications.

## 1. Enterprise Application Architecture Evolution
### 1st Gen: Monolithic Architecture:

*   **Description:** All functional modules of an application are packaged into a single project and typically share one database.
*   **Disadvantages:** As the application grows, it becomes difficult to manage, a single change requires replacing the entire package, and scaling individual components is not possible.

### 2nd Gen: SOA (Service-Oriented Architecture):

*   **Description:** A model where application components are designed as reusable services, often communicating through a central Enterprise Service Bus (ESB).
*   **Disadvantages:** The ESB can become a bottleneck with limited scalability, the SOAP protocol often used has low efficiency, and development is often restricted to a single language.

### 3rd Gen: Microservice Architecture:

*   **Description:** An architectural style that structures an application as a collection of small, independent, and loosely coupled services. It replaces the heavy ESB with a lightweight service gateway and adds robust service governance and monitoring capabilities.

## 2. Typical Microservice Frameworks

**Common Frameworks:** Popular frameworks for building microservices include Spring Cloud, Apache ServiceComb, and Apache Dubbo. Spring Cloud is a dominant choice in enterprise development.

**Core Concepts of Microservices (Spring Cloud):**

*   **Service Registry and Discovery:** Service instances register their location (IP, port) with a central registry (like Eureka or Consul). Other services query the registry to discover and communicate with them.
*   **API Gateway:** A single entry point for all external client requests. It handles routing, authentication, and other cross-cutting concerns.
*   **Configuration Center:** Manages application configurations externally. This allows for dynamic configuration updates without needing to restart services.
*   **Load Balancing:** Distributes incoming traffic across multiple instances of a service to improve performance and reliability.
*   **Circuit Breaker:** A fault tolerance pattern. If a downstream service becomes unavailable, the circuit breaker "trips", temporarily stopping calls to it and preventing cascading failures throughout the system.
*   **Tracing:** In a distributed system, tracing follows a request as it travels through multiple services, which is essential for performance monitoring and troubleshooting.

## 3. Huawei Cloud ServiceStage and Microservices

**Spring Cloud Huawei:** A suite of components that allows applications developed with the open-source Spring Cloud framework to seamlessly integrate with Huawei Cloud's managed microservice offerings. It supports using CSE as the backend for service discovery and configuration.

**Cloud Service Engine (CSE):**

*   **Definition:** CSE is high-performance, enterprise-grade cloud middleware for microservice applications. It provides managed services for registry and discovery, configuration management, and service governance.
*   **Benefits:** CSE is compatible with open-source ecosystems like Spring Cloud, Dubbo, and ServiceComb. It allows developers to replace open-source components like Eureka with a more robust, managed service without changing application code.

**ServiceStage:**

*   **Definition:** A comprehensive application and microservice management platform that simplifies the entire application lifecycle, from deployment and monitoring to O&M and governance.
*   **Environment Management:** ServiceStage allows you to define environments (e.g., development, testing, production), which are collections of cloud resources needed to run an application.
*   **Deployment and Lifecycle:** It supports one-click deployment from various sources (source code, JARs, images) to different runtimes like CCE, CCI, or ECS. It manages the full lifecycle, including starting, stopping, upgrading, and rolling back applications.

# Lecture Notes 6: Istio
This chapter introduces the concept of a service mesh, provides a deep dive into the architecture and traffic management capabilities of Istio, and describes Huawei Cloud's managed service mesh offering, Application Service Mesh (ASM).

## 1. Service Mesh Concepts
### Evolution of Microservice Governance:

*   **1st Gen:** Service governance logic (e.g., for service discovery, load balancing) was embedded directly into the application code, leading to high coupling and maintenance complexity.
*   **2nd Gen:** Governance logic was moved into shared libraries or SDKs. This reduced code duplication but introduced strong language dependencies and still required application code changes for upgrades.
*   **3rd Gen (Service Mesh):** Service governance is moved out of the application and into a dedicated infrastructure layer, implemented as a sidecar proxy. This approach is non-intrusive, language-independent, and decouples governance from the application lifecycle.

### What Is a Service Mesh?:

*   A service mesh is a dedicated infrastructure layer for handling service-to-service communication.
*   It is typically implemented as an array of lightweight network proxies deployed alongside application code (as a sidecar), without the application needing to be aware of the proxy.
*   It decouples applications from concerns like retries, timeouts, monitoring, tracing, and service discovery.

## 2. Introduction to Istio

**History and Definition:** Istio is a popular open-source service mesh jointly developed by Google, IBM, and Lyft. It has become a key technology in the cloud-native ecosystem.

**Istio Architecture:** Istio's architecture is logically split into a data plane and a control plane.

*   **Data Plane:** Composed of a set of intelligent proxies (Envoy) deployed as sidecars. These proxies mediate and control all network traffic between microservices.
*   **Control Plane:** Manages and configures the proxies to route traffic. In modern versions, its components are consolidated into a single binary called **istiod**. The main logical components are:
    *   **Pilot:** Provides service discovery and generates traffic management configurations for the Envoy proxies.
    *   **Citadel:** Manages security by providing certificate issuance and management for strong service-to-service authentication (mTLS).
    *   **Galley:** Responsible for validating, ingesting, and distributing Istio configurations.

## 3. Istio Traffic Management
Istio uses a set of Kubernetes Custom Resource Definitions (CRDs) to control traffic flow.

**Key Resources:**

*   **Gateway:** Describes a load balancer operating at the edge of the mesh, managing ingress or egress traffic. It configures L4-L6 properties like ports and TLS settings.
*   **VirtualService:** Defines the routing rules for traffic. It can direct requests to different versions of a service based on weights (for canary releases) or criteria like HTTP headers.
*   **DestinationRule:** Configures policies that are applied to traffic after routing decisions are made. This includes load balancing policies, connection pool settings, and outlier detection (circuit breaking). It also defines the service subsets (versions) that a VirtualService can route to.

**Traffic Management Policies:**

*   **Traffic Splitting / Grayscale Release:** Use a VirtualService to split traffic by percentage between different service versions (e.g., 80% to v1, 20% to v2).
*   **Circuit Breaking:** Use a DestinationRule to configure outlier detection, which automatically ejects unhealthy service instances from the load balancing pool, preventing cascading failures.
*   **Fault Injection:** Intentionally inject delays or HTTP errors into traffic to test the resilience of the system.
*   **Retries:** Configure automatic retries for failed HTTP requests to improve service reliability.

## 4. Huawei Cloud Application Service Mesh (ASM)

**Definition:** ASM is a fully-managed service mesh platform based on Istio. It seamlessly integrates with Huawei Cloud services like Cloud Container Engine (CCE) and provides an enhanced, out-of-the-box experience.

**Key Features and Scenarios:**

*   **Grayscale Releases:** ASM provides built-in, wizard-based processes for canary releases and blue-green deployments.
*   **Traffic Management:** Offers non-intrusive management of traffic with features like load balancing, circuit breaking, and fault injection.
*   **Security:** Provides end-to-end security with features like transparent mutual TLS (mTLS) for encrypted communication and fine-grained authorization policies.
*   **Observability:** Integrates with Application Performance Management (APM) to provide a real-time traffic topology, distributed tracing, and service performance metrics.

# Lecture Notes 7: Introduction to Cloud Native DevSecOps
This document describes the evolution of software development methodologies towards Agile and DevOps, outlines the core principles of continuous integration and delivery, and introduces Huawei Cloud's services for implementing a cloud-native DevSecOps workflow.

## 1. Agile Development and DevOps Mindset
### Agile Development: An iterative approach to software development that prioritizes flexibility and customer collaboration over rigid planning and processes.

**Agile Manifesto:** Its core values are:

*   Individuals and interactions over processes and tools.
*   Working software over comprehensive documentation.
*   Customer collaboration over contract negotiation.
*   Responding to change over following a plan.

**Agile vs. Waterfall:** The key difference is that Agile is value-driven, delivering value incrementally, while the traditional Waterfall model is plan-driven, with a rigid, sequential process.

**Scrum:** A popular Agile framework that uses fixed-length iterations called sprints. The key roles are the Product Owner (manages the product backlog), the Scrum Master (guides the team), and the self-managing Team.

### DevOps: A culture and practice that emphasizes collaboration and communication between software Development and IT Operations teams. It aims to automate and streamline the software delivery process, enabling faster and more reliable releases.

**Continuous Integration/Delivery/Deployment (CI/CD):**

*   **Continuous Integration (CI):** A development practice where developers frequently merge their code changes into a central repository, after which automated builds and tests are run.
*   **Continuous Delivery (CD):** An extension of CI where code changes are automatically built, tested, and prepared for a release to production. The final deployment to the production environment is typically a manual step.
*   **Continuous Deployment:** The next step after continuous delivery, where every change that passes all stages of the pipeline is automatically deployed to production.

## 2. HE2E DevOps Framework and CodeArts
**HE2E (Huawei End-to-End) DevOps Framework:** An E2E development methodology and toolchain from Huawei that integrates industry-leading concepts with Huawei's own R&D experience.

**CodeArts:** Huawei Cloud's one-stop, cloud-native DevSecOps platform that provides services covering the entire software lifecycle. Its key components include:

*   **CodeArts Req:** For agile project management using Scrum and Kanban.
*   **CodeArts Repo:** A Git-based code hosting service for secure and efficient collaboration.
*   **CodeArts Check:** An automated tool for static code analysis, checking for security vulnerabilities, coding style, and quality issues.
*   **CodeArts Build:** A cloud-based service for fast and scalable compilation and building of software packages.
*   **CodeArts Deploy:** An automated deployment service that supports deploying applications to various environments like VMs and containers.
*   **CodeArts Pipeline:** A service for creating visualized, automated CI/CD pipelines that orchestrate the build, check, test, and deployment tasks.

**DevSecOps:** An evolution of DevOps that integrates security practices into every phase of the software lifecycle ("shifting security left"), based on the principle that "Security Is Everybody's Job".

## 3. Serverless Programming and Huawei Cloud FunctionGraph
**Serverless Computing:** A cloud computing model where the cloud provider dynamically manages the allocation and provisioning of servers. Developers write and deploy code in the form of functions, without worrying about the underlying infrastructure.

**Serverless Architecture Types:**

*   **BaaS (Backend-as-a-Service):** Using third-party, API-based services for backend functionality.
*   **FaaS (Function-as-a-Service):** An event-driven model for running small, stateless units of code (functions).

**Why Serverless?:** It is fast (rollout in seconds, auto-scaling in milliseconds), simple (O&M-free), and economical (pay-per-use, billed for every 100 ms of execution).

### Huawei Cloud FunctionGraph:

**Definition:** FunctionGraph is Huawei Cloud's FaaS offering. It is a serverless compute service that lets you run code without provisioning or managing servers.

**How it Works:** Developers upload their code to FunctionGraph. The function is then executed in response to triggers from other cloud services (e.g., an object upload to OBS, a message on SMN, or an API call via APIG). FunctionGraph automatically handles scaling based on the number of requests.
