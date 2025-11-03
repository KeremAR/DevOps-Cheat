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

### How Containerization Works on Linux

In Linux, a "container" is an illusion created by isolating a process from the rest of the system. This is achieved with a few key Linux kernel features:
 
1.  **Namespaces (Isolation):** Namespaces are the primary feature for isolation, controlling what a process can see. A new set of namespaces is created for a container (using system calls like `unshare`) to provide a private view of system resources like processes (PID), network interfaces (Net), and the filesystem (Mnt). A foundational concept for filesystem isolation is `chroot`, which changes a process's root directory, making it seem like it has its own dedicated filesystem.

2.  **Control Groups (cgroups) (Resource Limiting):** Cgroups control how many system resources a process can use. This ensures a container cannot monopolize the host's CPU, memory, or I/O, allowing many containers to run on a single host without interfering with each other.

In short, namespaces make a process *think* it's running alone on an operating system, while cgroups ensure it doesn't consume more than its fair share of resources.

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

### Understanding Image Layers and Disk Usage
While `docker images` shows the size of an image, it's important to understand how Docker's layer system saves disk space. The size shown is the cumulative total of all its layers, but these layers are shared between images.

**Example:**
Imagine you start with a base image and build on it:
1.  Base image `ubuntu:20.04` → **700MB**
2.  You add a new layer by installing packages (`RUN apt-get install curl`) → **50MB** new layer
3.  You add another layer by copying your app (`COPY app.py .`) → **200KB** new layer

When you run `docker images`, you might see:
- `myapp:v1` → **750MB**
- `myapp:v2` → **750.2MB**

However, this does not mean they consume 1.5GB on disk. The actual disk usage is the sum of the individual, shared layers: `700MB + 50MB + 200KB`.

The size you see in `docker images` is the sum of the layers for that specific image, but Docker efficiently stores only one copy of each shared layer. The `docker system df` command provides a more accurate view of the actual disk space being used.

### Managing Images
- `docker images` → Lists all available Docker images.
- `docker rmi [image_id_or_name]` → Removes a specific Docker image. You might need to use `-f` (force) if the image is used by stopped containers.
- `docker rmi -f $(docker images -q)` → Removes *all* Docker images forcefully. Use with caution!
- `docker run --rm <image_name> cat /etc/os-release` → Checks the OS version inside an image by running a command in a temporary container (`--rm` cleans up afterwards).
- `docker build -t my-app:v1 .` → Builds a Docker image from a Dockerfile in the current directory.

### Managing Containers
- `docker run [image_name]:[tag]` → Creates and starts a new container from an image.
- `docker run -d -e MYSQL_ROOT_PASSWORD=db_pass123 --name mysql-db mysql` → Runs a MySQL container in the background, setting the root password via an environment variable (`-e`) and giving it a specific name (`--name`).
- `docker run -d ... [image_name]`: Runs the container in **detached mode** (in the background).
    - **Note:** For a detached container to stay running, the command specified in the image (`CMD`/`ENTRYPOINT`) must be a long-running process. If it's not (e.g., a basic `alpine` image), you often need to provide a command that doesn't exit, like `sleep infinity` or `tail -f /dev/null`.
    ```bash
    docker run -d --name my-alpine alpine:latest sleep infinity
    ```
- `docker run -it -w /myfiles [image_name] [command]` → Creates a new container from `[image_name]`, starts an interactive TTY session (`-it`), sets the working directory inside the container to `/myfiles` (`-w`), and then runs `[command]` (or the image's default command if none is provided) from within that directory.
- `docker ps` → Lists currently running containers.
- `docker ps -a` → Shows all containers that have been run previously.
- `docker container stop [container_id]` → Stops a running container.
- `docker stop $(docker ps -q)` → Stops all running containers at once by passing the IDs of running containers (`docker ps -q`) to the stop command.
- `docker container start [container_id]` → Restarts a stopped container.
- `docker rm [container_id_or_name]` → Removes a *specific* stopped container.
- `docker rm -f [container_id_or_name]` → Forcefully removes a *specific* running container. Use with caution.
- `docker container prune` → Cleans up *all* stopped containers (bulk removal).
- `docker exec -it [container_id_or_name] [command]` → Executes a command inside a *running* container. `-it` provides an interactive TTY (shell access).
    ```bash
    # Get an interactive shell inside a container
    docker exec -it my-container /bin/sh
    # Run a non-interactive command
    docker exec my-container ls /app
    ```
- `docker logs [container_name_or_id]` → Fetches the logs (stdout/stderr) of a container.
- `docker logs -f [container_name_or_id]` or `docker logs --follow [container_name_or_id]` → Follows the log output in real-time, similar to `tail -f`.
- `docker inspect [container_name_or_id]` → Displays detailed low-level information about a container in JSON format. Useful for finding IP addresses, checking environment variables, and **inspecting mounts**. Look for the `"Mounts"` array to see volumes and bind mounts.

## Dockerfile

### What is the Dockerfile?
It is a special script (text file) for Docker that provides commands (instructions) for building docker images. You can create a Docker file using any editor from the console or terminal.

A Dockerfile must always begin with a `FROM` instruction that defines a base image, often sourced from a public repository (e.g., an OS like Ubuntu, or a language runtime like Node.js).

### Sample Dockerfile and Instructions
```dockerfile
# FROM → Used to select a base image.
FROM ubuntu:22.04

# RUN → Runs a command during the container build and creates a new layer.
RUN apt-get update && apt-get install -y curl

# COPY → Copies files from the host into the image.
COPY . /app

# ADD → Works like COPY, but can also handle URLs or extract archive files.
# For example, it can download and extract a tarball in one step.
ADD https://example.com/archive.tar.gz /

# WORKDIR → Sets the working directory inside the container for subsequent commands.
WORKDIR /app

# ENV → Sets a persistent environment variable in the image.
ENV PORT=8080

# EXPOSE → Documents which port the container will listen on at runtime.
EXPOSE 80

# CMD → Provides the default command or arguments for a running container.
# This entire command can be overridden when the container is run.
CMD ["python", "app.py"]

# ENTRYPOINT → The main command for the container. CMD can be used to provide default arguments.
ENTRYPOINT ["python"]
CMD ["app.py"]

# VOLUME → Creates a mount point for persisting data, often used with Docker volumes.
VOLUME /data

# ARG → A build-time variable that can be passed during the build process.
# It is not available in the final image, unlike ENV.
ARG VERSION=1.0

# LABEL → Adds metadata to the image, such as maintainer information.
LABEL maintainer="me@example.com"
```

## Key Differences between ENTRYPOINT and CMD  

**ENTRYPOINT**

Defines the main command that will always run when the container starts. When used with `CMD`, the `CMD` value provides default arguments to the `ENTRYPOINT`.

*Example:*
```dockerfile
ENTRYPOINT ["echo"]
CMD ["Hello World"]
```
- `docker run myimage` → Runs `echo "Hello World"` and prints "Hello World".
- `docker run myimage "Hi"` → Runs `echo "Hi"` and prints "Hi" (the `CMD` value is overridden).

**CMD**

Provides the default command and/or parameters for a container. If no `ENTRYPOINT` is defined, the entire `CMD` instruction is the command that gets executed.

*Example:*
```dockerfile
CMD ["echo", "Hello World"]
```
- `docker run myimage` → Runs `echo "Hello World"` and prints "Hello World". ✅
- `docker run myimage "Hi"` → This attempts to run `"Hi"` as a command, which fails because `"Hi"` is not an executable. The arguments provided to `docker run` replace the entire `CMD` instruction. ❌



### Optimizing the Build Cache

Docker reuses layers from previous builds to speed up the `docker build` process. This is the **build cache**. For an instruction's layer to be reused, the instruction itself must be unchanged, and all previous layers must also be cached.

**Cache Invalidation:**
- A cache miss (invalidation) occurs when an instruction is changed.
- Crucially, when a layer is invalidated, **all subsequent layers are also rebuilt**, regardless of whether they changed.

**Best Practices for Caching:**
1.  **Order matters:** Place instructions that change less frequently (like installing dependencies) *before* instructions that change often (like copying source code).
2.  **Be specific with `COPY`:** Only copy the files you need. For example, in a Node.js app, copy `package.json` and run `npm install` *before* copying the rest of your source code. This way, the dependency layer is only rebuilt when `package.json` changes, not every time you change a source file.

**Example of Optimized Order:**
```dockerfile
FROM node:16-alpine

WORKDIR /app

# Copy dependency manifest first (less frequent changes)
COPY package*.json ./

# Install dependencies (this layer is cached if package*.json hasn't changed)
RUN npm install

# Copy source code last (most frequent changes)
COPY . .

EXPOSE 3000
CMD [ "node", "app.js" ]
```

### Multi-Stage Builds

Multi-stage builds are a powerful feature for creating smaller, more secure, and more efficient Docker images. They allow you to use multiple `FROM` instructions in a single Dockerfile. Each `FROM` instruction begins a new build "stage" that can have its own base image and dependencies.

**Why Use Multi-Stage Builds?**

The primary benefit is to separate the build-time environment from the runtime environment. For compiled languages (like Go, Java, or C++) or applications that require a build step (like transpiling JavaScript), you often need many tools and dependencies to build the final artifact. These tools are unnecessary in the final production image.

By using a multi-stage build, you can:
- **Build the application** in an early stage (the "builder" stage) with all the necessary SDKs and tools.
- **Copy only the final build artifact** (e.g., the compiled binary, the `dist` folder) into a later, clean stage that is based on a minimal runtime image.
- This results in a much smaller final image, as all the build-time dependencies are discarded.

> **A Note on `as` vs. `AS`**
> 
> In the `FROM <image> AS <name>` instruction, the `AS` keyword is **case-insensitive** for Docker's own builder. This means `as builder` and `AS builder` are functionally identical.
> 
> However, some third-party static analysis tools or linters, like SonarQube, may enforce a specific convention (e.g., uppercase `AS`) for code consistency or due to their own parsing rules. If your tooling reports an issue, it's best to follow its recommended convention.

**Example of a Multi-Stage Build (Node.js):**

```dockerfile
# --- Build Stage ---
# Use a full Node.js image to build the application
FROM node:16 as builder

WORKDIR /app

# Copy dependency manifests and install all dependencies (including devDependencies)
COPY package*.json ./
RUN npm install

# Copy the rest of the source code
COPY . .

# Run the build script to generate the production-ready 'dist' folder
RUN npm run build

# --- Production Stage ---
# Start a new, clean stage from a minimal base image
FROM node:16-alpine

WORKDIR /app

# Copy only the package.json and the production node_modules from the 'builder' stage
# (You could also run 'npm prune --production' in the builder stage)
COPY package*.json ./
RUN npm install --production

# Copy only the compiled application artifact from the 'builder' stage
COPY --from=builder /app/dist ./dist

EXPOSE 3000

# The final command to run the application
CMD [ "node", "dist/app.js" ]
```

In this example, the final image is based on the lightweight `node:16-alpine` and does not contain any of the `devDependencies` or source code needed for the build, only the final compiled assets.

## Docker Storage

By default, data generated within a container **does not persist** when the container is removed. Docker provides several ways to persist data or manage non-persistent data:

### Storage Options

#### Volumes
**Volumes** are managed by Docker (`/var/lib/docker/volumes/` on the host by default) and are the **recommended way to persist data** generated by and used by Docker containers. Volumes are easier to back up or migrate than bind mounts, and their lifecycle is managed by Docker commands. Volumes can be safely shared between multiple containers.

*   **Named Volumes:** You create and manage these explicitly.
    ```bash
    # Create a named volume
    docker volume create my-data-volume
    # Mount it into a container
    docker run -d -v my-data-volume:/app/data my_image
    ```
*   **Anonymous Volumes:** If you mount a volume using `-v /some/container/path` **without** specifying a host path or a named volume source first, Docker automatically creates an *anonymous volume*. These have a long, unique hash as their name on the host. They persist data but are harder to manage and reference later compared to named volumes. Anonymous volumes are often created implicitly by images that define a `VOLUME` instruction in their Dockerfile (like the official `postgres` or `nginx` images do for their data directories).
    ```bash
    # Creates an anonymous volume for /etc/nginx if one doesn't exist
    docker run -d -v /etc/nginx nginx
    ```

#### Bind Mounts (Live Code Sync for Development)

The primary use case for bind mounts during development is to **see code changes instantly inside a running container without rebuilding the image**. This is achieved by creating a live, two-way sync between a folder on your host machine and a folder inside the container.

*   **How they work:** Think of it as a "magic portal". A file or directory on the **host machine** is mounted directly into a container. When you change a file on your host, the change is immediately reflected inside the container, and vice-versa.
*   **Use Cases:** Essential for development workflows (live code reloading), sharing configuration files, or accessing host resources. Performance can be lower than volumes, especially on Docker Desktop (macOS/Windows).
*   **Example:** `docker run -v /path/on/host:/path/in/container -d my_image` → Runs a container, mounting the host directory `/path/on/host` to the container's `/path/in/container`.
*   **Warning:** Bind mounts rely on the host's directory structure and can have permission issues if the UID/GID inside the container doesn't match the host path's ownership.

#### Tmpfs Mounts
*   **How they work:** Mounts temporary filesystems (`tmpfs`) stored only in the **host system's memory**. Data is **not persisted** on the host disk; it disappears when the container stops.
*   **Use Cases:** Useful for storing temporary, sensitive data you don't want persisted, or for performance-critical I/O operations where disk persistence isn't needed.
*   **Syntax (`--tmpfs` or `--mount`):**
    ```bash
    # Simple tmpfs mount (no options)
    docker run -d --tmpfs /app/temp_data my_image
    # More explicit syntax using --mount
    docker run -d --mount type=tmpfs,destination=/app/temp_data my_image
    ```

#### Storage Plugins
Docker also supports **storage plugins** that allow containers to connect to external storage platforms (e.g., NFS, cloud storage).

#### Managing Volumes
- `docker volume create [volume_name]` → Creates a new named Docker volume.
- `docker volume ls` → Lists all Docker volumes (named and anonymous).
- `docker volume inspect [volume_name]` → Displays detailed low-level information about a specific Docker volume. The `"Mountpoint"` field shows the actual path on the host where the data is stored.
- `docker volume rm [volume_name...]` → Removes one or more specified volumes. The volume must not be in use by any container.
- `docker volume prune` → Removes all unused local volumes (not attached to any container).
- **Example:** `docker run -v my_volume:/var/lib/mysql -d --name mysql-db mysql` → Mounts a **named volume** `my_volume` to the container's data directory for persistent storage.

#### Sharing Volumes Between Containers (`--volumes-from`)
The `--volumes-from [container_name_or_id]` flag mounts all volumes from a source container into a new container. This is a less common pattern now; using the same named volume (`-v my_volume:/path`) in multiple containers is preferred.

```bash  
# Create a container with a data volume
docker create -v /app/data --name my-data-container busybox

# Run an app container using the data volume from the source container
docker run -d --volumes-from my-data-container --name my-app my_app_image

# Run a temporary backup container accessing the same volume to create a backup
docker run --rm --volumes-from my-data-container -v $(pwd):/backup busybox tar cvf /backup/data-backup.tar /app/data
```

### Storage Drivers

#### Overlay2
- **Overlay2** is the **default and preferred storage driver** for modern **Linux distributions**.
- It requires **no additional configuration** and is **more efficient** than older storage drivers.

## Docker Compose

**Docker compose** is a tool for defining and running multi-container docker applications using a YAML file (typically `docker-compose.yml`). It simplifies the management of applications that require multiple services (e.g., a web application and a database).

**Example `docker-compose.yml` (Multi-Service):**

```yaml
version: '3.8' # Specifies the Compose file format version (using a slightly newer common version)

services: # Defines the different containers (services)
  phpapp: # The name of the PHP application service
    build: # Instead of using a pre-built image, build one from a Dockerfile
      context: ./ # Specifies the build context directory (current directory)
      dockerfile: Dockerfile # Specifies the name of the Dockerfile to use
    image: phpapp:123 # Name and tag for the image built by Compose (optional but good practice)
    ports:
      - "8080:80" # Maps port 8080 on the host to port 80 in the phpapp container
    volumes:
      - ".:/var/www/html" # Mounts the current directory (.) on the host
                         # to /var/www/html inside the container (bind mount)
    container_name: myphpapp-app # Explicitly sets the container name
    # depends_on: # Might add this later if phpapp needs db to be ready first
    #  - db

  db: # The name of the database service
    image: mysql:latest # Use the official MySQL image
    restart: always # Always restart the db container if it stops
    environment:
      MYSQL_ROOT_PASSWORD: somepass # Set the root password via environment variable
      MYSQL_DATABASE: somedatabase # Set the database name via environment variable
    container_name: myphpapp-db # Explicitly sets the container name
      volumes:
        - my_vol:/var/lib/.mysql # Add a volume to persist database data
    
  volumes:
    my_vol:
      name: my-vol
```

#### The Magic of `volumes: - .:/app`

The `volumes` key in the `docker-compose.yml` example is what enables live code synchronization for development:

-   `volumes: - .:/var/www/html`

This line means:
-   **`.` (the part left of the colon):** "Take the current directory on my host machine (where the `docker-compose.yml` file is)."
-   **`/var/www/html` (the part right of the colon):** "...and mount/sync it into the `/var/www/html` directory inside the container."

As a result, any change you make to your code on your host machine is instantly available inside the container, eliminating the need to run `docker build` after every change.

### Docker Compose Commands
- `docker-compose up -d` → Runs multiple containers defined in a Compose file.

## Docker Networking

Docker uses networks to manage and isolate communication between containers, and between containers and the outside world.

### Port Mapping (`-p` / `--publish`)

When you run a service inside a container (e.g., a web server listening on port 80), that port is only accessible from within the Docker network by default.

*   **Container Port:** The port the application *inside* the container listens on (e.g., 80 for Nginx).
*   **Host Port:** A port on the Docker *host* machine (your computer).
*   **Mapping (`-p`):** Connects a host port to a container port, making the container's service accessible from outside. It controls **external access** to a container's port.
    *   Syntax: `docker run -p <host_port>:<container_port> [image_name]`
    *   Example: `docker run -d -p 8080:80 nginx`
        *   This command runs an Nginx container in the background (`-d`).
        *   Nginx inside the container listens on its default **Container Port** `80`.
        *   Docker maps the **Host Port** `8080` on your host machine to the container's port `80`.
        *   You can now access the Nginx server from your browser using `http://<your-host-ip>:8080` or `http://localhost:8080`.
    *   `docker run -dp 8080:8080 myimage:v1` → A shorthand to run a container in detached mode (`-d`) and publish a port (`-p`).
    *   If you only specify the container port (`-p 80`), Docker will automatically map it to a random available high port number on the host. You can see the assigned port using `docker ps`.

### Network Connection (`--network`)

This flag connects a container to a specific Docker network, controlling how it communicates with other containers and its network isolation.

*   **Purpose:** Attaches the container to a network (e.g., `bridge`, `host`, `none`, or a user-defined network).
*   **Function:** Determines which other containers it can communicate with directly (often using container names for DNS resolution on user-defined networks) and its overall network environment.
*   **Default:** If omitted, containers connect to the default `bridge` network.
*   **Example:** `docker run -d --name mysql-db --network my-custom-network -e MYSQL_ROOT_PASSWORD=db_pass123 mysql:5.6` → Runs a MySQL container and connects it specifically to the user-defined network `my-custom-network` for isolated communication.

### `--network` vs. `-p`

*   Use `-p` (or `--publish`) to **expose a container's port** to the host machine, allowing external connections.
*   Use `--network` to **connect a container to a specific network**, controlling its communication with other containers.
*   They serve different purposes and are often used together.

### Legacy Linking (`--link`)

*   **Purpose:** A legacy method to connect containers, allowing one container to discover the IP address of another by name.
*   **Function:** Adds an entry to the `/etc/hosts` file of the recipient container (e.g., `--link mysql-db:db` adds a host entry mapping `db` to the `mysql-db` container's IP).
*   **Example:** `docker run --network=wp-mysql-network --link mysql-db:mysql-db -d kodekloud/simple-webapp-mysql` → Runs a webapp, connecting it to a network and using a (now redundant) legacy link to connect to the `mysql-db` container.
*   **Status:** Generally **discouraged** and considered legacy. **User-defined networks (created with `docker network create`) are the preferred modern approach** as they provide cleaner isolation and use Docker's built-in DNS for service discovery by container name.
*   **Redundancy:** Using `--link` is redundant if containers are already connected to the same user-defined network.

### Managing Networks
- `docker network ls` → Lists all Docker networks on the host.
- `docker network create [network_name]` → Creates a new user-defined network (default driver is bridge).
- `docker network create --driver bridge --subnet 182.18.0.0/24 --gateway 182.18.0.1 my-custom-network` → Creates a custom bridge network with a specific IP subnet and gateway.

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

### Cleaning Up Unused Objects (Pruning)

**Dangling objects** are unused Docker resources, such as images, volumes, and networks, that are no longer referenced or used by any containers. They consume disk space and should be cleaned up periodically.

-   **Dangling Images:** Images tagged as `<none>`. These are often created as intermediate layers during a build or when you rebuild an image without changing the tag.
-   **Dangling Volumes:** Volumes that are not attached to any container.

**Pruning Commands:**
- `docker image prune` → Removes all dangling images.
- `docker volume prune` → Removes all unused (dangling) volumes.
- `docker container prune` → Removes all stopped containers.
- `docker system prune` → A comprehensive command that removes all stopped containers, dangling images, unused networks, and build cache. Use `-a` to also remove unused images (not just dangling ones).

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
