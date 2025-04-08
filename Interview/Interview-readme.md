# Common DevOps Interview Questions & Answers

Here are concise answers to common DevOps interview questions, suitable for verbal responses:

**1. What is a memory leak?**
   It's when an application fails to release memory it no longer needs. Over time, this consumes available memory, potentially slowing down or crashing the system.

**2. How do you transfer a file between two Linux machines?**
   Using `scp` (secure copy) or `rsync` (for synchronization). Example: `scp file.txt user@target_ip:/target/directory/`

**3. What happens when you plug a USB drive into Linux, and how do you access it?**
   Usually, the system auto-mounts it, often under `/media/username/usb_label/`. If not, use `lsblk` or `dmesg` to find the device name (e.g., `/dev/sdb1`) and manually mount it with `mount /dev/sdb1 /mnt/usb`.

**4. What does it mean for an `int` to default to 0 in many languages?**
   It means if you declare an integer variable without assigning an initial value, the language automatically gives it a value of 0. This provides a predictable starting point instead of random memory data.

**5. What is `curl`?**
   `curl` is a command-line tool for transferring data using URLs. It's very useful for testing APIs, downloading files, etc.

**6. How do you see the exit code of the last command in Linux?**
   With `echo $?`. 0 usually means success, non-zero indicates an error.

**7. How can you recover a deleted branch in Git?**
   Use `git reflog` to find the commit hash where the branch last pointed. Then, create a new branch from that commit: `git checkout -b <new_branch_name> <commit_hash>`.

**8. What is a Docker image?**
   It's an immutable template containing everything needed to run an application (code, libraries, dependencies, settings). Containers are created from images.

**9. After creating a Docker volume, how do you attach it to a container?**
   Using the `-v <volume_name>:/container/path` or `--mount source=<volume_name>,target=/container/path` flag with `docker run`, or by defining it in the `volumes` section of a `docker-compose.yml` file.

**10. How do you access the terminal of a running Docker container?**
    With `docker exec -it <container_id_or_name> /bin/bash` (or `/bin/sh`).

**11. What is Docker Swarm?**
    It's Docker's native container orchestration tool. It allows you to manage a cluster of Docker hosts as a single virtual host, simplifying container management and scaling.

**12. What is Continuous Delivery, and what's the difference with Continuous Deployment?**
    *   **Continuous Delivery:** Code changes are automatically built, tested, and prepared for release to production, but the final deployment requires manual approval.
    *   **Continuous Deployment:** The entire process is automated; every change that passes tests is automatically deployed to production. The key difference is the manual approval step for production deployment in Delivery.

**13. How does SSH work?**
    SSH (Secure Shell) creates an encrypted connection between two machines (client and server). Authentication happens via password or, more securely, public/private key pairs. All communication is encrypted.

**14. What are HTTP requests?**
    Messages sent by a client (like a browser) to a server (like a web server) to request resources (e.g., web pages, images). Common methods include `GET` (request data) and `POST` (send data).

**15. How do you install a program on Linux? What's the package manager in CentOS?**
    Typically using the system's package manager. In CentOS, the package manager is `yum` or `dnf` (newer versions). Example: `sudo yum install <package_name>`.

**16. What is Docker Compose, and what's the difference with Swarm?**
    *   **Docker Compose:** Used to define and run multi-container applications on a *single* host using a `docker-compose.yml` file. Ideal for development environments.
    *   **Docker Swarm:** Orchestrates containers across *multiple* hosts (cluster management, scaling, load balancing). More suitable for production environments.

**17. What is CI/CD? Explain the process.**
    CI/CD (Continuous Integration/Continuous Delivery or Deployment) automates the software build, test, and release process.
    *   **Process:** Developer commits code -> CI server detects change -> Builds code -> Runs automated tests -> (Delivery) Prepares for manual deployment / (Deployment) Automatically deploys to production. The goal is faster, more reliable software delivery.

**18. Describe a recent DevOps problem you solved.**
    *(Provide a personal example. Generic structure:)* "Our CI pipeline builds were failing intermittently. By analyzing logs [or monitoring tools], I identified that [specific cause, e.g., a flaky test depending on an external service, resource contention on the build agent]. My solution was to [action taken, e.g., mock the external service in tests, increase resources for agents, optimize the build script], which stabilized the pipeline."

**19. Why did you choose DevOps? What do you like most about it?**
    *(Personal answer. Potential points:)* "I enjoy bridging the gap between development and operations, automating processes to improve speed and reliability, solving complex system problems, and the culture of collaboration and continuous learning."

**20. Explain Kubernetes.**
    Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It runs applications in `Pods`, provides service discovery, load balancing, auto-scaling, and self-healing capabilities.

**21. List some DevOps tools you know.**
    *   **Version Control:** Git, GitHub, GitLab, Bitbucket
    *   **CI/CD:** Jenkins, GitLab CI, GitHub Actions, Tekton, Argo CD, Flux
    *   **Containerization & Orchestration:** Docker, Kubernetes, Docker Swarm
    *   **IaC:** Terraform, Ansible, Pulumi, CloudFormation
    *   **Config Management:** Ansible, Chef, Puppet
    *   **Monitoring & Logging:** Prometheus, Grafana, ELK Stack, Datadog, Dynatrace
    *   **Cloud:** AWS, Azure, Google Cloud (GCP)

**22. How do you rename a file in Linux?**
    Using the `mv` command: `mv old_filename new_filename`.

**23. What is `git fetch`?**
    It downloads changes (commits, branches) from a remote repository to your local repository but *does not* merge them into your current working branch. It's used to see what's new remotely.

**24. What is a Pull Request (or Merge Request)?**
    A request to merge code changes from one branch (usually a feature branch) into another (often `main` or `master`). It facilitates code review and discussion before merging.

**25. How do you prevent a file from being pushed every time?**
    Add the file's name or a matching pattern to the `.gitignore` file in the project's root directory. Git will then ignore changes to that file.

**26. What's the difference between TCP and UDP?**
    *   **TCP:** Connection-oriented, reliable (guarantees packet order and delivery), slower. Used for web (HTTP/S), email (SMTP).
    *   **UDP:** Connectionless, unreliable (no delivery/order guarantee), faster. Used for streaming (video/audio), DNS.

**27. Quick Definitions:**
    *   **Istio:** A popular service mesh for Kubernetes, managing communication between microservices.
    *   **Service Mesh:** An infrastructure layer handling service-to-service communication, providing features like traffic management, security, and observability.
    *   **containerd:** A core container runtime (manages the container lifecycle). Used by Docker.
    *   **Hypervisor:** Software or hardware that creates and runs virtual machines (VMs).
    *   **mTLS (Mutual TLS):** Both client and server authenticate each other using TLS certificates for secure communication.
    *   **VPA (Vertical Pod Autoscaler):** Automatically adjusts CPU/memory requests/limits for Kubernetes Pods.
    *   **HPA (Horizontal Pod Autoscaler):** Automatically scales the number of Pod replicas based on metrics like CPU/memory usage.
    *   **KEDA (Kubernetes Event-driven Autoscaling):** Scales Kubernetes workloads based on external event sources (like message queue length).
    *   **REST vs SOAP:** REST is an architectural style (often using JSON over HTTP), simpler and more flexible. SOAP is a protocol (usually XML-based), more rigid.
    *   **Cardinality:** The number of unique values in a dataset. High cardinality can impact performance in monitoring systems.
    *   **Uniqueness:** A database constraint ensuring that values in a column or set of columns are not repeated.
    *   **RAID:** A storage technology combining multiple disks for performance, redundancy, or both.
    *   **Split Brain:** A state in a cluster where network partitions cause subsets of nodes to operate independently, potentially leading to data inconsistency.
    *   **TCP:** (See above) Transmission Control Protocol.
    *   **UDP:** (See above) User Datagram Protocol.
    *   **ICMP:** Used for network diagnostics and error messages (e.g., `ping`).
    *   **CIDR:** Classless Inter-Domain Routing. A method for allocating IP addresses and routing (e.g., `192.168.1.0/24`).
    *   **Prefix:** The network portion of an IP address in CIDR notation (e.g., `/24`).
    *   **Calico:** A popular networking and network policy provider (CNI plugin) for Kubernetes.
