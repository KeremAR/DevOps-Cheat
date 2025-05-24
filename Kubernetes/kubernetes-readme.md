# Kubernetes Learning Notes

![k8s cheatsheet](/Media/k8s-cheatsheet.png)

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

## Kubernetes Objects

Kubernetes objects are persistent entities within the Kubernetes system representing the state of your cluster.

-   **Key Fields:**
    -   `spec`: Provided by the user, defining the *desired state* of the object.
    -   `status`: Provided by Kubernetes, describing the *current state* of the object. Kubernetes constantly works to match the current state to the desired state.
-   **Interaction:** Managed via the Kubernetes API (e.g., using `kubectl` or client libraries).

### Labels and Selectors

-   **Labels:** Key/value pairs attached to objects (e.g., `app: nginx`). Used for identification and organization, but are not unique; multiple objects can share the same label.
-   **Label Selectors:** Core grouping mechanism. Used to select a set of objects based on their labels (e.g., in ReplicaSets or Services).

### Namespaces

-   Mechanism for isolating groups of resources within a single cluster.
-   Useful for multi-tenant environments, separating projects, or organizing resources (e.g., `default`, `kube-system`).
-   Provide a scope for object names; an object name must be unique within its namespace for its resource type.

### Pod

-   The simplest and smallest deployable unit in Kubernetes.
-   Represents a single instance of an application/process running in the cluster.
-   Usually wraps one or more containers.
-   Can be replicated (scaled horizontally) using higher-level objects like ReplicaSets or Deployments.

**Example Pod YAML:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.7.9
    ports:
    - containerPort: 80
```

### ReplicaSet

-   Ensures that a specified number of identical Pod replicas are running at any given time.
-   Uses a `selector` (with `matchLabels`) to identify the Pods it manages.
-   Includes a `template` section defining the specification for the Pods it should create.
-   **Note:** Directly managing ReplicaSets is not recommended. Use Deployments instead.

**Example ReplicaSet YAML:**
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

### Deployment

-   A higher-level object that manages ReplicaSets and provides declarative updates for Pods.
-   Manages the rollout of new versions using strategies like **Rolling Updates** (scaling up the new version while scaling down the old one).
-   Suitable for stateless applications (StatefulSets are used for stateful ones).
-   Defines the desired state (e.g., number of replicas, container image, template) and the Deployment controller changes the actual state to match.

**Example Deployment YAML:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

### Service

-   An abstraction that defines a logical set of Pods and a policy by which to access them (often acting as an internal load balancer).
-   Provides a stable IP address and DNS name for a set of Pods, addressing the volatility of Pod IPs.
-   Uses selectors to target Pods.
-   Supports multiple protocols (TCP default, UDP, etc.) and port definitions.

**Service Types:**

1.  **`ClusterIP`:** (Default) Exposes the service on an internal IP within the cluster. Makes the service reachable only *from within* the cluster. Used for inter-service communication (e.g., frontend to backend).
2.  **`NodePort`:** Exposes the service on each Node's IP at a static port. Routes traffic to the `ClusterIP` service automatically. Allows external access but is often not recommended for production security.
3.  **`LoadBalancer`:** Exposes the service externally using a cloud provider's load balancer. Automatically creates `NodePort` and `ClusterIP` services. Provides an external IP address.
4.  **`ExternalName`:** Maps the service to an external DNS name (using a CNAME record) instead of using selectors. Useful for accessing external services from within the cluster.

### Ingress

-   An API object that manages external access to services within the cluster, typically HTTP/HTTPS.
-   Provides routing rules (based on host or path) to direct traffic to different services.
-   Requires an Ingress Controller to be running in the cluster to fulfill the Ingress rules.
-   Often used to expose multiple services under a single IP address, potentially with TLS termination.

### DaemonSet

-   Ensures that all (or some specified) Nodes run a copy of a specific Pod.
-   Pods are automatically added to new nodes joining the cluster.
-   Useful for cluster-level agents like log collectors, monitoring agents, or storage daemons.

### StatefulSet

-   Manages the deployment and scaling of a set of Pods, specifically designed for **stateful applications**.
-   Provides guarantees about the ordering and uniqueness of Pods (stable, persistent identifiers).
-   Provides stable, persistent storage volumes associated with each Pod replica.

### Job

-   Creates one or more Pods and ensures that a specified number of them successfully terminate (complete).
-   Tracks the completion of tasks; Pods are usually deleted after the Job completes.
-   Useful for batch processing, one-off tasks, or tasks that need to run to completion.
-   **CronJob:** Creates Jobs on a repeating schedule (like cron).

## Kubectl (Kubernetes CLI)

`kubectl` (kube control) is the primary command-line interface (CLI) tool for interacting with a Kubernetes cluster.

-   Used to deploy applications, inspect and manage cluster resources, view logs, etc.

### Kubectl Command Structure

```
kubectl [command] [type] [name] [flags]
```

-   **`[command]`**: The operation to perform (e.g., `create`, `get`, `apply`, `delete`).
-   **`[type]`**: The resource type (e.g., `pod`, `deployment`, `replicaset`, `service`).
-   **`[name]`**: The name of the specific resource (if applicable).
-   **`[flags]`**: Special options or modifiers (e.g., `-n` for namespace, `-o` for output format).

### Command Types

1.  **Imperative Commands:**
    -   Operate directly on live objects in the cluster (e.g., `kubectl run my-pod --image=nginx`, `kubectl create deployment ...`, `kubectl expose ...`).
    -   Easy to learn and use for simple tasks or development/testing.
    -   **Cons:** No audit trail, less flexible, doesn't use configuration files/templates, hard to replicate.

2.  **Imperative Object Configuration:**
    -   Uses a specific command (`create`, `replace`, `delete`) along with a configuration file (`-f file.yaml`).
    -   Requires a full object definition in YAML/JSON.
    -   Stored in source control (Git), provides audit trail, uses templates.
    -   **Cons:** Requires understanding the object schema, still requires specifying the *operation* (create vs. replace). Changes made outside the file can be lost.

3.  **Declarative Object Configuration:**
    -   Uses the `kubectl apply -f <file_or_directory>` command.
    -   Defines the *desired state* in configuration files (YAML/JSON).
    -   `kubectl` determines the necessary operations (create, patch, delete) to reach the desired state.
    -   Configuration stored in source control, ideal for production systems, tracks changes effectively.

### Common Kubectl Commands (Examples)

-   `kubectl get pods`: List pods in the current namespace.
-   `kubectl get pods -A` or `kubectl get pods --all-namespaces`: List pods in all namespaces.
-   `kubectl get deployment my-dep`: Get details of a specific deployment.
-   `kubectl get services`: List services in the current namespace.
-   `kubectl create -f my-resource.yaml`: Create resources defined in a file (imperative object config).
-   `kubectl apply -f my-resource.yaml` or `kubectl apply -f ./configs/`: Apply configuration from file(s) or directory (declarative).
-   `kubectl delete pod my-pod`: Delete a specific pod.
-   `kubectl delete -f my-resource.yaml`: Delete resources defined in a file.
-   `kubectl scale deployment my-dep --replicas=5`: Scale a deployment.
-   `kubectl autoscale deployment my-dep --min=2 --max=10 --cpu-percent=80`: Create a HorizontalPodAutoscaler.
-   `kubectl logs my-pod`: View logs from a pod.
-   `kubectl describe pod my-pod`: Get detailed information about a pod.
-   `kubectl exec -it my-pod -- /bin/bash`: Execute a command (like a shell) inside a pod's container.

## Kubernetes Practical Examples / Tasks

### Task 1: Create and Expose a Deployment

1.  **Create Deployment:**
    ```bash
    kubectl create deployment my-deployment1 --image=nginx
    ```
2.  **Expose Deployment as NodePort Service:**
    ```bash
    kubectl expose deployment my-deployment1 --port=80 --type=NodePort --name=my-service1
    ```
3.  **List Services:**
    ```bash
    kubectl get services
    ```

### Task 2: Manage Pods

1.  **List Pods:**
    ```bash
    kubectl get pods
    ```
2.  **Show Pod Labels:**
    ```bash
    # Replace <pod-name> with the actual pod name
    kubectl get pod <pod-name> --show-labels
    ```
3.  **Label a Pod:**
    ```bash
    # Replace <pod-name> with the actual pod name
    kubectl label pods <pod-name> environment=deployment
    ```
4.  **Run a Temporary Pod (for testing/debugging):**
    ```bash
    kubectl run my-test-pod --image=nginx --restart=Never
    ```
5.  **View Pod Logs:**
    ```bash
    # Replace <pod-name> with the actual pod name
    kubectl logs <pod-name>
    ```

### Task 3: Deploying a StatefulSet

1.  **Define StatefulSet (`statefulset.yaml`):**
    ```yaml
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: my-statefulset
    spec:
      serviceName: "nginx" # Headless service needs to be created separately
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx # Use appropriate image, e.g., k8s.gcr.io/nginx-slim:0.8
            ports:
            - containerPort: 80
              name: web
      volumeClaimTemplates:
      - metadata:
          name: www
        spec:
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 1Gi
    ```
2.  **Apply StatefulSet:**
    ```bash
    kubectl apply -f statefulset.yaml
    ```
3.  **Verify StatefulSet:**
    ```bash
    kubectl get statefulsets
    ```

### Task 4: Implementing a DaemonSet

1.  **Define DaemonSet (`daemonset.yaml`):**
    ```yaml
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: my-daemonset
    spec:
      selector:
        matchLabels:
          name: my-daemonset
      template:
        metadata:
          labels:
            name: my-daemonset
        spec:
          containers:
          - name: my-daemonset
            image: nginx # Use appropriate image
    ```
2.  **Apply DaemonSet:**
    ```bash
    kubectl apply -f daemonset.yaml
    ```
3.  **Verify DaemonSet:**
    ```bash
    kubectl get daemonsets
    ```

## Conclusion

Kubernetes automates container management, making systems more resilient, scalable, and efficient. While Docker is used to build and package containers, Kubernetes is responsible for managing and orchestrating them.
