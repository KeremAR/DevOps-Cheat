# GitHub Actions & Minikube Deployment Report

This report details the process of setting up a Continuous Integration and Continuous Deployment (CI/CD) pipeline using GitHub Actions to automatically build a Node.js application, deploy it to a Minikube cluster, and verify the deployment.

### Step 1: Project and Application File Setup

The foundation of the project involved creating all the necessary files for a containerized Node.js application and its Kubernetes deployment.

1.  **`Dockerfile`**: A standard Dockerfile was created to containerize the application. It uses a `node:14` base image, sets up the working directory, installs dependencies from `package.json`, copies the source code, and defines the command to run the application.

2.  **`package.json` & `server.js`**: A basic `package.json` was defined to manage the project's single dependency, `express`. The `server.js` file contains a simple "Hello World" web server to confirm the application is running after deployment.

3.  **`k8s-node-app.yaml`**: A Kubernetes manifest file was created to define the desired state of the application in the cluster. It includes two main resources:
    *   A **Deployment**: Manages the application's pods, ensuring one replica of the `devopshint/node-app` image is always running.
    *   A **Service**: Exposes the application running on the pod via a `NodePort`, making it accessible from outside the pod within the Minikube network.

### Step 2: Creating the GitHub Actions Workflow

The core of the automation is the `.github/workflows/deploy-to-minikube-github-actions.yaml` file. This file instructs the GitHub Actions runner on how to execute the pipeline.

The pipeline was designed with a single job that runs on an `ubuntu-latest` runner and is triggered on every `push` event to the repository.

The key steps defined in the workflow are:
- **Checkout Code**: Uses the standard `actions/checkout@v4` action to get a copy of the repository's code.
- **Start Minikube**: Leverages the community action `medyagh/setup-minikube@master` to install and start a single-node Kubernetes cluster directly within the runner environment.
- **Build Docker Image**: This crucial step first points the runner's Docker client to the Docker daemon inside the Minikube VM using `eval $(minikube -p minikube docker-env)`. This ensures that when `docker build` is run, the resulting image is built directly within Minikube's environment, making it immediately available to Kubernetes without needing a separate container registry.
- **Deploy to Minikube**: Applies the Kubernetes manifest using `kubectl apply -f k8s-node-app.yaml`, which instructs the cluster to create the Deployment and Service.
- **Test Service URLs**: Verifies the deployment by listing all services with `minikube service list` and, most importantly, fetching the direct URL for the `nodejs-app` service. A successful URL retrieval confirms the application is running and accessible.

### Step 3: Resolving Authentication and Permission Issues

During the initial attempt to push the project files to the GitHub repository, the push was rejected with a specific error message.

**Challenge:**
`! [remote rejected] main -> main (refusing to allow a Personal Access Token to create or update workflow... without 'workflow' scope)`

**Analysis:** The error indicated that the Personal Access Token (PAT) being used for authentication did not have sufficient permissions. For security reasons, GitHub requires explicit permission for any token that creates or modifies files within the `.github/workflows` directory.

**Solution:** The issue was resolved by generating a new Personal Access Token in GitHub's Developer Settings. The new token was created with the **`workflow`** scope enabled, in addition to the standard `repo` scope. Using this new, more privileged token for the `git push` operation satisfied GitHub's security requirements and allowed the workflow file to be successfully pushed.

### Final Configuration Files

Below are the final versions of the key files used in the successful CI/CD pipeline.

#### `deploy-to-minikube-github-actions.yaml`
```yaml
name: Deploy to Minikube using GitHub Actions

on: [push]
  
jobs:
  job1:
    runs-on: ubuntu-latest
    name: build Node.js Docker Image and deploy to minikube
    steps:
    - uses: actions/checkout@v4
    - name: Start minikube
      uses: medyagh/setup-minikube@master
    - name: Try the cluster !
      run: kubectl get pods -A
    - name: Build image
      run: |
          export SHELL=/bin/bash
          eval $(minikube -p minikube docker-env)
          docker build -f ./Dockerfile -t devopshint/node-app:latest .
          echo -n "verifying images:"
          docker images         
    - name: Deploy to minikube
      run:
        kubectl apply -f k8s-node-app.yaml
    - name: Test service URLs
      run: |
          minikube service list
          minikube service nodejs-app --url
```

#### `Dockerfile`
```dockerfile
FROM node:14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
RUN npm install express
COPY . .
EXPOSE 3000
CMD [ "node", "server.js" ]
```

#### `package.json`
```json
{
    "name": "docker_web_app",
    "version": "1.0.0",
    "description": "Node.js on Docker",
    "author": "First Last <first.last@example.com>",
    "main": "server.js",
    "scripts": {
      "start": "node server.js"
    },
    "dependencies": {
      "express": "^4.16.1"
    }
  }
```

#### `server.js`
```javascript
'use strict';

const express = require('express');

// Constants
const PORT = 3000;
const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello World');
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
```

#### `k8s-node-app.yaml`
```yaml
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nodejs-app
  namespace: default
  labels:
    app: nodejs-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
    spec:
      containers:
      - name: nodejs-app
        image: "devopshint/node-app:latest"
        ports:
          - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app
  namespace: default
spec:
  selector:
    app: nodejs-app
  type: NodePort
  ports:
  - name: http
    targetPort: 3000
    port: 80
```
