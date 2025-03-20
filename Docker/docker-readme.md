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

### What is Docker Client?
A component of the Docker architecture that provides Command Line Interface tools to interact with Docker daemon.

## Docker Benefits
- **Isolation**: Processes in one container don't affect those in another.
- **Consistency**: Ensures applications run consistently across different environments.
- **Scalability**: Easy to horizontally scale applications.

## Docker Images and Containers

### What is a Docker Container?
A container is a runnable instance of the Docker image.

- You **can** create multiple containers from the **same** Docker image.
- Each container will run **independently** and can have its own configuration, environment variables, and mounted volumes.

## Dockerfile

### What is the Dockerfile?
It is a special script for Docker that provides commands for building docker images.

### Key Dockerfile Instructions

- **RUN** executes a command **during the image build process**.
- Each RUN instruction **creates a new layer** in the Docker image.
- This is typically used to install dependencies, update packages, or configure the system.

## Docker Storage

### Storage Options

#### Volumes
**Volumes** are managed by Docker and are the recommended way to persist data. Volumes can be safely shared between multiple docker containers.

#### Bind Mounts
Where are bind mounts stored on the host system?
Anywhere on the host system.

### Storage Drivers

#### Overlay2
- **Overlay2** is the **default and preferred storage driver** for modern **Linux distributions**.
- It requires **no additional configuration** and is **more efficient** than older storage drivers.

## Docker Compose

**Docker compose** is tool for defining and running multi container docker applications.

### Docker Compose Commands
- `docker-compose up -d` → Runs multiple containers defined in a Compose file.

## Docker Engine and System

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

### Container Management
- `docker ps` → Lists currently running containers.
- `docker ps -a` → Shows all containers that have been run previously.
- `docker container stop [container_id]` → Stops a running container.
- `docker container start [container_id]` → Restarts a stopped container.
- `docker container prune` → Cleans up all stopped containers.

### Running Ubuntu Inside Docker
- `docker run -dit ubuntu` → Runs an Ubuntu container in the background.
- `docker container exec -it [container_id] bash` → Opens a bash shell inside the container.

### Volume Management
- `docker volume create [volume_name]` → Creates a new Docker volume.
- `docker inspect [volume_name]` → Displays details about a Docker volume.

### Image and Build Process
- `docker build -t [image_name]:v1 .` → Builds an image from the Dockerfile in the current directory.
- `docker run [image_name]:v1` → Runs the created image.
- `docker images` → Lists all available Docker images.

### System Information
- `docker system df --v` → Shows detailed information on Docker disk usage.

## Artifact Registry

### What is Artifact Registry?
- Artifact Registry is a **centralized storage system** used for managing and versioning various build artifacts generated during the software development lifecycle.
- It helps store, version, and manage artifacts like Docker images, dependencies, or compiled code, ensuring efficient and secure software deployment.
