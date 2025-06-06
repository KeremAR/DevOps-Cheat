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
          # annotations:
          #   nginx.ingress.kubernetes.io/rewrite-target: /
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
            app: olive-svc # Default label added by kubectl create
          name: olive-svc
          namespace: default
        spec:
          ports:
          - port: 80
            protocol: TCP
            targetPort: 80
          selector:
            color: olive # <-- IMPORTANT: Changed for olive
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
          # annotations:
          #   nginx.ingress.kubernetes.io/rewrite-target: /
        spec:
          rules:
          - host: olive.k8slab.net
            http:
              paths:
              - path: /
                pathType: Prefix # <-- IMPORTANT: Added
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

8.  **Check your services in a browser:**
    Ensure your `hosts` file is correctly configured and `minikube tunnel` (if needed) is running.
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
    Create a new file named `colors-ingress.yaml`. This YAML defines a single Ingress resource with one host and multiple path routing rules. The path ` / ` acts as the default or "catch-all" because the Ingress controller will always match the most specific path first (e.g., `/aqua` will be matched before `/`).

    **`colors-ingress.yaml` content:**
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: colors-ingress
      namespace: default
    spec:
      ingressClassName: nginx
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
          - path: / 
            pathType: Prefix
            backend:
              service:
                name: olive-svc
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
