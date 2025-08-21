## Docker

### 1) Diff between CMD & Entrypoint?
CMD and ENTRYPOINT are two instructions in a Dockerfile that specify what command to run when a container starts.
If only CMD exists, docker run can replace it completely. If ENTRYPOINT exists, docker run just gives arguments to it.

---

### 2) What are Cgroups in Docker?
Docker uses Cgroups to isolate and control the resource usage of each container.

---

### 3) What are dangling objects in Docker?
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

### 4) Kubernetes Components?
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

### 5) Kubernetes Objects: Why and How We Use Them?
- **Pods:** The smallest deployable unit. A Pod is a group of one or more containers that share the same network and storage.
- **ReplicaSets:** ensure a certain number of Pods run. Automatically replaces failed Pods.
- **Deployments:** manage ReplicaSets, support rollout/rollback.
- **StatefulSets:** manage Pods with stable identity, for databases.
- **DaemonSets:** run one Pod per node (e.g. logging, monitoring).
- **Taint** = prevent pods from being scheduled on nodes.
- **Toleration** = allow a Pod to run on a tainted node.
- **Affinity** = schedule pods/nodes based on the labels

---

### 6) Types of Services?
- **ClusterIP:** Makes the service reachable only from within the cluster.
- **NodePort:** open port on each node, external access.
- **LoadBalancer:** Exposes the service externally using a cloud provider's load balancer.
- **ExternalName:** maps service to external DNS.
- **Ingress:** acts as a smart router for external access.

---

### 7) Storage?
- **Volumes:** data storage for a Pod.
- **Persistent Volumes (PV):** cluster-wide storage.
- **Persistent Volume Claims (PVC):** request for PV by a Pod.
- **Storage Classes:** It allows developers to get the storage they need without having to manually set up the specific storage infrastructure

---

### 8) Basic kubectl commands?
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

### 9) How do you troubleshoot POD's with unhealthy status?
1.  **Check Status:** First, I use `kubectl get pods` to see the Pod's current status (e.g., ImagePullBackOff, CrashLoopBackOff, Pending).
2.  **Describe the Pod:** I use `kubectl describe pod <pod-name>`. This command is the most useful for troubleshooting. It provides detailed information.
3.  **Check the Logs:** I use `kubectl logs <pod-name>` to view the application logs. This is essential for problems like CrashLoopBackOff, as it shows why the application is crashing.
4.  **Execute into the Container:** If the Pod is running but behaving unexpectedly, I use `kubectl exec -it <pod-name> -- /bin/bash` to get a shell inside the container and check the environment, files, and running processes.

---

### 10) How do you fix the POD issue with OOMKilled issues?
An OOMKilled (Out Of Memory Killed) status means the Pod's container was using more memory than was allocated to it, so the operating system killed it. To fix this, I would:
increase memory requests/limits in the manifest or optimize the application to use less memory.

---

### 11) What are diff probes in Kubernetes?
Probes are health checks defined in a Pod's manifest. They are used by the kubelet to check the health of a container and manage its lifecycle.
- **Liveness probe:** checks if container is alive, restarts if not.
- **Readiness probe:** checks if container is ready to accept traffic.
- **Startup probe:** checks slow starting apps, avoids killing too early.

---

## CI/CD

### 12) How do you migrate pipelines from one Ci-CD to other?
I first write down all the steps and what tools they use. Then moves environment variables, tokens, and passwords using the new system’s secret manager. Then I create a small version of the pipeline and test each stage one by one before moving everything.

---

### 13) How do you store secrets in your CI-CD?
I use the secret manager from the CI/CD tool or a service like AWS Secrets Manager. I pass the secrets as environment variables at runtime, so they are not hardcoded in the pipeline files.

---

### 14) What is Github actions and why it is gaining more popularity now?
GitHub Actions is a CI/CD tool inside GitHub. You don't need to connect or configure an external CI/CD service. It has many pre-built actions in the GitHub Marketplace, so you don’t need to write scripts for common tasks. It is also popular because it has a big and active community.

---

### 15) What's the purpose of CI?
The purpose of Continuous Integration is to build and test changes frequently to get fast feedback. This helps find problems early and keep the code stable.

---

### 16) You need to build a CI pipeline from scratch. What steps would you include?
- **Source Code Checkout:** Pull the latest code from the version control system (like Git).
- **Install Dependencies:** Download and install all the necessary libraries and packages for the project.
- **Static Code Analysis:** Use tools like SonarQube or linters to check for code quality, style, and potential security issues.
- **Build:** Compile the code into an executable or a deployable artifact.
- **Unit Tests:** Run all automated unit tests to check if the smallest parts of the code work correctly.
- **Artifact Creation:** Package the compiled code and all necessary files into a single artifact (e.g., a .jar or a Docker image).

---

### 17) What types of tests do you know?
- **Unit Tests:** Tests that check individual functions or methods. They are fast and run often during development.
- **Integration Tests:** Tests that verify if different parts of the application or external services work together correctly.
- **End-to-End (E2E) Tests:** Tests that simulate a user's behavior to check if the entire application works as expected, from the front end to the database.
- **Performance Tests:** Measures how the system performs under a particular workload.

---

### 18) Static code analysis tools?
I know tools that analyze code without running it to find potential problems. Examples include:
- **SonarQube:** A popular tool for checking code quality and security.
- **Linters:** Tools like ESLint (for JavaScript) or pylint (for Python) that check code for style and syntax errors.
- **Formatters:** Tools like Prettier or Black that automatically format code to ensure a consistent style.
- **Trivy:** A security tool that finds vulnerabilities in open-source dependencies.

---

### 19) Sonar related questions - quality gates, etc.?
Quality gates in SonarQube are rules that decide if code is good to pass. For example, if test coverage is below 80% or there are critical bugs, the gate fails and CI stops.

---

### 20) What is an artifact?
An artifact is the result of the CI build process. It's the final, packaged output that is ready to be deployed.

---

### 21) Where can we store artifacts?
Docker Hub, Amazon ECR, Google Container Registry (GCR) or GitLab Container Registry.

---

### 22) When does the CI process end?
The CI process ends after all build steps, tests, static analysis, and the artifact is created and stored in a repository.

---

### 23) What's the difference between Continuous Deployment and Continuous Delivery?
Continuous Delivery means the code is ready to deploy, but humans decide when to release it.
Continuous Deployment means the code is automatically deployed to production without any human intervention, as long as all tests pass.

---

### 24) What kind of deployment strategies do you know?
- **Blue/Green Deployment:** You have two identical environments, "Blue" (the current production version) and "Green" (the new version). You deploy to the "Green" environment, test it, and then switch all traffic to it. You can quickly switch back to "Blue" if there are any problems.
- **Canary Deployment:** You release the new version to a small subset of users first. If it works well, you gradually roll it out to all users.
- **Shadow Deployment:** Two versions run at the same time. Only the old version sends responses to users. The new version also gets the same requests, but only for logs and tests. Users don’t see it. It is used to test the new version with real production traffic.

---

### 25) What do you know about versioning? What is semver?
Versioning gives a number to each release. Semantic versioning (semver) uses three numbers: MAJOR.MINOR.PATCH. MAJOR changes break compatibility, MINOR adds features, PATCH fixes bugs.

---

### 26) How would you apply versioning for a project with main, develop and feature branches?
I would keep the main branch for stable releases(MAIN), develop branch for upcoming release(MINOR), and feature branches for new work. The PATCH version is used for bug fixes.

---

### 27) What branching strategies do you know?
- **GitFlow:** A complex strategy with long-lived main and develop branches. It uses feature, release, and hotfix branches for new work, releases, and bug fixes.
- **GitHub Flow:** A much simpler strategy. It has only one main branch. All new work is done in short-lived feature branches.
- **Trunk-Based Development:** All developers work on a single main branch. This is popular for CI/CD because it encourages frequent, small commits.

---

### 28) Good to know: DORA metrics?
DORA metrics measure DevOps performance. They include;
- Deployment Frequency (how often we release),
- Lead Time for Changes (time from commit to deploy),
- Change Failure Rate (how often deploy fails),
- Mean Time to Recovery (time to fix failures).



## AWS

### IAM
#### 29) What is the difference between assumerole and passrole?
- AssumeRole means you take temporary permissions from another role.
- PassRole means you allow a service to use a role you already have.

---

### Networking
#### 30) What is the difference between public and private subnet?
- Public subnet has route to internet gateway. Resources inside can connect to internet.
- Private subnet has no direct internet route. It is more secure for databases or backend services.

---

#### 31) What are VPC Endpoints and their benefits?
A VPC endpoint lets you connect your VPC to an AWS service without needing an internet gateway or NAT gateway. The benefits are improved security because traffic stays within the AWS network and better performance because it avoids the public internet.

---

#### 32) How do you troubleshoot with VPC Flow Logs?
I check logs for accepted/rejected connections to see if security group or NACL is blocking.

---

#### 33) What is VPC Peering vs Direct Connect? When to use them?
- VPC Peering connects two VPCs privately using AWS backbone.
- Direct Connect is a physical connection between AWS and on-premise data center. Use it when you need low latency and stable bandwidth.

---

#### 34) What is an Elastic IP?
A static IPv4 address in AWS. It stays the same even if instance stops or restarts.

---

### Compute
#### 35) Load Balancers?
- ALB (Application LB): layer 7, use for HTTP/HTTPS for web apps, path or host-based routing.
- NLB (Network LB): layer 4, very fast, use for TCP/UDP or low latency.

---

#### 36) How to auto scale EC2?
Auto Scaling Group (ASG) uses a Launch Template to know how to create EC2 instances, and then scales them in or out based on metrics, like CPU usage, using scaling policies

---

#### 37) What are spot instances and what are their benefits?
Unused EC2 instances that are available for less money. They can be interrupted by AWS if the service needs the capacity back. They are great for fault-tolerant applications or background jobs where it's okay if the instance is stopped suddenly.

---

#### 38) EC2 vs Fargate hosting – advantages?
- EC2: You have full control over the EC2 instance, including the operating system and installed software.
- Fargate: This is a serverless option. You don't manage the underlying EC2 instances. You only pay for the resources your containers use.

---

### Storage
#### 39) S3 features?
- Versioning: It keeps different versions of an object. This helps protect against accidental deletions or overwrites.
- Replication: You can automatically copy objects to another S3 bucket in a different region.
- Lifecycle Policies: You can set rules to automatically move objects to cheaper storage classes (like Glacier) or delete them after a certain period.
- Event Notifications: S3 can send notifications to other services when an event happens, like when a new object is uploaded.

---

#### 40) EBS vs EFS vs Instance Store?
- EBS: block storage for one EC2, persistent, can snapshot.
- EFS: network file system, can attach to many EC2s, scales automatically.
- Instance Store: temporary storage directly on the host. Data lost if instance stops.

---

#### 41) What is point-in-time recovery?
Point-in-time recovery (PITR) is a backup feature that allows you to restore your data to any specific second within a defined period. It's commonly used with databases like AWS Aurora and DynamoDB to recover from accidental data loss or corruption without having to restore from a full backup.

---

#### 42) Read Replica?
Read replicas are used to scale read-heavy workloads, reduce load on the primary instance, and can also be promoted for disaster recovery.

---

#### 43) S3 Glacier offering?
Glacier is for long-term, low-cost archival storage. Retrieval time can be minutes or hours.

---

### Cost Optimization
#### 44) How to reduce cost in AWS?
- Use auto scaling so resources match demand.
- Move workloads to serverless when possible.
- Use spot instances for batch jobs.
- Use S3 lifecycle rules to move data to cheaper storage (Glacier).
- Use reserved instances or saving plans for steady workloads.

---

### Observability
#### 45) Tell me about observability services in AWS.
- CloudWatch: collects metrics, logs, and alarms for resources like EC2, Lambda.
- CloudTrail: records API calls and user actions for auditing.
- VPC Flow Logs: These logs capture all the IP traffic going to and from the network interfaces in my VPC.
- X-Ray: Distributed tracing. It lets me follow a single request as it travels through all the different microservices in my application.

## Terraform

### 46) Why Infrastructure as Code (IaC)?
IaC means managing infrastructure with code instead of manual steps. It gives repeatability, version control, and easy automation

---

### 47) What is Idempotency?
Idempotency means when I apply the same code again, the result is the same. No duplicate or unexpected resources are created.

---

### 48) What is the Terraform state file?(terraform.tfstate)
State file keeps the mapping between my Terraform code and real resources in the cloud. Terraform uses it to know what exists.

---

### 49) What are the best practices for managing the state file?
- Storage: Store the state file remotely in a service like AWS S3 . This makes it accessible to the whole team.
- Locking: Use a locking mechanism, like DynamoDB with S3. Locking prevents two people from running terraform apply at the same time, which could corrupt the state.
- Encryption: The state file can contain sensitive information, so it must be encrypted at rest. Most remote backends like S3 handle this automatically.
- Versioning: Enable versioning on your remote storage (like an S3 bucket). This keeps a history of your state file, so you can roll back if something goes wrong.
- Access Control: Use IAM policies to restrict who can read and write the state file.

---

### 50) What is a Terraform provider?
A provider is a plugin that allows Terraform to communicate with a specific API. For example, the AWS provider knows how to talk to the AWS API to create resources like EC2 instances or S3 buckets.

---

### 51) What is the difference between variables and locals?
- Variables: input values from user or tfvars file.
- Locals: internal values calculated from variables, used to simplify code.(DRY)

---

### 52) What is the difference between count and for_each?
- count is used to create multiple identical resources by index (0,1,2...).
- For each: Create resources with different configurations using map

---

### 53) How to delete existing resources in Terraform?
- The standard way: You remove the resource's code block from your .tf file. Then, when you run terraform apply, Terraform sees that the resource is no longer in the code and destroys it.
- The direct way: You can run the terraform destroy -target=resource.name command.

---

### 54) How can you import existing infrastructure to a fresh Terraform project?
First, you write the Terraform code for the resource that already exists. For example, you write the aws_s3_bucket resource block in a .tf file.

Then, you run the command terraform import <resource_address> <resource_id>. This tells Terraform to connect your code to the existing resource and save its details into the state file.

---

### 55) How can you restrict someone from deleting resources?
- IAM Policies: In AWS, you can create an IAM policy that  Deny for delete actions like ec2:TerminateInstances. This can be difficult to manage for all services.
- Policy as Code: A better way is to use a policy-as-code tool like Sentinel (in Terraform Cloud) or Open Policy Agent (OPA). You can write a policy that inspects the Terraform plan. If the plan includes a "destroy" action, the policy will automatically fail the pipeline before the apply step, preventing the deletion.

---

### 56) What is configuration drift and how do you deal with it?
Configuration drift is when real infrastructure changes outside Terraform.
To fix, I run terraform plan and apply to sync code with reality

---

### 57) How can you avoid storing secrets in Terraform files?
I never hardcode secrets in code.The best practice is to store them in a dedicated secrets manager, like AWS Secrets Manager or HashiCorp Vault.Then, in your Terraform code, you use a data source to read the secret from the secrets manager at runtime (during the plan or apply)



