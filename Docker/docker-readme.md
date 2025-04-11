# Docker Study Notes

## Table of Contents
- [Docker Basics](#docker-basics)
- [Docker Benefits](#docker-benefits)
- [Docker Images and Containers](#docker-images-and-containers)
- [Dockerfile](#dockerfile)
- [Docker Storage](#docker-storage)
- [Docker Compose](#docker-compose)
- [Docker Engine and System](#docker-engine-and-system)
- [Docker Commands](#docker-commands)
- [Artifact Registry](#artifact-registry)

## Docker Basics
![ROADMAP](/Media/container_proccess.png)
Docker uses a **client-server architecture** consisting of three main components:
1.  **Docker Client:** The primary interface for users to interact with Docker.
2.  **Docker Host:** Runs the Docker Daemon and manages Docker objects.
3.  **Docker Registry:** Stores Docker images.

Key Docker objects include images, containers, Dockerfiles, networks, and storage volumes.

### What is Docker Client?
A component of the Docker architecture that provides Command Line Interface (CLI) tools or uses REST APIs to send instructions to the Docker daemon. The client can communicate with a local or a remote Docker daemon.

### Basic Containerization Process
1.  **Build:** Use a `Dockerfile` (or an existing base image) and the `docker build` command to create a container image.
2.  **Push:** Use the `docker push` command to store the built image in a Docker Registry.
3.  **Run/Pull:** Use the `docker run` command to create and start a container from an image.
    -   The Docker Host first checks if the image exists locally.
    -   If not found locally, the Docker Daemon pulls the image from the configured Docker Registry.
    -   The Daemon then creates and runs the container using the image.

## Docker Benefits
- **Isolation**: Processes in one container don't affect those in another.
- **Consistency**: Ensures applications run consistently across different environments.
- **Scalability**: Easy to horizontally scale applications.

## Docker Images and Containers

A **Docker image** is a **read-only template** containing instructions for creating a Docker container. Images are built in layers based on the Dockerfile instructions. When an image is rebuilt, only the changed layers are updated. These layers can be shared across multiple images, saving disk space and network bandwidth.

### Image Naming
An image name typically follows the format: `[hostname]/[repository]:[tag]`
-   **hostname:** Identifies the image registry (e.g., `docker.io` for Docker Hub). This is often omitted when using the default Docker Hub via the CLI.
-   **repository:** A group of related container images (e.g., `ubuntu`, `nginx`).
-   **tag:** Specifies a particular version or variant of the image (e.g., `latest`, `18.04`, `stable`).

### What is a Docker Container?
A **Docker container** is a **runnable instance** of a Docker image.

- You **can** create multiple containers from the **same** Docker image.
- Each container runs **independently**, is well **isolated** from other containers and the host machine, and can have its own configuration, environment variables, and mounted volumes.


## Dockerfile

### What is the Dockerfile?
It is a special script (text file) for Docker that provides commands (instructions) for building docker images. You can create a Docker file using any editor from the console or terminal.

A Dockerfile must always begin with a `FROM` instruction that defines a base image, often sourced from a public repository (e.g., an OS like Ubuntu, or a language runtime like Node.js).

### Key Dockerfile Instructions

- **RUN** executes a command **during the image build process**.
    - Each RUN instruction **creates a new layer** in the Docker image.
    - This is typically used to install dependencies, update packages, or configure the system.
- **CMD** defines the **default command** to be executed when a container starts from the image.
    - A Dockerfile should only have **one CMD instruction**. If multiple are present, only the **last one takes effect**.
    - See the `Docker Commands` section for comparison with `ENTRYPOINT`.

### Sample Dockerfile and Instructions

Below is a sample Dockerfile followed by explanations of the commonly used instructions.

```dockerfile
# Use the official Node.js image as the base image
FROM node:14

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json files first for layer caching
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Add additional file (can also handle URLs and auto-extract archives)
# ADD public/index.html /app/public/index.html

# Expose the port on which the application will run
EXPOSE $PORT

# Specify the default command to run when the container starts
CMD ["node", "app.js"]

# Labeling the image with metadata
LABEL version="1.0"
LABEL description="Node.js application Docker image"
LABEL maintainer="Your Name <your.email@example.com>"

# Healthcheck to ensure the container is running correctly
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -fs http://localhost:$PORT || exit 1

# Set a non-root user for security purposes
USER node
```

**Instruction Explanations:**

-   **`FROM`**: Specifies the base image to build upon (e.g., `node:14`). Must be the first instruction.
-   **`ENV`**: Sets persistent environment variables within the image (e.g., `NODE_ENV=production`).
-   **`WORKDIR`**: Sets the working directory for subsequent instructions (`RUN`, `CMD`, `ENTRYPOINT`, `COPY`, `ADD`) within the Dockerfile and when running the container.
-   **`COPY`**: Copies files or directories from the build context (your local machine) into the container's filesystem. It's generally preferred for simple file copying.
-   **`RUN`**: Executes commands in a new layer on top of the current image. Used for installing packages, compiling code, etc. Each `RUN` creates a layer.
-   **`ADD`**: Similar to `COPY`, but with additional features like handling remote URLs and automatically extracting compressed files (tar, gzip, bzip2) into the destination directory.
-   **`EXPOSE`**: Informs Docker that the container listens on the specified network ports at runtime. It doesn't actually publish the port; it functions as documentation between the image builder and the person running the container.
-   **`CMD`**: Provides defaults for an executing container. These defaults can include an executable, or they can omit the executable, in which case you must specify an `ENTRYPOINT` instruction as well. There can only be one `CMD` instruction. If you list more than one `CMD`, only the last `CMD` will take effect. The primary purpose of a `CMD` is to provide default execution parameters that can be easily overridden when running the container (`docker run image_name optional_command`).
-   **`LABEL`**: Adds metadata to an image, such as version, description, or maintainer information.
-   **`HEALTHCHECK`**: Defines a command to run inside the container to check if it's still working correctly. Docker can use this to determine the container's health status.
-   **`USER`**: Sets the user name (or UID) and optionally the user group (or GID) to use when running the image and for any `RUN`, `CMD`, and `ENTRYPOINT` instructions that follow it in the Dockerfile. Running containers as a non-root user is a security best practice.

## Docker Storage

By default, data generated within a container **does not persist** when the container is removed. Docker provides several ways to persist data:

### Storage Options

#### Volumes
**Volumes** are managed by Docker and are the recommended way to persist data. Volumes can be safely shared between multiple docker containers.

#### Bind Mounts
Where are bind mounts stored on the host system?
Anywhere on the host system.

#### Storage Plugins
Docker also supports **storage plugins** that allow containers to connect to external storage platforms.

### Storage Drivers

#### Overlay2
- **Overlay2** is the **default and preferred storage driver** for modern **Linux distributions**.
- It requires **no additional configuration** and is **more efficient** than older storage drivers.

## Docker Compose

**Docker compose** is tool for defining and running multi container docker applications.

### Docker Compose Commands
- `docker-compose up -d` → Runs multiple containers defined in a Compose file.

## Docker Networking

Docker uses networks to manage and isolate communication between containers, and between containers and the outside world.

### Port Mapping (`-p` / `--publish`)

When you run a service inside a container (e.g., a web server listening on port 80), that port is only accessible from within the Docker network by default.

*   **Container Port:** The port the application *inside* the container listens on (e.g., 80 for Nginx).
*   **Host Port:** A port on the Docker *host* machine (your computer).
*   **Mapping:** The `-p` (or `--publish`) flag connects a host port to a container port, making the container's service accessible from outside.
    *   Syntax: `docker run -p <host_port>:<container_port> [image_name]`
    *   Example: `docker run -d -p 8080:80 nginx`
        *   This command runs an Nginx container in the background (`-d`).
        *   Nginx inside the container listens on its default **Container Port** `80`.
        *   Docker maps the **Host Port** `8080` on your host machine to the container's port `80`.
        *   You can now access the Nginx server from your browser using `http://<your-host-ip>:8080` or `http://localhost:8080`.
    *   If you only specify the container port (`-p 80`), Docker will automatically map it to a random available high port number on the host. You can see the assigned port using `docker ps`.

## Docker Engine and System

The Docker Host runs the Docker Engine, which includes the Docker Daemon.

### Default Docker Data Directory (Linux)
By default on Linux systems, Docker stores all its data, including images, container filesystems, volumes, and network configurations, within the `/var/lib/docker` directory. It's generally recommended to manage these objects using Docker commands rather than modifying this directory directly.

### Docker Daemon (`dockerd`)
-   The core background service that runs on the Docker Host.
-   Listens for Docker API requests (from the client via CLI or REST API) and manages Docker objects.
-   Handles the building, running, and distribution of Docker containers.
-   Manages images, containers, namespaces, networks, storage volumes, plugins, and add-ons.
-   Docker daemons can also communicate with other daemons to manage Docker services.

### Docker Engine cgroups
Docker Engine uses the following cgroups:

- **Memory cgroup** is used to manage accounting, limits, and notifications.
- **HugeTBL cgroup** is utilized to account for the usage of huge pages by process group.
- **CPU group** is used to manage user/system CPU time and usage.
- **CPUSet cgroup** is used to bind a group to a specific CPU; recommended for real-time applications and NUMA systems with localized memory per CPU.
- **BlkIO cgroup** is used to measure & limit the amount of blckIO by a group.
- **net_cls and net_prio cgroup** is used to tag the traffic control.
- **Devices cgroup** is used to read/write access devices.
- **Freezer cgroup** is used to freeze a group; recommended for cluster batch scheduling, process migration, and debugging without affecting prtrace.

### Namespaces
PID namespace used in Docker Engine for process isolation.

**net_cls** and **net_prio** cgroup used in Docker Engine for tagging the traffic control.

## Docker Commands

## Key Differences between ENTRYPOINT and CMD  

| Feature       | ENTRYPOINT                                      | CMD                                      |
|--------------|------------------------------------------------|------------------------------------------|
| **Purpose**   | Defines the main application that always runs  | Provides default arguments for execution |
| **Overridable?** | ❌ No, unless `--entrypoint` is used        | ✅ Yes, by passing a command at runtime  |
| **Flexibility** | Less flexible, ensures a specific executable always runs | More flexible, allows runtime overrides |
| **Best Used For** | Scripts, services, daemons (e.g., Nginx, MySQL) | Default parameters, test commands |



### Container Management
- `docker ps` → Lists currently running containers.
- `docker ps -a` → Shows all containers that have been run previously.
- `docker container stop [container_id]` → Stops a running container.
- `docker stop $(docker ps -q)` → Stops all running containers at once by passing the IDs of running containers (`docker ps -q`) to the stop command.
- `docker container start [container_id]` → Restarts a stopped container.
- `docker rm [container_id_or_name]` → Removes a *specific* stopped container.
- `docker rm -f [container_id_or_name]` → Forcefully removes a *specific* running container. Use with caution.
- `docker container prune` → Cleans up *all* stopped containers (bulk removal).

### Running Ubuntu Inside Docker
- `docker run -dit ubuntu` → Runs an Ubuntu container in the background.
- `docker container exec -it [container_id] bash` → Opens a bash shell inside the container.

### Volume Management
- `docker volume create [volume_name]` → Creates a new Docker volume.
- `docker inspect [volume_name]` → Displays details about a Docker volume.

### Image and Build Process
- `docker build -t [image_name]:v1 .` → Builds an image from the Dockerfile in the current directory.
- `docker run [image_name]:v1` → Runs the created image.
- `docker run -dp 8080:8080 myimage:v1` → Runs a container in detached mode (`-d`) and maps host port 8080 to container port 8080 (`-p`).
- `docker run -d -e MYSQL_ROOT_PASSWORD=db_pass123 --name mysql-db mysql` → Runs a MySQL container named `mysql-db` in the background, setting the root password via an environment variable (`-e`).
- `docker images` → Lists all available Docker images.
- `docker rmi [image_id_or_name]` → Removes a specific Docker image. You might need to use `-f` (force) if the image is used by stopped containers.
- `docker rmi -f $(docker images -q)` → Removes *all* Docker images forcefully. Use with caution!
- `docker run --rm <image_name> cat /etc/os-release` → Checks the OS version inside an image by running a command in a temporary container (`--rm` cleans up afterwards).

### System Information
- `docker system df --v` → Shows detailed information on Docker disk usage.



## Docker Registry / Artifact Registry

A Docker Registry is a stateless, scalable storage system for Docker images. Registries facilitate the distribution of images.

-   **Access:**
    -   **Public:** Accessible by everyone (e.g., Docker Hub).
    -   **Private:** Restricted access, often used by enterprises for security. Private registries can be hosted by third-party providers (e.g., IBM Cloud Container Registry, Google Artifact Registry, AWS ECR) or self-hosted on-premises or in the cloud.
-   **Mechanism:**
    -   `docker push`: Uploads an image to a registry.
    -   `docker pull`: Downloads an image from a registry to the local Docker host.

### What is Artifact Registry (General Concept)?
- Artifact Registry is a **centralized storage system** used for managing and versioning various build artifacts generated during the software development lifecycle.
- It helps store, version, and manage artifacts like Docker images, dependencies, or compiled code, ensuring efficient and secure software deployment.
