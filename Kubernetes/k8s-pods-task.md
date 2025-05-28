## Task 1: Create a Pod

**Requirements:**

*   Pod name: `nginx-pod`
*   Pod image: `nginx:alpine`
*   Pod label: `app=nginx`
*   Namespace: `default`
*   Container Port: `80`

---

### Imperative Way

```bash
kubectl run nginx-pod --image=nginx:alpine --labels=app=nginx --namespace=default --port=80
```

---

### Declarative Way

To create the pod declaratively, save the following YAML content into a file (e.g., `nginx-pod.yaml`):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: default
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-container # You can name the container anything, this is a common practice
    image: nginx:alpine
    ports:
    - containerPort: 80
```

Then, apply the configuration using the following command:

```bash
kubectl apply -f task1.yaml
```

---

## Task 2: Save Pod Manifest

**Requirements:**

*   Find a pod named `save-me`.
*   Save its manifest in YAML format to `$HOME/k8s_pods/save-me-pod.yml`.

---

```bash
# First, ensure the target directory exists
mkdir -p $HOME/k8s_pods

# Get all pods in all namespaces to find the pod
kubectl get pods -A 

# Get the pod's YAML and redirect it to the file
kubectl get pod save-me -n find-me -o yaml > $HOME/k8s_pods/save-me-pod.yml
```

---

## Task 3: Troubleshoot and Fix a Failed Pod

**Scenario:**

A new Pod named `web` has been deployed in the `trouble` namespace. It has failed. You need to investigate the reason for the failure and fix it.

**Desired State Requirements:**

*   Pod Name: `web`
*   Namespace: `trouble`
*   Image: `nginx:1.19-alpine` (nginx version 1.19, alpine base)
*   Pod Status: `Running`

---

### Imperative Way (Investigation & Fix)

1.  **Inspect the pod to understand its current status and recent events:**
    Events often provide clues about why a pod is failing. For this pod, `kubectl describe pod web -n trouble` would show an event similar to:
    ```
    Warning  Failed     7s    kubelet            Failed to pull image "nginxxx": Error response from daemon: pull access denied for nginxxx
    ```
   

2.  **Check the logs from the pod's container(s):**
    In this case, the container likely never started, so logs might be empty or show errors related to image pulling. However, it's a good general step.
    ```bash
    kubectl logs web -n trouble
    ```


3.  **Fix the pod by updating its image:**
    I found the errored line in the pod's manifest:
    ```bash
    kubectl get pod web -n trouble -o yaml  
    ```
    In the editor, found the `spec.containers[0].image` field.
     ```yaml
    #I found errored line:
    -image: nginxxx
   
    ```
    updated the image to `nginx:1.19-alpine`
    ```bash
    kubectl set image pod/web web=nginx:1.19-alpine -n trouble
    # The format is pod/<pod-name> <container-name>=<new-image>
    ```

5.  **Verify the pod is now running:**
    ```bash
    kubectl get pod web -n trouble -w
    ```

---

### Declarative Way (Investigation & Fix)

1.  **Get the current (failed) pod's manifest:**
    This allows you to inspect its full configuration.
    ```bash
    kubectl get pod web -n trouble -o yaml > task3.yaml
    ```

2.  **Inspect `task3.yaml` and identify the issue.**
    ```yaml
    #I found errored line:
    -image: nginxxx
    #I corrected it to:
    -image: nginx:1.19-alpine
    ```
    *Important*: When reusing a manifest obtained via `kubectl get -o yaml`, you should typically remove the `status` section.

3.  **Apply the corrected manifest:**
    ```bash
    kubectl delete pod web -n trouble
    kubectl apply -f task3.yaml
    ```

4.  **Verify the pod is now running:**
    ```bash
    kubectl get pod web -n trouble
    ```

---

## Task 4: Fix a Pod in CrashLoopBackOff due to Command Typo

**Scenario:**

A new Pod named `redis-db` has been deployed in the `trouble` namespace. It is failing.

**Desired State Requirements:**

*   Pod Name: `redis-db`
*   Namespace: `trouble`
*   Pod Status: `Running` (The underlying command/script typo is fixed).

---

### Declarative Way (Investigation & Fix)


1.  **Check pod status:**
    ```bash
    kubectl get pod redis-db -n trouble
    ```
    *Observed:* `NAME READY STATUS RESTARTS AGE`
    `redis-db 0/1 CrashLoopBackOff 11 (65s ago) 33m`

2.  **Check pod logs:**
    ```bash
    kubectl logs redis-db -n trouble
    ```
    *Observed:* `sh: sleeep: not found`


1.  **Get the current pod's manifest:**
    ```bash
    kubectl get pod redis-db -n trouble -o yaml > task4.yaml
    ```

2.  **Inspect `task4.yaml`:**
    Find `sleeep infinity` in `spec.containers[0].args[0]`.
    ```yaml
    
    # spec:
    #   containers:
    #   - args:
    #     - sleeep infinity 
    #   - command:
    #     - sh
    #     - -c
    ```

3.  **Edit `task4.yaml` with the correct command:**
    ```yaml
    # Example: Corrected in task4.yaml
    # spec:
    #   containers:
    #   - args:
    #     - sleep infinity
    #     command:
    #     - sh
    #     - -c
    ```

4.  **Apply the corrected manifest:**
    ```bash
    kubectl delete pod redis-db -n trouble
    kubectl apply -f task4.yaml
    ```

5.  **Verify the pod is running:**
    ```bash
    kubectl get pod redis-db -n trouble
    ```
    

## Task 7: Create Pod with Environment Variables and Save Logs

**Requirements:**

*   Namespace: `default`
*   Pod Name: `envtest`
*   Image: `busybox:1.34`
*   Container Process: `env && sleep infinity`
*   Environment Variables for the main container:
    *   `STUDENT_FIRST_NAME`: `<yourname>`
    *   `STUDENT_LAST_NAME`: `<yourlastname>`
*   Verify logs show the environment variables.
*   Save full pod logs to `$HOME/k8s_pods/default-envtest.log`.

---

### Imperative Way

1.  **Create the Pod with environment variables:**
    ```bash
    kubectl run envtest --image=busybox:1.34 --namespace=default --env="STUDENT_FIRST_NAME=<yourname>" --env="STUDENT_LAST_NAME=<yourlastname>" -- sh -c "env && sleep infinity"
    ```
    *Note: The `--` is used to separate `kubectl run` options from the command and arguments to be run in the container.*

2.  **Wait for the Pod to be ready and check its status (optional but good practice):**
    ```bash
    kubectl get pod envtest -n default
    ```

3.  **Check Pod logs to verify environment variables:**
    ```bash
    kubectl logs envtest -n default
    ```
    You should see output similar to:
    ```
    ...
    STUDENT_FIRST_NAME=<yourname>
    STUDENT_LAST_NAME=<yourlastname>
    ...
    ```

4.  **Save full Pod logs to a file:**
    ```bash
    # Ensure the target directory exists
    mkdir -p $HOME/k8s_pods
    kubectl logs envtest -n default > $HOME/k8s_pods/default-envtest.log
    ```

---

### Declarative Way

1.  **Create a YAML manifest for the Pod (e.g., `envtest-pod.yaml`):**
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: envtest
      namespace: default
    spec:
      containers:
      - name: main # Container name can be anything, e.g., busybox-container
        image: busybox:1.34
        command: ["sh", "-c", "env && sleep infinity"]
        env:
        - name: STUDENT_FIRST_NAME
          value: "<yourname>"
        - name: STUDENT_LAST_NAME
          value: "<yourlastname>"
    ```

2.  **Apply the manifest to create the Pod:**
    ```bash
    kubectl apply -f envtest-pod.yaml
    ```

3.  **Wait for the Pod to be ready and check its status (optional but good practice):**
    ```bash
    kubectl get pod envtest -n default 
    ```

4.  **Check Pod logs to verify environment variables:**
    ```bash
    kubectl logs envtest -n default
    ```
    You should see output similar to:
    ```
    ...
    STUDENT_FIRST_NAME=<yourname>
    STUDENT_LAST_NAME=<yourlastname>
    ...
    ```

5.  **Save full Pod logs to a file:**
    ```bash
    # Ensure the target directory exists
    mkdir -p $HOME/k8s_pods
    kubectl logs envtest -n default > $HOME/k8s_pods/default-envtest.log
    ```

---

## Task 8: Create Pod with Downward API Environment Variables

**Requirements (Advanced):**

*   Namespace: `default`
*   Pod Name: `i-know-who-i-am`
*   Image: `busybox:1.34`
*   Container Process: `env && sleep infinity`
*   Specify the following environment variables for the `main` container using the Downward API:
    *   `MY_NODE_NAME`: Name of the Pod's node.
    *   `MY_POD_NAME`: Name of the Pod (from metadata).
    *   `MY_POD_NAMESPACE`: Namespace of the Pod (from metadata).
    *   `MY_POD_IP`: Pod's IP address.
    *   `MY_POD_SERVICE_ACCOUNT`: Pod's service account name.
*   Verify by checking the Pod's logs.

---

### Declarative Way (Recommended for Downward API)

**Generating an initial template (optional):**

While `kubectl run` cannot directly define Downward API `env` variables, you can use it to generate a basic Pod template that you can then manually edit. For example:

```bash
kubectl run i-know-who-i-am --image=busybox:1.34 --dry-run=client -o yaml --env="EXAMPLE_VAR=example_value" -- sh -c "env && sleep infinity" > task8.yaml
```
This `task8-template.yaml` would then need to be edited to add the `namespace` and the specific Downward API `env` definitions as shown below.

1.  **Create a YAML manifest for the Pod (e.g., `task8.yaml`):**
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: i-know-who-i-am
      namespace: default
    spec:
      containers:
      - name: main # Container name can be anything
        image: busybox:1.34
        command: ["sh", "-c", "env && sleep infinity"]
        env:
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

2.  **Apply the manifest to create the Pod:**
    ```bash
    kubectl apply -f task8.yaml
    ```

3.  **Wait for the Pod to be ready and check its status:**
    (The `MY_POD_IP` variable might only be populated once the pod has an IP assigned and is running).
    ```bash
    kubectl get pod i-know-who-i-am -n default
    ```

4.  **Check Pod logs to verify environment variables:**
    ```bash
    kubectl logs i-know-who-i-am -n default
    ```
    You should see output similar to (node name, IP, etc., will vary):
    ```
    ...
    MY_NODE_NAME=minikube
    MY_POD_NAME=i-know-who-i-am
    MY_POD_NAMESPACE=default
    MY_POD_IP=172.17.0.5
    MY_POD_SERVICE_ACCOUNT=default
    ...
    ```

---

## Task 9: Delete All Pods in a Namespace

**Requirements:**

*   Delete all pods located in the `clean-up` namespace.

---

### Imperative Way

1.  **Delete all pods in the `clean-up` namespace:**
    ```bash
    kubectl delete pods --all -n clean-up
    ```

2.  **Verify that pods are being terminated (optional):**
    ```bash
    kubectl get pods -n clean-up
    ```
    You should see the pods in `Terminating` state or they will disappear from the list once fully deleted.

---

## Task 10: Create a Static Pod (Advanced)

**Requirements:**

*   Pod Name: `nginx-static`
*   Pod Image: `nginx:alpine`
*   Pod Label: `app=nginx-static`
*   Namespace: `static` (Static Pods are often created in a specific namespace if defined in their manifest, though they are visible cluster-wide with node name suffix)
*   Container Port: `80`
*   **Verification:** Attempt to delete the static pod using `kubectl delete`. It should be automatically recreated by the kubelet.

---

### Imperative Way (Static Pods are managed directly on nodes)

1.  **(Optional) If the `static` namespace doesn't exist, create it:**
    *(Note: While the Pod manifest can specify a namespace, static Pods are special. The kubelet manages them. Creating the namespace via `kubectl` might be good practice if other non-static resources will also use it.)*
    ```bash
    kubectl create namespace static
    ```

2.  **SSH into your Kubernetes node (e.g., Minikube):**
    ```bash
    # For Minikube:
    minikube ssh 
    ```

3.  **Navigate to the kubelet's manifest directory:**
    This is typically `/etc/kubernetes/manifests`.
    ```bash
    # Inside the node
    cd /etc/kubernetes/manifests
    ```

4.  **Create the static Pod manifest file (`nginx-static.yaml`):**
    Use `sudo` if necessary. The content should be:
    ```yaml
    # Inside the node, create /etc/kubernetes/manifests/nginx-static.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx-static
      namespace: static
      labels:
        app: nginx-static
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
    ```

5.  **Restart kubelet for changes to take effect immediately:**
    ```bash
    # Inside the node 
    sudo systemctl restart kubelet
    ```

6.  **Exit the node:**
    ```bash
    exit
    ```

7.  **Verify the static Pod is running:**
    Static Pods are typically named `<pod-name>-<node-name>`. List pods in all namespaces or the specified namespace to find it.
    ```bash
    kubectl get pods -n static
    ```
---

## Task 11: Delete a Static Pod (Advanced)

**Requirements:**

*   Delete the static pod `nginx-static` (created in Task 10).

---

### Imperative Way (Static Pods are managed directly on nodes)

1.  **SSH into the Kubernetes node where the static Pod is running (e.g., Minikube):**
    ```bash
    # For Minikube:
    minikube ssh
    ```

2.  **Navigate to the kubelet's manifest directory:**
    ```bash
    # Inside the node
    cd /etc/kubernetes/manifests
    ```

3.  **Remove the static Pod's manifest file:**
    Use `sudo` if necessary.
    ```bash
    # Inside the node
    sudo rm nginx-static.yaml
    ```

4.  **Restart kubelet:**

    ```bash
    # Inside the node 
    sudo systemctl restart kubelet
    ```

5.  **Exit the node:**
    ```bash
    exit
    ```

6.  **Verify the static Pod is deleted:**
    Check that the Pod no longer appears.
    ```bash
    kubectl get pods -n static
    ```


