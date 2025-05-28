## Kubernetes StatefulSet Tasks

---

## Task 1: Create a StatefulSet with a Headless Service

**Requirements:**

*   **StatefulSet Name:** `random-generator`
*   **Image:** `sbeliakou/random-generator:1`
*   **Namespace:** `default` (will be assumed if not specified in manifest metadata)
*   **Replicas:** `3`
*   **Governing Service Name:** `random-generator`
*   **Labels (for StatefulSet, Pod template, and Service selector):** `app=random-generator`

--- 

### Declarative Way (Recommended for StatefulSets)

1.  **Create a YAML manifest file (e.g., `task1.yaml`) with definitions for both the Headless Service and the StatefulSet:**



    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: random-generator # This is the Headless Service
      namespace: default
      labels:
        app: random-generator
    spec:
      ports:
      - port: 80 # Arbitrary port, adjust if your app inside the pod listens on a specific port
        name: web # Optional port name
      clusterIP: None # Makes the service headless
      selector:
        app: random-generator # Must match the labels of the Pods created by the StatefulSet
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: random-generator
      namespace: default
      labels:
        app: random-generator
    spec:
      serviceName: "random-generator" # Must match the Headless Service name
      replicas: 3
      selector:
        matchLabels:
          app: random-generator # Must match labels in Pod template
      template:
        metadata:
          labels:
            app: random-generator # Labels for the Pods
        spec:
          # terminationGracePeriodSeconds: 10 # Optional: faster shutdown for these pods
          containers:
          - name: random-generator-container
            image: sbeliakou/random-generator:1
            ports:
            - containerPort: 80 # Should match one of the service ports if applicable
              # name: web # Optional, but good practice if service port has a name
            
    ```

2.  **Apply the manifest to create the Service and StatefulSet:**
    ```bash
    kubectl apply -f sts-task1.yaml
    ```

3.  **Verify the creation and status:**

    *   **Check the Service:**
        ```bash
        kubectl get svc random-generator -n default
        # You should see CLUSTER-IP as None
        ```
    *   **Check the StatefulSet:**
        ```bash
        kubectl get sts random-generator -n default
        # Wait for DESIRED and CURRENT to match (e.g., 3/3)
        ```
    *   **Check the Pods (created in order):**
        ```bash
        kubectl get pods -n default -l app=random-generator -w
        # You should see pods like random-generator-0, random-generator-1, random-generator-2 being created and becoming Ready.
        ```


---

## Task 2: Add Persistent Storage (volumeClaimTemplates) to a StatefulSet

**Requirements:**

*   Target StatefulSet: `random-generator` (from Task 1)
*   Add `volumeClaimTemplates` for persistent logging storage.
*   **Volume Claim Template Name:** `logs`
*   **Container `mountPath`:** `/logs`
*   **Storage Capacity:** `10Mi`
*   **Access Mode:** `ReadWriteOnce`

**Important Consideration:**
Modifying `volumeClaimTemplates` on an existing StatefulSet is a significant change. While `kubectl apply` might attempt an update, it often doesn't work as expected if Pods with previous (or no) volume configurations exist. The most reliable way to apply such changes is to delete the StatefulSet (which will also delete its Pods) and then recreate it with the new definition. Ensure you understand the implications, especially if there's data on existing volumes that isn't managed by these new PVCs.

--- 

### Declarative Way

1.  **Modify the YAML manifest file (e.g., `task1.yaml`) to include `volumeClaimTemplates` in the StatefulSet and `volumeMounts` in the container spec:**

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: random-generator # Headless Service (unchanged from Task 1)
      namespace: default
      labels:
        app: random-generator
    spec:
      ports:
      - port: 80
        name: web
      clusterIP: None
      selector:
        app: random-generator
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: random-generator
      namespace: default
      labels:
        app: random-generator
    spec:
      serviceName: "random-generator"
      replicas: 3
      selector:
        matchLabels:
          app: random-generator
      template:
        metadata:
          labels:
            app: random-generator
        spec:
          # terminationGracePeriodSeconds: 10 
          containers:
          - name: random-generator-container
            image: sbeliakou/random-generator:1
            ports:
            - containerPort: 80
              # name: web 
            volumeMounts:
            - name: logs
              mountPath: /logs
      volumeClaimTemplates:
      - metadata:
          name: logs
        spec:
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 10Mi
    ```

2.  **Delete the existing StatefulSet (if it was created in Task 1):**
    This will also delete the Pods. If you need to preserve data from any previous volumes not managed by these PVCs, back it up first.
    ```bash
    kubectl delete sts random-generator -n default
    # Optionally, also delete the service if you want a completely clean slate, though not strictly necessary for this change.
    # kubectl delete svc random-generator -n default
    ```
    *Wait for the StatefulSet and its Pods to be fully terminated before proceeding.* You can watch with `kubectl get pods -n default -l app=random-generator -w`.

3.  **Apply the updated manifest to recreate the StatefulSet with persistent storage:**
    (Ensure the Service `random-generator` exists or is created by this manifest if you deleted it).
    ```bash
    kubectl apply -f task1.yaml \
    ```

4.  **Verify the creation and PersistentVolumeClaims (PVCs):**

    *   **Check the StatefulSet and Pods:**
        ```bash
        kubectl get sts random-generator -n default
        kubectl get pods -n default -l app=random-generator -w
        # Wait for random-generator-0, -1, -2 to be Running
        ```
    *   **Check the PersistentVolumeClaims:**
        You should see a PVC created for each Pod, named `logs-<statefulset-name>-<ordinal>`.
        ```bash
        kubectl get pvc -n default -l app=random-generator
        # Example output:
        # NAME                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
        # logs-random-generator-0    Bound    pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx   10Mi       RWO            standard       2m
        # logs-random-generator-1    Bound    pvc-yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy   10Mi       RWO            standard       1m
        # logs-random-generator-2    Bound    pvc-zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz   10Mi       RWO            standard       30s
        ```
---

## Task 3: Update Container Image of a StatefulSet

**Requirements:**

*   Target StatefulSet: `random-generator` (from Task 1 & 2)
*   New Container Image: `sbeliakou/random-generator:2`
*   Observe reverse ordinal update order (e.g., pod-2, then pod-1, then pod-0 for 3 replicas).

**StatefulSet Update Strategy - RollingUpdate:**
By default, StatefulSets use the `RollingUpdate` strategy. When the `.spec.template` (e.g., container image) is changed:
1.  Pods are updated one at a time, in reverse ordinal order (from highest ordinal to lowest, e.g., `N-1` down to `0`).
2.  Kubernetes waits for an updated Pod to be Running and Ready before updating the next one.
3.  If a `partition` is specified in `.spec.updateStrategy.rollingUpdate.partition`, only Pods with an ordinal greater than or equal to the partition value will be updated. For a full rollout, this is typically undefined or set to 0.

--- 

### Declarative Way

1.  **Modify the YAML manifest file (e.g., `task1.yaml` which might now include changes from Task 2) to update the container image:**

    ```yaml
    # In your StatefulSet manifest (e.g., task1.yaml)
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: random-generator
      # ... other metadata ...
    spec:
      serviceName: "random-generator"
      replicas: 3
      selector:
        matchLabels:
          app: random-generator
      template:
        metadata:
          labels:
            app: random-generator
        spec:
          containers:
          - name: random-generator-container
            image: sbeliakou/random-generator:2 # UPDATED IMAGE
            ports:
            - containerPort: 80
            volumeMounts:
            - name: logs
              mountPath: /logs
      volumeClaimTemplates:
      - metadata:
          name: logs
        spec:
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 10Mi
    # Ensure the Headless Service (random-generator) definition is also in this file or already exists in the cluster.
    ```

2.  **Apply the updated manifest:**
    ```bash
    kubectl apply -f your-updated-sts-manifest.yaml # (e.g., task1.yaml)
    ```

3.  **Verify the rolling update and the new image:**

    *   **Monitor the rollout status:**
        You will see Pods being updated one by one, starting from the highest ordinal.
        ```bash
        kubectl rollout status sts/random-generator -n default -w
        # Example output progression:
        # Waiting for partitioned roll out to finish: 2 out of 3 new pods have been updated...
        # Waiting for partitioned roll out to finish: 1 out of 3 new pods have been updated...
        # statefulset rolling update complete 3 pods running...
        ```
        *(The exact messages might vary slightly based on Kubernetes version.)*

    *   **Watch the Pods being updated (observe reverse order):**
        ```bash
        kubectl get pods -n default -l app=random-generator -w
        ```
        *Observe `random-generator-2` being terminated and recreated first, then `random-generator-1`, and finally `random-generator-0`.*

---

### Imperative Way (using `kubectl set image` or `kubectl patch`)

While possible, for StatefulSets, keeping the YAML manifest as the source of truth (declarative approach) is generally preferred.

*   **Using `kubectl set image` (similar to Deployments):**
    ```bash
    kubectl set image sts/random-generator random-generator-container=sbeliakou/random-generator:2 -n default
    # Format: kubectl set image statefulset/<sts-name> <container-name>=<new-image>
    ```
    This will also trigger the rolling update in reverse ordinal order.

After running any of these imperative commands, you would use the same verification steps as in the declarative approach (monitor rollout status, check pod images).

---

## Task 4: Verify StatefulSet Pod DNS Records

**Requirements:**

*   Run a test Pod (e.g., using an image like `busybox` that includes `nslookup`).
*   From your local machine, using `kubectl exec`, perform `nslookup` against the test Pod for each Pod in the `random-generator` StatefulSet.
*   Save the output of the `nslookup` commands to a file named `$HOME/k8s_sts.txt` on your local machine.

**Background - StatefulSet Pod DNS:**
Each Pod in a StatefulSet gets a unique, stable DNS hostname based on its ordinal index. The format is typically:
`<pod-name>.<governing-service-name>.<namespace>.svc.<cluster-domain>`

For the `random-generator` StatefulSet in the `default` namespace, with `random-generator` as the governing service name, and assuming `cluster.local` as the cluster domain, the DNS names for the Pods will be:
*   `random-generator-0.random-generator.default.svc.cluster.local`
*   `random-generator-1.random-generator.default.svc.cluster.local`
*   `random-generator-2.random-generator.default.svc.cluster.local`

--- 

### Steps (User Preferred Method)

1.  **Create and run a temporary Pod that will stay running for a while:**
    We'll use the `busybox` image. The `sleep 3600` command keeps it running for an hour, giving enough time for the `nslookup` commands. Ensure it's in the `default` namespace.
    ```bash
    kubectl run test-pod --image=busybox:1.34 --restart=Never -n default -- sleep 3600
    ```
    *Wait for the Pod to be in the `Running` state before proceeding:*
    ```bash
    kubectl get pod test-pod -n default -w
    # Press Ctrl+C once you see it's Running
    ```

2.  **From your local machine, execute `nslookup` commands inside the `test-pod` and redirect output to a local file:**

    ```bash
    kubectl exec test-pod -n default -- nslookup random-generator-0.random-generator.default.svc.cluster.local > $HOME/k8s_sts.txt
    kubectl exec test-pod -n default -- nslookup random-generator-1.random-generator.default.svc.cluster.local >> $HOME/k8s_sts.txt
    kubectl exec test-pod -n default -- nslookup random-generator-2.random-generator.default.svc.cluster.local >> $HOME/k8s_sts.txt
    ```

3.  **Verify the contents of the saved file on your local machine:**
    ```bash
    cat $HOME/k8s_sts.txt
    ```
    *Expected output structure (BusyBox nslookup format might vary slightly):*
    ```
    Server:    <your-cluster-dns-ip>  (This line might be missing with BusyBox nslookup)
    Address:   <your-cluster-dns-ip>#53 (This line might be missing or different)

    Name:      random-generator-0.random-generator.default.svc.cluster.local
    Address:   <pod-0-ip>
    
    Server:    <your-cluster-dns-ip>  (This line might be missing with BusyBox nslookup)
    Address:   <your-cluster-dns-ip>#53 (This line might be missing or different)

    Name:      random-generator-1.random-generator.default.svc.cluster.local
    Address:   <pod-1-ip>

    Server:    <your-cluster-dns-ip>  (This line might be missing with BusyBox nslookup)
    Address:   <your-cluster-dns-ip>#53 (This line might be missing or different)

    Name:      random-generator-2.random-generator.default.svc.cluster.local
    Address:   <pod-2-ip>
    ```

4.  **Delete the test Pod once you are done:**
    ```bash
    kubectl delete pod test-pod -n default
    ```

---

