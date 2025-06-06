## Task 1: Expose Multiple Deployments via Separate Ingress Resources

**Objective:**
Create Kubernetes Services for existing `aqua`, `maroon`, and `olive` deployments. Then, create three separate Ingress resources to route external traffic from specific hostnames to these services.

**Prerequisites:**

*   The `aqua`, `maroon`, and `olive` Deployments are already running in the `default` namespace with appropriate selectors (e.g., `color=aqua`, `color=maroon`, `color=olive`).
*   The Minikube Ingress addon is enabled: `minikube addons enable ingress`.
*   Your `hosts` file is configured to resolve `aqua.k8slab.net`, `maroon.k8slab.net`, and `olive.k8slab.net` to your Minikube IP.
*   (Potentially) `minikube tunnel` is running in a separate terminal.

---

### Method 1: Imperative Commands (with limitations)

This method uses imperative commands to create Services and basic Ingress resources. However, for more advanced Ingress features like `pathType` or annotations, you would typically need to edit the generated YAML or use a declarative approach (Method 2).

1.  **Enable Minikube Ingress Addon (if not already done):**
    ```bash
    minikube addons enable ingress
    kubectl get pods -n ingress-nginx # Verify controller pods are running
    ```

2.  **Create Services Imperatively:**
    *(These commands assume your deployments `aqua`, `maroon`, `olive` automatically set a selector that `kubectl expose` can use, or you would use `kubectl create service clusterip <name> --tcp=80:80 --selector="color=<value>"` if more explicit control is needed and the deployment doesn't directly provide the right selector for `expose`.)*
    ```bash
    # Aqua Service
    kubectl expose deployment aqua --name=aqua-svc --port=80 --target-port=80 -n default
    # Maroon Service
    kubectl expose deployment maroon --name=maroon-svc --port=80 --target-port=80 -n default
    # Olive Service
    kubectl expose deployment olive --name=olive-svc --port=80 --target-port=80 -n default
    ```
    Verify services:
    ```bash
    kubectl get svc aqua-svc maroon-svc olive-svc -n default
    ```

3.  **Create Basic Ingress Resources Imperatively:**
    The `kubectl create ingress` command can create basic Ingress rules. The `--class=nginx` flag is typically used with Minikube's NGINX Ingress controller.
    ```bash
    # Aqua Ingress
    kubectl create ingress aqua-ingress --class=nginx --rule="aqua.k8slab.net/=aqua-svc:80" -n default
    # Maroon Ingress
    kubectl create ingress maroon-ingress --class=nginx --rule="maroon.k8slab.net/=maroon-svc:80" -n default
    # Olive Ingress
    kubectl create ingress olive-ingress --class=nginx --rule="olive.k8slab.net/=olive-svc:80" -n default
    ```

4.  **Limitations and Next Steps for Imperative Ingress:**
    *   **`pathType`:** The command above does not set `pathType: Prefix`. By default, it uses `ImplementationSpecific`, which for NGINX Ingress usually behaves like `Prefix` for root paths (`/`). For explicit control and best practice, `pathType` should be defined. You would need to edit each Ingress: `kubectl edit ingress <ingress-name> -n default` and add `pathType: Prefix` under each path entry.
    *   **Annotations:** Annotations like `nginx.ingress.kubernetes.io/rewrite-target: /` cannot be easily added with `kubectl create ingress`. These also require editing the YAML.

    To make these Ingress resources fully match the task's intent (especially regarding `pathType`), further editing of the YAML is needed, or use the Declarative method below.

5.  **Verify Ingresses (after potential edits for `pathType`):**
    ```bash
    kubectl get ingress -n default
    kubectl describe ingress aqua-ingress -n default # Check rules and annotations
    ```

6.  **Test in Browser (after hosts file setup and `minikube tunnel` if needed):**
    *   `http://aqua.k8slab.net`
    *   `http://maroon.k8slab.net`
    *   `http://olive.k8slab.net`

---

### Method 2: Declarative YAML (Step-by-Step with `dry-run`)

This method provides full control over the resource definitions, including `pathType` and annotations, from the start.

1.  **Enable Minikube Ingress Addon (if not already done):**
    ```bash
    minikube addons enable ingress
    ```
    Verify that the Ingress controller pods are running in the `ingress-nginx` namespace (or `kube-system` for older versions):
    ```bash
    kubectl get pods -n ingress-nginx
    ```

2.  **Identify Deployment Selectors:**
    Based on your `kubectl get deployment -o wide` output, the selectors are:
    *   `aqua` deployment: `color=aqua`
    *   `maroon` deployment: `color=maroon`
    *   `olive` deployment: `color=olive`

3.  **Create Resources for AQUA:**

    a.  **Generate `aqua-svc.yaml`:**
        ```bash
        kubectl create service clusterip aqua-svc --tcp=80:80 --dry-run=client -o yaml > aqua-svc.yaml
        ```
    b.  **Edit `aqua-svc.yaml`:**
        Open `aqua-svc.yaml` and modify the `selector` field to match the `aqua` deployment's selector. Ensure the `targetPort` and `port` are correct (80 in this case).

        **Expected `aqua-svc.yaml` content:**
        ```yaml
        apiVersion: v1
        kind: Service
        metadata:
          creationTimestamp: null 
          labels:
            app: aqua-svc 
          name: aqua-svc
          namespace: default
        spec:
          ports:
          - port: 80
            protocol: TCP
            targetPort: 80
          selector:
            color: aqua
          type: ClusterIP
        status:
          loadBalancer: {}
        ```
    c.  **Apply `aqua-svc.yaml`:**
        ```bash
        kubectl apply -f aqua-svc.yaml
        ```
    d.  **Generate `aqua-ingress.yaml`:**
        ```bash
        kubectl create ingress aqua-ingress --rule="aqua.k8slab.net/=aqua-svc:80" --dry-run=client -o yaml > aqua-ingress.yaml
        ```
    e.  **Edit `aqua-ingress.yaml`:**
        Open `aqua-ingress.yaml`. Ensure the `host`, `service.name`, and `service.port` are correct. Add `pathType: Prefix`. You might also want to add annotations like `nginx.ingress.kubernetes.io/rewrite-target: /` if you are using NGINX ingress and need path rewriting (often useful).

        **Expected `aqua-ingress.yaml` content:**
        ```yaml
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
          creationTimestamp: null
          name: aqua-ingress
          namespace: default
        spec:
          rules:
          - host: aqua.k8slab.net
            http:
              paths:
              - path: /
                pathType: 
                backend:
                  service:
                    name: aqua-svc
                    port:
                      number: 80
        status:
          loadBalancer: {}
        ```
    f.  **Apply `aqua-ingress.yaml`:**
        ```bash
        kubectl apply -f aqua-ingress.yaml
        ```

4.  **Create Resources for MAROON (Repeat process in Step 3):**

    a.  **Generate `maroon-svc.yaml`:**
        ```bash
        kubectl create service clusterip maroon-svc --tcp=80:80 --dry-run=client -o yaml > maroon-svc.yaml
        ```
    b.  **Edit `maroon-svc.yaml` (selector: `color: maroon`):**
        **Expected `maroon-svc.yaml` content:**
        ```yaml
        apiVersion: v1
        kind: Service
        metadata:
          creationTimestamp: null
          labels:
            app: maroon-svc 
          name: maroon-svc
          namespace: default
        spec:
          ports:
          - port: 80
            protocol: TCP
            targetPort: 80
          selector:
            color: maroon 
          type: ClusterIP
        status:
          loadBalancer: {}
        ```
    c.  **Apply `maroon-svc.yaml`:**
        ```bash
        kubectl apply -f maroon-svc.yaml
        ```
    d.  **Generate `maroon-ingress.yaml` (host: `maroon.k8slab.net`, service: `maroon-svc`):**
        ```bash
        kubectl create ingress maroon-ingress --rule="maroon.k8slab.net/=maroon-svc:80" --dry-run=client -o yaml > maroon-ingress.yaml
        ```
    e.  **Edit `maroon-ingress.yaml` (add `pathType: Prefix`):**
        **Expected `maroon-ingress.yaml` content:**
        ```yaml
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
          creationTimestamp: null
          name: maroon-ingress
          namespace: default
        spec:
          rules:
          - host: maroon.k8slab.net
            http:
              paths:
              - path: /
                pathType: Prefix 
                backend:
                  service:
                    name: maroon-svc
                    port:
                      number: 80
        status:
          loadBalancer: {}
        ```
    f.  **Apply `maroon-ingress.yaml`:**
        ```bash
        kubectl apply -f maroon-ingress.yaml
        ```

5.  **Create Resources for OLIVE (Repeat process in Step 3):**

    a.  **Generate `olive-svc.yaml`:**
        ```bash
        kubectl create service clusterip olive-svc --tcp=80:80 --dry-run=client -o yaml > olive-svc.yaml
        ```
    b.  **Edit `olive-svc.yaml` (selector: `color: olive`):**
        **Expected `olive-svc.yaml` content:**
        ```yaml
        apiVersion: v1
        kind: Service
        metadata:
          creationTimestamp: null
          labels:
            app: olive-svc 
          name: olive-svc
          namespace: default
        spec:
          ports:
          - port: 80
            protocol: TCP
            targetPort: 80
          selector:
            color: olive 
          type: ClusterIP
        status:
          loadBalancer: {}
        ```
    c.  **Apply `olive-svc.yaml`:**
        ```bash
        kubectl apply -f olive-svc.yaml
        ```
    d.  **Generate `olive-ingress.yaml` (host: `olive.k8slab.net`, service: `olive-svc`):**
        ```bash
        kubectl create ingress olive-ingress --rule="olive.k8slab.net/=olive-svc:80" --dry-run=client -o yaml > olive-ingress.yaml
        ```
    e.  **Edit `olive-ingress.yaml` (add `pathType: Prefix`):**
        **Expected `olive-ingress.yaml` content:**
        ```yaml
        apiVersion: networking.k8s.io/v1
        kind: Ingress
        metadata:
          creationTimestamp: null
          name: olive-ingress
          namespace: default
        spec:
          rules:
          - host: olive.k8slab.net
            http:
              paths:
              - path: /
                pathType: Prefix 
                backend:
                  service:
                    name: olive-svc
                    port:
                      number: 80
        status:
          loadBalancer: {}
        ```
    f.  **Apply `olive-ingress.yaml`:**
        ```bash
        kubectl apply -f olive-ingress.yaml
        ```

6.  **Verify the Services:**
    ```bash
    kubectl get svc aqua-svc maroon-svc olive-svc -n default
    # Expected output: Each service should have a ClusterIP and be on port 80
    ```

7.  **Verify the Ingress Resources:**
    ```bash
    kubectl get ingress aqua-ingress maroon-ingress olive-ingress -n default
    # Expected output: Each Ingress should list its host and have an ADDRESS (this might take a moment to populate, and depends on your Ingress controller and `minikube tunnel` if used)
    ```
    You can also describe an Ingress to see more details:
    ```bash
    kubectl describe ingress aqua-ingress -n default
    ```

8.  **Test in Browser (after hosts file setup and `minikube tunnel` if needed):**
    *   Open `http://aqua.k8slab.net`
    *   Open `http://maroon.k8slab.net`
    *   Open `http://olive.k8slab.net`

    You should see the respective applications.

9.  **Cleanup (Optional):**
    To delete the resources created in this task:
    ```bash
    kubectl delete ingress aqua-ingress maroon-ingress olive-ingress -n default
    kubectl delete service aqua-svc maroon-svc olive-svc -n default
    # Or delete from files if you still have them:
    # kubectl delete -f aqua-ingress.yaml
    # kubectl delete -f aqua-svc.yaml
    # ... and so on for maroon and olive
    ```

---

## Task 2: Expose Multiple Services via a Single Ingress with Path-Based Routing

**Objective:**
Using the services created in Task 1 (`aqua-svc`, `maroon-svc`, `olive-svc`), create a single Ingress resource that routes traffic based on the URL path.

*   **Ingress Name:** `colors-ingress`
*   **Hostname:** `colors.k8slab.net`
*   **Routing Rules:**
    *   `http://colors.k8slab.net/aqua` -> `aqua-svc`
    *   `http://colors.k8slab.net/maroon` -> `maroon-svc`
    *   `http://colors.k8slab.net/*` (any other path) -> `olive-svc` (default backend)

**Prerequisites:**

*   The `aqua-svc`, `maroon-svc`, and `olive-svc` Services from Task 1 are running.
*   Your `hosts` file is configured to resolve `colors.k8slab.net` to your Minikube IP.
*   (Potentially) `minikube tunnel` is running in a separate terminal.

---

### Method 1: Imperative Command

This method is quick but has the same limitations as in Task 1 regarding `pathType`. It relies on the `--default-backend` flag for the catch-all rule.

1.  **Create Ingress with Multiple Rules:**
    The `kubectl create ingress` command allows specifying multiple rules and a default backend.
    ```bash
    kubectl create ingress colors-ingress --class=nginx \
      --rule="colors.k8slab.net/aqua=aqua-svc:80" \
      --rule="colors.k8slab.net/maroon=maroon-svc:80" \
      --default-backend=olive-svc:80 \
      -n default
    ```

2.  **Limitations and Verification:**
    *   **`pathType`:** As in Task 1, this command creates paths with `pathType: ImplementationSpecific`. For explicit control, you should edit the Ingress to set `pathType: Prefix`.
      ```bash
      kubectl edit ingress colors-ingress -n default
      ```
      (You would add `pathType: Prefix` under each path for `/aqua` and `/maroon`).
    *   **Path Rewriting:** This setup forwards requests with the original path (e.g., a request to `.../aqua/page` is sent to the `aqua-svc` pod with the path `/aqua/page`). If your application expects to receive traffic at `/`, this will fail. See the note on path rewriting in Method 2 for details on how to solve this with annotations.

3.  **Verify the Ingress:**
    ```bash
    kubectl get ingress colors-ingress -n default
    kubectl describe ingress colors-ingress -n default
    ```
    The description should show two rules for `/aqua` and `/maroon`, and a default backend pointing to `olive-svc`.

---

### Method 2: Declarative YAML (Recommended)

This method provides full control over the definition, including `pathType` and annotations for features like path rewriting.

1.  **Create `colors-ingress.yaml`:**
    Create a new file named `colors-ingress.yaml`. This YAML defines a single Ingress resource with one host and multiple path routing rules. The `spec.defaultBackend` field acts as the "catch-all" for any requests that don't match the more specific paths.

    **`colors-ingress.yaml` content:**
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: colors-ingress
      namespace: default
    spec:
      ingressClassName: nginx
      defaultBackend:
        service:
          name: olive-svc
          port:
            number: 80
      rules:
      - host: colors.k8slab.net
        http:
          paths:
          - path: /aqua
            pathType: Prefix
            backend:
              service:
                name: aqua-svc
                port:
                  number: 80
          - path: /maroon
            pathType: Prefix
            backend:
              service:
                name: maroon-svc
                port:
                  number: 80
    ```

2.  **Apply the YAML:**
    ```bash
    kubectl apply -f colors-ingress.yaml
    ```

---

### Verification and Testing (For Both Methods)

1.  **Check Ingress Status:**
    It may take a minute for the Ingress controller to assign an address.
    ```bash
    kubectl get ingress colors-ingress -n default
    # NAME             CLASS   HOSTS                ADDRESS        PORTS   AGE
    # colors-ingress   nginx   colors.k8slab.net    192.168.49.2   80      30s
    ```

2.  **Test in Browser:**
    Ensure your `hosts` file maps `colors.k8slab.net` to the ADDRESS from the command above (or your Minikube IP) and that `minikube tunnel` is running (if needed).
    *   Open `http://colors.k8slab.net/aqua` -> Should show the `aqua` application.
    *   Open `http://colors.k8slab.net/maroon` -> Should show the `maroon` application.
    *   Open `http://colors.k8slab.net/` -> Should show the `olive` application.
    *   Open `http://colors.k8slab.net/anything-else` -> Should also show the `olive` application.

### Cleanup (Optional)

```bash
kubectl delete ingress colors-ingress -n default
# If you created the YAML file:
# rm colors-ingress.yaml
```

---

## Task 3: Create a Multi-Application Setup with Complex Routing

**Objective:**
Deploy three separate applications (`red`, `green`, `yellow`) and expose them through individual services. Create a fourth "switch" service that round-robins across all application pods. Finally, create a single Ingress resource to route traffic based on path, using the switch service as the default backend.

---

### Method 1: Imperative Commands

**1. Create Deployments & Set Environment Variables**
```bash
# Red Application
kubectl create deployment red-color --image=sbeliakou/color:v1 --replicas=3
kubectl set env deployment/red-color COLOR=red PORT=8080

# Green Application
kubectl create deployment green-color --image=sbeliakou/color:v1 --replicas=1
kubectl set env deployment/green-color COLOR=green PORT=8080

# Yellow Application
kubectl create deployment yellow-color --image=sbeliakou/color:v1 --replicas=2
kubectl set env deployment/yellow-color COLOR=yellow PORT=8080
```

**2. Add Common Label to Pod Templates for `switch` Service**
This patches the deployments to add a new label to their pods. This is required for the `switch` service to select them all.
```bash
kubectl patch deployment red-color -p '{"spec":{"template":{"metadata":{"labels":{"component":"color-light"}}}}}
kubectl patch deployment green-color -p '{"spec":{"template":{"metadata":{"labels":{"component":"color-light"}}}}}
kubectl patch deployment yellow-color -p '{"spec":{"template":{"metadata":{"labels":{"component":"color-light"}}}}}
```

**3. Create Services**
The `expose` command uses the default `app=<deployment-name>` label selector created with the deployment. The `switch` service is created and then patched to use the common label selector.
```bash
# Services for each color
kubectl expose deployment red-color --name=red-svc --port=8080 --target-port=8080
kubectl expose deployment green-color --name=green-svc --port=8080 --target-port=8080
kubectl expose deployment yellow-color --name=yellow-svc --port=8080 --target-port=8080

# Service for the switch (selecting all color pods)
kubectl create service clusterip switch --tcp=80:8080
kubectl patch service switch -p '{"spec":{"selector":{"component":"color-light"}}}'
```

**4. Create Ingress Resource**
This command creates the Ingress with path-based rules and sets the default backend to the `switch` service for any traffic that doesn't match the more specific paths.
```bash
kubectl create ingress lights-ingress --class=nginx \
  --rule="lights.k8slab.net/red=red-svc:8080" \
  --rule="lights.k8slab.net/green=green-svc:8080" \
  --rule="lights.k8slab.net/yellow=yellow-svc:8080" \
  --default-backend=switch:80
```

---

### Method 2: Declarative YAML (Separated Files)

This approach organizes resources into logical files (deployments, services, ingress), which is a common best practice for managing complex applications.

**1. Generate YAML Templates (Optional)**
You can generate starter templates for your YAML files using `kubectl create` with the `--dry-run=client -o yaml` flags. These generated files will then need to be edited to match the final configuration (e.g., adding environment variables, specific labels, or multiple ingress paths).

```bash
# Generate initial deployment YAML (then edit to add env vars, component label, etc.)
kubectl create deployment red-color --image=sbeliakou/color:v1 --replicas=3 --dry-run=client -o yaml > lights-deployments.yaml
kubectl create deployment green-color --image=sbeliakou/color:v1 --replicas=1 --dry-run=client -o yaml >> lights-deployments.yaml
kubectl create deployment yellow-color --image=sbeliakou/color:v1 --replicas=2 --dry-run=client -o yaml >> lights-deployments.yaml

# Generate initial services YAML (then edit selectors)
kubectl create service clusterip red-svc --tcp=8080:8080 --dry-run=client -o yaml > lights-services.yaml
kubectl create service clusterip green-svc --tcp=8080:8080 --dry-run=client -o yaml >> lights-services.yaml
kubectl create service clusterip yellow-svc --tcp=8080:8080 --dry-run=client -o yaml >> lights-services.yaml
kubectl create service clusterip switch --tcp=80:8080 --dry-run=client -o yaml >> lights-services.yaml

# Generate initial ingress YAML (then edit to add more paths)
kubectl create ingress lights-ingress --class=nginx --rule="lights.k8slab.net/red=red-svc:8080" --dry-run=client -o yaml > lights-ingress.yaml
```

**2. Create/Edit Manifest Files**

After generating the templates (or creating the files from scratch), ensure they contain the correct specifications. The final content for the three files is shown below. It's a good practice to place them in a dedicated directory (e.g., `lights-manifests/`).

**`lights-deployments.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: red-color
spec:
  replicas: 3
  selector:
    matchLabels:
      app: red-color
  template:
    metadata:
      labels:
        app: red-color
        component: color-light
    spec:
      containers:
      - name: color
        image: sbeliakou/color:v1
        ports:
        - containerPort: 8080
        env:
        - name: COLOR
          value: "red"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: green-color
spec:
  replicas: 1
  selector:
    matchLabels:
      app: green-color
  template:
    metadata:
      labels:
        app: green-color
        component: color-light
    spec:
      containers:
      - name: color
        image: sbeliakou/color:v1
        ports:
        - containerPort: 8080
        env:
        - name: COLOR
          value: "green"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: yellow-color
spec:
  replicas: 2
  selector:
    matchLabels:
      app: yellow-color
  template:
    metadata:
      labels:
        app: yellow-color
        component: color-light
    spec:
      containers:
      - name: color
        image: sbeliakou/color:v1
        ports:
        - containerPort: 8080
        env:
        - name: COLOR
          value: "yellow"

```

**`lights-services.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: red-svc
spec:
  type: ClusterIP
  selector:
    app: red-color
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: green-svc
spec:
  type: ClusterIP
  selector:
    app: green-color
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: yellow-svc
spec:
  type: ClusterIP
  selector:
    app: yellow-color
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: switch
spec:
  type: ClusterIP
  selector:
    component: color-light
  ports:
  - name: http
    port: 80
    targetPort: 8080
```

**`lights-ingress.yaml`**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lights-ingress
spec:
  ingressClassName: nginx
  defaultBackend:
    service:
      name: switch
      port:
        number: 80
  rules:
  - host: lights.k8slab.net
    http:
      paths:
      - path: /red
        pathType: Prefix
        backend:
          service:
            name: red-svc
            port:
              number: 8080
      - path: /green
        pathType: Prefix
        backend:
          service:
            name: green-svc
            port:
              number: 8080
      - path: /yellow
        pathType: Prefix
        backend:
          service:
            name: yellow-svc
            port:
              number: 8080
```

**3. Apply the Manifests**

You can apply all files from a single directory or specify each file individually.
```bash
# If you created a directory for the files (e.g., lights-manifests/):
kubectl apply -f ./lights-manifests/

# Or apply each file individually:
kubectl apply -f lights-deployments.yaml -f lights-services.yaml -f lights-ingress.yaml
```

---

### Verification

1.  **Check Resources:**
    Ensure all deployments, pods, services, and the ingress are running correctly.
    ```bash
    kubectl get deployment -l 'component in (color-light)'
    kubectl get pods -l 'component in (color-light)' -o wide
    kubectl get svc red-svc green-svc yellow-svc switch
    kubectl get ingress lights-ingress
    ```

2.  **Test Endpoints:**
    Ensure your `hosts` file maps `lights.k8slab.net` to your Minikube IP and run `minikube tunnel` if necessary.
    ```bash
    # Should return "red"
    curl http://lights.k8slab.net/red

    # Should return "green"
    curl http://lights.k8slab.net/green

    # Should return "yellow"
    curl http://lights.k8slab.net/yellow

    # Should return a mix of red, green, and yellow on repeated calls
    curl http://lights.k8slab.net/
    curl http://lights.k8slab.net/some/other/path
    ```

---

### Cleanup

```bash
# Delete all resources created in this task
kubectl delete ingress lights-ingress
kubectl delete svc red-svc green-svc yellow-svc switch
kubectl delete deployment red-color green-color yellow-color

# Or, if you used the YAML file:
# kubectl delete -f lights-deployments.yaml -f lights-services.yaml -f lights-ingress.yaml
# Or from a directory:
# kubectl delete -f ./lights-manifests/
```

---

### Troubleshooting Common Issues

#### 502 Bad Gateway on Ingress

A `502 Bad Gateway` error from the Ingress controller (like NGINX) means it accepted the request but couldn't get a valid response from the backend service it tried to forward the request to. This is a very common issue when setting up Ingress.

Here's a step-by-step guide to diagnose the problem, using the `lights.k8slab.net/red` endpoint from Task 3 as an example.

**1. Check if the Service has Endpoints**

First, verify that the service is correctly connected to the pods. A service connects to pods using labels. If the labels don't match or the pods aren't ready, the service will have no "endpoints".

```bash
# Describe the service
kubectl describe svc red-svc
```

**What to look for:**
Look at the `Endpoints` line in the output.
*   **Good:** `Endpoints: 10.244.0.10:8080,10.244.0.9:8080,10.244.1.8:8080` (You will see a list of IP addresses and ports).
*   **Bad:** `Endpoints: <none>` (This is the most common cause of 502 errors. It means the service's selector did not find any running and ready pods).

If you see `<none>`, proceed to the next step.

**2. Check Backend Pod Status**

If there are no endpoints, the problem is with the pods that the service is trying to select. Check their status. The service `red-svc` looks for pods with the label `app: red-color`.

```bash
# Get pods using the service's selector
kubectl get pods -l app=red-color

# Check the deployment's status as well
kubectl describe deployment red-color
```

**What to look for:**
*   Are the pods in the `Running` state? If they are in `Pending`, `CrashLoopBackOff`, or `Error`, they won't be registered as endpoints.
*   If pods are in `CrashLoopBackOff`, use `kubectl logs <pod-name>` to see why they are failing.
*   In the deployment description, check the `Replicas` status. You should see something like `3 desired | 3 updated | 3 total | 3 available | 0 unavailable`. If `available` is 0, the pods are not considered "ready".

**3. Check Pod Logs**

Even if pods are `Running`, the application inside might be failing. Check the logs.

```bash
# Get logs from all pods matching the label
kubectl logs -l app=red-color --tail=50
```

**What to look for:**
Look for any application-level errors, stack traces, or configuration problems. For example, the `COLOR` environment variable might be misspelled, causing the app to crash.

**4. Check Service and Ingress Port Mismatch**

This is another common mistake. Let's trace the port numbers from Ingress to Pod.
*   **Ingress -> Service:** The Ingress rule for `/red` points to `red-svc` on port `8080`.
*   **Service:** The `red-svc` definition listens on `port: 8080` and forwards traffic to the `targetPort: 8080` on the pods.
*   **Deployment/Pod:** The `red-color` deployment defines a `containerPort: 8080` for the pods.

A mismatch in any of these places (e.g., Ingress pointing to port `80` while the service listens on `8080`) will cause a 502 error. Double-check the `lights-ingress.yaml` and `lights-services.yaml` files.

---
