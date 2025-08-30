### Q1: Let's assume that an organization needs to process large amounts of data in bursts, on a cloud-based Kubernetes cluster. For instance: each Monday morning, they need to run a batch of 1000 compute jobs of 1 hour each, and these jobs must be completed by Monday night. What's going to be the most cost-effective method?
Leverage the Kubernetes Cluster Autoscaler to automatically start and stop nodes as they're needed.

*The Cluster Autoscaler ensures you only pay for compute resources when the jobs are actually running.*

### Q2: What native runtime is Open Container Initiative (OCI) compliant?
runC

*runC is a lightweight, universal container runtime that conforms to the OCI specification.*

### Q3: What standard does kubelet use to communicate with the container runtime?
Container Runtime Interface (CRI)

*CRI provides a standard API for kubelet to interact with different container runtimes like containerd or CRI-O.*

### Q4: Which prometheus metric type represents a single number value that can increase and decrease over time?
Gauge

*A Gauge is ideal for metrics like temperature or current memory usage that can arbitrarily increase or decrease.*

### Q5: What command use to get documentation about kubernetes resource type
```bash
alias k='kubectl'
k explain
```

*The `explain` command provides detailed documentation about Kubernetes API objects and their fields directly from the command line.*

### Q6: What makes cloud native technology so important?
- Speeds up delivery of new features
- Improves scalability and resilience
- Lets teams experiment and innovate faster without being blocked by traditional infrastructure limits

*Cloud-native practices allow organizations to build and run scalable applications in modern, dynamic environments like public, private, and hybrid clouds.*

### Q7: Notary and The Update Framework (TUF) are leading security projects in CNCF?
YES.
- **Notary:** A project that provides a way to sign and verify container images (so you can trust the source).
- **The Update Framework (TUF):** A framework for secure software update systems, ensuring that attackers cannot tamper with updates or distribute malicious versions.

Together, they are leading CNCF security projects because they focus on one of the biggest risks in cloud-native: supply chain security (protecting images and updates).

*Both projects are crucial for securing the software supply chain by ensuring the integrity and authenticity of container images and software updates.*

### Q8: What is OPA?
Open Policy Agent (OPA) is an open source, general-purpose policy engine.

*OPA decouples policy decision-making from application code, allowing for unified policy enforcement across the stack.*

### Q9: Which CNCF project is the dominant project with respect to container registries?
Harbor is an open-source cloud-native container registry.

*Harbor is a trusted, enterprise-grade container registry that stores, signs, and scans container images for vulnerabilities.*

### Q10: What does the acronym CNCF stand for?
Cloud Native Computing Foundation

*The CNCF is a part of the Linux Foundation that hosts and promotes critical open-source projects for cloud-native computing.*

### Q11: Which of the following statements is true regarding the Kubernetes networking model?
- Pods can communicate with all other pods on any other node without Network Address Translation (NAT).
- Agents running on a node such as system daemons and kubelet can communicate with all pods on any node of the cluster.

*This flat networking model simplifies communication by giving every pod a unique IP address across the entire cluster.*

### Q12: In Node Selection, the kube-scheduler selects a node for the pod in a 2-step operation, namely Filtering and ________.
Scoring (Priorities)

*After filtering out nodes that cannot run the pod, the scheduler scores the remaining nodes to pick the most suitable one.*

### Q13: How does the Kubernetes API ensure that different clients can interact with the cluster autonomously and in a consistent manner?
- Through a single and uniform endpoint known as the kube-apiserver.
- By implementing a versioned set of API objects and operations.

*The API server acts as a central gateway, providing a consistent, versioned RESTful interface for all cluster interactions.*

### Q14: Which of the following are key features provided by a service mesh?
- Load balancing and service discovery.
- Communication security (e.g., mTLS).

*A service mesh provides a dedicated infrastructure layer for making service-to-service communication safe, fast, and reliable. It handles load balancing by intelligently routing traffic, service discovery by keeping a catalog of services, and security by automatically encrypting communication with mTLS.*

### Q15: Which component is responsible for monitoring resource utilization and scaling decisions in Kubernetes Autoscaling?
Metrics Server

*The Metrics Server collects resource usage data from nodes and pods, which is then used by autoscalers to make scaling decisions.*

### Q16: Why are Namespaced containers considered less secure?
They share a host kernel.

*Sharing the host kernel means a container escape vulnerability could potentially compromise the entire host system.*

### Q17: Containers running in one pod share which of the following options?
- Storage
- Networking

*Containers within the same pod share the network namespace and can share storage volumes, facilitating close communication and data sharing.*

### Q18: What role does the Kubernetes Steering Committee Play in the project?
They oversee the technical direction of Kubernetes development.

*The Steering Committee is responsible for the overall governance and high-level direction of the Kubernetes project.*

### Q19: Which tool is often used for monitoring and managing the cost efficiency of cloud-native applications deployed on Kubernetes?
Kubecost.

*Kubecost provides real-time cost visibility and insights for teams using Kubernetes, helping them reduce their cloud spend.*

### Q20: In distributed system tracing, what is the term used to refer to a request as it passes through a single component of the distributed system?
Span

*A **Trace** is the full request journey across services. A **Span** is one step in that journey for a single component. **Logs** are events or messages from a component.*

### Q21: Which of the following are not the metrics for Site Reliability Engineering?
A- Service Level Objectives 'SLO'
B- Service Level Agreements 'SLA'
C- Service Level Indicators 'SLI'
ANSWER:D- Service Level Definition 'SLD'

*SREs create SLAs, SLOs, and SLIs to define and implement standards for application and infrastructure reliability. A Service Level Agreement (SLA) is a contract defining service reliability, an SLO is a goal for that reliability, and an SLI is the measurement of it. 'SLD' is not a standard SRE metric.*

### Q22: What is the command to list all the available objects in your Kubernetes cluster?
`kubectl api-resources`

*This command lists all available API resource types in the cluster, including their short names and API group.*

### Q23: What feature is used for selecting the container runtime configuration?
RuntimeClass

*RuntimeClass is a feature for selecting the container runtime configuration used to run a pod's containers.*

### Q24: What tool allows you to create self-managing, self-scaling, self-healing storage?
Rook

*Rook turns distributed storage systems into self-managing, self-scaling, and self-healing storage services by automating administrator tasks.*

### Q25: How can persistent volume be provisioned?
Dynamically

*Dynamic provisioning uses a StorageClass to automatically create a PersistentVolume when a PersistentVolumeClaim requests it.*

### Q26: What command to view the kube config?
`kubectl config view`

*This command displays the merged kubeconfig settings from all specified kubeconfig files.*

### Q27: What does the 'kops' acronym means?
Kubernetes Operations

*Kops helps you create, destroy, upgrade, and maintain production-grade, highly available Kubernetes clusters from the command line.*

### Q28: Observability tools are commonly used for multiple purposes. Which of the following is not commonly monitored by them?
a) Log files
b) Network latency
c) Network throughput
d) Application restarts
ANSWER: a) Log files

*This question focuses on the technical definition of "monitoring." While observability tools process logs, they actively "monitor" metrics like latency, throughput, and restarts, which are changing numerical values that can trigger alerts. Logs are treated as a data source to be collected, parsed, and queried, rather than a metric to be continuously monitored in the same way.*

### Q29: Which logging option should be used to collect log information directly from a Pod?
a) Application level logging
b) Node level logging
c) Cluster level logging
d) Sidecar container-based logging
ANSWER: d) Sidecar container-based logging

*A sidecar container is a second container that runs inside the same Pod as the application container. This pattern allows you to extend or enhance the main application's functionality. For logging, a sidecar container (like Fluentd) can collect logs directly from the application container (e.g., by reading from a shared volume) and forward them to a logging backend. This is considered the most direct method as the collection agent operates within the Pod's own boundary.*

### Q30: Which type of Kubernetes networking is handled by the overlay network?
a) Container-to-container
b) Pod-to-Pod
c) Pod-to-service
d) External-to-service
ANSWER: b) Pod-to-Pod

*The primary role of an overlay network (implemented by CNI plugins like Flannel or Calico) is to create a flat, virtual network that spans all nodes in the cluster. This ensures that every Pod gets a unique IP address and can communicate directly with any other Pod on any other node without NAT. Container-to-container communication happens locally within a Pod, while Pod-to-service and external traffic are managed by higher-level abstractions like kube-proxy and Ingress controllers.*

### Q31: Which Kubernetes component is running on a worker node and is contacted by the kube-scheduler to run Pods?
a) The container runtime
b) kubelet
c) kube-proxy
d) service
ANSWER: b) kubelet

*The kube-scheduler decides which node a Pod should run on. After this decision, the kubelet on that specific worker node is the agent responsible for taking the Pod specification and ensuring its containers are started and running. The kubelet directly communicates with the container runtime to manage the container lifecycle on the node.*

### Q32: Using container volumes offers different benefits. Which of the following is not one of them?
a) it allows data to survive container life time
b) it allows sharing storage between different containers
c) It offers increased security
d) it separates site specific data from generic code
ANSWER: c) It offers increased security

*Volumes are essential for data persistence (surviving container restarts), sharing data between containers in a Pod, and decoupling configuration/data from the container image. However, they are not inherently a security feature. While some volume types and configurations can be secured, their primary purpose is storage management, not enhancing security. In fact, misconfigured volumes (like `hostPath` volumes) can create significant security risks.*

### Q33: What is the name of the foundation that aims at standardization in the container landscape?
a) Container Foundation
b) Open Containers Initiative
c) Cloud Native Computing Foundation
d) Linux Foundation
ANSWER: b) Open Containers Initiative

*The Open Containers Initiative (OCI) is a project under the Linux Foundation specifically created to establish open industry standards for container formats and runtimes (e.g., the Image Specification and the Runtime Specification). While the CNCF also operates under the Linux Foundation, its goal is to promote and host cloud-native projects (like Kubernetes), not to create the low-level container standards themselves.*

### Additional Notes: Observability

Observability is a measure of how well we can understand the internal state of a system from the external outputs it produces (metrics, logs, traces). It allows us not just to know that "something is wrong," but also to understand "why it's wrong." In the Cloud Native world, it is critical for understanding distributed and dynamic systems.

#### The Three Pillars of Observability

**1. Metrics**
*   **What are they?** Numerical data collected over a period of time. They provide real-time information about the overall health and performance of the system (e.g., CPU usage, memory consumption, request count).
*   **What are they used for?** Used to detect anomalies, create alerts, and monitor performance trends.
*   **Key Tool:** **Prometheus** is the de facto standard CNCF project for metrics-based monitoring and alerting.

**2. Logs**
*   **What are they?** Timestamped, immutable records of events that occurred within an application or system. They provide detailed context when an error occurs or a specific transaction takes place.
*   **What are they used for?** Used for debugging, root cause analysis, and security audits.
*   **Key Tools:** **Fluentd** is a CNCF tool for log collection and forwarding. The ELK Stack (Elasticsearch, Logstash, Kibana) is also a popular solution.

**3. Traces**
*   **What are they?** Records that show the end-to-end journey of a request through a distributed system. They show which services a request passes through and how much time it spends in each service.
*   **What are they used for?** Used to find performance bottlenecks, understand inter-service dependencies, and analyze latency issues.
*   **Key Tools:** **Jaeger** and **Zipkin** are popular open-source distributed tracing systems. **OpenTelemetry** is a next-generation CNCF project that has emerged to collect metrics, logs, and traces in a standardized way.

#### Kubernetes Logging Patterns

Beyond the three pillars, it's important to understand how logs are collected in a Kubernetes environment. The primary methods are:

*   **Node-level Logging:** This is the most common and fundamental approach. A logging agent (like Fluentd or Fluent Bit) is deployed as a `DaemonSet` on each node. This agent collects logs from all containers on that node by reading the container log files managed by the kubelet. It's robust because it doesn't depend on the individual application pods.

*   **Sidecar Container-based Logging:** As explained in Q29, a dedicated logging container runs within the same Pod as the application. This is useful when an application has specific logging requirements or writes to files that are not on stdout/stderr. The sidecar container tails these logs and forwards them, encapsulating the logging logic for that specific application.

*   **Application-level Logging:** In this pattern, the application code itself is responsible for sending its logs directly to a logging backend. This gives developers granular control but also tightly couples the application to the logging system, which can be inflexible.

*   **Cluster-level Logging:** This refers to the centralized logging backend that aggregates logs from all across the cluster. Typically, node-level or sidecar agents forward their collected logs to this central system (e.g., an Elasticsearch, Logstash, and Kibana - ELK stack) for storage, indexing, and analysis.
