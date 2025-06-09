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
This command builds a Docker image named `keremar/keremar_application:latest` using the Dockerfile.

```bash
docker build -t keremar/keremar_application:latest .
```

### Publishing to Docker Hub
The built image was pushed to a private repository on Docker Hub using the `docker push` command. Storing the image in a private repository is important for security.

```bash
docker login
docker push keremar/keremar_application:latest
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
    image: keremar/keremar_application:latest
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
kubectl create deployment application --image=keremar/keremar_application:latest --dry-run=client -o yaml >> manifest.yaml

# Service
kubectl create service clusterip application --tcp=80:5000 --dry-run=client -o yaml >> manifest.yaml

# Ingress
kubectl create ingress nginx --class=nginx --rule="keremar.application.com/=application:80" --dry-run=client -o yaml >> manifest.yaml
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
To access the application from a browser using the name `keremar.application.com`, the local machine's `hosts` file was updated to map this address to the Minikube IP.
```
<minikube-ip> keremar.application.com
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
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
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
        command: ['sh', '-c', 'until nslookup mongo.kar.svc.cluster.local; do echo waiting for mongo; sleep 2; done;']
      containers:
      - name: application
        image: keremar/keremar_application:latest
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
          initialDelaySeconds: 5
          periodSeconds: 5

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
# It routes external HTTP traffic from the host `keremar.application.com` to the application Service, fulfilling the requirement for the presentation layer.
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: keremar.application.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: application
            port:
              number: 80
```

This manifest includes:
- **ConfigMap:** Decouples application configuration (like database host and port) from the code.
- **Secret:** Securely stores sensitive data, such as MongoDB credentials.
- **StatefulSet:** Used for stateful applications like MongoDB. It provides stable network identities and ordered deployment/scaling.
- **Headless Service (mongo):** Used to provide direct access to each pod in the StatefulSet (`clusterIP: None`).
- **Deployment:** Manages the stateless pods of the application. The `Recreate` strategy ensures that old pods are completely removed before the new version is deployed.
- **Service (application):** Provides a single point of access (ClusterIP) to the application pods within the cluster.
- **Ingress:** Makes the application accessible from outside the cluster and routes traffic from `keremar.application.com` to the application service.

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
- http://keremar.application.com

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

## 6. Troubleshooting Commands

Below are basic `kubectl` commands that can be used to diagnose issues that may arise during or after deployment.

### Check Pod Status
```bash
kubectl get pods
```

### Check Services
```bash
kubectl get services
```

### Check Ingress
```bash
kubectl get ingress
```

### View Pod Logs
```bash
kubectl logs <pod-name>
```

### Describe Resources
```bash
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe ingress <ingress-name>
```