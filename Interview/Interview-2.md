## Docker

### Diff between CMD & Entrypoint?
CMD and ENTRYPOINT are two instructions in a Dockerfile that specify what command to run when a container starts.
If only CMD exists, docker run can replace it completely. If ENTRYPOINT exists, docker run just gives arguments to it.

---

### What are Cgroups in Docker?
Docker uses Cgroups to isolate and control the resource usage of each container.

---

### What are dangling objects in Docker?
Dangling objects are unused Docker resources that are not referenced anymore.

**Examples:**
- Dangling images → `<none>` tagged images left after rebuilds.
- Dangling volumes/networks → not attached to any container.

They waste disk space, so we clean them with commands like:
```
docker image prune
docker volume prune
docker system prune
```

---

## Kubernetes

### Kubernetes Components?
Control plane manages cluster, worker nodes run workloads.

**Control plane components:**
- **API Server:** entry point, Validates requests.
- **etcd:** key-value store for cluster state.
- **Controller Manager:** watches objects and makes changes to match desired state stored in etcd.
- **Scheduler:** Assigns newly created Pods (via api-server) to available Nodes. through scheduling decisions.

**Worker node components:**
- **kubelet:** agent on each node, makes sure the Pods are running in a healthy state on the node.
- **kube-proxy:** handles networking and Services.
- **Container runtime:** runs containers (Docker, containerd, etc.).

---

### Kubernetes Objects: Why and How We Use Them?
- **Pods:** The smallest deployable unit. A Pod is a group of one or more containers that share the same network and storage.
- **ReplicaSets:** ensure a certain number of Pods run. Automatically replaces failed Pods.
- **Deployments:** manage ReplicaSets, support rollout/rollback.
- **StatefulSets:** manage Pods with stable identity, for databases.
- **DaemonSets:** run one Pod per node (e.g. logging, monitoring).
- **Taint** = prevent pods from being scheduled on nodes.
- **Toleration** = allow a Pod to run on a tainted node.
- **Affinity** = schedule pods/nodes based on the labels

---

### Types of Services?
- **ClusterIP:** Makes the service reachable only from within the cluster.
- **NodePort:** open port on each node, external access.
- **LoadBalancer:** Exposes the service externally using a cloud provider's load balancer.
- **ExternalName:** maps service to external DNS.
- **Ingress:** acts as a smart router for external access.

---

### Storage?
- **Volumes:** data storage for a Pod.
- **Persistent Volumes (PV):** cluster-wide storage.
- **Persistent Volume Claims (PVC):** request for PV by a Pod.
- **Storage Classes:** It allows developers to get the storage they need without having to manually set up the specific storage infrastructure

---

### Basic kubectl commands?
```bash
kubectl run <pod> --image=busybox --dry-run=client -o yaml
kubectl scale --replicas=2 rs/frontend
kubectl create deployment <deployment> --image=nginx --replicas=3 --dry-run=client -o yaml
kubectl expose deployment <deployment> --port=80 --type=NodePort --name=my-service1 --target-port=80
kubectl set image deployment/<deployment> nginx=nginx
kubectl scale deployments.apps <deployment> --replicas=5
kubectl rollout status deployment <deployment-name>
kubectl edit deployment <deployment-name>
kubectl autoscale deployment my-dep --min=2 --max=10 --cpu-percent=80
#statefulset commands are same
```

---

### How do you troubleshoot POD's with unhealthy status?
1.  **Check Status:** First, I use `kubectl get pods` to see the Pod's current status (e.g., ImagePullBackOff, CrashLoopBackOff, Pending).
2.  **Describe the Pod:** I use `kubectl describe pod <pod-name>`. This command is the most useful for troubleshooting. It provides detailed information.
3.  **Check the Logs:** I use `kubectl logs <pod-name>` to view the application logs. This is essential for problems like CrashLoopBackOff, as it shows why the application is crashing.
4.  **Execute into the Container:** If the Pod is running but behaving unexpectedly, I use `kubectl exec -it <pod-name> -- /bin/bash` to get a shell inside the container and check the environment, files, and running processes.

---

### How do you fix the POD issue with OOMKilled issues?
An OOMKilled (Out Of Memory Killed) status means the Pod's container was using more memory than was allocated to it, so the operating system killed it. To fix this, I would:
increase memory requests/limits in the manifest or optimize the application to use less memory.

---

### What are diff probes in Kubernetes?
Probes are health checks defined in a Pod's manifest. They are used by the kubelet to check the health of a container and manage its lifecycle.
- **Liveness probe:** checks if container is alive, restarts if not.
- **Readiness probe:** checks if container is ready to accept traffic.
- **Startup probe:** checks slow starting apps, avoids killing too early.

---

## CI/CD

### How do you migrate pipelines from one Ci-CD to other?
I first write down all the steps and what tools they use. Then moves environment variables, tokens, and passwords using the new system’s secret manager. Then I create a small version of the pipeline and test each stage one by one before moving everything.

---

### How do you store secrets in your CI-CD?
I use the secret manager from the CI/CD tool or a service like AWS Secrets Manager. I pass the secrets as environment variables at runtime, so they are not hardcoded in the pipeline files.

---

### What is Github actions and why it is gaining more popularity now?
GitHub Actions is a CI/CD tool inside GitHub. You don't need to connect or configure an external CI/CD service. It has many pre-built actions in the GitHub Marketplace, so you don’t need to write scripts for common tasks. It is also popular because it has a big and active community.

---

### What's the purpose of CI?
The purpose of Continuous Integration is to build and test changes frequently to get fast feedback. This helps find problems early and keep the code stable.

---

### You need to build a CI pipeline from scratch. What steps would you include?
- **Source Code Checkout:** Pull the latest code from the version control system (like Git).
- **Install Dependencies:** Download and install all the necessary libraries and packages for the project.
- **Static Code Analysis:** Use tools like SonarQube or linters to check for code quality, style, and potential security issues.
- **Build:** Compile the code into an executable or a deployable artifact.
- **Unit Tests:** Run all automated unit tests to check if the smallest parts of the code work correctly.
- **Artifact Creation:** Package the compiled code and all necessary files into a single artifact (e.g., a .jar or a Docker image).

---

### What types of tests do you know?
- **Unit Tests:** Tests that check individual functions or methods. They are fast and run often during development.
- **Integration Tests:** Tests that verify if different parts of the application or external services work together correctly.
- **End-to-End (E2E) Tests:** Tests that simulate a user's behavior to check if the entire application works as expected, from the front end to the database.
- **Performance Tests:** Measures how the system performs under a particular workload.

---

### Static code analysis tools?
I know tools that analyze code without running it to find potential problems. Examples include:
- **SonarQube:** A popular tool for checking code quality and security.
- **Linters:** Tools like ESLint (for JavaScript) or pylint (for Python) that check code for style and syntax errors.
- **Formatters:** Tools like Prettier or Black that automatically format code to ensure a consistent style.
- **Trivy:** A security tool that finds vulnerabilities in open-source dependencies.

---

### Sonar related questions - quality gates, etc.?
Quality gates in SonarQube are rules that decide if code is good to pass. For example, if test coverage is below 80% or there are critical bugs, the gate fails and CI stops.

---

### What is an artifact?
An artifact is the result of the CI build process. It's the final, packaged output that is ready to be deployed.

---

### Where can we store artifacts?
Docker Hub, Amazon ECR, Google Container Registry (GCR) or GitLab Container Registry.

---

### When does the CI process end?
The CI process ends after all build steps, tests, static analysis, and the artifact is created and stored in a repository.

---

### What's the difference between Continuous Deployment and Continuous Delivery?
Continuous Delivery means the code is ready to deploy, but humans decide when to release it.
Continuous Deployment means the code is automatically deployed to production without any human intervention, as long as all tests pass.

---

### What kind of deployment strategies do you know?
- **Blue/Green Deployment:** You have two identical environments, "Blue" (the current production version) and "Green" (the new version). You deploy to the "Green" environment, test it, and then switch all traffic to it. You can quickly switch back to "Blue" if there are any problems.
- **Canary Deployment:** You release the new version to a small subset of users first. If it works well, you gradually roll it out to all users.
- **Shadow Deployment:** Two versions run at the same time. Only the old version sends responses to users. The new version also gets the same requests, but only for logs and tests. Users don’t see it. It is used to test the new version with real production traffic.

---

### What do you know about versioning? What is semver?
Versioning gives a number to each release. Semantic versioning (semver) uses three numbers: MAJOR.MINOR.PATCH. MAJOR changes break compatibility, MINOR adds features, PATCH fixes bugs.

---

### How would you apply versioning for a project with main, develop and feature branches?
I would keep the main branch for stable releases(MAIN), develop branch for upcoming release(MINOR), and feature branches for new work. The PATCH version is used for bug fixes.

---

### What branching strategies do you know?
- **GitFlow:** A complex strategy with long-lived main and develop branches. It uses feature, release, and hotfix branches for new work, releases, and bug fixes.
- **GitHub Flow:** A much simpler strategy. It has only one main branch. All new work is done in short-lived feature branches.
- **Trunk-Based Development:** All developers work on a single main branch. This is popular for CI/CD because it encourages frequent, small commits.

---

### Good to know: DORA metrics?
DORA metrics measure DevOps performance. They include;
- Deployment Frequency (how often we release),
- Lead Time for Changes (time from commit to deploy),
- Change Failure Rate (how often deploy fails),
- Mean Time to Recovery (time to fix failures).



