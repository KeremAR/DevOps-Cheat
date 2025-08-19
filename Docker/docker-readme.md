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

**Example Build and Run Commands:**

```bash
# Build the Docker image from the Dockerfile in the current directory (.)
# Tag the image as 'myphpapp' with the tag 'web'
$ docker build -t myphpapp:web .

# Run a container from the built image
# Map port 8080 on the host to port 8000 inside the container
# (Port 8000 is exposed by the Dockerfile and used by the CMD)
$ docker run -p 8080:8000 myphpapp:web
```

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

#### Bind Mounts
*   **How they work:** A file or directory on the **host machine** is mounted directly into a container. The path on the host machine is specified. Changes made in the container are reflected on the host, and vice-versa.
*   **Use Cases:** Useful for sharing configuration files, source code during development, or accessing host resources. Performance can be lower than volumes, especially on Docker Desktop (macOS/Windows).
*   **Persistence Example (`-v /<host_path>:<container_path>`):** Consider `docker run -d -v /opt/host_data:/app/data my_image`. Data written to `/app/data` inside the container is stored in `/opt/host_data` on the host. If the container is removed, `/opt/host_data` remains.
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
    *   If you only specify the container port (`-p 80`), Docker will automatically map it to a random available high port number on the host. You can see the assigned port using `docker ps`.

### Network Connection (`--network`)

This flag connects a container to a specific Docker network, controlling how it communicates with other containers and its network isolation.

*   **Purpose:** Attaches the container to a network (e.g., `bridge`, `host`, `none`, or a user-defined network).
*   **Function:** Determines which other containers it can communicate with directly (often using container names for DNS resolution on user-defined networks) and its overall network environment.
*   **Default:** If omitted, containers connect to the default `bridge` network.
*   **Example:** `--network my-custom-bridge` connects the container to the network named `my-custom-bridge`.

### `--network` vs. `-p`

*   Use `-p` (or `--publish`) to **expose a container's port** to the host machine, allowing external connections.
*   Use `--network` to **connect a container to a specific network**, controlling its communication with other containers.
*   They serve different purposes and are often used together.

### Legacy Linking (`--link`)

*   **Purpose:** A legacy method to connect containers, allowing one container to discover the IP address of another by name.
*   **Function:** Adds an entry to the `/etc/hosts` file of the recipient container (e.g., `--link mysql-db:db` adds a host entry mapping `db` to the `mysql-db` container's IP).
*   **Status:** Generally **discouraged** and considered legacy. **User-defined networks (created with `docker network create`) are the preferred modern approach** as they provide cleaner isolation and use Docker's built-in DNS for service discovery by container name.
*   **Redundancy:** Using `--link` is redundant if containers are already connected to the same user-defined network.

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

## Docker Commands




### Container Management
- `docker ps` → Lists currently running containers.
- `docker ps -a` → Shows all containers that have been run previously.
- `docker container stop [container_id]` → Stops a running container.
- `docker stop $(docker ps -q)` → Stops all running containers at once by passing the IDs of running containers (`docker ps -q`) to the stop command.
- `docker container start [container_id]` → Restarts a stopped container.
- `docker rm [container_id_or_name]` → Removes a *specific* stopped container.
- `docker rm -f [container_id_or_name]` → Forcefully removes a *specific* running container. Use with caution.
- `docker container prune` → Cleans up *all* stopped containers (bulk removal).
- `docker run [image_name]:[tag]` → Creates and starts a new container from an image.
- `docker run -d ... [image_name]`: Runs the container in **detached mode** (in the background).
    - **Note:** For a detached container to stay running, the command specified in the image (`CMD`/`ENTRYPOINT`) must be a long-running process. If it's not (e.g., a basic `alpine` image), you often need to provide a command that doesn't exit, like `sleep infinity` or `tail -f /dev/null`.
    ```bash
    docker run -d --name my-alpine alpine:latest sleep infinity
    ```
- `docker exec -it [container_id_or_name] [command]` → Executes a command inside a *running* container. `-it` provides an interactive TTY (shell access).
    ```bash
    # Get an interactive shell inside a container
    docker exec -it my-container /bin/sh
    # Run a non-interactive command
    docker exec my-container ls /app
    ```
- `docker run -it -w /myfiles [image_name] [command]` → Creates a new container from `[image_name]`, starts an interactive TTY session (`-it`), sets the working directory inside the container to `/myfiles` (`-w`), and then runs `[command]` (or the image's default command if none is provided) from within that directory.

### Running Ubuntu Inside Docker
- `docker run -dit ubuntu sleep infinity` → Runs an Ubuntu container in detached (`d`), interactive (`i`), TTY (`t`) mode, kept alive by `sleep infinity`.
- `docker container exec -it [container_id] bash` → Opens a bash shell inside the running container.

### Volume Management
- `docker volume create [volume_name]` → Creates a new named Docker volume.
- `docker volume ls` → Lists all Docker volumes (named and anonymous).
- `docker volume rm [volume_name...]` → Removes one or more specified volumes. Volume must not be in use by any container.
- `docker volume prune` → Removes all unused local volumes (not attached to any container).
- `--volumes-from [container_name_or_id]` (Option for `docker run`): Mounts all the volumes defined in another container into the new container. Useful for sharing persistent data (e.g., databases) or for backup/restore scenarios. **Note:** This is less common now; using the same named volume (`-v my_volume:/path`) in multiple containers is often preferred.
    ```bash  
    # Run a data container (might exit, doesn't matter)
    docker create -v /app/data --name my-data-container busybox
    # Run an app container using the data volume
    docker run -d --volumes-from my-data-container --name my-app my_app_image
    # Run a backup container accessing the same volume
    docker run --rm --volumes-from my-data-container -v $(pwd):/backup busybox tar cvf /backup/data-backup.tar /app/data
    ```
    - *(Conceptual) Sidecar Pattern:* Sharing volumes (`-v my_volume:/path` in both containers, or `--volumes-from`) allows containers to collaborate. One common pattern is a "sidecar" where one container writes data (e.g., logs) into a volume, and another container reads from that same volume (e.g., to ship logs elsewhere), without the two containers needing direct network communication.

### Container/Volume Inspection
- `docker inspect [container_name_or_id]` → Displays detailed low-level information about a container in JSON format. Useful for finding IP addresses, checking environment variables, and **inspecting mounts**. Look for the `"Mounts"` array to see volumes and bind mounts, including their type, source (host path or volume name), and destination (container path).
- `docker inspect [volume_name]` → Displays detailed low-level information about a specific Docker volume. Key field is `"Mountpoint"`, which shows the actual path on the host machine where the volume's data is stored (usually within `/var/lib/docker/volumes/`).

### Container Logs
- `docker logs [container_name_or_id]` → Fetches the logs (stdout/stderr) of a container.
- `docker logs -f [container_name_or_id]` or `docker logs --follow [container_name_or_id]` → Follows the log output in real-time, similar to `tail -f`.

### Network Management
- `docker network ls` → Lists all Docker networks on the host (showing ID, Name, Driver, Scope).
- `docker network create [network_name]` → Creates a new user-defined network (default driver is bridge).
- `docker network create --driver bridge --subnet 182.18.0.0/24 --gateway 182.18.0.1 wp-mysql-network` → Creates a custom bridge network named `wp-mysql-network` with a specific IP subnet and gateway.

### Image and Build Process
- `docker build -t [image_name]:v1 .` → Builds an image from the Dockerfile in the current directory.
- `docker run [image_name]:v1` → Runs the created image.
- `docker run -dp 8080:8080 myimage:v1` → Runs a container in detached mode (`-d`) and maps host port 8080 to container port 8080 (`-p`).
- `docker run -d -e MYSQL_ROOT_PASSWORD=db_pass123 --name mysql-db mysql` → Runs a MySQL container named `mysql-db` in the background, setting the root password via an environment variable (`-e`).
- `docker run -v /opt/data:/var/lib/mysql -d --name mysql-db -e MYSQL_ROOT_PASSWORD=db_pass123 mysql` → Runs MySQL, **mounting the host directory `/opt/data` to the container's `/var/lib/mysql` (`-v`) for persistent database storage**, setting the root password (`-e`), naming it (`--name`), and running in the background (`-d`).
- `docker run -d -e MYSQL_ROOT_PASSWORD=db_pass123 --name mysql-db --network wp-mysql-network mysql:5.6` → Runs MySQL 5.6, setting password (`-e`), naming it (`--name`), running in background (`-d`), and **connecting it specifically to the user-defined network `wp-mysql-network` (`--network`)** for isolated communication with other containers on that network.
- `docker run --network=wp-mysql-network -e DB_Host=mysql-db -e DB_Password=db_pass123 -p 38080:8080 --name webapp --link mysql-db:mysql-db -d kodekloud/simple-webapp-mysql` → Runs a webapp container, connecting it to `wp-mysql-network`, passing DB credentials (`-e`), exposing port (`-p`), naming it (`--name`), using a (redundant) legacy link (`--link`), and running in background (`-d`).
- `docker images` → Lists all available Docker images.
- `docker rmi [image_id_or_name]` → Removes a specific Docker image. You might need to use `-f` (force) if the image is used by stopped containers.
- `docker rmi -f $(docker images -q)` → Removes *all* Docker images forcefully. Use with caution!
- `docker run --rm <image_name> cat /etc/os-release` → Checks the OS version inside an image by running a command in a temporary container (`--rm` cleans up afterwards).
- `docker run -v my_volume:/var/lib/mysql -d --name mysql-db ... mysql`: Example mounting a **named volume** `my_volume` to the container's data directory.

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
