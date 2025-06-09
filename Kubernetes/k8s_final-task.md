# Kubernetes Final Task Documentation

This document provides a comprehensive walkthrough of the process for containerizing a web application with Docker and deploying it on a Kubernetes cluster. The project follows a three-tier architecture, consisting of an NGINX Ingress for the presentation layer, a Flask application for the application layer, and a MongoDB database for the data layer. Each step, from Dockerfile optimization to the final Kubernetes deployment, is detailed with explanations to clarify the technical decisions and best practices applied.

## 1. Dockerfile Creation and Optimization

This section describes the process of creating and optimizing the Dockerfile, which defines the environment where the application will run.

### Initial Dockerfile Creation
A basic Dockerfile was created to containerize the application. This initial version includes the fundamental commands to install dependencies and run the application.

```dockerfile
FROM python:3.9.7

ENTRYPOINT /app

COPY requirements.txt requirements.txt

RUN pip3 install --no-cache-dir --requirement requirements.txt

COPY . .

CMD ["python3", "-m", "flask", "run", "--host=8.8.8.8"]
```

### Dockerfile Optimization
Based on analysis with the `Hadolint` linter, the Dockerfile was optimized to be more efficient and secure.

```dockerfile
FROM python:3.9.7

WORKDIR /app

COPY requirements.txt .

RUN pip3 install --no-cache-dir --requirement requirements.txt

COPY . .

CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]
```

**Key improvements:**
- **WORKDIR:** The `WORKDIR` instruction was used to set the working directory inside the container, leading to cleaner and more manageable commands.
- **COPY Command:** The usage of `COPY` commands was standardized.
- **Host Binding:** The host was updated to `0.0.0.0` to make the container accessible from outside.
- **ENTRYPOINT Removed:** The redundant `ENTRYPOINT` command was removed, providing a standard execution command with `CMD`.

## 2. Docker Image Building and Publishing

In this step, the application's Docker image was built using the optimized Dockerfile and pushed to Docker Hub to be accessible by the Kubernetes cluster.

### Building the Image
This command builds a Docker image named `keremar/kar_application` using the Dockerfile.

```bash
docker build -t keremar/kar_application .
```

### Publishing to Docker Hub
The built image was pushed to a private repository on Docker Hub using the `docker push` command. Storing the image in a private repository is important for security.

```bash
docker login
docker push keremar/kar_application
```

## 3. Docker Compose Setup

Before deploying to Kubernetes, a `docker-compose.yaml` file was created to test how the application and database run together locally. This speeds up the development process and helps identify potential integration issues early.

```yaml
version: '3'
services:
  mongo:
    image: mongo
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    ports:
      - "27017:27017"

  application:
    image: keremar/kar_application
    ports:
      - "5000:5000"
    environment:
      MONGO_HOST: mongo
      MONGO_PORT: 27017
      BG_COLOR: teal
    depends_on:
      - mongo
```

### Testing with Docker Compose
The application and database services were started and tested together in the local environment using the `docker-compose up` command.

```bash
docker-compose up
```

## 4. Kubernetes Deployment

This section explains the steps and manifest files required to deploy the application in a Kubernetes environment.

### Environment Setup
The working environment was prepared before deploying on Kubernetes.

1. **Starting Minikube:**
Minikube was started to create a local Kubernetes cluster, and the Ingress addon was enabled for external access.
```bash
minikube start
minikube addons enable ingress
```

2. **Creating Namespace and Context:**
A dedicated namespace (`kar`) and context were created using the `local_minikube_preparation.sh` script to isolate the project from other applications and manage resources more effectively.
```bash
./utils/local_minikube_preparation.sh "Kerem Ar"
```

3. **Creating Docker Registry Secret:**
A secret named `docker-secret` was created to allow Kubernetes to pull the application image from the private repository on Docker Hub. This secret securely stores the Docker Hub credentials.
```bash
# Create secret for Docker Hub authentication
kubectl create secret docker-registry docker-secret \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=keremar \
    --docker-password=<access-token> \
    --docker-email=keremar0000@gmail.com \
    --dry-run=client -o yaml > docker-secret.yaml

```

### Best Practices and Tips

#### YAML vs YML
- `.yaml` and `.yml` extensions mean the same thing.
- `.yaml` is more commonly used.
- Both extensions are valid and supported by Kubernetes.
- `.yaml` is generally preferred for consistency.

#### Manifest Creation Approach
Drafts of the Kubernetes manifests were generated using the `kubectl create --dry-run=client -o yaml` command. This approach minimizes syntax errors that can occur when writing manifests manually and speeds up the process.

1. **Generate templates for each resource type using dry-run:**
```bash
# ConfigMap
kubectl create configmap application --from-literal=MONGO_HOST=mongo --from-literal=MONGO_PORT=27017 --from-literal=BG_COLOR=teal --from-literal=FAIL_FLAG=false --dry-run=client -o yaml > manifest.yaml

# Secret
kubectl create secret generic mongo --from-literal=MONGO_INITDB_ROOT_USERNAME=root --from-literal=MONGO_INITDB_ROOT_PASSWORD=example --dry-run=client -o yaml >> manifest.yaml

# Deployment
kubectl create deployment application --image=keremar/kar_application --dry-run=client -o yaml >> manifest.yaml

# Service
kubectl create service clusterip application --tcp=80:5000 --dry-run=client -o yaml >> manifest.yaml

# Ingress
kubectl create ingress nginx --class=nginx --rule="kar.application.com/=application:80" --dry-run=client -o yaml >> manifest.yaml
```

2. **Manual YAML for StatefulSet (no dry-run command available):**
Since a dry-run command is not available for some resources like `StatefulSet`, these resources are created manually or by referencing examples from the official Kubernetes documentation.
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
spec:
  serviceName: mongo
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
      - name: mongo
        image: mongo:4.4
        ports:
        - containerPort: 27017
        resources:
          limits:
            cpu: "0.5"
            memory: "256Mi"
          requests:
            cpu: "0.2"
            memory: "128Mi"
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongo
              key: MONGO_INITDB_ROOT_USERNAME
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongo
              key: MONGO_INITDB_ROOT_PASSWORD
```

3. **Edit the generated templates:**
The generated draft manifests are enriched with additional configurations such as resource limits, environment variables, and health checks.

4. **Apply the final manifest:**
The finalized manifest file is applied to the cluster using the `kubectl apply` command.
```bash
kubectl apply -f manifest.yaml
```

### Deployment Steps
1. **Applying the Manifest:**
The prepared `manifest.yml` file was applied to the cluster with the `kubectl apply` command, creating all the necessary resources (Deployment, Service, Ingress, etc.).
```bash
kubectl apply -f manifest.yml
```

2. **Local DNS Entry:**
To access the application from a browser using the name `kar.application.com`, the local machine's `hosts` file was updated to map this address to the Minikube IP.
```
<minikube-ip> kar.application.com
```

### Complete Manifest Example
Below is the final manifest file that includes all Kubernetes resources and meets the task requirements. This file defines all layers of the application (data, application, and presentation).

```yaml
# ConfigMap
# This ConfigMap stores non-sensitive application configurations like the MongoDB host and port.
# As required by the task, it decouples the configuration from the application container, allowing for easier updates without rebuilding the image.
apiVersion: v1
kind: ConfigMap
metadata:
  name: application
data:
  MONGO_HOST: mongo
  MONGO_PORT: "27017"
  BG_COLOR: teal
  FAIL_FLAG: "false"

---
# Secret
# This Secret holds sensitive data for the MongoDB database, specifically the root username and password.
# This approach securely manages credentials, fulfilling the requirement to obtain them from a Kubernetes Secret.
apiVersion: v1
kind: Secret
metadata:
  name: mongo
type: Opaque
data:
  MONGO_INITDB_ROOT_USERNAME: cm9vdA==  # root
  MONGO_INITDB_ROOT_PASSWORD: ZXhhbXBsZQ==  # example

---
# StatefulSet
# A StatefulSet is used for the MongoDB database to provide a stable network identity and ordered deployment, which is crucial for stateful applications.
# It is configured with one replica, resource limits, and environment variables sourced from the `mongo` secret, as specified in the requirements.
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
  labels:
    app: mongo
spec:
  serviceName: mongo
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
      - name: mongo
        image: mongo:4.4
        ports:
        - containerPort: 27017
        resources:
          limits:
            cpu: "0.5"
            memory: "256Mi"
          requests:
            cpu: "0.2"
            memory: "128Mi"
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongo
              key: MONGO_INITDB_ROOT_USERNAME
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongo
              key: MONGO_INITDB_ROOT_PASSWORD

---
# MongoDB Service
# This is a Headless Service (`clusterIP: None`) that works with the StatefulSet.
# It provides a unique DNS entry for the MongoDB pod, allowing the application to connect to it directly via a stable network address.
apiVersion: v1
kind: Service
metadata:
  name: mongo
spec:
  selector:
    app: mongo
  ports:
  - port: 27017
    targetPort: 27017
  clusterIP: None

---
# Application Deployment
# The application itself is deployed using a Deployment, which is ideal for stateless services.
# It's configured with one replica, a 'Recreate' strategy, and resource limits.
# It pulls the private Docker image using `docker-secret` and includes an initContainer to ensure it only starts after the database is ready, meeting all task requirements.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: application
  labels:
    app: application
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: application
  template:
    metadata:
      labels:
        app: application
    spec:
      imagePullSecrets:
      - name: docker-secret
      initContainers:
      - name: init-mongo
        image: busybox:latest
        command: ['sh', '-c', 'until nc -z -v mongo 27017; do echo "waiting for mongo..."; sleep 2; done;']
      containers:
      - name: application
        image: keremar/kar_application
        ports:
        - containerPort: 5000
        resources:
          limits:
            cpu: "0.5"
            memory: "128Mi"
          requests:
            cpu: "0.2"
            memory: "64Mi"
        env:
        - name: MONGO_HOST
          valueFrom:
            configMapKeyRef:
              name: application
              key: MONGO_HOST
        - name: MONGO_PORT
          valueFrom:
            configMapKeyRef:
              name: application
              key: MONGO_PORT
        - name: BG_COLOR
          valueFrom:
            configMapKeyRef:
              name: application
              key: BG_COLOR
        - name: MONGO_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongo
              key: MONGO_INITDB_ROOT_USERNAME
        - name: MONGO_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongo
              key: MONGO_INITDB_ROOT_PASSWORD
        livenessProbe:
          httpGet:
            path: /healthz
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /healthx
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 10

---
# Application Service
# This ClusterIP Service exposes the application pods on a stable internal IP address within the cluster.
# It maps port 80 to the container's port 5000, allowing other components, like the Ingress, to communicate with the application.
apiVersion: v1
kind: Service
metadata:
  name: application
spec:
  selector:
    app: application
  ports:
  - port: 80
    targetPort: 5000
  type: ClusterIP

---
# Ingress
# Finally, the Ingress resource exposes the application to the outside world.
# It routes external HTTP traffic from the host `kar.application.com` to the application Service, fulfilling the requirement for the presentation layer.
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: kar.application.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: application
            port:
              number: 80

### Key Interview Notes

These notes explain the "why" behind key technical decisions, which are common interview questions.

#### Why Use the 'Recreate' Deployment Strategy?
- **Answer:** The `Recreate` strategy terminates all old pods before creating any new ones. This causes a short downtime. We used it because it was a requirement of the task. In real-world production environments, `RollingUpdate` is the preferred strategy for achieving zero-downtime deployments.

#### Difference Between `requests` and `limits`
- **`requests`:** This is the **guaranteed minimum** amount of resources (CPU/Memory) that Kubernetes reserves for a container. The scheduler uses this value to decide which node to place the pod on.
- **`limits`:** This is the **maximum** amount of resources a container is allowed to use.
  - If a container exceeds its **memory limit**, it gets terminated (OOMKilled).
  - If a container exceeds its **CPU limit**, its performance is throttled (slowed down).

#### Role of the Init Container and `netcat`
- **Role:** An `initContainer` is a setup container that runs and must complete successfully before the main application container starts. In this project, it prevents the application from starting until the `mongo` database is ready to accept connections. This avoids application crashes from database connection errors at startup.
- **The `until nc -z ...` Command:** This command loops until it can successfully establish a connection to port `27017` on the `mongo` service.
- **Why `netcat (nc)` instead of `nslookup`?**
  - `nslookup` only checks if the service name (`mongo`) resolves to an IP address (a DNS check). This does not guarantee the database process is ready.
  - `netcat (nc)` checks if the port (`27017`) is actually open and listening. This is a much more reliable way to confirm that the database is ready to accept connections.

#### Difference Between Liveness and Readiness Probes
- **`livenessProbe` (`/healthz`):** Asks the question, "Is the application still running?" If this probe fails, Kubernetes assumes the application is stuck in a deadlock and **restarts the container**.
- **`readinessProbe` (`/healthx`):** Asks, "Is the application ready to accept new traffic?" If this probe fails, Kubernetes **stops sending traffic to the pod** (by removing it from the service's endpoints). This is useful when an application needs time to warm up or is temporarily busy.

---
`
This manifest includes:
- **ConfigMap:** Decouples application configuration (like database host and port) from the code.
- **Secret:** Securely stores sensitive data, such as MongoDB credentials.
- **StatefulSet:** Used for stateful applications like MongoDB. It provides stable network identities and ordered deployment/scaling.
- **Headless Service (mongo):** Used to provide direct access to each pod in the StatefulSet (`clusterIP: None`).
- **Deployment:** Manages the stateless pods of the application. The `Recreate` strategy ensures that old pods are completely removed before the new version is deployed.
- **Service (application):** Provides a single point of access (ClusterIP) to the application pods within the cluster.
- **Ingress:** Makes the application accessible from outside the cluster and routes traffic from `kar.application.com` to the application service.

### Key features:
- Resource limits and requests are defined for both containers (application and MongoDB).
- Liveness and readiness probes are added to check the health of the application.
- A flexible configuration is achieved by sourcing environment variables from ConfigMaps and Secrets.
- Proper service discovery mechanisms are set up for services to find each other.
- External access is configured with Ingress.
- Image pulling from a private repository is secured using a `docker-secret`.

## 5. Verification

The following checks are performed to verify that the application has been deployed successfully and is running with the correct configurations.

The application is now accessible at:
- http://kar.application.com

### Health Checks
- **Liveness probe:** `/healthz` - Checks if the container is running. If it fails, the container is restarted.
- **Readiness probe:** `/healthx` - Checks if the container is ready to accept incoming traffic. If not ready, it's removed from the service endpoints.

### Resource Limits
**Application:**
- CPU: limit-0.5, request-0.2
- Memory: limit-128Mi, request-64Mi

**MongoDB:**
- CPU: limit-0.5, request-0.2
- Memory: limit-256Mi, request-128Mi

## 6. Live Troubleshooting Commands (For Interview Demo)

Here are useful commands to demonstrate your debugging skills during an interview. They cover common failure scenarios.

### Scenario 1: "My application pod is not running or is crashing."

1.  **Get an overview of everything in your namespace.** This is the best first step.
    ```bash
    # See the status of all resources: Pods, Services, Deployments, etc.
    kubectl get all
    ```
    *Look for pods with status `CrashLoopBackOff`, `Error`, or `Pending`.*

2.  **Describe the failing pod to find the root cause.** This is your most powerful command.
    ```bash
    # Replace <pod-name> with the actual pod name, e.g., application-xxxx-yyyy
    kubectl describe pod <pod-name>
    ```
    *Check the `Events` section at the bottom. It will show you errors like: `ImagePullBackOff` (image name is wrong or secret is missing), probe failures (`Liveness probe failed`), or scheduling failures.*

3.  **Check the logs.**
    ```bash
    # Get logs from the main container
    kubectl logs <pod-name>

    # If the pod is crashing, check the logs of the *previous* container instance
    kubectl logs --previous <pod-name>

    # If the Init Container is failing, check its specific logs
    kubectl logs <pod-name> -c init-mongo
    ```

### Scenario 2: "I can't access my application from the browser."

1.  **Check that the Ingress is configured correctly.**
    ```bash
    # Check if the Ingress resource exists and has the correct host and service
    kubectl get ingress

    # Describe the ingress to see detailed rules and backend health
    kubectl describe ingress nginx
    ```
    *Look at the `Rules` and `Backend` sections. Also, check the `Events` for any errors reported by the Ingress controller.*

2.  **Check that the Service is pointing to the right pods.**
    ```bash
    # See if the application Service exists and has a ClusterIP
    kubectl get service application

    # Check if the Service has found any pods. The "ENDPOINTS" should not be <none>.
    kubectl describe service application
    ```
    *If `ENDPOINTS` is `<none>`, it means the service's `selector` doesn't match your pod's `labels`, or the pod's `readinessProbe` is failing.*

3.  **Check the Ingress Controller logs for traffic issues.**
    ```bash
    # First, find the name of the ingress controller pod
    kubectl get pods -n ingress-nginx

    # Then, view its logs for any errors related to your ingress host
    kubectl logs <ingress-controller-pod-name> -n ingress-nginx
    ```

### Scenario 3: "My application can't connect to the database."

1.  **Verify the database (StatefulSet) is running.**
    ```bash
    kubectl get statefulset mongo
    kubectl get pod mongo-0
    ```
    *Ensure the pod `mongo-0` is in the `Running` state.*

2.  **Verify the database service is correct.** It should be a headless service (`CLUSTER-IP` should be `None`).
    ```bash
    kubectl get service mongo
    ```

3.  **Exec into the application pod to test connectivity directly.**
    ```bash
    # Get a shell inside the running application pod
    kubectl exec -it <application-pod-name> -- /bin/sh

    # Inside the pod, check that environment variables are set correctly
    printenv | grep MONGO

    # Use netcat to test the connection to the mongo service on its port
    # This is the same command used by the init container.
    nc -zv mongo 27017
    # Expected output: Connection to mongo 27017 port [tcp/*] succeeded!
    ```