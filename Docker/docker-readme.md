# Docker Study Notes

## Table of Contents
- [Docker Basics](#docker-basics)
- [Docker Images and Containers](#docker-images-and-containers)
- [Dockerfile](#dockerfile)
- [Docker Storage](#docker-storage)
- [Docker Compose](#docker-compose)
- [Docker Engine and System](#docker-engine-and-system)
- [Docker Commands](#docker-commands)

## Docker Basics

### What is Docker Client?
A component of the Docker architecture that provides Command Line Interface tools to interact with Docker daemon.

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

### View All Containers
If you want to see all containers, including those that are stopped, run:
```
docker ps -a
```

### Check Docker Disk Usage
```
docker system df --v
```
Shows detailed information on Docker disk space usage.
