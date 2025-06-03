## Task 1: Create a ClusterIP Service for pod-info-app Deployment

**Requirements:**

*   Service Name: `pod-info-svc`
*   Service Type: `ClusterIP`
*   Namespace: `default` (assuming pod-info-app Deployment is in default)
*   Service Port: `80` (Service's listening port)
*   Target Port: `80` (Port on the Pods where traffic is forwarded)
*   Selector: `app=podInfoApp` (Verify this by inspecting the `pod-info-app` Deployment's Pod labels or use `kubectl describe deployment pod-info-app -n default`)

---

### Declarative Way (Recommended for Services)

1.  **Create the Service manifest (`task1.yaml`):
    Save the following content into a file named `task1.yaml`:**
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: pod-info-svc
      namespace: default # Ensure this matches the namespace of pod-info-app Deployment
    spec:
      type: ClusterIP
      selector:
        app: podInfoApp # Ensure this label matches the Pods of pod-info-app Deployment
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80
    ```

2.  **Apply the manifest to create the Service:**
    ```bash
    kubectl apply -f pod-info-svc.yaml
    ```

3.  **Verify the Service creation:**
    ```bash
    # Check if the service is created and has a ClusterIP
    kubectl get svc pod-info-svc -n default

    ```

---

### Imperative Way

1.  **Create the Service:**
    To explicitly define the selector when creating the Service imperatively:
    ```bash
    # Ensure the selector matches your Deployment's Pod labels, e.g., "app=podInfoApp"
    kubectl create service clusterip pod-info-svc --tcp=80:80 --selector="app=podInfoApp" -n default
    ```

2.  **Verify the Service creation:**
    ```bash
    kubectl get svc pod-info-svc -n default
    kubectl describe svc pod-info-svc -n default
    ```

---

### Deleting the Service

To delete the `pod-info-svc` Service from the `default` namespace (e.g., before trying the other creation method or after completing the task):

```bash
kubectl delete service pod-info-svc -n default
# or
kubectl delete svc pod-info-svc -n default
```

---

## Task 2: Test ClusterIP Service (`pod-info-svc`) Connectivity from a Pod

**Goal:**
Verify that the `pod-info-svc` (created in Task 1) is accessible from within the cluster and that its DNS name resolves correctly.

**Prerequisites:**
*   The `pod-info-svc` Service (from Task 1) must exist in the `default` namespace.
*   The Deployment that `pod-info-svc` targets (e.g., `pod-info-app`) must have running Pods so that the Service has active endpoints.

**Requirements:**

*   Run a temporary Pod using an image like `busybox:1.36`.
*   Ensure the temporary Pod runs in the `default` namespace (the same namespace as `pod-info-svc`).
*   From inside this temporary Pod, execute the following commands:
    1.  Access the service via HTTP: `wget -q -O- http://pod-info-svc:80`
        *   Save the output to a local file named `$HOME/testing-clusterip-web.log`.
    2.  Resolve the service DNS name: `nslookup pod-info-svc`
        *   Save the output to a local file named `$HOME/testing-clusterip-nslookup.log`.
*   The temporary Pod(s) should be cleaned up after the commands are executed.

---

### Imperative Way (Using `kubectl run --rm`)

This approach uses `kubectl run` with the `--rm` flag to create temporary Pods that are automatically deleted after the command completes. Each command will run in a separate temporary Pod.

1.  **(Optional) Create the target directory on your local machine if it's a subdirectory of `$HOME` (for this task, files are saved directly to `$HOME`, which usually exists):**
    ```bash
    # Example if saving to a subdirectory: mkdir -p $HOME/k8s-service-tests
    ```

2.  **Test HTTP connectivity to `pod-info-svc` using `wget` and save the output:**
    ```bash
    kubectl run busybox-wget-test --image=busybox:1.36 --namespace=default --restart=Never --rm -i --tty -- sh -c "wget -q -O- http://pod-info-svc:80" > $HOME/testing-clusterip-web.log
    ```
    *Explanation of flags:*
        *   `busybox-wget-test`: Name of this temporary Pod.
        *   `--image=busybox:1.36`: Specifies the container image.
        *   `--namespace=default`: Runs the Pod in the `default` namespace.
        *   `--restart=Never`: Ensures the Pod is for a one-off task.
        *   `--rm`: Automatically removes the Pod upon termination.
        *   `-i --tty` (or `-it`): Attaches stdin and allocates a TTY. Useful for interactive shells, and helps ensure the command output is correctly captured.
        *   `--`: Separates `kubectl run` options from the command/args to be run in the container.
        *   `sh -c "wget ..."`: The command executed inside the Pod.
        *   `> $HOME/...`: Redirects the standard output of the command run inside the Pod to a local file.

3.  **Test DNS resolution for `pod-info-svc` using `nslookup` and save the output:**
    ```bash
    kubectl run busybox-nslookup-test --image=busybox:1.36 --namespace=default --restart=Never --rm -i --tty -- nslookup pod-info-svc > $HOME/testing-clusterip-nslookup.log
    ```

4.  **Verify the content of the log files on your local machine:**
    ```bash
    cat $HOME/testing-clusterip-web.log
    cat $HOME/testing-clusterip-nslookup.log
    ```

---

## Task 3: Create Deployment, Headless Service, and ClusterIP Service

**Goal:**
Understand the difference in DNS resolution between a headless and a non-headless (ClusterIP) service by creating a Deployment and exposing it via both types of services.

**Requirements:**

1.  **Create a Deployment:**
    *   Name: `myapp`
    *   Image: `sbeliakou/web-pod-info:v1`
    *   Replicas: `1`
    *   Namespace: `default` (or specify and use consistently)
    *   Ensure the Pods have a consistent label for service selectors (e.g., `app=myapp`).

2.  **Create a Headless Service:**
    *   Name: `myapp-headless`
    *   Type: `ClusterIP` with `clusterIP: None`
    *   Selector: Must point to the Pods of the `myapp` Deployment (e.g., `app=myapp`).
    *   Ports: Define appropriate ports (e.g., if the application in `sbeliakou/web-pod-info:v1` listens on port 80, then `port: 80`, `targetPort: 80`).

3.  **Create a Non-Headless (ClusterIP) Service:**
    *   Name: `myapp-clusterip`
    *   Type: `ClusterIP` (default)
    *   Selector: Must point to the Pods of the `myapp` Deployment (e.g., `app=myapp`).
    *   Ports: Define appropriate ports (e.g., `port: 80`, `targetPort: 80`).

4.  **Check Name Resolution:**
    *   Use a temporary `busybox` Pod to run `nslookup` for `myapp-clusterip`.
    *   Use a temporary `busybox` Pod to run `nslookup` for `myapp-headless`.
    *   Observe and note the differences in the `nslookup` output.

---

### Declarative Way (Recommended for multiple related resources)

1.  **Create a single YAML file (`task3.yaml`) with definitions for the Deployment, Headless Service, and ClusterIP Service:**

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: myapp
      namespace: default
      labels:
        app: myapp # Label for the Deployment itself
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: myapp # Selector for Pods managed by this Deployment
      template:
        metadata:
          labels:
            app: myapp # Labels for the Pods
        spec:
          containers:
          - name: web-pod-info
            image: sbeliakou/web-pod-info:v1
            ports:
            - containerPort: 80 # Assuming the app in the image listens on port 80
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: myapp-headless
      namespace: default
    spec:
      clusterIP: None # This makes it a headless service
      selector:
        app: myapp # Must match the labels of the Pods from the 'myapp' Deployment
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80 # Port on the Pods
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: myapp-clusterip
      namespace: default
    spec:
      type: ClusterIP # Default, but can be explicit
      selector:
        app: myapp # Must match the labels of the Pods from the 'myapp' Deployment
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80 # Port on the Pods
    ```

2.  **Apply the manifest to create all resources:**
    ```bash
    kubectl apply -f task3.yaml -n default
    ```

3.  **Verify Deployment and Services:**
    ```bash
    kubectl get deployment myapp -n default
    kubectl get pods -l app=myapp -n default # Check Pod status and labels
    kubectl get svc myapp-headless -n default
    kubectl get svc myapp-clusterip -n default
    kubectl describe svc myapp-headless -n default # Note: No ClusterIP, but should have Endpoints
    kubectl describe svc myapp-clusterip -n default # Note: Will have a ClusterIP and Endpoints
    ```

4.  **Check Name Resolution for `myapp-clusterip`:**
    The non-headless service gets its own IP address and acts as a proxy.
    ```bash
    kubectl run --rm -it test-clusterip --image=busybox:1.36 --restart=Never -n default -- nslookup myapp-clusterip
    ```
    *Expected: `nslookup` should return the ClusterIP of the `myapp-clusterip` service.*

5.  **Check Name Resolution for `myapp-headless`:**
    The headless service directly returns the IP addresses of the backing Pods.
    ```bash
    kubectl run --rm -it test-headless --image=busybox:1.36 --restart=Never -n default -- nslookup myapp-headless
    ```
    *Expected: `nslookup` should return the IP address(es) of the Pod(s) selected by `myapp-headless` (e.g., the IP of the `myapp` Pod since replicas=1). If replicas were >1, it would return multiple Pod IPs.*

---

### Imperative Way (Step-by-step creation)

1.  **Create the Deployment:**
    ```bash
    kubectl create deployment myapp --image=sbeliakou/web-pod-info:v1 --replicas=1 -n default
    # (Optional) Add/ensure Pod labels if not automatically set as desired by the create deployment command.
    # For most `kubectl create deployment` versions, it automatically sets a label like app=myapp 
    # based on the deployment name, which is then used by its selector.
    # You can verify with: kubectl get deployment myapp -o yaml -n default (check spec.selector.matchLabels and spec.template.metadata.labels)
    ```

2.  **Create the Headless Service:**
    *(Assuming the Pods from `myapp` Deployment have the label `app=myapp`)*
    ```bash
    kubectl create service clusterip myapp-headless --clusterip="None" --tcp=80:80 --selector="app=myapp" -n default
    ```

3.  **Create the Non-Headless (ClusterIP) Service:**
    *(Assuming the Pods from `myapp` Deployment have the label `app=myapp`)*
    ```bash
    kubectl create service clusterip myapp-clusterip --tcp=80:80 --selector="app=myapp" -n default
    ```

4.  **Verify Deployment and Services (as shown in the Declarative Way - Step 3).**

5.  **Check Name Resolution (as shown in the Declarative Way - Steps 4 & 5).**

---

## Task 4: Create a NodePort Service for an Existing Deployment

**Goal:**
Expose an existing web application (`hello-hello` Deployment) externally using a `NodePort` service and verify access.

**Scenario:**
A Deployment named `hello-hello` is already running in your cluster (assume `default` namespace unless specified otherwise). You need to create a Service to access it from outside the cluster node network.

**Requirements:**

*   **Service Name:** `hello-hello-service`
*   **Service Type:** `NodePort`
*   **Target Port (Pod Port):** `80` (The port on the `hello-hello` Pods that the Service should forward traffic to).
*   **NodePort:** `30300` (The static port on each node where the Service will be exposed).
*   **Selector:** You must figure out the correct Pod selector labels by inspecting the `hello-hello` Deployment.
*   **Service Port:** The port on the Service itself (within the cluster). For NodePort services, this often matches the `targetPort` if not specified, but it can be different. Let's assume it should also be `80` for simplicity unless inspection suggests otherwise.

**Verification:**
*   Access the application using `curl $NODE_IP:30300` from a machine that can reach your Kubernetes node(s), or open `http://$NODE_IP:30300` in a browser. Replace `$NODE_IP` with the actual IP address of one of your Kubernetes nodes.

---

### Steps

1.  **Inspect the `hello-hello` Deployment to find its Pod selector labels and the port its containers expose:**
    *(Assuming the Deployment is in the `default` namespace. Adjust if different.)*
    ```bash
    kubectl get deployment hello-hello -n default -o yaml
    ```
    *Look for `spec.selector.matchLabels` to find the labels the Deployment uses to select its Pods. These will be your Service's selector.*
    *Also, look at `spec.template.spec.containers[].ports[].containerPort` to confirm the Pods are indeed listening on port `80`.*

    **Example Output Snippet to look for:**
    ```yaml
    # ... (other deployment details)
    spec:
      selector:
        matchLabels:
          app: hello-hello # <--- This is likely your selector key-value pair
    # ...
      template:
        metadata:
          labels:
            app: hello-hello # <--- Pods will have this label
    # ...
        spec:
          containers:
          - name: hello-hello-container # Or whatever the container is named
            image: some-image # Image used by the deployment
            ports:
            - containerPort: 80 # <--- Confirms targetPort
              protocol: TCP
    # ...
    ```
    *Based on this example, the selector for your service would be `app: hello-hello`.*

2.  **Create the NodePort Service (Declarative Way - Recommended):**
    Save the following content into a file named `task4.yaml`. 

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

3.  **Apply the manifest to create the Service:**
    ```bash
    kubectl apply -f task4.yaml -n default
    ```

4.  **Verify the Service creation and check its NodePort:**
    ```bash
    kubectl get svc hello-hello-service -n default
    # Look for the PORT(S) column, it should show something like 80:30300/TCP
    kubectl describe svc hello-hello-service -n default
    ```

    ***Note on "FailedToUpdateEndpointSlices" Warning:***
    *You might see a warning in the events section like `Warning FailedToUpdateEndpointSlices ... endpointslices.discovery.k8s.io "..." not found`.
    EndpointSlices are used by Services to track their backing Pods. This warning indicates a potential hiccup in managing these slices.
    However, if the `Endpoints:` field in the `describe` output shows an IP address (e.g., `Endpoints: 10.244.1.161:80`), the Service has likely identified the Pod(s) it needs to forward traffic to.
    It's recommended to proceed with testing the service (Step 6) as it may still be functional. If the service is not working as expected, this warning might be a symptom to investigate further.*

5.  **Get a Node IP address:**
    *   If using Minikube: `minikube ip`
    *   For other clusters, you might use: `kubectl get nodes -o wide` (look at `EXTERNAL-IP` or `INTERNAL-IP` depending on your setup and network accessibility).

6.  **Test the NodePort Service:**
    Replace `$NODE_IP` with an actual IP address of one of your cluster nodes.
    ```bash
    curl $NODE_IP:30300
    ```
    Or open `http://$NODE_IP:30300` in a web browser.
    You should see the output from the `hello-hello` web application.

    **Note for Minikube users:**
    If direct access via `$NODE_IP:$NODE_PORT` doesn't work from your host machine or WSL (which can happen due to networking configurations with drivers like Docker), the recommended way to test and access the service is to use the `minikube service` command:
    ```bash
    minikube service hello-hello-service
    ```
    This command will provide a URL (often using `127.0.0.1` and a different port) that tunnels directly to your service. Accessing this URL successfully verifies that the NodePort service is operational. The tunnel typically needs to remain active in your terminal to keep the service accessible via this local URL.

---

