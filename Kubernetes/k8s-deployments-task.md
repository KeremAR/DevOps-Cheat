## Kubernetes Deployment Tasks

---

## Task 1: Create a Deployment

**Requirements:**

*   Name: `nginx-deploy`
*   Image: `nginx:1.19-alpine`
*   Namespace: `default`
*   Replicas: `1`
*   Labels (for the Deployment and Pod template): `app=nginx-deploy`

---

### Imperative Way

1.  **Create the Deployment: (default replicas and labels)**
    ```bash
    kubectl create deployment nginx-deploy --image=nginx:1.19-alpine -n default
    ```

2.  **(optional)Set the number of replicas (it has default replicas 1 but we can change it):**
    ```bash
    kubectl scale deployment nginx-deploy --replicas=1 -n default
    ```

3.  **(optional)Label the Deployment (it has default labels same with deployment name but we can add more labels):**
    ```bash
    kubectl label deployment nginx-deploy app=nginx-deploy -n default
    ```

4.  **Verify the Deployment and Pods:**
    ```bash
    kubectl get deployment nginx-deploy -n default --show-labels
    kubectl get pods -n default -l app=nginx-deploy --show-labels
    ```

---

### Declarative Way

1.  **Create a YAML manifest for the Deployment (e.g., `task1.yaml`):**
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deploy
      namespace: default
      labels:
        app: nginx-deploy # Label for the Deployment object itself
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: nginx-deploy # This selector must match the Pod template labels
      template:
        metadata:
          labels:
            app: nginx-deploy # Labels for the Pods created by this Deployment
        spec:
          containers:
          - name: nginx
            image: nginx:1.19-alpine
            ports:
            - containerPort: 80 # Optional: specify container port
    ```

2.  **Apply the manifest to create the Deployment:**
    ```bash
    kubectl apply -f nginx-deployment-task1.yaml
    ```

3.  **Verify the Deployment and Pods:**
    ```bash
    kubectl get deployment nginx-deploy -n default --show-labels
    kubectl get pods -n default -l app=nginx-deploy --show-labels
    ```

---

## Task 2: Create Deployment with Specific Replicas and Command

**Requirements:**

*   Name: `easy-peasy`
*   Image: `busybox:1.34`
*   Namespace: `default` (assuming, as not specified)
*   Replicas: `5`
*   Command (for the container): `sleep infinity`

---

### Declarative Way (Recommended for setting container command)

**Generating an initial template (optional):**

You can generate a basic Deployment YAML template using `kubectl create deployment` with `--dry-run=client -o yaml`. This gives you a starting point to then manually edit to add specific fields like `replicas` and container `command`.

```bash
kubectl create deployment easy-peasy --image=busybox:1.34 --dry-run=client -o yaml > task2-template.yaml
```

1.  **Create/Edit the YAML manifest for the Deployment (e.g., `task2-template.yaml`):**

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: easy-peasy
      namespace: default
      labels:
        app: easy-peasy # Label for the Deployment
    spec:
      replicas: 5
      selector:
        matchLabels:
          app: easy-peasy # Selector for Pods
      template:
        metadata:
          labels:
            app: easy-peasy # Labels for Pods
        spec:
          containers:
          - name: busybox # Container name
            image: busybox:1.34
            command: ["sleep", "infinity"]
    ```

2.  **Apply the manifest:**
    ```bash
    kubectl apply -f easy-peasy-deployment.yaml
    ```

3.  **Verify the Deployment and Pods:**
    ```bash
    kubectl get deployment easy-peasy -n default
    kubectl get pods -n default -l app=easy-peasy
    kubectl rollout status deployment/easy-peasy -n default
    ```

---

## Task 3: Scale a Deployment

**Requirements:**

*   Scale the `nginx-deploy` deployment (from Task 1) to `6` replicas.
*   Namespace: `default` (assuming from Task 1).

---

### Imperative Way

1.  **Scale the Deployment:**
    ```bash
    kubectl scale deployment nginx-deploy --replicas=6 -n default
    ```

2.  **Verify the number of replicas:**
    ```bash
    kubectl get deployment nginx-deploy -n default
    # Observe the READY and AVAILABLE counts
    kubectl get pods -n default -l app=nginx-deploy
    # You should see 6 pods running or being created
    ```

---

### Declarative Way

**Option A: If you have the original manifest (`task1.yaml` from Task 1):**

1.  **Edit the manifest file (`nginx-deployment-task1.yaml`):**
    Change the `spec.replicas` field from `1` to `6`.
    ```yaml
    # In nginx-deployment-task1.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deploy
      namespace: default
      labels:
        app: nginx-deploy
    spec:
      replicas: 6 # Changed from 1 to 6
      selector:
        matchLabels:
          app: nginx-deploy
      template:
        metadata:
          labels:
            app: nginx-deploy
        spec:
          containers:
          - name: nginx
            image: nginx:1.19-alpine
            ports:
            - containerPort: 80
    ```

2.  **Apply the updated manifest:**
    ```bash
    kubectl apply -f nginx-deployment-task1.yaml
    ```

4.  **Verify the number of replicas:**
    ```bash
    kubectl get deployment nginx-deploy -n default
    kubectl get pods -n default -l app=nginx-deploy
    kubectl rollout status deployment/nginx-deploy -n default
    ```

---

## Task 4: Create Deployment with Init Container, Custom Labels, and Port

**Requirements:**

*   Deployment Name: `<yourname>-app`
*   Namespace: `default` (assuming, as not specified)
*   Replicas: `1`
*   Deployment Labels:
    *   `task: deploy`
    *   `app: <yourname>-app`
    *   `student: <yourname>`
*   Pod Labels:
    *   `deploy: <yourname>-app`
    *   `kind: redis`
    *   `role: master`
    *   `tier: db`
*   Main Container:
    *   Name: `redis-master`
    *   Image: `redis:5-alpine`
    *   Port: `6379`
*   Init Container:
    *   Image: `busybox:1.34`
    *   Command: `sleep 10` (Note: `sleep 10` needs to be correctly formatted as a list in YAML, e.g., `["sleep", "10"]`)

---

### Declarative Way (Highly Recommended for this complexity)

**Generating an initial template (optional, with limitations):**

You could start by generating a very basic template:
```bash
kubectl create deployment kerem-app --image=redis:5-alpine --dry-run=client -o yaml > task4-template.yaml
```
However, you would then need to manually edit `task4-template.yaml` extensively to add:
*   Correct replica count.
*   All Deployment labels.
*   The init container definition.
*   The specific Pod labels.
*   The main container's name and port.
*   The main container's command (if different from image default, though not specified here, Redis image has its own default).
*   The init container's command.
*   Ensure the selector matches the Pod labels.

**1. Create/Edit the YAML manifest for the Deployment (e.g., `task4-template.yaml`):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kerem-app
  namespace: default # Assuming default namespace
  labels:
    task: deploy
    app: kerem-app
    student: kerem
spec:
  replicas: 1
  selector:
    matchLabels:
      deploy: kerem-app # Must match labels in Pod template
      # kind: redis    #optional
      # role: master # Selectors should be specific enough
      # tier: db       # but not overly restrictive if not needed for selection logic
  template:
    metadata:
      labels:
        deploy: kerem-app
        kind: redis
        role: master
        tier: db
    spec:
      initContainers:
      - name: init-wait
        image: busybox:1.34
        command: ["sleep", "10"]
      containers:
      - name: redis-master
        image: redis:5-alpine
        ports:
        - containerPort: 6379
          #name: redis # Optional port name
```


**2. Apply the manifest:**
```bash
kubectl apply -f <yourname>-app-deployment.yaml
```

**3. Verify the Deployment, Pods, and Init Container:**
```bash
kubectl get deployment kerem-app -n default --show-labels
kubectl get pods -n default -l deploy=kerem-app --show-labels
# Check rollout status
kubectl rollout status deployment/kerem-app -n default


```

---

## Task 6: Troubleshoot Deployment with No Pods (Replicas Set to 0)

**Scenario:**

A Deployment named `lemon` exists in the `trouble` namespace, but no pods are being created or managed by it.

**Investigation Steps:**

1.  **Get the Deployment's YAML definition to understand its current state:**
    ```bash
    kubectl get deployment lemon -n trouble -o yaml
    ```
    *Output from user (showing `replicas: 0` initially):*
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      annotations:
        deployment.kubernetes.io/revision: "1"
        kubectl.kubernetes.io/last-applied-configuration: |
          {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"lemon","namespace":"trouble"},"spec":{"replicas":0,"selector":{"matchLabels":{"app":"lemon"}},"template":{"metadata":{"labels":{"app":"lemon"}},"spec":{"containers":[{"image":"nginx:alpine","name":"lemon"}]}}}}
      creationTimestamp: "2025-05-28T16:27:13Z"
      generation: 1
      name: lemon
      namespace: trouble
      resourceVersion: "55773"
      uid: 06118100-c851-45ca-84d5-65095c9dc699
    spec:
      progressDeadlineSeconds: 600
      replicas: 0 # <<< ROOT CAUSE IDENTIFIED HERE
      revisionHistoryLimit: 10
      selector:
        matchLabels:
          app: lemon
      strategy:
        rollingUpdate:
          maxSurge: 25%
          maxUnavailable: 25%
        type: RollingUpdate
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: lemon
        spec:
          containers:
          - image: nginx:alpine
            imagePullPolicy: IfNotPresent
            name: lemon
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
          dnsPolicy: ClusterFirst
          restartPolicy: Always
          schedulerName: default-scheduler
          securityContext: {}
          terminationGracePeriodSeconds: 30
    status:
      # ... status omitted for brevity, but it showed minimum availability due to 0 replicas ...
    ```

2.  **Describe the Deployment (Optional but good practice):**
    This can provide additional context or event information.
    ```bash
    kubectl describe deployment lemon -n trouble
    ```

**Root Cause Analysis:**

The YAML output from `kubectl get deployment ... -o yaml` clearly shows `spec.replicas: 0`. This tells Kubernetes to maintain zero instances of the pod, which is why no pods were running.

---

### Fixing the Issue

#### Imperative Way

1.  **Scale the Deployment to the desired number of replicas (e.g., 1):**
    ```bash
    kubectl scale deployment lemon --replicas=1 -n trouble
    ```

2.  **Verify that Pods are now being created and running:**
    ```bash
    kubectl get pods -n trouble -l app=lemon -w
    ```

#### Declarative Way

1.  **Get the current (broken) Deployment YAML and save it to a file:**

    ```bash
    kubectl get deployment lemon -n trouble -o yaml > task6-fix.yaml
    ```
2.  **Edit the saved YAML file (`task6-fix.yaml`):**
    Open the file and change `spec.replicas` from `0` to `1`.
    ```yaml
    # In task6-fix.yaml
    # ...
    spec:
      replicas: 1 # Change from 0 to 1
    # ...
    ```
3.  **Apply the corrected manifest:**
    ```bash
    kubectl apply -f lemon-deployment-fix.yaml
    ```

---

### Verification (After either Imperative or Declarative Fix)

1.  **Check the Deployment status:**
    ```bash
    kubectl get deployment lemon -n trouble
    ```
    *Expected output should show 1/1 replicas ready.*

2.  **Check the Pods:**
    ```bash
    kubectl get pods -n trouble -l app=lemon
    ```
    *Expected output should show one pod in Running state.*

3.  **Check rollout status (optional):**
    ```bash
    kubectl rollout status deployment/lemon -n trouble
    ```
    *Expected output: "deployment 'lemon' successfully rolled out"*

---

## Task 7: Troubleshoot Deployment with Pod in CrashLoopBackOff (Command Error)

**Scenario:**

A Deployment named `orange` has been deployed in the `trouble` namespace. It has 1 replica configured, but the Pod is in a `CrashLoopBackOff` state, and the Deployment reports that it does not have minimum availability.

**Investigation Steps:**

1.  **Get the Deployment's YAML definition:**
    ```bash
    kubectl get deployment orange -n trouble -o yaml
    ```
    *User output (showing the problematic command):*
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      annotations:
        deployment.kubernetes.io/revision: "1"
        kubectl.kubernetes.io/last-applied-configuration: |
          {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"orange","namespace":"trouble"},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"orange"}},"template":{"metadata":{"labels":{"app":"orange"}},"spec":{"containers":[{"command":["sh","c","sleeep infinity"],"image":"alpine","name":"orange"}]}}}}
      creationTimestamp: "2025-05-28T16:27:13Z"
      generation: 1
      name: orange
      namespace: trouble
      resourceVersion: "55782"
      uid: c6fa706a-6889-482e-a916-b290a1653a07
    spec:
      progressDeadlineSeconds: 600
      replicas: 1
      revisionHistoryLimit: 10
      selector:
        matchLabels:
          app: orange
      strategy:
        rollingUpdate:
          maxSurge: 25%
          maxUnavailable: 25%
        type: RollingUpdate
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: orange
        spec:
          containers:
          - command: # <<< PROBLEM AREA
            - sh
            - c # Should be -c
            - sleeep infinity # Should be sleep infinity
            image: alpine
            imagePullPolicy: Always
            name: orange
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
          dnsPolicy: ClusterFirst
          restartPolicy: Always
          schedulerName: default-scheduler
          securityContext: {}
          terminationGracePeriodSeconds: 30
    status:
      conditions:
      - lastTransitionTime: "2025-05-28T16:27:13Z"
        lastUpdateTime: "2025-05-28T16:27:13Z"
        message: Deployment does not have minimum availability.
        reason: MinimumReplicasUnavailable
        status: "False"
        type: Available
      # ... other status fields ...
      observedGeneration: 1
      replicas: 1
      unavailableReplicas: 1
      updatedReplicas: 1
    ```

2.  **Check the status of Pods managed by the Deployment:**
    ```bash
    kubectl get pods -n trouble -l app=orange
    ```
    *User output:*
    ```
    NAME                      READY   STATUS             RESTARTS       AGE
    orange-6cccc88d9f-ds96f   0/1     CrashLoopBackOff   6 (5m8s ago)   10m
    ```

3.  **Inspect the logs of the failing Pod:**
    (Using the Pod name from the previous step)
    ```bash
    kubectl logs orange-6cccc88d9f-ds96f -n trouble
    ```
    *User output:*
    ```
    sh: can't open 'c': No such file or directory
    ```

**Root Cause Analysis:**

The Pod is in `CrashLoopBackOff` because the container's entrypoint command is failing. The logs `sh: can't open 'c': No such file or directory` indicate that the `sh` shell is trying to execute a file named `c` instead of interpreting the subsequent string as a command. This is because the `-c` flag (which tells `sh` to read commands from the next argument) is missing. Additionally, the command itself has a typo: `sleeep` instead of `sleep`.

The incorrect command in the Deployment template is:
`command: ["sh", "c", "sleeep infinity"]`

It should be:
`command: ["sh", "-c", "sleep infinity"]`

---

### Fixing the Issue

#### Imperative Way (using `kubectl edit`)

1.  **Edit the Deployment directly:**
    ```bash
    kubectl edit deployment orange -n trouble
    ```
2.  In the editor, navigate to `spec.template.spec.containers[0].command`.
3.  Modify the command section as follows:
    ```yaml
          containers:
          - command:
            - sh
            - "-c"
            - "sleep infinity"
            image: alpine
    ```
4.  Save and exit the editor. Kubernetes will automatically start a rolling update to apply the changes.

#### Declarative Way

1.  **Get the current (broken) Deployment YAML and save it to a file (if you don't have the original manifest):**
    ```bash
    kubectl get deployment orange -n trouble -o yaml > task7-fix.yaml
    ```
2.  **Edit the saved YAML file (`task7-fix.yaml`):**
    Open the file and correct the `spec.template.spec.containers[0].command` section:
    ```yaml
    # ...
    spec:
      # ...
      template:
        # ...
        spec:
          containers:
          - command:
            - sh
            - "-c" # Corrected from "c"
            - "sleep infinity" # Corrected from "sleeep infinity"
            image: alpine
            # ... rest of container spec
    ```
3.  **Apply the corrected manifest:**
    ```bash
    kubectl apply -f orange-deployment-fix.yaml
    ```

---

### Verification (After either Imperative or Declarative Fix)

1.  **Monitor the rollout status:**
    ```bash
    kubectl rollout status deployment/orange -n trouble
    ```
    *Expected output: "deployment 'orange' successfully rolled out"*

2.  **Check the Pods:**
    Wait for new pods to be created and old ones to terminate.
    ```bash
    kubectl get pods -n trouble -l app=orange -w
    ```
    *Expected output should show a new pod in `Running` state with 1/1 ready, and the old pod terminating or gone.*


