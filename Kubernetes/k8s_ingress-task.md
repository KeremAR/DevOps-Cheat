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
  labels:
    app: red-color
    component: color-light
spec:
  replicas: 3
  selector:
    matchLabels:
      app: red-color
      component: color-light
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
        - name: PORT
          value: "8080"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: green-color
  labels:
    app: green-color
    component: color-light
spec:
  replicas: 1
  selector:
    matchLabels:
      app: green-color
      component: color-light
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
        - name: PORT
          value: "8080"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: yellow-color
  labels:
    app: yellow-color
    component: color-light
spec:
  replicas: 2
  selector:
    matchLabels:
      app: yellow-color
      component: color-light
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
        - name: PORT
          value: "8080"
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
# Because changing an immutable selector requires deleting the resource first, the correct cleanup/re-apply procedure is:
kubectl delete deployment red-color green-color yellow-color --ignore-not-found=true
kubectl delete -f lights-services.yaml -f lights-ingress.yaml
# Or from a directory:
# kubectl delete -f ./lights-manifests/
```
---

## Task 4: Troubleshooting Service Selector and Port Configuration

**Objective:**
In the `trouble-2` namespace, two applications (`teal` and `navy`) are not accessible through their respective URLs:
- `http://trouble-2.k8slab.net/teal`
- `http://trouble-2.k8slab.net/navy`

**Initial State:**
- Pods are running correctly on port 80
- Services exist but have incorrect selectors and port configurations
- Ingress exists but has incorrect configuration

**Problems Identified:**
1. **Service Selector Issue**: The `navy-svc` service had an incorrect selector pointing to `teal-color` pods
2. **Port Mismatch**: Services were configured to forward traffic to port 8080, but pods were running on port 80
3. **Ingress Configuration**: `pathType` was set to `ImplementationSpecific` instead of `Prefix`

---

### Method 1: Imperative Approach (Using kubectl commands)

1. **Fix the Service Selector**
   ```bash
   # Patch the navy-svc to use the correct selector
   kubectl patch service navy-svc -n trouble-2 -p '{"spec":{"selector":{"app":"navy-color"}}}'
   ```

2. **Fix the Service Port Configuration**
   ```bash
   # Update both services to use the correct targetPort (80)
   kubectl patch service navy-svc -n trouble-2 -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
   kubectl patch service teal-svc -n trouble-2 -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
   ```

3. **Delete the Existing Ingress**
   ```bash
   kubectl delete ingress trouble-2-ingress -n trouble-2
   ```

4. **Create New Ingress with Correct Configuration**
   ```bash
   kubectl create ingress trouble-2-ingress \
     --class=nginx \
     --rule="trouble-2.k8slab.net/teal=teal-svc:80" \
     --rule="trouble-2.k8slab.net/navy=navy-svc:80" \
     -n trouble-2
   ```

5. **Update pathType to Prefix**
   ```bash
   kubectl patch ingress trouble-2-ingress -n trouble-2 -p '{"spec":{"rules":[{"host":"trouble-2.k8slab.net","http":{"paths":[{"path":"/teal","pathType":"Prefix","backend":{"service":{"name":"teal-svc","port":{"number":80}}}},{"path":"/navy","pathType":"Prefix","backend":{"service":{"name":"navy-svc","port":{"number":80}}}}]}}]}'
   ```

---

### Method 2: Declarative Approach (Using YAML files)

1. **Create Service Patch YAML**
   Create a file named `navy-svc-patch.yaml`:
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: navy-svc
     namespace: trouble-2
   spec:
     selector:
       app: navy-color
     ports:
     - port: 80
       targetPort: 80
     type: ClusterIP
   ```

2. **Create Teal Service Patch YAML**
   Create a file named `teal-svc-patch.yaml`:
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: teal-svc
     namespace: trouble-2
   spec:
     selector:
       app: teal-color
     ports:
     - port: 80
       targetPort: 80
     type: ClusterIP
   ```

3. **Create Ingress YAML**
   Create a file named `trouble-2-ingress.yaml`:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: trouble-2-ingress
     namespace: trouble-2
   spec:
     ingressClassName: nginx
     rules:
     - host: trouble-2.k8slab.net
       http:
         paths:
         - path: /teal
           pathType: Prefix
           backend:
             service:
               name: teal-svc
               port:
                 number: 80
         - path: /navy
           pathType: Prefix
           backend:
             service:
               name: navy-svc
               port:
                 number: 80
   ```

4. **Apply the Changes**
   ```bash
   # Delete existing ingress
   kubectl delete ingress trouble-2-ingress -n trouble-2

   # Apply the service patches
   kubectl apply -f navy-svc-patch.yaml
   kubectl apply -f teal-svc-patch.yaml

   # Apply the new ingress
   kubectl apply -f trouble-2-ingress.yaml
   ```

---

### Verification

After applying either method, verify the configuration:

```bash
# Check service selectors and ports
kubectl get svc -n trouble-2 -o wide

# Check ingress configuration
kubectl get ingress trouble-2-ingress -n trouble-2 -o yaml

# Test the endpoints
curl http://trouble-2.k8slab.net/teal
curl http://trouble-2.k8slab.net/navy
```

---

## Task 6: Troubleshooting Deployment and Service Configuration

**Objective:**
In the `trouble-3` namespace, two applications (`maroon` and `fuchsia`) are not accessible through their respective URLs:
- `http://trouble-3.k8slab.net/maroon` - should show "maroon" page
- `http://trouble-3.k8slab.net/fuchsia` - should show "fuchsia" page

**Initial State:**
- Maroon deployment has 0 replicas
- Fuchsia pods are running but service selector doesn't match pod labels
- Services and Ingress exist but have incorrect configurations

**Problems Identified:**
1. **Maroon Deployment Issue**: 
   - Replica count is set to 0
   - Missing PORT environment variable
2. **Label Selector Mismatch**:
   - Fuchsia pods have `app=fuchsia` label
   - Service has `app=fuchsia-color` selector
3. **Port Configuration**:
   - Services are configured for port 8080
   - Pods are running on port 80

---

### Method 1: Imperative Approach (Using kubectl commands)

1. **Fix Maroon Deployment**
   ```bash
   # Scale up the deployment to 2 replicas
   kubectl scale deployment maroon-color --replicas=2 -n trouble-3
   
   # Set the PORT environment variable
   kubectl set env deployment/maroon-color PORT=80 -n trouble-3
   ```

2. **Fix Service Selectors**
   ```bash
   # Update fuchsia service selector to match pod labels
   kubectl patch service fuchsia-svc -n trouble-3 -p '{"spec":{"selector":{"app":"fuchsia"}}}'
   
   # Update maroon service selector to match pod labels
   kubectl patch service maroon-svc -n trouble-3 -p '{"spec":{"selector":{"app":"maroon"}}}'
   ```

3. **Fix Service Port Configuration**
   ```bash
   # Update both services to use port 80
   kubectl patch service fuchsia-svc -n trouble-3 -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
   kubectl patch service maroon-svc -n trouble-3 -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
   ```

4. **Update Ingress Configuration**
   ```bash
   # Delete existing ingress
   kubectl delete ingress trouble-3-ingress -n trouble-3
   
   # Create new ingress with correct configuration
   kubectl create ingress trouble-3-ingress \
     --class=nginx \
     --rule="trouble-3.k8slab.net/maroon=maroon-svc:80" \
     --rule="trouble-3.k8slab.net/fuchsia=fuchsia-svc:80" \
     -n trouble-3
   ```

---

### Method 2: Declarative Approach (Using YAML files from kubectl get)

1. **Get Current YAML Configurations**
   ```bash
   # Get deployment YAML
   kubectl get deployment maroon-color -n trouble-3 -o yaml > maroon-deployment.yaml
   
   # Get service YAMLs
   kubectl get service fuchsia-svc -n trouble-3 -o yaml > fuchsia-service.yaml
   kubectl get service maroon-svc -n trouble-3 -o yaml > maroon-service.yaml
   
   # Get ingress YAML
   kubectl get ingress trouble-3-ingress -n trouble-3 -o yaml > trouble-3-ingress.yaml
   ```

2. **Edit Maroon Deployment YAML**
   ```yaml
   # maroon-deployment.yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: maroon-color
     namespace: trouble-3
   spec:
     replicas: 2  # Changed from 0 to 2
     selector:
       matchLabels:
         app: maroon  # Changed from maroon-color to maroon
     template:
       metadata:
         labels:
           app: maroon  # Changed from maroon-color to maroon
       spec:
         containers:
         - name: webapp-color
           image: sbeliakou/color:v1
           env:
           - name: COLOR
             value: "maroon"
           - name: PORT  # Added PORT environment variable
             value: "80"
   ```

3. **Edit Service YAMLs**
   ```yaml
   # fuchsia-service.yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: fuchsia-svc
     namespace: trouble-3
   spec:
     selector:
       app: fuchsia  # Changed from fuchsia-color to fuchsia
     ports:
     - port: 80  # Changed from 8080 to 80
       targetPort: 80  # Changed from 8080 to 80
     type: ClusterIP
   ```

   ```yaml
   # maroon-service.yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: maroon-svc
     namespace: trouble-3
   spec:
     selector:
       app: maroon  # Changed from maroon-color to maroon
     ports:
     - port: 80  # Changed from 8080 to 80
       targetPort: 80  # Changed from 8080 to 80
     type: ClusterIP
   ```

4. **Edit Ingress YAML**
   ```yaml
   # trouble-3-ingress.yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: trouble-3-ingress
     namespace: trouble-3
   spec:
     ingressClassName: nginx
     rules:
     - host: trouble-3.k8slab.net
       http:
         paths:
         - path: /maroon
           pathType: Prefix  # Added pathType
           backend:
             service:
               name: maroon-svc
               port:
                 number: 80  # Changed from 8080 to 80
         - path: /fuchsia
           pathType: Prefix  # Added pathType
           backend:
             service:
               name: fuchsia-svc
               port:
                 number: 80  # Changed from 8080 to 80
   ```

5. **Apply the Changes**
   ```bash
   # Delete existing resources
   kubectl delete deployment maroon-color -n trouble-3
   kubectl delete service fuchsia-svc maroon-svc -n trouble-3
   kubectl delete ingress trouble-3-ingress -n trouble-3
   
   # Apply new configurations
   kubectl apply -f maroon-deployment.yaml
   kubectl apply -f fuchsia-service.yaml
   kubectl apply -f maroon-service.yaml
   kubectl apply -f trouble-3-ingress.yaml
   ```

---

### Verification

After applying either method, verify the configuration:

```bash
# Check deployment status
kubectl get deployment -n trouble-3

# Check pod status and labels
kubectl get pods -n trouble-3 --show-labels

# Check service configuration
kubectl get svc -n trouble-3 -o wide

# Check ingress configuration
kubectl get ingress trouble-3-ingress -n trouble-3 -o yaml

# Test the endpoints
curl http://trouble-3.k8slab.net/maroon
curl http://trouble-3.k8slab.net/fuchsia
```


## Task 7: Customizing Default Error Page

**Objective:**
Create a custom default backend for the ingress-nginx-controller to show a custom error page when a requested page is not found.

**Requirements:**
1. Create a custom default backend deployment and service
2. Configure ingress-nginx-controller to use this custom backend
3. Test the configuration by accessing a non-existent page

### Method 1: Imperative Approach

1. **Create Namespace**
   ```bash
   kubectl create namespace ingress-default-backend
   ```

2. **Create Deployment**
   ```bash
   kubectl create deployment sorry-page \
     --image=sbeliakou/http-sorry-page \
     -n ingress-default-backend
   ```

3. **Create Service**
   ```bash
   kubectl create service clusterip sorry-page-service \
     --tcp=80:80 \
     -n ingress-default-backend
   ```

4. **Configure Ingress Controller**
   ```bash
   # Get the current ingress-nginx-controller deployment
   kubectl get deployment ingress-nginx-controller -n ingress-nginx -o yaml > ingress-controller.yaml

   # Edit the deployment to add default backend service
   kubectl patch deployment ingress-nginx-controller -n ingress-nginx \
     --patch '{"spec":{"template":{"spec":{"containers":[{"name":"controller","args":["--default-backend-service=ingress-default-backend/sorry-page-service"]}]}}}}'
   ```

### Method 2: Declarative Approach (Using YAML files from kubectl get)

1. **Get Current YAML Configurations**
   ```bash
   # Get namespace YAML
   kubectl get namespace ingress-default-backend -o yaml > namespace.yaml

   # Create deployment YAML using --dry-run=client
   kubectl create deployment sorry-page \
     --image=sbeliakou/http-sorry-page \
     -n ingress-default-backend \
     --dry-run=client -o yaml > sorry-page-deployment.yaml

   # Create service YAML using --dry-run=client
   kubectl create service clusterip sorry-page-service \
     --tcp=80:80 \
     -n ingress-default-backend \
     --dry-run=client -o yaml > sorry-page-service.yaml

   # Get ingress controller YAML
   kubectl get deployment ingress-nginx-controller -n ingress-nginx -o yaml > ingress-controller.yaml
   ```

2. **Edit Deployment YAML**
   ```yaml
   # sorry-page-deployment.yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: sorry-page
     namespace: ingress-default-backend
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: sorry-page
     template:
       metadata:
         labels:
           app: sorry-page
       spec:
         containers:
         - name: sorry-page
           image: sbeliakou/http-sorry-page
           ports:
           - containerPort: 80
   ```

3. **Edit Service YAML**
   ```yaml
   # sorry-page-service.yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: sorry-page-service
     namespace: ingress-default-backend
   spec:
     selector:
       app: sorry-page
     ports:
     - port: 80
       targetPort: 80
     type: ClusterIP
   ```

4. **Edit Ingress Controller YAML**
   ```yaml
   # ingress-controller.yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: ingress-nginx-controller
     namespace: ingress-nginx
   spec:
     template:
       spec:
         containers:
         - name: controller
           args:
           - --default-backend-service=ingress-default-backend/sorry-page-service
   ```

5. **Apply the Configurations**
   ```bash
   # Create namespace
   kubectl apply -f namespace.yaml

   # Create deployment and service
   kubectl apply -f sorry-page-deployment.yaml
   kubectl apply -f sorry-page-service.yaml

   # Update ingress controller
   kubectl apply -f ingress-controller.yaml
   ```

### Verification

1. **Check Resources**
   ```bash
   # Check namespace
   kubectl get ns ingress-default-backend

   # Check deployment
   kubectl get deployment -n ingress-default-backend

   # Check service
   kubectl get svc -n ingress-default-backend

   # Check ingress controller configuration
   kubectl get deployment ingress-nginx-controller -n ingress-nginx -o yaml | grep default-backend-service
   ```

2. **Test the Configuration**
   ```bash
   # Try to access a non-existent page
   curl -v http://trouble-3.k8slab.net/non-existent-page
   ```



