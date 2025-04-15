# Common DevOps Interview Questions & Answers

Here are concise answers to common DevOps interview questions, suitable for verbal responses:

**1. What is a memory leak?**

   It's when an application fails to release memory it no longer needs. Over time, this consumes available memory, potentially slowing down or crashing the system. *Example: A web server might load user session data into memory but fail to clear it when the user logs out. If many users log in and out, the server's memory usage grows continuously.*

**2. How do you transfer a file between two Linux machines?**

   Using `scp` (secure copy) or `rsync` (for synchronization). Example: `scp file.txt user@target_ip:/target/directory/`

**3. What happens when you plug a USB drive into Linux, and how do you access it?**

   Usually, the kernel detects the device (`dmesg` shows messages) and creates a device file (e.g., `/dev/sdb1`). A desktop environment often auto-mounts it under `/media/username/usb_label/`. **Mounting** means making the filesystem on the device accessible at a specific directory (the mount point) in the main filesystem tree. If not auto-mounted, use `lsblk` to find the device name and manually mount it: `sudo mount /dev/sdb1 /mnt/usb` (assuming `/mnt/usb` exists).


**5. What is `curl`?**

   `curl` is a command-line tool for transferring data using various network protocols, most commonly HTTP/HTTPS. It's useful for downloading files, testing API endpoints, sending data, and viewing response headers. *Example: `curl -X GET https://api.example.com/users` retrieves user data from an API.*

**6. What is exit code 0 in Linux?**

   In Linux/Unix, commands return an exit code upon completion. An exit code of **0** conventionally means the command executed **successfully**. Any non-zero exit code (1-255) typically indicates an **error** or failure. You can check the last command's exit code with `echo $?`.

**7. How can you recover a deleted branch in Git?**

   Use `git reflog` to find the **commit hash** (a unique SHA-1 identifier for a specific set of changes) where the branch last pointed before deletion. Then, create a new branch pointing to that commit: `git checkout -b <new_branch_name> <commit_hash>`.

**8. What is a Docker image?**

   A **Docker image** is a **read-only template** containing instructions for creating a Docker container.

**9. After creating a Docker volume, how do you attach it to a container?**

   Using the `-v <volume_name>:/container/path` or `--mount source=<volume_name>,target=/container/path` flag with `docker run`, or by defining it in the `volumes` section of a `docker-compose.yml` file.

**10. How do you access the terminal of a running Docker container?**

    With `docker exec -it <container_id_or_name> /bin/bash` (or `/bin/sh`).

**11. What is Docker Swarm?**

    It's Docker's native container orchestration tool. It allows you to manage a cluster of Docker hosts as a single virtual host, simplifying container management and scaling.

**11a. How do you stop all running Docker containers at once?**

    You can use the command `docker stop $(docker ps -q)`. This command first lists the IDs (`-q` for quiet, IDs only) of all running containers (`docker ps`) and then passes those IDs to the `docker stop` command.

**12. What is Continuous Delivery, and what's the difference with Continuous Deployment?**

    - Continuous Deployment is one step beyond Continuous Delivery and means that deployment to the production environment is fully automated.
    - In Continuous Delivery, the code is production-ready, but deployment can be done with a manual approval step. In Continuous Deployment, the code is always automatically deployed to production.

**13. How does SSH work?**

    SSH (Secure Shell) creates an encrypted connection between two machines (client and server). Authentication happens via password or, more securely, public/private key pairs. All communication is encrypted.

**14. What are HTTP requests?**

    Messages sent by a client (like a browser) to a server (like a web server) to request resources (e.g., web pages, images). Common methods include `GET` (request data) and `POST` (send data).

**15. How do you install a program on Linux? What's the package manager in CentOS?**

    Typically using the system's package manager. In CentOS, the package manager is `yum` or `dnf` (newer versions). Example: `sudo yum install <package_name>`.

**15a. How do you create a scheduled task in Linux?**

    Using `cron`. Edit the crontab file with `crontab -e` and add entries specifying the schedule (minute, hour, day of month, month, day of week) and the command. Example: `0 5 * * * /path/to/script.sh` runs a script daily at 5 AM.

**15b. How is service management handled in Linux (e.g., systemd)?**

    Modern Linux systems primarily use `systemd`. You manage services with the `systemctl` command (e.g., `systemctl start|stop|status|enable|disable <service_name>`). It handles starting services at boot and managing them while the system runs. Older systems might use `init.d` scripts.

**16. What is Docker Compose, and what's the difference with Swarm?**

    *   **Docker Compose:** Used to define and run multi-container applications on a *single* host using a `docker-compose.yml` file. Ideal for development environments.
    *   **Docker Swarm:** Orchestrates containers across *multiple* hosts (cluster management, scaling, load balancing). More suitable for production environments.

**17. What is CI/CD? Explain the process.**

    CI/CD (Continuous Integration/Continuous Delivery or Deployment) automates the software build, test, and release process.
    *   **Process:** Developer commits code -> CI server detects change -> Builds code -> Runs automated tests -> (Delivery) Prepares for manual deployment / (Deployment) Automatically deploys to production. The goal is faster, more reliable software delivery.

**18. Describe a recent DevOps problem you solved.**

    *(Example based on your story:)* "While working on a Python trading bot project, I faced significant issues due to version conflicts between the many libraries used (like numpy, pandas, binance-connector). The project wouldn't run reliably on different machines. To solve this, I containerized the application using Docker, creating a Dockerfile that specified the exact Python version and library versions needed. This ensured a consistent environment. I then deployed this containerized application to Azure Container Instances, which allowed the bot to run reliably regardless of the underlying infrastructure."


**20. Explain Kubernetes.**

    Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It runs applications in `Pods`, provides service discovery, load balancing, auto-scaling, and self-healing capabilities.


**20b. How do Pods work behind the scenes?**

    A Pod is the smallest deployable unit, representing one or more containers sharing network namespace and storage volumes. The Kubernetes scheduler assigns a Pod to a Node. The `kubelet` on that Node instructs the container runtime (like `containerd`) to pull the necessary images and start the containers defined in the Pod specification, configuring their shared network and storage.

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

    It downloads changes (commits, files, branches) from a remote repository to your local repository but *does not* merge them into your current working branch. It's used to see what's new remotely. You can then use commands like `git diff main origin/main` to compare your local branch with the fetched remote branch.

**24. What is a Pull Request (or Merge Request)?**

    A request to merge code changes from one branch (usually a feature branch) into another (often `main` or `master`). It facilitates code review and discussion before merging.

**25. How do you prevent a file from being pushed every time?**

    Add the file's name or a matching pattern to the `.gitignore` file in the project's root directory. Git will then ignore changes to that file.

**25a. How do you remove just one specific commit from your branch (without altering later commits)?**

    Use `git revert <commit_hash>`. This creates a *new* commit that exactly reverses the changes made in the specified commit, preserving the project history.

**25b. You accidentally pushed unnecessary files in the last commit. How can you remove them from the remote without messing up history for others?**

    1. Remove the files locally: `git rm --cached <file_to_remove>` (keeps local copy, removes from Git tracking) or `git rm <file_to_remove>` (removes completely).
    2. Amend the previous commit: `git commit --amend --no-edit` (adds the removal to the last commit without changing its message).
    3. Push carefully: `git push --force-with-lease origin <branch_name>`. **Warning:** This rewrites remote history. Use `--force-with-lease` for safety, and ensure no one else has based work on the bad commit.

**25c. How to fix Linux/Windows case sensitivity conflicts in Git (e.g., "file" and "File" committed on Linux)?**

    Windows filesystems are typically case-insensitive. If both "file" and "File" exist in Git history, checking out on Windows will cause problems. To fix, use Git's rename command *on a case-sensitive system* (like Linux): `git mv File temp_name && git mv temp_name file` (or the other way around). Commit this rename. This explicitly tells Git about the case change.

**25d. How do you completely remove a commit from Git history?**

    Use interactive rebase: `git rebase -i <commit_hash_BEFORE_the_one_to_remove>`. In the editor that opens, find the line with the commit you want to delete, and change `pick` to `drop` (or delete the line). Save and exit. **Warning:** This rewrites history and requires a force push (`git push --force-with-lease`). Use with extreme caution, especially on shared branches.

**26. What's the difference between TCP and UDP?**

    *   **TCP:** Connection-oriented, reliable (guarantees packet order and delivery), slower. Used for web (HTTP/S), email (SMTP).
    *   **UDP:** Connectionless, unreliable (no delivery/order guarantee), faster. Used for streaming (video/audio), DNS.

**26a. What's the difference between binding to localhost (127.0.0.1) and 0.0.0.0?**

    *   **`localhost` (or `127.0.0.1`):** Binds only to the loopback interface. The service is accessible *only* from the same machine where it's running.
    *   **`0.0.0.0`:** Binds to *all* available network interfaces on the host (Ethernet, Wi-Fi, loopback, etc.). The service is accessible from other machines on the network (using the host's actual IP address) as well as locally.

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
    *   **ICMP:** Used for network diagnostics and error messages (e.g., `ping`).
    *   **CIDR:** Classless Inter-Domain Routing. A method for allocating IP addresses and routing (e.g., `192.168.1.0/24`).
    *   **Prefix:** The network portion of an IP address in CIDR notation (e.g., `/24`).
    *   **Calico:** A popular networking and network policy provider (CNI plugin) for Kubernetes.
    *   **VPN (Virtual Private Network):** Creates a secure, encrypted tunnel over a public network (like the internet) to access a private network's resources.
    *   **Active Directory (AD):** Microsoft's directory service for managing users, computers, and policies in a Windows domain network.
    *   **Dockerfile COPY vs ADD:** `COPY` simply copies local files/dirs into the image. `ADD` does the same but can also handle URLs and auto-extract compressed archives. Prefer `COPY` unless `ADD`'s extra features are needed.
    *   **Dockerfile ENTRYPOINT vs CMD:** `ENTRYPOINT` defines the main command/executable. `CMD` defines default arguments for `ENTRYPOINT` or the default command if no `ENTRYPOINT` exists. `CMD` is easily overridden at runtime.
    *   **Embedded Database:** A database engine that runs within the application process, without needing a separate server (e.g., SQLite).
    *   **GitLab Runner:** An agent that executes CI/CD jobs defined in `.gitlab-ci.yml` for GitLab CI/CD.
