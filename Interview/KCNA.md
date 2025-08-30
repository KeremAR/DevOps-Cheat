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
