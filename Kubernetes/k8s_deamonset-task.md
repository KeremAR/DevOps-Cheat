# DaemonSet Tasks

## Task 1: Create a new node and set up worker role for it.

1.  **Add a new node to your Minikube cluster:**
    *   If using the default Minikube profile:
        ```bash
        minikube node add
        ```

2.  **Verify the new node and its role:**
    Wait for the node addition to complete, then run:
    ```bash
    kubectl get nodes -o wide
    ```
    -   Check the `STATUS` (should be `Ready`).
    -   Check the `ROLES`. For nodes added with `minikube node add`, the role is typically a worker by default, and might show as `<none>` or imply a worker role.

3.  **Explicitly label the node as a worker:**

    *   To add the standard worker role label:
        ```bash
        kubectl label node <new-node-name> node-role.kubernetes.io/worker=worker
        ```
    *   Alternatively, for a custom `role=worker` label (sometimes used in examples):
        ```bash
        kubectl label node <new-node-name> role=worker
        ```
    *   Verify labels:
        ```bash
        kubectl get nodes --show-labels
        ```

## Task 2: Taint your nodes.

**Requirements:**
*   Control-plane node (e.g., `minikube`):
    *   Key: `node-role.kubernetes.io/control-plane`
    *   Effect: `NoSchedule`
*   Worker node (e.g., `minikube-m02`):
    *   Key: `node-role.kubernetes.io/worker`
    *   Effect: `NoSchedule`

**Commands:**

1.  **Taint the control-plane node (replace `minikube` if your control-plane node has a different name):**
    ```bash
    kubectl taint nodes minikube node-role.kubernetes.io/control-plane:NoSchedule
    ```

2.  **Taint the worker node (replace `minikube-m02` with your worker node's actual name):**
    ```bash
    kubectl taint nodes minikube-m02 node-role.kubernetes.io/worker:NoSchedule
    ```

3.  **Verify the taints:**
    *   For the control-plane node:
        ```bash
        kubectl describe node minikube | grep Taints
        ```
    *   For the worker node:
        ```bash
        kubectl describe node minikube-m02 | grep Taints
        ```
    You should see the taints listed in the output (e.g., `node-role.kubernetes.io/control-plane:NoSchedule` and `node-role.kubernetes.io/worker:NoSchedule`).

## Task 3: Deploy DaemonSet (Initial Attempt - Expecting Failure)

**Objective for this version of Task 3:** Deploy the DaemonSet *without* any tolerations. This is to observe that Pods will NOT be scheduled on your tainted nodes.

**Requirements:**
*   Name: `fluentd-elasticsearch`
*   Image: `quay.io/fluentd_elasticsearch/fluentd:v4`
*   Instruction: Please pay attention to how many Pods were created and why.



**1. Create `task3.yaml`:**
   Create a file named `task3.yaml` with the following content. **Note the absence of a `tolerations` section.**

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
         # NO tolerations defined here for this step
         containers:
         - name: fluentd-elasticsearch
           image: quay.io/fluentd_elasticsearch/fluentd:v4
           resources:
             limits:
               memory: "200Mi"
             requests:
               cpu: "100m"
               memory: "200Mi"
   ```

**3. Apply the DaemonSet configuration:**
   ```bash
   kubectl apply -f fluentd-elasticsearch-ds-task3.yaml
   ```

**4. Check the DaemonSet status and its Pods:**
   *   Check the DaemonSet (look for `DESIRED: 2` but `CURRENT: 0`, `READY: 0`):
       ```bash
       kubectl get ds fluentd-elasticsearch -o wide
       ```
   *   Check the Pods (expect "No resources found" or Pods in `Pending` state):
       ```bash
       kubectl get pods -l app=fluentd-elasticsearch -o wide
       ```
   *   Describe the DaemonSet to see events related to scheduling failures:
       ```bash
       kubectl describe ds fluentd-elasticsearch
       ```

**Expected Outcome & Analysis for THIS version of Task 3 ("Why"):**
*   **How many Pods?** 0 successfully running Pods.
*   **Why?**
    *   The DaemonSet controller attempts to create Pods on both nodes (`minikube` and `minikube-m02`).
    *   Both nodes have `NoSchedule` taints (from Task 2).
    *   The Pod template in `fluentd-elasticsearch-ds-task3.yaml` does **not** include any `tolerations`.
    *   Therefore, the Kubernetes scheduler cannot place these Pods on the tainted nodes, resulting in 0 running Pods. Pods might be created but will remain in a `Pending` state due to scheduling failure.


## Task 4: Modify `fluentd-elasticsearch` DaemonSet to run on all tainted nodes and include secret phrase.

**Objective:** Modify the DaemonSet configuration from Task 3 by adding tolerations so its Pods can run on your tainted nodes, and include the specified secret phrase as an environment variable.

**Assumptions for starting Task 4:**
*   You have completed the revised Task 3.
*   The `fluentd-elasticsearch` DaemonSet currently has 0 running Pods due to lacking tolerations for your tainted nodes.

**1. Modify your DaemonSet YAML file (e.g., `task3.yaml` or a new `task4.yaml`):**
   Take the YAML file used in Task 3 and add:
    *   A `tolerations` section to `spec.template.spec` to tolerate any `NoSchedule` taint.

   **Resulting YAML for Task 4:**
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
         # This general toleration allows Pods to run on ANY node with ANY NoSchedule taint
         - operator: "Exists"
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

**2. Apply the updated DaemonSet configuration:**
   ```bash
   kubectl apply -f task4.yaml
   ```
**3. Check the DaemonSet status, Pods, and environment variable:**
   *   Optional: Check rollout status:
       ```bash
       kubectl rollout status ds/fluentd-elasticsearch
       ```
   *   Check the DaemonSet (expect `DESIRED: 2`, `CURRENT: 2`, `READY: 2`):
       ```bash
       kubectl get ds fluentd-elasticsearch -o wide
       ```
   *   Check the Pods (expect 2 Pods, one on each node):
       ```bash
       kubectl get pods -l app=fluentd-elasticsearch -o wide
       ```

## Task 5: Add another worker node and configure it

**Requirements:**
*   Worker node (e.g., `minikube-m03`):
    *   Key: `node-role.kubernetes.io/worker`
    *   Effect: `NoSchedule`

**Commands:**

1.  **Add a new node to your Minikube cluster:**
    ```bash
    minikube node add
    ```

2.  **Verify the new node and its role:**
    Wait for the node addition to complete, then run:
    ```bash
    kubectl get nodes -o wide
    ```
    -   Check the `STATUS` (should be `Ready`).
    -   Check the `ROLES`. For nodes added with `minikube node add`, the role is typically a worker by default.

3.  **Label the new node as a worker:**
    ```bash
    kubectl label node minikube-m03 node-role.kubernetes.io/worker=worker
    ```

4.  **Taint the new worker node:**
    ```bash
    kubectl taint nodes minikube-m03 node-role.kubernetes.io/worker:NoSchedule
    ```

5.  **Verify the taints:**
    ```bash
    kubectl describe node minikube-m03 | grep Taints
    ```
    You should see the taint listed in the output (e.g., `node-role.kubernetes.io/worker:NoSchedule`).

6.  **Check the DaemonSet status:**
    ```bash
    kubectl get ds fluentd-elasticsearch -o wide
    ```
    You should see 3 pods (one on each node).

7.  **Verify pod distribution:**
    ```bash
    kubectl get pods -l app=fluentd-elasticsearch -o wide
    ```
    You should see pods running on all three nodes (minikube, minikube-m02, and minikube-m03).

## Task 6: Cleanup and Node Information

**Prerequisites:**
*   Install jq utility if not already installed:
    ```bash
    sudo apt-get update && sudo apt-get install -y jq
    ```

**Steps:**

1.  **Get node details in JSON format and save to file:**
    ```bash
    kubectl get nodes -o json > $HOME/nodes-info.json
    ```

2.  **Delete worker nodes:**
    ```bash
    minikube node delete minikube-m02
    minikube node delete minikube-m03
    ```

3.  **Untaint the control-plane node:**
    ```bash
    kubectl taint nodes minikube node-role.kubernetes.io/control-plane:NoSchedule-
    ```

4.  **Remove the fluentd-elasticsearch DaemonSet:**
    ```bash
    kubectl delete ds fluentd-elasticsearch
    ```

5.  **Verify the cleanup:**
    ```bash
    # Check nodes
    kubectl get nodes
    
    # Check DaemonSet
    kubectl get ds
    
    # Check taints on control-plane
    kubectl describe node minikube | grep Taints
    ```



