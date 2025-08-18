# Kubernetes Learning Notes

![k8s cheatsheet](/Media/k8s_cheatsheet.png)

### Creating a Kubernetes Cluster with `kubeadm`

`kubeadm` is a Kubernetes tool for bootstrapping a cluster on existing machines, often used for learning and self-managed setups.
*   **`kubeadm init`**: This command initializes the primary control-plane node by setting up its core components (API server, etcd, etc.).
*   **`kubeadm join`**: Using a token from the `init` process, this command securely adds worker or additional control-plane nodes to the cluster.
For local development, tools like Minikube, Kind, or k3s offer simpler single-command cluster creation. (e.g. `minikube start`)

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

The Control Plane components act as the brain of the cluster. They are the core services that manage the cluster's state, make global decisions (like scheduling), and detect and respond to cluster events. In a typical `kubeadm` setup, they run as **static pods**, which are managed directly by the kubelet on the control-plane node and defined by manifest files in `/etc/kubernetes/manifests/`.

-   **kube-apiserver (API Server):**
    - Central management point for the entire cluster. 
    - It exposes the Kubernetes API which is the main entry point for all cluster operations, processing all requests from `kubectl`, other components, and external clients.
    -   Validates and processes requests: performs authentication, authorization, and admission control (e.g., applying security policies, resource quotas) before persisting objects to etcd.
    -   The only component that directly interacts with `etcd` to store and retrieve cluster state and configuration.
    -   Coordinates actions between other control plane components (like kube-scheduler, kube-controller-manager) and worker node agents (kubelets) by serving as their primary interface to the cluster state.
    -   Designed to scale horizontally for high availability (can run multiple instances).
-   **etcd:**
    -   Stores all cluster data and represents the desired state of the cluster.
    -   Backup and restore of the entire cluster state is made from etcd snapshots.
    -   A consistent and highly-available distributed key-value store.
-   **kube-scheduler (Scheduler):**
    -   Assigns newly created Pods (which it discovers via the kube-apiserver) to available Nodes.
    -   Considers various factors for scheduling decisions: resource requirements, affinity/anti-affinity rules, taints/tolerations, Pod priority, and other policies/constraints.
-   **kube-controller-manager (Controller Manager):**
    -   Runs controller processes that monitor the cluster state.
    -   Works to make the current cluster state match the desired state stored in etcd.
    
    -   Examples: Node controller, Replication controller.
-   **cloud-controller-manager (Cloud Controller Manager):**
    -   Runs controllers that interact with the underlying cloud provider's API.
    -   Allows Kubernetes to be cloud-agnostic by separating cloud-specific logic.

### Worker Node Components

Worker Node components are the services that run on every node. Their primary job is to run and maintain the pods assigned to them and provide the Kubernetes runtime environment.

-   **kubelet:**
    -   Reports node and pod health/status back to the control plane (kube-apiserver).
    -   It is the primary agent that runs on **every node** in the cluster (both control-plane and worker).
    -   Its startup parameters (environment variables) can be found in `/var/lib/kubelet/kubeadm-flags.env`, which is useful for debugging node configuration issues.
-   **Container Runtime:**
    -   The software responsible for running containers (e.g., downloading images, starting/stopping containers).
    -   Kubernetes supports various runtimes via the Container Runtime Interface (CRI).
    -   Examples: Docker, containerd, CRI-O.
-   **kube-proxy:**
    -   Responsible for implementing the Kubernetes Service concept.
    -   Maintains network rules on nodes to route traffic to a Service's IP address and port to the correct backend Pods (load balancing).
    -   Enables network communication to Pods from network sessions inside or outside of the cluster.
-   **Pods:**
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
-   Provide a scope for object names; an object name must be unique within its namespace for its resource type.
-   Each namespace must define its own ConfigMap.
-   **Use Cases:**
    -   Grouping resources for different teams or projects.
    -   Resolving naming conflicts when multiple teams deploy the same application.
    -   Sharing resources between environments like staging and development.
    -   Enforcing access control and resource quotas on a per-namespace basis.

#### Common Namespace Commands:

-   Get list of all namespaces:
    ```bash
    kubectl get namespace
    # or
    kubectl get ns
    ```
-   Create a namespace:
    ```bash
    kubectl create namespace test
    # or
    kubectl create ns test
    ```
-   Get list of pods in a specific namespace (e.g., monitoring):
    ```bash
    kubectl get pods -n monitoring
    ```
    The `-n` flag specifies the namespace to query.

#### Default Namespaces

After a Kubernetes cluster is created, you can find these pre-created namespaces:

-   `default`: The default namespace for objects with no other namespace specified.
-   `kube-system`: The namespace for objects created by the Kubernetes system itself.
-   `kube-public`: This namespace is created automatically and is readable by all users (including those not authenticated). It's primarily for cluster usage, in case some resources need to be publicly visible and readable throughout the cluster. The public aspect of this namespace is a convention, not a strict requirement.
-   `kube-node-lease`: This namespace holds Lease objects associated with each node. Node leases allow the kubelet to send heartbeats so that the control plane can detect node failure.

### Pod

-   The simplest and smallest deployable unit in Kubernetes.
-   Represents a single instance of an application/process running in the cluster.
-   Usually wraps one or more containers.
-   Can be replicated (scaled horizontally) using higher-level objects like ReplicaSets or Deployments.
-   **Priority & Preemption:** A `priorityClassName` can be assigned to a Pod. If a high-priority pod cannot be scheduled, the scheduler can evict a lower-priority pod to make room. This ensures critical workloads can always run.

-   `--dry-run=client`: Quick, local syntax check and template generation.
-   `--dry-run=server`: More thorough validation against the actual API server and its logic, good for pre-flight checks and understanding server-side mutations.

A basic Pod manifest can be generated with `kubectl run`:
```bash
kubectl run i-know-who-i-am --image=busybox:1.34 --dry-run=client -o yaml
```

**Example Pod YAML:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: i-know-who-i-am
  namespace: default
  labels:
    app: nginx
spec:
  priorityClassName: high-priority # Assigns a pre-defined PriorityClass
  containers:
  - name: main
    image: busybox:1.34
    ports:
    - containerPort: 80
    command: ["sh", "-c", "env && sleep infinity"]
    env:
        - name: STUDENT_FIRST_NAME
          value: "Kerem"
        - name: STUDENT_LAST_NAME
          value: "Ar"
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: MY_POD_SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName
  # Init containers run to completion in order before main containers start
  initContainers:
  - name: wait-for-db
    image: busybox:1.28
    command: ['sh', '-c', "echo 'Waiting for database...' && sleep 5 && echo 'Database ready!'"]
```
#### Common Pod Commands

-   **List Pods:**
    ```bash
    kubectl get pods # In current namespace
    kubectl get pods -A # In all namespaces
    ```
-   **Get Detailed Information:**
    ```bash
    kubectl describe pod <pod-name>
    ```
-   **View Pod Logs:**
    ```bash
    kubectl logs <pod-name>
    ```
-   **Execute a Command in a Pod:**
    ```bash
    kubectl exec -it <pod-name> -- /bin/bash
    ```
-   **Manage Pod Labels:**
    ```bash
    kubectl get pod <pod-name> --show-labels
    kubectl label pods <pod-name> environment=deployment
    ```
-   **Delete Pods:**
    ```bash
    kubectl delete pod <pod-name>
    kubectl delete pods --all -n <namespace-name> # Delete all pods in a namespace
    ```

### ReplicaSet

-   Ensures that a specified number of identical Pod replicas are running at any given time.
-   Maintains a constant number of Pod instances to prevent application downtime if a Pod fails.
-   Automatically replaces failed Pods.
-   Does not handle updates to pod templates automatically. If you change the pod spec (like the container image), you must manually delete and recreate the ReplicaSet or the pods.
-   Uses a `selector` (with `matchLabels`) to identify the Pods it manages.
-   Includes a `template` section defining the specification for the Pods it should create.
-   **When to Use:** Choose ReplicaSets when you don't need automatic Pod upgrades (use Deployments for that) or when implementing custom upgrade logic. For batch jobs, prefer the `Job` resource. For running a Pod on every node, use `DaemonSet`.

#### ReplicaSet Scenarios for Manual Control

While Deployments are generally preferred, ReplicaSets offer fine-grained manual control in specific scenarios, especially when automatic updates or rollback logic are not desired:

1.  **Detailed Canary Deployments:**
    *   Allows exposing a new version to a very small, specific user percentage (e.g., 1% traffic) for extended monitoring.
    *   Achieved by creating two ReplicaSets (old and new versions) and manually adjusting pod counts to precisely control traffic distribution, offering more granular control than standard Deployment strategies.

2.  **Blue/Green Deployments:**
    *   **Blue Environment:** Runs the current, stable version (e.g., ReplicaSet A with 3 pods).
    *   **Green Environment:** Runs the new version (e.g., ReplicaSet B with 3 pods).
    *   The new version in the Green environment is tested thoroughly.
    *   If tests pass, traffic is switched instantly from Blue to Green by updating the Service configuration.
    *   If issues arise in Green, traffic is immediately reverted to Blue by updating the Service again.
    *   "Manual control" here means explicitly deciding which ReplicaSet (and thus version) receives live traffic and managing pod counts for each version independently, bypassing Deployment's automated rolling updates.

- ReplicaSet can be used on its own, but it's rare. The most valid use case is blue-green deployment, or when you need manual control without auto-updates or rollback logic

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

#### Scaling a ReplicaSet

For example, to scale a ReplicaSet named `frontend` to 2 replicas:
```bash
kubectl scale --replicas=2 rs/frontend
```

### Deployment

-   Manages the application lifecycle through ReplicaSets, handling rolling updates (by creating a new ReplicaSet and gradually scaling it up while scaling down the old one), rollbacks (by reverting to a previous ReplicaSet's state), and ensuring zero-downtime deployments.
-   Suitable for stateless applications (does not store any data or state between requests.).
-   Defines the desired state (e.g., number of replicas, container image, template) and the Deployment controller changes the actual state to match.

**Why Expose a Deployment?**

A Deployment itself (which manages Pods) is not directly accessible from outside its own Pod network or from outside the cluster by default. To make the application running in a Deployment's Pods accessible, you "expose" it, typically using a Service. You expose a Deployment to:

*   Allow other services or Pods within the cluster to communicate with it.
*   Allow users or systems outside the cluster to access your application (e.g., a website or an API), often via an Ingress controller in conjunction with a Service.

A basic Deployment manifest can be generated with `kubectl create`:
```bash
kubectl create deployment nginx-deployment --image=nginx:1.7.9 --replicas=3 --dry-run=client -o yaml
```

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

2.  **Expose Deployment as NodePort Service:**
    ```bash
    kubectl expose deployment my-deployment1 --port=80 --type=NodePort --name=my-service1 --target-port=80
    ```

#### Setting a New Deployment Image

For example, to set the `nginx` container in the Deployment named `my-dep` to use the `nginx:1.9.1` image:
```bash
kubectl set image deployment/my-dep nginx=nginx:1.9.1
```

#### Scaling a Deployment

For example, to scale the Deployment named `my-dep` to 5 replicas:
```bash
kubectl scale deployments.apps my-dep --replicas=5
```

#### Common Deployment Commands

-   **Get Deployment Details:**
    ```bash
    kubectl get deployment my-dep
    ```
-   **Check Rollout Status:**
    ```bash
    kubectl rollout status deployment <deployment-name>
    ```
-   **Edit a Live Deployment:**
    ```bash
    kubectl edit deployment <deployment-name>
    ```
-   **Create a HorizontalPodAutoscaler:**
    ```bash
    kubectl autoscale deployment my-dep --min=2 --max=10 --cpu-percent=80
    ```



### StatefulSet

-   Manages the deployment and scaling of a set of Pods, specifically designed for **stateful applications**.
-   Stable identities(when pod get replaced with new pod it keeps that identity)
-   Persistent storage (different volumes for each pod, continously synchronizing data, storage has the state of the pod)
-   Ordered startup/shutdown (pod-0, pod-1, pod-2)
-   If we changed volume claim template, we should delete statefulset then create again. Because volume claim templates are immutable.
-   We create a headless service before a StatefulSet so each pod gets a stable DNS hostname. This is required because StatefulSet pods need to communicate with each other using fixed names (like pod-0, pod-1) for clustering and data consistency.

**Key Characteristics:**

1. **Pod Identity:**
   - Each Pod gets a fixed, predictable name (e.g., mysql-0, mysql-1, mysql-2)
   - Pods maintain their identity even after rescheduling
   - Each Pod gets its own DNS endpoint

2. **Ordered Operations:**
   - Pods are created in order (0, 1, 2...)
   - Pods are deleted in reverse order (2, 1, 0)
   - Next Pod won't be created until previous one is running

3. **Storage:**
   - Each Pod gets its own persistent storage
   - Storage is tied to Pod's identity
   - Requires remote storage for Pod rescheduling
   - Data synchronization between Pods must be configured manually

4. **Use Cases:**
   - Databases (MySQL, MongoDB, Elasticsearch)
   - Applications that need to maintain state
   - Applications requiring ordered deployment/scaling


Deploying a StatefulSet

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

#### Setting a New StatefulSet Image

For example, to set the `nginx` container in the StatefulSet named `nginx` to use the `nginx:1.9.1` image:
```bash
kubectl set image statefulset/nginx nginx=nginx:1.9.1
```

#### Scaling a StatefulSet

For example, to scale the StatefulSet named `nginx` to 1 replica:
```bash
kubectl scale statefulsets.apps nginx --replicas=1
```


### DaemonSet

-   Ensures that all (or some specified) Nodes run a copy of a specific Pod.
-   Pods are automatically added to new nodes joining the cluster.
-   But not all nodes are available to every Pod — some are tainted for specific workloads.
-   That's why we use tolerations in DaemonSet Pods, so they can still run on tainted nodes too.
-   As nodes are removed from the cluster, the DaemonSet controller ensures that Pods running on those nodes are garbage collected (automatically deleted).
-   Deleting a DaemonSet Will clean up the Pods it created
-   The `spec.selector` field of a DaemonSet is immutable; to change it, the DaemonSet must be deleted and recreated.
-   Useful for cluster-level agents like log collectors, monitoring agents, or storage daemons.

   ```yaml
   apiVersion: apps/v1
   kind: DaemonSet
   metadata:
     name: fluentd-elasticsearch
     labels:
       app: fluentd-elasticsearch
   spec:
     selector:
       matchLabels:
         app: fluentd-elasticsearch
     template:
       metadata:
         labels:
           app: fluentd-elasticsearch
       spec:
         tolerations:
          # This toleration allows the Pod to run on the control-plane node
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          # This toleration allows the Pod to run on the worker node
          - key: "node-role.kubernetes.io/worker"
            operator: "Exists"
            effect: "NoSchedule"
         containers:
         - name: fluentd-elasticsearch
           image: quay.io/fluentd_elasticsearch/fluentd:v4
           resources:
             limits:
               memory: "200Mi"
             requests:
               cpu: "100m"
               memory: "200Mi"
           volumeMounts:
           - name: varlog
             mountPath: /var/log
           - name: varlibdockercontainers
             mountPath: /var/lib/docker/containers
             readOnly: true
         volumes:
         - name: varlog
           hostPath:
             path: /var/log
         - name: varlibdockercontainers
           hostPath:
             path: /var/lib/docker/containers
   ```

### Taints and Tolerations

Taints and tolerations are used to control which pods can be scheduled on which nodes.

**Taints:**
- Applied to nodes to **prevent** pods from being scheduled on them if they don't have a matching toleration.
- Three effects:
  - `NoSchedule`: Pods without matching toleration won't be scheduled
  - `PreferNoSchedule`: System will try to avoid scheduling pods without matching toleration
  - `NoExecute`: Pods without matching toleration will be evicted if already running

**Common Taint Patterns:**
- Control-plane nodes: `node-role.kubernetes.io/control-plane:NoSchedule`
- Worker nodes: `node-role.kubernetes.io/worker:NoSchedule`
- Taint keys can be arbitrary; you are not required to follow common patterns like `node-role.kubernetes.io/worker`.

**Commands:**
```bash
# Add a taint
kubectl taint nodes <node-name> node-role.kubernetes.io/worker:NoSchedule

# Remove a taint
kubectl taint nodes <node-name> node-role.kubernetes.io/worker:NoSchedule-

# List node taints
kubectl describe node <node-name> | grep Taints
```

**Tolerations:**
- Applied to pods to allow them to be scheduled on tainted nodes
- Can be specific to a taint or general:
  ```yaml
  tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"
  ```
- General toleration for all NoSchedule taints:
  ```yaml
  tolerations:
  - operator: "Exists"
    effect: "NoSchedule"
  ```

**Common Use Cases:**
- Keeping control-plane nodes dedicated to system workloads
- Creating specialized worker nodes for specific workloads
- Ensuring DaemonSets can run on all nodes regardless of taints



#### Node Affinity

Node Affinity is a Pod scheduling feature that attracts Pods to a specific set of nodes based on their labels. It allows you to constrain which nodes your Pod can be scheduled on for example, to ensure a Pod runs on a node with specialized hardware like a GPU or SSD.
It comes in two forms: 

-   **`requiredDuringSchedulingIgnoredDuringExecution`**: The pod will *only* be scheduled on a node if the label condition is met. If the node's labels change later, the pod continues to run.
-   **`preferredDuringSchedulingIgnoredDuringExecution`**: The scheduler *tries* to find a node matching the label condition. If not found, the pod can still be scheduled on other nodes.

Node affinity provides more expressive control over pod scheduling based on node characteristics. It can be used alongside or as an alternative to taints and tolerations.
```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: ssd
            operator: In
            values:
            - "true"
```
#### Pod Affinity and Anti-Affinity
Pod Affinity and Anti-Affinity schedule pods based on the labels of other pods already running on a node.


-   **Pod Affinity vs. Node Affinity (Scenarios):**
    -   **Node Affinity** answers: "*Which nodes should this pod run on?*" (e.g., "Run this pod on a node with an SSD disk").
    -   **Pod Affinity** answers: "*Which other pods should this pod run near?*" (e.g., "Run this web server pod on the same node as the redis cache pod for low latency").
    -   **Pod Anti-Affinity** answers: "*Which other pods should this pod stay away from?*" (e.g., "Ensure that replicas of my database pod run on different nodes for high availability").
    
### Service

Pods are frequently created and destroyed, causing their IP addresses to change. A Service provides a stable, virtual IP address (ClusterIP) and a consistent DNS name, ensuring reliable access to the application even as individual Pods come and go.

-   Defines a logical set of Pods (typically selected via labels) and an access policy for them, enabling **loose coupling** between client applications and backend Pods; clients only need to know the Service's stable address.
-   Distributes network traffic across the selected Pods, providing **load balancing** to prevent any single Pod from being overwhelmed and to improve application availability.
-   Uses selectors to dynamically discover and route traffic to the appropriate backend Pods.
-   Supports multiple protocols (TCP default, UDP, etc.) and port definitions for flexible communication.


**Service Types:**

1.  **`ClusterIP`:** (Default) Exposes the service on an internal IP within the cluster. Makes the service reachable only *from within* the cluster. Used for inter-service communication (e.g., frontend to backend).
     **`Headless Service`:** A Headless Service is a type of Service used for direct Pod discovery without providing a stable IP or load balancing. By setting `clusterIP` to `None`, the DNS system is configured to return the IP addresses of all individual Pods backing the service. This is primarily used with StatefulSets, where stateful applications like databases need to discover and communicate with their peers directly.
2.  **`NodePort`:** Allows external access by exposing the service on a static port on each Node's IP, but this method is often not recommended for production security. It operates at Layer 4 (TCP/UDP), making it suitable for any kind of network traffic (e.g., databases, message brokers). Routes traffic to the `ClusterIP` service automatically.
3.  **`LoadBalancer`:** Exposes the service externally using a cloud provider's load balancer. Automatically creates `NodePort` and `ClusterIP` services. Provides an external IP address.
4.  **`ExternalName`:** Maps the service to an external DNS name (using a CNAME record) instead of using selectors. Useful for accessing external services from within the cluster.


  A basic Service manifest can be generated with `kubectl create`:
    ```bash
    # This creates a manifest for a NodePort service, exposing the service on port 80
    kubectl create service nodeport hello-hello-service --tcp=80:80 --node-port=30300 --dry-run=client -o yaml
    ```
    **Example NodePort Service YAML:**
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: hello-hello-service
      namespace: default # Assuming hello-hello deployment is in default
    spec:
      type: NodePort
      selector:
        app: hello-hello # IMPORTANT: Replace with the actual label key-value from the deployment
      ports:
        - protocol: TCP
          port: 80 # Port the service is available on within the cluster
          targetPort: 80 # Port on the Pods
          nodePort: 30300 # Static port on the Node
    ```

#### Common Service Commands
- **Expose a Deployment:** This is the quickest way to create a service for an existing deployment.
  ```bash
  # Expose deployment 'my-app' as a NodePort service on port 80, targeting pod port 8080
  kubectl expose deployment my-app --name=my-app-svc --type=NodePort --port=80 --target-port=8080

  # Expose deployment 'my-app' as a ClusterIP service
  kubectl expose deployment my-app --name=my-app-svc --port=80 --target-port=8080 # type is ClusterIP by default
  ```

- **Create a Service with a specific selector:** Use this when you need more control than `expose` provides, for example, to create a headless service or target pods not managed by a single deployment.
  ```bash
  # Create a standard ClusterIP service with a specific TCP port mapping and selector
  kubectl create service clusterip my-app-svc --tcp=80:8080 --selector="app=myapp"

  # Create a Headless service by setting clusterIP to "None"
  kubectl create service clusterip my-app-headless-svc --clusterIP="None" --tcp=80:8080 --selector="app=myapp"
  ```

### Ingress

Ingress is a Kubernetes API object that manages external access to services within a cluster, typically for Layer 7 (HTTP/HTTPS) traffic. It acts as a smart router or an entry point, allowing you to define rules for how incoming traffic should be directed to backend services based on hostnames or URL paths. This provides a way to consolidate routing rules into a single resource.

**Benefits:**
-   **Load Balancing:** Distributes incoming traffic across appropriate backend service's `ClusterIP` port (the `targetPort`), managed by the Ingress controller.
-   **Cost-Effectiveness:** Can reduce the need for multiple external `LoadBalancer` services by exposing many services through a single Ingress point, potentially lowering cloud provider costs.


#### Key Concepts and Components

-   **Ingress Resource:** A Kubernetes object where you define the routing rules. It specifies how traffic from outside the Kubernetes cluster should reach services inside the cluster.
-   **Ingress Controller:**
    -   The Ingress resource itself doesn't do anything on its own. It's a set of rules. An Ingress controller is an application (typically a reverse proxy like NGINX, Traefik, or HAProxy) that runs in the cluster and is responsible for fulfilling the Ingress rules by watching the API server for Ingress resources.
    -   When an Ingress resource is created, the Ingress controller configures itself (e.g., updates its NGINX configuration) to route traffic according to those rules.
    -   You need to have an Ingress controller deployed in your cluster for Ingress resources to work. Common controllers include NGINX Ingress Controller, Traefik Kubernetes Ingress provider, and HAProxy Ingress. Cloud providers often offer their own managed Ingress controllers.
-   **IngressClass:** A resource that specifies which Ingress controller should handle the Ingress. It's necessary when you have multiple controllers in your cluster (e.g., one for internal traffic, another for external). An Ingress object requests a class using the `spec.ingressClassName` field.
-   **Rules:** Define how traffic is routed. Rules can be based on:
    -   **Host:** Direct traffic based on the requested hostname (e.g., `api.example.com`, `blog.example.com`). This is also known as virtual hosting.
    -   **Path:** Direct traffic based on the requested URL path (e.g., `example.com/api`, `example.com/ui`).
    -   A combination of both host and path.
-   **Backend Service:** The Kubernetes Service that traffic is ultimately routed to after matching a rule.
-   **Default Backend:** An optional catch-all service. If no rules in the Ingress match an incoming request, the traffic is routed to the default backend. This is often a custom error page or a default application.
-   **TLS/SSL Termination:** Ingress can terminate SSL/TLS connections. You can specify a Kubernetes Secret (containing a TLS certificate and private key) in your Ingress resource. The Ingress controller will use this certificate to secure traffic from clients, and then forward traffic to backend services, possibly unencrypted (HTTP).

#### Example Ingress YAML
A basic Ingress manifest with rules can be generated with `kubectl create`:
    ```bash
    kubectl create ingress my-ingress-example --rule="myapp.com/user=user-service:80" --class=nginx --dry-run=client -o yaml
    ```

This example shows an Ingress that routes traffic based on host and path.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress-example
  annotations:
    # Annotations are often used to configure Ingress controller-specific behavior
    # For example, with an NGINX Ingress controller:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  # Specify an IngressClass to choose which controller implements the rules.
  ingressClassName: "nginx-example"
  tls: # Optional: For TLS termination
  - hosts:
    - myapp.example.com
    secretName: myapp-tls-secret # Secret containing TLS cert and key
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /user
        pathType: Prefix # Options: Prefix, Exact, ImplementationSpecific
        backend:
          service:
            name: user-service
            port:
              number: 80
      - path: /order
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 8080
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1-service
            port:
              number: 3000
  defaultBackend: # Optional
    service:
      name: default-http-backend # A service to handle unmatched requests
      port:
        number: 80
```

**Explanation of fields:**

-   `metadata.annotations`: Used for controller-specific settings. The example `nginx.ingress.kubernetes.io/rewrite-target: /` is common for NGINX Ingress to correctly route paths.
-   `spec.ingressClassName`: (Recommended) Specifies which Ingress controller should handle this Ingress if multiple are present.
-   `spec.tls`: Defines TLS settings.
    -   `hosts`: List of hosts covered by the TLS certificate.
    -   `secretName`: The name of the Secret containing the TLS certificate and key.
-   `spec.rules`: A list of routing rules.
    -   `host`: The hostname to match.
    -   `http.paths`: A list of path-based rules for that host.
        -   `path`: The URL path to match.
        -   `pathType`: How the `path` should be matched. This is a crucial field that determines matching behavior:
            -   **`Prefix`**: Matches based on a URL path prefix. The rule `/foo` with `pathType: Prefix` will match `/foo`, `/foo/`, `/foo/bar`, `/foobar` (if not followed by a `/` and the controller interprets it this way), etc. It's the most common and flexible type. The matching is case-sensitive. A common gotcha is that `/foo` will match `/foobar` unless your Ingress controller has specific logic to prevent it or you use `/foo/` (with a trailing slash) to be more specific about matching directory-like paths.
            -   **`Exact`**: Matches the URL path exactly as specified, and it is case-sensitive. The rule `/foo` with `pathType: Exact` will only match `/foo`. It will not match `/foo/` or `/foo/bar`.
            -   **`ImplementationSpecific`**: With this `pathType`, the matching behavior depends entirely on the Ingress controller being used (e.g., NGINX, Traefik). Its behavior is not strictly defined by the Kubernetes Ingress specification and can vary. It's generally recommended to use `Prefix` or `Exact` for predictable behavior unless you specifically need a feature unique to your Ingress controller's implementation of this type.
        -   `backend.service.name`: The name of the backend Service.
-   `spec.defaultBackend`: Specifies a default Service to route to if no rules match.

#### Managing Ingress Resources

-   **Create an Ingress:**
    - Declaratively (recommended):
      ```bash
      kubectl apply -f my-ingress.yaml
      ```
    - Imperatively:
      ```bash
      # Create a simple Ingress for a single service
      kubectl create ingress my-ingress --class=nginx --rule="myapp.com/=my-service:80"

      # Create an Ingress with multiple path-based rules and a default backend
      kubectl create ingress multi-rule-ingress --class=nginx \
        --rule="colors.k8slab.net/aqua=aqua-svc:80" \
        --rule="colors.k8slab.net/maroon=maroon-svc:80" \
        --default-backend=olive-svc:80
      ```

-   **List Ingresses:**
    ```bash
    kubectl get ingress
    # or
    kubectl get ing
    ```
-   **Describe an Ingress (to see details and events):**
    ```bash
    kubectl describe ingress my-ingress-example
    ```
-   **Delete an Ingress:**
    ```bash
    kubectl delete ingress my-ingress-example
    ```

### NetworkPolicy

A `NetworkPolicy` acts as a firewall for Pods in Kubernetes. It defines rules to specify which Pods can communicate with each other and other network endpoints, which is crucial for security and creating isolated environments. By default, all pods in a cluster can communicate freely with each other

**Example Ingress Policy:**
This policy selects pods with `app: backend` and only allows incoming traffic from pods with the label `role: frontend`.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-ingress-policy
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
```

**Example Egress Policy:**
This policy selects pods with `role: frontend` and only allows outgoing traffic to pods with the label `app: backend` on port 80.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-egress-policy
spec:
  podSelector:
    matchLabels:
      role: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 80
```

### Secrets

Secrets are Kubernetes objects used to store and manage sensitive information, such as passwords, OAuth tokens, and SSH keys. Storing this information in a Secret is more secure than putting it verbatim in a Pod definition or in a container image.

#### Overview of Secrets

- Secrets allow you to control how sensitive information is used and reduce the risk of accidental exposure.
- Data in Secrets is stored base64 encoded by default, but it's important to note that base64 is an encoding, not an encryption, scheme. For true protection, additional measures like etcd encryption at rest and RBAC policies are crucial.
- Secrets can be mounted as data volumes or exposed as environment variables to be used by containers in a Pod.

#### Creating Secrets

Secrets can be created in a few ways:

1.  **Using `kubectl` (Imperative Commands):**
    -   **From literal values:**
        ```bash
        kubectl create secret generic <secret-name> --from-literal=username='admin' --from-literal=password='s3cr3t'
        ```
    -   **From files:**
        Create files, e.g., `username.txt` containing `admin` and `password.txt` containing `s3cr3t`.
        ```bash
        kubectl create secret generic <secret-name> --from-file=./username.txt --from-file=./password.txt
        ```
    -   **For Docker registry credentials (image pull secrets):**
        ```bash
        kubectl create secret docker-registry <secret-name> --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
        ```

2.  **Manually (Declarative - YAML manifest):**
    Create a YAML file (e.g., `my-secret.yaml`):
    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: my-manual-secret
    type: Opaque # Default type, can be other types like kubernetes.io/service-account-token, kubernetes.io/dockerconfigjson
    data:
      # Values must be base64 encoded
      # echo -n 'admin' | base64  -> YWRtaW4=
      # echo -n 's3cr3t' | base64 -> czNjcjN0
      username: YWRtaW4=
      password: czNjcjN0
    # stringData can be used for non-binary data, Kubernetes will base64 encode it for you
    # stringData:
    #   username: admin
    #   password: password123
    ```
    Then apply it:
    ```bash
    kubectl apply -f my-secret.yaml
    ```

#### Decoding Secrets

To view the decoded data from a Secret:
```bash
# Get the secret in YAML format
kubectl get secret my-secret -o yaml

# To decode a specific data field (e.g., username):
# Replace <base64-encoded-string> with the actual encoded value from the secret
echo '<base64-encoded-string>' | base64 --decode
```
For example, if `username` in the secret is `YWRtaW4=`:
```bash
echo 'YWRtaW4=' | base64 --decode
# Output: admin
```

#### Consuming Secrets

Secrets can be consumed by Pods in two main ways:

1.  **As Environment Variables:**
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: secret-env-pod
    spec:
      containers:
      - name: mycontainer
        image: redis
        env:
          - name: SECRET_USERNAME
            valueFrom:
              secretKeyRef:
                name: my-secret # Name of the Secret
                key: username  # Key within the Secret
          - name: SECRET_PASSWORD
            valueFrom:
              secretKeyRef:
                name: my-secret
                key: password
      restartPolicy: Never
    ```

2.  **As Volumes (files mounted into the Pod):**
    Each key in the Secret becomes a file in the mounted directory.
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: secret-volume-pod
    spec:
      containers:
      - name: mycontainer
        image: nginx
        volumeMounts:
        - name: secret-storage
          mountPath: "/etc/mysecret" # Path where secret files will be mounted
          readOnly: true
      volumes:
      - name: secret-storage
        secret:
          secretName: my-secret # Name of the Secret
    # Files in /etc/mysecret would be 'username' and 'password'
    # containing the decoded values.
    ```

#### When to Use Which Method (Secrets)

In general, for single, discrete sensitive values, environment variables are often simpler. For sets of related sensitive data or file-based sensitive configurations, volumes are more powerful and flexible, especially when updates need to be reflected in running Pods (if the application supports reloading).

---

### ConfigMap

ConfigMaps are Kubernetes objects used to store non-confidential configuration data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume.


#### ConfigMaps Overview

-   Store configuration data that Pods can use.
-   Allow you to separate configuration from your application code.
-   Data is stored as key-value pairs.
-   Can be used to store entire configuration files or individual property values.
-   Not designed for sensitive data (use Secrets for that).

#### Creating ConfigMaps

ConfigMaps can be created from directories, files, or literal values:

1.  **From Files:**
    Create a file, e.g., `app-config.properties`:
    ```properties
    app.color=blue
    app.environment=dev
    ```
    Then create the ConfigMap:
    ```bash
    kubectl create configmap <configmap-name> --from-file=app-config.properties
    # This creates a ConfigMap with one key 'app-config.properties',
    # and its value is the content of the file.
    #
    # To create a key for each file with file content as value:
    kubectl create configmap <configmap-name> --from-file=path/to/config1.conf --from-file=path/to/config2.conf
    # This creates keys like 'config1.conf' and 'config2.conf'
    ```

2.  **From Directories:**
    If you have a directory with multiple configuration files:
    ```bash
    # Assume 'my-configs/' directory contains 'game.properties' and 'ui.properties'
    kubectl create configmap <configmap-name> --from-file=./my-configs/
    # This creates a ConfigMap where each file in 'my-configs/' becomes a key,
    # and the file content is its value.
    ```

3.  **From Literal Values:**
    ```bash
    kubectl create configmap <configmap-name> \
      --from-literal=app.mode=test \
      --from-literal=app.retries=5
    ```

4.  **Declaratively (YAML manifest):**
    Create a YAML file (e.g., `my-configmap.yaml`):
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: my-app-config
    data:
      # Key-value pairs
      database.host: "mysql-server"
      database.port: "3306"

      # You can also embed file-like content
      app.conf: |
        property1=value1
        property2=value2
        complex.setting=true
    ```
    Then apply it:
    ```bash
    kubectl apply -f my-configmap.yaml
    ```

#### Accessing ConfigMaps in Pods

ConfigMaps can be accessed by Pods in several ways:

1.  **As Environment Variables:**
    Each key-value pair in the ConfigMap can become an environment variable.
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: configmap-env-pod
    spec:
      containers:
      - name: mycontainer
        image: alpine
        command: [ "sleep", "3600" ]
        env:
          - name: APP_MODE
            valueFrom:
              configMapKeyRef:
                name: app-settings-literal # Name of the ConfigMap
                key: app.mode            # Key within the ConfigMap
          - name: APP_RETRIES
            valueFrom:
              configMapKeyRef:
                name: app-settings-literal
                key: app.retries
        # Or expose all keys from a ConfigMap as environment variables
        # envFrom:
        # - configMapRef:
        #     name: app-settings-literal
    ```

2.  **As Command-line Arguments:**
    While not directly consumed as command-line args, values from ConfigMaps (usually via env vars) can be passed to container entrypoints/commands.
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: configmap-args-pod
    spec:
      containers:
      - name: mycontainer
        image: busybox
        command: [ "sh", "-c", "echo Running in mode $APP_MODE with $APP_RETRIES retries && sleep 3600" ]
        env:
          - name: APP_MODE
            valueFrom:
              configMapKeyRef:
                name: app-settings-literal
                key: app.mode
          - name: APP_RETRIES
            valueFrom:
              configMapKeyRef:
                name: app-settings-literal
                key: app.retries
    ```

3.  **As Volume Mounts (files in a directory):**
    Each key in the `data` field of the ConfigMap becomes a file in the mounted directory.
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: configmap-volume-pod
    spec:
      containers:
      - name: mycontainer
        image: nginx
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config # Path where config files will be mounted
      volumes:
      - name: config-volume
        configMap:
          name: my-app-config # Name of the ConfigMap
          # items: # Optionally specify which keys to mount and their paths
          #   - key: "app.conf"
          #     path: "my_custom_app.conf"
    # If my-app-config has keys 'database.host' and 'app.conf',
    # then /etc/config/database.host and /etc/config/app.conf files will be created.
    ```
    If a ConfigMap used in a volume mount is updated, the mounted files are updated as well (eventually consistent). Pods consuming these files might need to be restarted or have a mechanism to reload their configuration.

#### When to Use Which Method (ConfigMaps)

In general, for single, simple configuration values, environment variables are often sufficient. For providing entire configuration files or for configurations that might need to be updated in running Pods (if the application supports reloading), volume mounts are generally preferred.

### Storage in Kubernetes

By default, any data written to a container's filesystem is **non-persistent** and is lost if the container or Pod restarts. This is suitable for stateless applications but not for those needing data to persist beyond a Pod's lifecycle.

#### How to Persist Data

Kubernetes uses PersistentVolumes (PV), PersistentVolumeClaims (PVC), and StorageClasses to manage durable storage. These abstractions allow data to exist independently of Pods.

##### PersistentVolume (PV)

-   A **PersistentVolume (PV)** is a cluster-wide piece of pre-provisioned storage, managed by an administrator or dynamically via StorageClasses. -   It's a resource in the cluster, like a node, with a lifecycle independent of any Pod.
-   PVs define the actual storage details (NFS, iSCSI, cloud storage) and its capacity, access modes (e.g., RWO, RWX), and reclaim policy.

**Example PersistentVolume YAML (NFS):**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-nfs-pv
spec:
  capacity:
    storage: 5Gi # Total storage capacity of this PV
  volumeMode: Filesystem # Type of volume: Filesystem or Block
  accessModes:
    - ReadWriteMany # How the volume can be mounted: ReadWriteOnce, ReadOnlyMany, ReadWriteMany, ReadWriteOncePod
  persistentVolumeReclaimPolicy: Retain # What happens to PV data when PVC is deleted: Retain, Recycle, Delete
  storageClassName: manual # Links PV to a StorageClass; 'manual' for manually provisioned PVs
  nfs: # Example for NFS storage type
    path: /mnt/nfs_share # Path exported by the NFS server
    server: nfs-server.example.com # Address of the NFS server
```

##### PersistentVolumeClaim (PVC)

-   A **PersistentVolumeClaim (PVC)** is a request for storage by a user or Pod, similar to how a Pod requests CPU/memory. PVCs specify desired storage capacity, access modes, and optionally a StorageClass.
-   Kubernetes binds a PVC to a suitable PV. If dynamic provisioning is enabled via a StorageClass, a PV can be automatically created to satisfy the PVC. PVCs must be in the same namespace as the Pod using them.

**Example PersistentVolumeClaim YAML:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-app-pvc
  namespace: my-app-namespace # PVC must be in the same namespace as the Pod
spec:
  accessModes:
    - ReadWriteOnce # Requested access mode for the storage
  volumeMode: Filesystem
  resources:
    requests:
      storage: 2Gi # Amount of storage requested
  storageClassName: slow # Optional: request a specific StorageClass for dynamic provisioning or matching
  # selector: # Optional: to select a specific PV with matching labels
  #   matchLabels:
  #     release: "stable"
```

**Using PVC in a Pod:**
Pods use PVCs to access persistent storage. The Pod definition references the PVC, and Kubernetes mounts the bound PV into the specified container path.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-persistent-pod
  namespace: my-app-namespace
spec:
  containers:
  - name: my-frontend
    image: nginx
    volumeMounts:
    - mountPath: "/var/www/html" # Path inside the container where storage will be mounted
      name: my-storage # Must match the volume name below
  volumes:
  - name: my-storage
    persistentVolumeClaim:
      claimName: my-app-pvc # Name of the PVC to use for this volume
```

##### StorageClass

-   A **StorageClass** allows administrators to define different "classes" or tiers of storage (e.g., fast SSD, standard HDD, backup storage) with associated provisioners and parameters. They enable **dynamic provisioning** of PVs, automatically creating storage when a PVC requests a particular class.
-   Each StorageClass specifies a `provisioner` (e.g., AWS EBS, GCE PD), `parameters` for that provisioner, and a `reclaimPolicy` for dynamically created PVs.

**Example StorageClass YAML (using AWS EBS provisioner):**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd # Name of the storage class
provisioner: kubernetes.io/aws-ebs # Identifies the underlying storage provisioner (e.g., for AWS EBS)
parameters:
  type: gp2 # Provisioner-specific parameters (e.g., EBS volume type 'gp2' for General Purpose SSD)
  encrypted: "true" # Example parameter: enable encryption for the provisioned volume
reclaimPolicy: Delete # Policy for dynamically provisioned PVs: Delete or Retain (default for dynamic is Delete)
volumeBindingMode: Immediate # When to provision: Immediate (default) or WaitForFirstConsumer (delays until a Pod uses it)
allowVolumeExpansion: true # If true, allows PVCs of this class to be resized later
# mountOptions: # Optional mount options for volumes of this class
#   - debug
```

*   **StorageClass**:
    *   Defines a "class" of storage (e.g., SSD, HDD) and enables dynamic PV provisioning.
    *   *Best Practice*: A default StorageClass is recommended so PVCs without a specified class can still trigger automatic PV creation. This lets users request storage types without needing to know backend details.
*   **PersistentVolume (PV)**:
    *   Represents an actual piece of storage in the cluster (e.g., a physical disk), managed by an admin or dynamically provisioned via a StorageClass.
    *   *Best Practice*: Pods should *not* directly reference PVs in their configuration; this ensures application portability across different clusters.
*   **PersistentVolumeClaim (PVC)**:
    *   A user's request for storage, specifying desired size and access mode.
    *   *Best Practice*: Pods should *always* use PVCs to consume storage. Users can optionally specify a StorageClass in their PVC to request a particular type of storage.
*   **Interaction Flow**:
    *   A PVC requests storage.
    *   It attempts to bind to a suitable, available PV.
    *   If no matching PV is found, and a StorageClass is defined (either in the PVC or as a cluster default), a new PV is dynamically provisioned according to that class and then bound to the PVC.

### Job

-   Creates one or more Pods and ensures that a specified number of them successfully terminate (complete).
-   Tracks the completion of tasks; Pods are usually deleted after the Job completes.
-   Useful for batch processing, one-off tasks, or tasks that need to run to completion.
-   Can scale up using kubectl scale command
-   **CronJob:** Creates Jobs on a repeating schedule (like cron).

```bash
# Command to generate the basic Job manifest YAML:
kubectl create job countdown --image=centos:7 --dry-run=client -o yaml -- /bin/bash -c "for i in 987654321; do echo \$i; done" > countdown-job.yaml
```
```yaml
# Job.yaml YAML file
apiVersion: batch/v1
kind: Job
metadata:
  name: countdown
spec:
  template:
    metadata:
      name: countdown
    spec:
      containers:
      - name: counter
        image: centos:7
        command:
        - "bin/bash"
        - "for i in 987654321; do echo $i; done"
      restartPolicy: Never
```bash
kubectl apply -f Job.yaml
kubectl get jobs
kubectl get pods
kubectl logs <pod-name>
kubectl describe job countdown
kubectl delete job countdown
```

### CronJob

-   Creates Jobs on a repeating schedule (like cron).
-   Useful for scheduled tasks, backups, or any recurring work.
-   Can scale up using kubectl scale command

```
# Cron Schedule Syntax:
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems,
# │ │ │ │ │                                   or use names like sun, mon, tue, wed, thu, fri, sat)
# │ │ │ │ │
# │ │ │ │ │
# * * * * *
```
```bash
# Command to generate the basic CronJob manifest YAML:
kubectl create cronjob hello --image=busybox:1.28 --schedule="* * * * *" --dry-run=client -o yaml -- /bin/sh -c "date; echo Hello from the Kubernetes cluster" > hello-cronjob.yaml
```
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command: 
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          containers:
      restartPolicy: OnFailure
```

#### Manually Triggering a Job from a CronJob Template

You can manually create a Job based on the template of an existing CronJob. This is useful for testing or running the job on demand outside its schedule.

```bash
kubectl create job <new-job-name> --from=cronjob/<your-cronjob-name> -n <namespace-of-cronjob>
# Example:
# kubectl create job manual-run-1 --from=cronjob/hello -n default
```



### Troubleshooting in Kubernetes

#### Understanding Pod Status

When you run `kubectl get pods`, the `STATUS` column gives you a quick insight.

-   **`Running`**: The Pod is bound to a node, and all of its containers have been created. At least one container is still running, or is in the process of starting or restarting.
-   **`Pending`**: The Pod has been accepted by the cluster, but one or more of its container images have not been created. This can be due to scheduling delays (no available nodes), image pull issues, or pending volume mounts.
-   **`Succeeded`**: All containers in the Pod have terminated in success, and will not be restarted. (Common for Jobs).
-   **`Failed`**: All containers in the Pod have terminated, and at least one container has terminated in failure.
-   **`CrashLoopBackOff`**: This is not a status, but a state. It means a container is repeatedly starting and crashing. Kubernetes waits for an increasing amount of time (`back-off`) before restarting it. To debug, you must check the container's logs.
-   **`ImagePullBackOff` / `ErrImagePull`**: Kubernetes could not pull the container image from the registry. This could be due to an incorrect image name/tag, a private registry requiring credentials, or network issues.

#### Core Troubleshooting Commands

-   **`kubectl describe pod <pod-name>`**: The most important command for debugging. Shows a Pod's configuration, status, and most importantly, a list of recent **Events**. Events will often tell you exactly why a Pod is `Pending` or failing (e.g., "FailedScheduling", "FailedMount").
-   **`kubectl logs <pod-name>`**: Essential for `CrashLoopBackOff`. This command prints the logs from the application running inside the container, which usually reveals the cause of the crash (e.g., a configuration error, a bug in the code).
    -   Use `kubectl logs <pod-name> --previous` to see logs from a previously crashed instance of the container.
-   **`kubectl get pods -l app=<label>`**: The most practical way to find all Pods belonging to a specific deployment or service is by using its labels.
-   **Node-level debugging**: If `kubectl` is not enough, you may need to SSH into the node to investigate.
    -   **Log files**: Check `/var/log/pods/` and `/var/log/containers/`.
    -   **Container runtime**: Use `crictl ps` to list containers and `crictl logs <container-ID>` to get logs directly from the runtime (or use `docker` equivalents if applicable).

### Role-Based Access Control (RBAC)

It is a method of regulating access to computer or network resources based on the roles of individual users within an organization. In Kubernetes, RBAC allows administrators to precisely define who can perform what actions on which resources, adhering to the principle of least privilege and enhancing cluster security.

#### Why RBAC is Important

-   **Security**: Restricts users and workloads to only the permissions they absolutely need, reducing the potential impact of a compromised account or application.
-   **Organization**: Helps manage permissions declaratively for numerous users and applications across different namespaces.
-   **Compliance**: Enables auditing and enforcement of access policies.

#### Core RBAC Objects

Kubernetes RBAC is built around four main API objects:

1.  **`Role`** (Namespaced)
    *   Defines permissions *within a specific namespace*. 
    *   A Role contains rules that represent a set of permissions. Permissions are purely additive (there are no "deny" rules).
    *   Each rule specifies `apiGroups`, `resources`, and `verbs`. Common verbs include `get`, `list`, `watch`, `create`, `update`, `patch`, `delete`, and `deletecollection`.

    **Example:** Allow reading Pods in the "default" namespace.

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      namespace: default # Role is specific to this namespace
      name: pod-reader
    rules:
    - apiGroups: [""] # "" indicates the core API group
      resources: ["pods"]
      verbs: ["get", "watch", "list", "create", "update", "patch", "delete", "deletecollection"]
    ```
    ```bash
    # Imperative command to create a similar Role:
    kubectl create role pod-reader --verb=get,watch,list,create,update,patch,delete,deletecollection --resource=pods --namespace=default
    ```

2.  **`ClusterRole`** (Cluster-wide)
    *   Defines permissions *cluster-wide* (rules are similar to `Role` and can use the same verbs).
    *   Can be used for:
        *   Cluster-scoped resources (e.g., nodes, persistent volumes).
        *   Namespaced resources, granting access across *all* namespaces (e.g., allow reading Pods in every namespace).
        *   Non-resource endpoints (e.g., `/healthz`).

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: secret-reader # Name is cluster-wide, no namespace
    rules:
    - apiGroups: [""]
      resources: ["secrets"]
      verbs: ["get", "watch", "list", "create", "update", "patch", "delete", "deletecollection"]
    ```
    ```bash
    # Imperative command to create a similar ClusterRole:
    kubectl create clusterrole secret-reader --verb=get,watch,list,create,update,patch,delete,deletecollection --resource=secrets
    ```

3.  **`RoleBinding`** (Namespaced)
    *   Grants the permissions defined in a `Role` to a user, group, or ServiceAccount *within a specific namespace*.
    *   It links a `Role` to a subject (user, group, or ServiceAccount).

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: read-pods-in-default
      namespace: default # RoleBinding is specific to this namespace
    subjects:
    - kind: User
      name: "jane" # Name is case-sensitive
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: Role # Can be Role or ClusterRole
      name: pod-reader # Name of the Role being granted
      apiGroup: rbac.authorization.k8s.io
    ```
    ```bash
    # Imperative command to create a similar RoleBinding for a User:
    kubectl create rolebinding read-pods-in-default --role=pod-reader --user=jane --namespace=default
    # For a ServiceAccount: kubectl create rolebinding <binding-name> --role=<role-name> --serviceaccount=<namespace>:<sa-name> -n <namespace>
    ```

4.  **`ClusterRoleBinding`** (Cluster-wide)
    *   Grants the permissions defined in a `ClusterRole` to a user, group, or `ServiceAccount` *cluster-wide*.
    *   Used to authorize subjects for all namespaces in the cluster.

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: read-secrets-global
    subjects:
    - kind: Group
      name: "developers"
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: ClusterRole
      name: secret-reader # Name of the ClusterRole being granted
      apiGroup: rbac.authorization.k8s.io
    ```
    ```bash
    # Imperative command to create a similar ClusterRoleBinding for a Group:
    kubectl create clusterrolebinding read-secrets-global --clusterrole=secret-reader --group=developers
    # For a User: kubectl create clusterrolebinding <binding-name> --clusterrole=<clusterrole-name> --user=<user-name>
    ```

#### RBAC Combinations Summary

-   **`Role` + `RoleBinding`**: Grants permissions within a *single namespace*. This is the most common combination for application-specific permissions.
-   **`ClusterRole` + `ClusterRoleBinding`**: Grants permissions *cluster-wide*, across all namespaces. Used for administrators or cluster-wide components.
-   **`ClusterRole` + `RoleBinding`**: Grants permissions from a cluster-wide `ClusterRole` but only *within a single namespace*. This is a powerful, reusable pattern: define a role once (e.g., "view") and apply it to different users/services in different namespaces.

#### Subjects

Subjects are the entities that are being granted permissions. They can be:
-   **User**: Individual human users. These are not managed by Kubernetes directly; they are assumed to be managed by an external identity provider (e.g., LDAP, SAML, X509 certificates).
-   **Group**: A set of users. Like users, groups are not managed by Kubernetes but are provided by the authenticator.
-   **ServiceAccount**: An identity for processes running inside Pods. ServiceAccounts are managed by Kubernetes.

#### ServiceAccounts

A ServiceAccount provides a dedicated identity for processes that run inside a Pod, allowing them to authenticate with the Kubernetes API server. Unlike user accounts, which are for humans, ServiceAccounts are for applications. When a Pod needs to interact with the cluster—for example, to list other Pods or read a ConfigMap—it uses the token from its associated ServiceAccount to do so. These permissions are granted by binding the ServiceAccount to a Role or ClusterRole.

**Example: Creating a ServiceAccount and binding it to a Role:**

   ```bash
    kubectl create serviceaccount my-app-sa -n my-namespace
   ```

1.  **Create a ServiceAccount:**
    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: my-app-sa
      namespace: my-namespace
    ```

#### Common `kubectl` RBAC Commands

-   **Check permissions (can I do something?):**
    ```bash
    kubectl auth can-i get pods --namespace=default
    kubectl auth can-i list nodes --as=jane # Check as another user
    kubectl auth can-i create deployments --namespace=myapp --as=system:serviceaccount:myapp:mysa
    ```



## Filesystem-Hosted Static Pod Creation Steps

These steps describe how to create a static Pod that is managed directly by the kubelet daemon on a specific node, not by the API server.

1.  **(Optional) If using a custom namespace:**
    ```bash
    kubectl create namespace <namespace-name>
    ```
2.  **SSH into Minikube (or your target node):**
    ```bash
    minikube ssh
    ```
3.  **Navigate to the manifest directory:**
    The kubelet periodically scans this directory for Pod manifest files.
    ```bash
    cd /etc/kubernetes/manifests
    ```
4.  **Create the Pod manifest file (e.g., `nginx-static.yaml`):**
    Use `sudo` if necessary to write to this directory.
    ```bash
    sudo vi nginx-static.yaml
    ```

5.  **(Still inside Minikube/node) Restart kubelet:**
    This prompts kubelet to re-scan the manifest directory.
    ```bash
    sudo systemctl restart kubelet
    ```
6.  **Exit Minikube/node:**
    ```bash
    exit
    ```
    Or press `Ctrl+D`.
7.  **Check if the static Pod is running:**
    Static Pods usually have the node name appended to their name and are visible across all namespaces when listing.
    ```bash
    kubectl get pods -A
    ```

**To delete a static Pod:**

Simply remove the manifest file (e.g., `nginx-static.yaml`) from the `/etc/kubernetes/manifests` directory on the node and restart the kubelet again.

```bash
# Inside Minikube/node
sudo rm /etc/kubernetes/manifests/nginx-static.yaml
sudo systemctl restart kubelet
```

### Helm: Kubernetes Package Manager

Helm is a tool for managing **Charts**, which are packages of pre-configured Kubernetes resources. It streamlines installing and managing Kubernetes applications, similar to package managers like `apt`, `yum`, or `homebrew`. Helm renders your templates and communicates with the Kubernetes API, running from your local machine, CI/CD, or other environments.

**Core Helm Concepts:**

*   **Charts**:
    *   Helm's packaging format; a collection of files describing a related set of Kubernetes resources.
    *   Can deploy simple or complex applications (e.g., a memcached pod or a full web stack).
    *   Key files in a chart directory (e.g., `wordpress/`):
        *   `Chart.yaml`: Required. Contains metadata like `apiVersion`, `name` (chart name), `version` (SemVer 2). May also include `kubeVersion`, `description`, `type`, `keywords`, `home`, `sources`, `dependencies`, `maintainers`, `icon`, `appVersion`, `deprecated`, `annotations`.
        *   `values.yaml`: Default configuration values for the chart.
        *   `templates/`: Directory of templates that generate Kubernetes manifest files when combined with values.
        *   Optional: `LICENSE`, `README.md`, `values.schema.json`, `charts/` (dependencies/subcharts), `crds/` (Custom Resource Definitions), `templates/NOTES.txt`.
    *   Charts can be stored on disk or fetched from remote **Chart Repositories**.

*   **Repository**:
    *   A location where Charts are stored and can be shared.

*   **Release**:
    *   An instance of a Chart running in your Kubernetes cluster. Created when you install a chart.

**Key Helm Operations & Commands:**

*   **Search Charts**:
    *   `helm search hub <keyword>`: Search for charts on Artifact Hub (e.g., `helm search hub wordpress`).
    *   `helm search repo <keyword>`: Search repositories added to your local Helm client (e.g., `helm search repo brigade`).
*   **Manage Repositories**:
    *   `helm repo add <repo-name> <repo-url>`: Add a chart repository to your local client (e.g., `helm repo add brigade https://brigadecore.github.io/charts`).
*   **Inspect Charts**:
    *   `helm pull <chart-repo>/<chart-name>`: Download chart files to inspect them without installing.
*   **Manage Releases**:
    *   `helm install <your-release-name> <chart-repo>/<chart-name>`: Install a chart (e.g., `helm install happy-panda bitnami/wordpress`).
    *   `helm list`: List all releases in the current namespace.
    *   `helm uninstall <your-release-name>`: Uninstall a release.

### Custom Resource Definitions (CRDs) in Kubernetes

🧩 **What is a CRD in Kubernetes?**

CRD stands for Custom Resource Definition.

It allows you to define your own resource types in Kubernetes, just like built-in ones like `Pod`, `Service`, or `Deployment`.

💡 **In Simple Terms:**

Kubernetes comes with built-in resources like this:

```yaml
apiVersion: v1
kind: Pod
```

But with CRDs, you can create your own `kind`s, for example:

```yaml
apiVersion: mycompany.com/v1
kind: MyApp
```

Then, you can create and manage `MyApp` resources in your cluster — just like you would with Pods or Deployments.

✅ **What problem does CRD solve?**

Kubernetes is extensible — not everything has to be built-in.

CRDs allow developers and platform teams to:

*   Add new kinds of resources.
*   Build custom controllers/operators to manage them.
*   Store structured data within Kubernetes.
*   Extend Kubernetes to support any type of application or infrastructure.

🔧 **How does it work?**

1.  You define a CRD, which registers a new resource type with the API server.
2.  You can now `kubectl get`, `apply`, etc., your custom resource (CR).
3.  (Optional) You write a controller or operator to watch and act on these CRs.

🛠️ **Example**

Let's say you're building a database operator. You define a CRD for `MySQLCluster`:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: mysqlclusters.mycompany.com
spec:
  group: mycompany.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                replicas:
                  type: integer
  scope: Namespaced
  names:
    plural: mysqlclusters
    singular: mysqlcluster
    kind: MySQLCluster
```

Now you can do:

```bash
kubectl get mysqlclusters
kubectl apply -f my-db-cluster.yaml
```

🧠 **CRD vs Controller vs Operator**

| Concept      | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| CRD          | Schema/definition of your custom resource (e.g., "I have a new kind called `MySQLCluster`) |
| Custom Resource (CR) | An instance of your CRD (e.g., `mysql-db-prod`)                               |
| Controller   | A process that watches CRs and takes action based on their state             |
| Operator     | A specific type of controller, typically for managing complex apps (e.g., databases, queues) | 

📦 **Real-world Examples of CRDs**

| Tool/Platform        | Custom Resources it defines             |
|----------------------|-----------------------------------------|
| Cert-Manager         | `Certificate`, `Issuer`                 |
| Prometheus Operator  | `Prometheus`, `ServiceMonitor`          |
| ArgoCD               | `Application`                           |
| Istio                | `VirtualService`, `Gateway`             |
| Crossplane           | `Composition`, `XRD`, etc.              |

🚀 **Summary**

*   CRD = way to define your own Kubernetes resource types.
*   Used to extend Kubernetes without modifying its core.
*   Powerful when paired with a controller/operator.
*   Enables building platform APIs on top of Kubernetes.

## Conclusion

Kubernetes automates container management, making systems more resilient, scalable, and efficient. While Docker is used to build and package containers, Kubernetes is responsible for managing and orchestrating them.