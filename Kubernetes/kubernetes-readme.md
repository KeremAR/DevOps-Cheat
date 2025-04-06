# Kubernetes Learning Notes

## What is Kubernetes and Why is it Needed?

Kubernetes is an open-source container orchestration tool used to manage and scale containers efficiently. As microservices became more common, managing containers became increasingly complex. Kubernetes solves this problem by automatically scaling applications based on load and ensuring service continuity.

## Container Orchestration

Kubernetes provides the following container orchestration capabilities:

- **Provisioning and deployment** (IT altyapısının hazırlanmı ve dağıtımı)
- **Configuration and scheduling** (Konfigürasyon ve Zamanlama)
- **Resource allocation** (Kaynak tahsisi)
- **Container availability** (Konteyner kullanılabilirliği)
- **Scaling or removing containers** based on balancing workloads across your infrastructure (Altyapınızdaki iş yüklerini dengelemeye dayalı olarak workload birimlerini ölçeklendirme veya kaldırma)
- **Load balancing and traffic routing** (Yük dengeleme ve trafik yönlendirme)
- **Monitoring container health** (Konteynerların çalışma durumlarını izleme)
- **Keeping interactions between containers secure** (Konteynerlar arası etkileşimleri güvende tutmak)


## Key Features

### Resilience

Kubernetes ensures system reliability by restarting failed applications or relocating them to healthy servers. For example, if a server crashes, Kubernetes automatically redistributes the containers to other available servers, keeping the system running.

### Deployment

Kubernetes supports different deployment strategies:

* **Disruptive Deployment:** The old version is completely shut down before the new version is launched (risk of downtime).
* **Seamless Deployment:** The old version is gradually phased out while the new version is brought online (more reliable).
* **Rollback:** If an issue occurs in the new version, Kubernetes can automatically revert to the previous version.

### Provisioning (Resource Management)

Kubernetes optimizes hardware resource usage by:

* **Automatic Scaling:** Adding new containers when traffic increases and shutting down unnecessary ones when demand is low.
* **Load Balancing:** Distributing incoming requests across available containers efficiently.

## Kubernetes and CI/CD

**CD tools handle the deployment process**, but Kubernetes **ensures that deployed applications run continuously, scalably, and securely**. Without Kubernetes, CI/CD tools can still perform deployments, but features like load balancing, self-healing, and scaling would be missing. This is why **CI/CD and Kubernetes are typically used together**.

## Kubernetes Architecture

![worker node](/Media/workernode.png)
![control plane](/Media/controlplane.png)

### Kubernetes Cluster

A deployment of Kubernetes is called a **Kubernetes cluster**. It consists of a set of worker machines, called **nodes**, that run containerized applications.

Every cluster has at least one worker node and one master node, which runs the **Control Plane**.

-   **Control Plane:** Maintains the desired state of the cluster (like a thermostat). It makes global decisions about the cluster (e.g., scheduling) and detects/responds to cluster events (e.g., starting new pods).
-   **Nodes (Worker Nodes):** The machines (VMs or physical) where user applications actually run. Nodes are managed by the Control Plane.

### Control Plane Components

These components typically run on the master node(s) and manage the overall cluster state.

-   **kube-apiserver (API Server):**
    -   Exposes the Kubernetes API. It's the front-end for the control plane.
    -   All communication (internal and external) goes through the API server.
    -   Designed to scale horizontally (run multiple instances).
-   **etcd:**
    -   A consistent and highly-available distributed key-value store.
    -   Stores all cluster data and represents the desired state of the cluster.
-   **kube-scheduler (Scheduler):**
    -   Assigns newly created Pods to available Nodes based on resource requirements, policies, and other constraints.
-   **kube-controller-manager (Controller Manager):**
    -   Runs controller processes that monitor the cluster state.
    -   Works to make the current cluster state match the desired state stored in etcd.
    -   Examples: Node controller, Replication controller.
-   **cloud-controller-manager (Cloud Controller Manager):**
    -   Runs controllers that interact with the underlying cloud provider's API.
    -   Allows Kubernetes to be cloud-agnostic by separating cloud-specific logic.

### Worker Node Components
These components run on every node, maintaining running pods and providing the Kubernetes runtime environment.

-   **kubelet:**
    -   An agent that runs on each node in the cluster.
    -   Communicates with the kube-apiserver to ensure containers described in PodSpecs are running and healthy.
    -   Reports node and pod health/status back to the control plane.
-   **Container Runtime:**
    -   The software responsible for running containers (e.g., downloading images, starting/stopping containers).
    -   Kubernetes supports various runtimes via the Container Runtime Interface (CRI).
    -   Examples: Docker, containerd, CRI-O.
-   **kube-proxy:**
    -   A network proxy that runs on each node.
    -   Maintains network rules on nodes, enabling network communication to Pods from network sessions inside or outside of the cluster.

### Pods

-   The **smallest deployable unit** in Kubernetes.
-   Represents a single instance of a running process in the cluster.
-   Contains **one or more containers** (like Docker containers).
-   Containers within a Pod share the same network namespace, IP address, and storage volumes.

## Conclusion

Kubernetes automates container management, making systems more resilient, scalable, and efficient. While Docker is used to build and package containers, Kubernetes is responsible for managing and orchestrating them.
