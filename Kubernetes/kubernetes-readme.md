# Kubernetes Learning Notes

![k8s cheatsheet](/Media/k8s_cheatsheet.png)

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
    -   The front-end for the Kubernetes control plane, exposing the Kubernetes API.
    -   Acts as the central management point for the entire cluster. All internal and external communications, including `kubectl` commands, go through the API Server.
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
    -   Works to make the current cluster state match the desired state stored in etcd.
    -   Runs controller processes that monitor the cluster state.
    -   Examples: Node controller, Replication controller.
-   **cloud-controller-manager (Cloud Controller Manager):**
    -   Runs controllers that interact with the underlying cloud provider's API.
    -   Allows Kubernetes to be cloud-agnostic by separating cloud-specific logic.

### Worker Node Components
These components run on every node, maintaining running pods and providing the Kubernetes runtime environment.

-   **kubelet:**
    -   Reports node and pod health/status back to the control plane.
    -   An agent that runs on each node in the cluster.
    -   Communicates with the kube-apiserver to ensure containers described in PodSpecs are running and healthy.
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

When you create or update resources using `kubectl` without specifying a namespace, Kubernetes uses the `default` namespace.

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
```
Manage Pods
-   `--dry-run=client`: Quick, local syntax check and template generation.
-   `--dry-run=server`: More thorough validation against the actual API server and its logic, good for pre-flight checks and understanding server-side mutations.

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

To change the number of replicas managed by a ReplicaSet, you can use the `kubectl scale` command.

For example, to scale a ReplicaSet named `frontend` to 2 replicas:
```bash
kubectl scale --replicas=2 rs/frontend
```

### Deployment

-   A higher-level object that manages ReplicaSets and provides declarative updates for Pods.
-   Manages the application lifecycle through ReplicaSets, handling rolling updates (by creating a new ReplicaSet and gradually scaling it up while scaling down the old one), rollbacks (by reverting to a previous ReplicaSet's state), and ensuring zero-downtime deployments.
-   Suitable for stateless applications (does not store any data or state between requests.).
-   Defines the desired state (e.g., number of replicas, container image, template) and the Deployment controller changes the actual state to match.

**Why Expose a Deployment?**

A Deployment itself (which manages Pods) is not directly accessible from outside its own Pod network or from outside the cluster by default. To make the application running in a Deployment's Pods accessible, you "expose" it, typically using a Service. You expose a Deployment to:

*   Allow other services or Pods within the cluster to communicate with it.
*   Allow users or systems outside the cluster to access your application (e.g., a website or an API), often via an Ingress controller in conjunction with a Service.

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

#### Setting a New Deployment Image

To update the image for a container within a Deployment, you can use the `kubectl set image` command.

For example, to set the `nginx` container in the Deployment named `my-dep` to use the `nginx:1.9.1` image:
```bash
kubectl set image deployment/my-dep nginx=nginx:1.9.1
```

#### Scaling a Deployment

To change the number of replicas for a Deployment, you can use the `kubectl scale` command.

For example, to scale the Deployment named `my-dep` to 5 replicas:
```bash
kubectl scale deployments.apps my-dep --replicas=5
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

To update the image for a container within a StatefulSet, you can use the `kubectl set image` command.

For example, to set the `nginx` container in the StatefulSet named `nginx` to use the `nginx:1.9.1` image:
```bash
kubectl set image statefulset/nginx nginx=nginx:1.9.1
```

#### Scaling a StatefulSet

To change the number of replicas for a StatefulSet, you can use the `kubectl scale` command.

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
- Applied to nodes to repel pods that don't have matching tolerations
- Three effects:
  - `NoSchedule`: Pods without matching toleration won't be scheduled
  - `PreferNoSchedule`: System will try to avoid scheduling pods without matching toleration
  - `NoExecute`: Pods without matching toleration will be evicted if already running

**Common Taint Patterns:**
- Control-plane nodes: `node-role.kubernetes.io/control-plane:NoSchedule`
- Worker nodes: `node-role.kubernetes.io/worker:NoSchedule`

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

**Commands:**
```bash
# Add a taint
kubectl taint nodes <node-name> node-role.kubernetes.io/worker:NoSchedule

# Remove a taint
kubectl taint nodes <node-name> node-role.kubernetes.io/worker:NoSchedule-

# List node taints
kubectl describe node <node-name> | grep Taints
```

#### Node Affinity

Node affinity is another mechanism to control pod placement, working with node labels. Unlike taints (which repel pods), affinity rules attract pods to nodes with specific labels.

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
### Service

Pods are frequently created and destroyed, causing their IP addresses to change. A Service provides a stable, virtual IP address (ClusterIP) and a consistent DNS name, ensuring reliable access to the application even as individual Pods come and go.

-   Defines a logical set of Pods (typically selected via labels) and an access policy for them, enabling **loose coupling** between client applications and backend Pods; clients only need to know the Service's stable address.
-   Distributes network traffic across the selected Pods, providing **load balancing** to prevent any single Pod from being overwhelmed and to improve application availability.
-   Uses selectors to dynamically discover and route traffic to the appropriate backend Pods.
-   Supports multiple protocols (TCP default, UDP, etc.) and port definitions for flexible communication.


**Service Types:**

1.  **`ClusterIP`:** (Default) Exposes the service on an internal IP within the cluster. Makes the service reachable only *from within* the cluster. Used for inter-service communication (e.g., frontend to backend).
     **`Headless Service`:** A variation of `ClusterIP` where `clusterIP` is explicitly set to `None`.
    *   **No Load Balancing, No Single IP:** Kubernetes does not allocate a cluster IP for a headless service and does not perform load balancing or proxying for it.
    *   **Direct Pod Discovery:** Instead, the DNS system is configured to return the IP addresses of all Pods selected by the Service. This allows clients to connect directly to a specific Pod if needed.
    *   **Use Cases:** Often used with StatefulSets, where each Pod has a unique, stable network identity and clients might need to connect to a specific instance (e.g., a primary database replica). Also useful for peer-to-peer discovery mechanisms.
2.  **`NodePort`:** Exposes the service on each Node's IP at a static port. Routes traffic to the `ClusterIP` service automatically. Allows external access but is often not recommended for production security.
3.  **`LoadBalancer`:** Exposes the service externally using a cloud provider's load balancer. Automatically creates `NodePort` and `ClusterIP` services. Provides an external IP address.
4.  **`ExternalName`:** Maps the service to an external DNS name (using a CNAME record) instead of using selectors. Useful for accessing external services from within the cluster.

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

### Ingress

Ingress is a Kubernetes API object that manages external access to services within a cluster, typically for HTTP and HTTPS traffic. It acts as a smart router or an entry point, allowing you to define rules for how incoming traffic should be directed to backend services based on hostnames or URL paths. This provides a way to consolidate routing rules into a single resource.

**Benefits:**
-   **Load Balancing:** Distributes incoming traffic across appropriate backend services, managed by the Ingress controller.
-   **Cost-Effectiveness:** Can reduce the need for multiple external `LoadBalancer` services by exposing many services through a single Ingress point, potentially lowering cloud provider costs.

#### Key Concepts and Components

-   **Ingress Resource:** A Kubernetes object where you define the routing rules. It specifies how traffic from outside the Kubernetes cluster should reach services inside the cluster.
-   **Ingress Controller:**
    -   The Ingress resource itself doesn't do anything on its own. It's a set of rules. An Ingress controller is an application (typically a reverse proxy like NGINX, Traefik, or HAProxy) that runs in the cluster and is responsible for fulfilling the Ingress rules by watching the API server for Ingress resources.
    -   When an Ingress resource is created, the Ingress controller configures itself (e.g., updates its NGINX configuration) to route traffic according to those rules.
    -   You need to have an Ingress controller deployed in your cluster for Ingress resources to work. Common controllers include NGINX Ingress Controller, Traefik Kubernetes Ingress provider, and HAProxy Ingress. Cloud providers often offer their own managed Ingress controllers.
-   **Rules:** Define how traffic is routed. Rules can be based on:
    -   **Host:** Direct traffic based on the requested hostname (e.g., `api.example.com`, `blog.example.com`). This is also known as virtual hosting.
    -   **Path:** Direct traffic based on the requested URL path (e.g., `example.com/api`, `example.com/ui`).
    -   A combination of both host and path.
-   **Backend Service:** The Kubernetes Service that traffic is ultimately routed to after matching a rule.
-   **Default Backend:** An optional catch-all service. If no rules in the Ingress match an incoming request, the traffic is routed to the default backend. This is often a custom error page or a default application.
-   **TLS/SSL Termination:** Ingress can terminate SSL/TLS connections. You can specify a Kubernetes Secret (containing a TLS certificate and private key) in your Ingress resource. The Ingress controller will use this certificate to secure traffic from clients, and then forward traffic to backend services, possibly unencrypted (HTTP).

#### Example Ingress YAML

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
  # Optional: Specify an IngressClass if you have multiple Ingress controllers
  # ingressClassName: "nginx-example"
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
    ```bash
    kubectl apply -f my-ingress.yaml
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
        kubectl create secret generic my-secret --from-literal=username='admin' --from-literal=password='s3cr3t'
        ```
    -   **From files:**
        Create files, e.g., `username.txt` containing `admin` and `password.txt` containing `s3cr3t`.
        ```bash
        kubectl create secret generic my-secret-from-file --from-file=./username.txt --from-file=./password.txt
        ```
    -   **For Docker registry credentials (image pull secrets):**
        ```bash
        kubectl create secret docker-registry my-docker-secret --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
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
    kubectl create configmap app-settings-from-file --from-file=app-config.properties
    # This creates a ConfigMap with one key 'app-config.properties',
    # and its value is the content of the file.
    #
    # To create a key for each file with file content as value:
    kubectl create configmap app-settings-from-file-keys --from-file=path/to/config1.conf --from-file=path/to/config2.conf
    # This creates keys like 'config1.conf' and 'config2.conf'
    ```

2.  **From Directories:**
    If you have a directory with multiple configuration files:
    ```bash
    # Assume 'my-configs/' directory contains 'game.properties' and 'ui.properties'
    kubectl create configmap app-settings-from-dir --from-file=./my-configs/
    # This creates a ConfigMap where each file in 'my-configs/' becomes a key,
    # and the file content is its value.
    ```

3.  **From Literal Values:**
    ```bash
    kubectl create configmap app-settings-literal \
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

-   `kubectl run nginx-pod --image=nginx:alpine --dry-run=client -o yaml > nginx_pod.yaml`: Generates the YAML manifest for a new pod without creating it in the cluster, saving it to `nginx_pod.yaml`. Useful for quickly creating a template for declarative configuration.

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
-   `kubectl logs <pod_name>`: View logs from a specific pod (alternative to `kubectl logs my-pod`).
-   `kubectl delete pods --all -n <namespace_name>`: Delete all pods in a specific namespace.
-   `kubectl rollout status deployment <deploy-name> -n <namespace-name>`: Check the status of a deployment rollout in a specific namespace.
-   `kubectl edit deployment <deployment-name> -n <namespace-name>`: Edit a deployment in a specific namespace using the default editor.




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

## Conclusion

Kubernetes automates container management, making systems more resilient, scalable, and efficient. While Docker is used to build and package containers, Kubernetes is responsible for managing and orchestrating them.