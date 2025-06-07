# Kubernetes Final Task Documentation

## 1. Dockerfile Creation and Optimization

### Initial Dockerfile Creation
Created a Dockerfile in the application directory with the following content:
```dockerfile
FROM python:3.9.7

ENTRYPOINT /app

COPY requirements.txt requirements.txt

RUN pip3 install --no-cache-dir --requirement requirements.txt

COPY . .

CMD ["python3", "-m", "flask", "run", "--host=8.8.8.8"]
```

### Dockerfile Optimization
After Hadolint analysis, the Dockerfile was optimized to:
```dockerfile
FROM python:3.9.7-slim

WORKDIR /app

COPY requirements.txt .

RUN pip3 install --no-cache-dir --requirement requirements.txt

COPY . .

EXPOSE 5000

CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]
```

Key improvements:
- Used slim base image for smaller size
- Added WORKDIR instruction
- Fixed COPY command syntax
- Added EXPOSE instruction
- Changed host to 0.0.0.0 for proper container networking
- Removed unnecessary ENTRYPOINT

## 2. Docker Image Building and Publishing

### Building the Image
```bash
docker build -t keremar/keremar_application:latest .
```

### Publishing to Docker Hub
```bash
docker login
docker push keremar/keremar_application:latest
```

## 3. Docker Compose Setup

Created docker-compose.yaml for local testing:
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
```bash
docker-compose up
```

## 4. Kubernetes Deployment

### Environment Setup
1. Started Minikube with ingress enabled:
```bash
minikube start
minikube addons enable ingress
```

2. Created namespace and context:
```bash
./utils/local_minikube_preparation.sh "Kerem Ar"
```

3. Created Docker registry secret:
```bash
# Create secret for Docker Hub authentication
kubectl create secret docker-registry docker-secret \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=keremar \
    --docker-password=glpat-JionjSLgFf3jZmdizsP6 \
    --docker-email=keremar0000@gmail.com

# Save the secret to a YAML file for reference
kubectl get secret docker-secret -o yaml > docker-secret.yaml
```

### Best Practices and Tips

#### YAML vs YML
- `.yaml` and `.yml` extensions mean the same thing
- `.yaml` is more commonly used
- Both extensions are valid and supported by Kubernetes
- `.yaml` is generally preferred for consistency

#### Manifest Creation Approach
A systematic approach to creating Kubernetes manifests using dry-run:

1. Generate templates for each resource type using dry-run:
```bash
# ConfigMap
kubectl create configmap application --from-literal=MONGO_HOST=mongo --from-literal=MONGO_PORT=27017 --from-literal=BG_COLOR=teal --dry-run=client -o yaml > manifest.yaml

# Secret
kubectl create secret generic mongo --from-literal=username=root --from-literal=password=example --dry-run=client -o yaml >> manifest.yaml

# Deployment
kubectl create deployment application --image=keremar/keremar_application:latest --dry-run=client -o yaml >> manifest.yaml

# Service
kubectl create service clusterip application --tcp=80:5000 --dry-run=client -o yaml >> manifest.yaml

# Ingress
kubectl create ingress nginx --class=nginx --rule="keremar.application.com/=application:80" --dry-run=client -o yaml >> manifest.yaml
```

2. Manual YAML for StatefulSet (no dry-run command available):
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
              key: username
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongo
              key: password
```

3. Edit the generated templates to add:
   - Resource limits
   - Environment variables
   - Health checks
   - Volumes
   - etc.

4. Apply the final manifest:
```bash
kubectl apply -f manifest.yaml
```

Benefits of this approach:
- Automatically generates correct syntax for each resource type
- Reduces the risk of errors
- Provides a systematic development process
- Follows Kubernetes best practices

Note: Some resource types (like StatefulSet) don't have dry-run commands available. For these, manual YAML creation or examples from Kubernetes documentation can be used.

### Deployment Steps
1. Applied the Kubernetes manifest:
```bash
kubectl apply -f manifest.yml
```

2. Added local DNS entry:
```
127.0.0.1 keremar.application.com
```

3. Updated hosts file with Minikube IP:
```bash
minikube ip
```

### Complete Manifest Example
Here's the complete manifest that combines all resources:

```yaml
# Docker Registry Secret
apiVersion: v1
kind: Secret
metadata:
  name: docker-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>

---
# ConfigMap for application configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: application
data:
  MONGO_HOST: mongo
  MONGO_PORT: "27017"
  BG_COLOR: teal

---
# Secret for MongoDB credentials
apiVersion: v1
kind: Secret
metadata:
  name: mongo
type: Opaque
data:
  username: cm9vdA==  # root
  password: ZXhhbXBsZQ==  # example

---
# StatefulSet for MongoDB
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
              key: username
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongo
              key: password
        volumeMounts:
        - name: mongo-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongo-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi

---
# Service for MongoDB
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
# Deployment for the application
apiVersion: apps/v1
kind: Deployment
metadata:
  name: application
spec:
  replicas: 1
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
      containers:
      - name: application
        image: keremar/keremar_application:latest
        ports:
        - containerPort: 5000
        resources:
          limits:
            cpu: "0.5"
            memory: "256Mi"
          requests:
            cpu: "0.2"
            memory: "128Mi"
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
              key: username
        - name: MONGO_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongo
              key: password
        livenessProbe:
          httpGet:
            path: /
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5

---
# Service for the application
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
# Ingress for the application
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
- Docker registry secret for private repository access
- ConfigMap for application configuration
- Secret for MongoDB credentials
- StatefulSet for MongoDB with persistent storage
- Service for MongoDB
- Deployment for the application with resource limits and health checks
- Service for the application
- Ingress for external access

Key features:
- Resource limits and requests for both containers
- Health checks (liveness and readiness probes)
- Persistent storage for MongoDB
- Environment variables from ConfigMap and Secret
- Proper service discovery setup
- Ingress configuration for external access
- Private repository access using docker-secret

## 5. Verification

The application is now accessible at:
- http://keremar.application.com

### Health Checks
- Liveness probe: /healthz
- Readiness probe: /healthx

### Resource Limits
Application:
- CPU: limit-0.5, request-0.2
- Memory: limit-128Mi, request-64Mi

MongoDB:
- CPU: limit-0.5, request-0.2
- Memory: limit-256Mi, request-128Mi

## 6. Troubleshooting Commands

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