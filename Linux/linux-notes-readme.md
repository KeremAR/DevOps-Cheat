# Linux Study Notes

## Table of Contents
- [Linux Introduction](#linux-introduction)
  - [Unix-based OS's](#unix-based-oss)
  - [Linux Distributions](#linux-distributions)
  - [Shell](#shell)
  - [File Systems](#file-systems)
- [LVM (Logical Volume Manager)](#lvm-logical-volume-manager)
- [SWAP](#swap)
- [Disk Quotas](#disk-quotas)
- [Boot Loaders](#boot-loaders)
- [Runlevels](#runlevels)
- [Linux Shell Basics](#linux-shell-basics)
  - [Introduction to Shells](#introduction-to-shells)
  - [Shell Programming](#shell-programming)
  - [Basic Shell Commands](#basic-shell-commands)
  - [Text Editors](#text-editors)
  - [Filesystem Files Search](#filesystem-files-search)
  - [Xargs](#xargs)
  - [Working with Archives](#working-with-archives)
- [Package Management](#package-management)
  - [Software Management](#software-management)
  - [Alternatives](#alternatives)
- [Systemd/init.d](#systemdinit.d)
- [Crond](#crond)
- [JAVA (OpenJDK)](#java-openjdk)
- [Users, Groups, Permissions](#users-groups-permissions)
  - [Users and Groups](#users-and-groups)
  - [Permission Model](#permission-model)
  - [SELinux](#selinux)
- [Networking, Remote Access](#networking-remote-access)
  - [Network Configuration](#network-configuration)
  - [Networking Tools](#networking-tools)
  - [Firewall.d and IPtables](#firewalld-and-iptables)
  - [Remote Access](#remote-access)
- [Monitoring, Processes Control, Logs](#monitoring-processes-control-logs)
  - [Process Monitoring](#process-monitoring)
  - [Monitoring CPU](#monitoring-cpu)
  - [Monitoring Memory](#monitoring-memory)
  - [Monitoring Storage](#monitoring-storage)
  - [Logs](#logs)

## Linux Introduction

### Unix-based OS's

Linux is a Unix-like operating system, sharing many characteristics with traditional Unix systems while being open-source and freely distributable.

### Linux Distributions

Different Linux distributions include:
- **RPM-based**: RHEL, CentOS, Fedora (use YUM/DNF package manager)
- **Debian-based**: Ubuntu, Debian, Kali Linux, Linux Mint (use APT package manager)

### Shell

The shell is the command-line interface that interprets user commands. Common shells include Bash, Zsh, and others.

### File Systems

**Linux Native File Systems:**
- **ext4**: Default and most commonly used in modern Linux distributions
- **ext3**: Older, journaling file system
- **ext2**: Non-journaling file system, used in some older systems or for specialized uses
- **Btrfs**: Advanced features like snapshots, copy-on-write, and RAID functionality
- **XFS**: High-performance file system, best for large files and enterprise environments
- **ReiserFS**: Less commonly used, optimized for small files
- **F2FS**: Optimized for flash storage devices

**Pseudo Filesystems:**
- **/proc**: Virtual filesystem providing an interface to kernel data structures
- **/sys**: Exposes kernel device and driver information
- **/dev**: Contains device files
- **/tmp**: Temporary file storage

**Key Characteristics of a Pseudo-Filesystem:**
- **No Physical Storage**: Files not backed by physical disk storage, but generated dynamically
- **Dynamic Content**: Contents change depending on system state
- **Interface to Kernel Data**: Provides a mechanism for interacting with kernel data structures

The **/proc filesystem** is a virtual filesystem that provides an interface to kernel data structures. Files in /proc do not exist on disk; they are virtual and generated dynamically when accessed, providing a real-time snapshot of the system's state.

## LVM (Logical Volume Manager)

LVM allows for flexible disk space management through:

1. **Identify Available Devices**:
```bash
lsblk
# or
sudo fdisk -l
```

2. **Create Physical Volume**:
```bash
sudo pvcreate /dev/sdc
```

3. **Create Volume Group**:
```bash
sudo vgcreate student /dev/sdc
```

4. **Create Logical Volume**:
```bash
sudo lvcreate -L 500M -n student student
```

5. **Format the Volume**:
```bash
sudo mkfs.ext4 /dev/student/student
```

6. **Find UUID and Mount Permanently**:
```bash
sudo blkid /dev/student/student
```

7. **Add to /etc/fstab for permanent mounting**:
```bash
sudo nano /etc/fstab
# Add: UUID=<UUID> /lvm/student ext4 defaults 0 2
```

8. **Create Mount Point and Mount**:
```bash
sudo mkdir -p /lvm/student
sudo mount -a
```

**Important Notes:**
- After resizing LVM logical volume, remember to resize the filesystem
- Using UUID for mount points is more secure than device paths

## SWAP

Swap space provides virtual memory when RAM is insufficient. It can be created as either a swap partition or a swap file.

**Creating a 1GB Swap File**:

1. **Create the Swap File**:
```bash
sudo fallocate -l 1G /swapfile
```

2. **Set Permissions**:
```bash
sudo chmod 600 /swapfile
```

3. **Convert to Swap Space**:
```bash
sudo mkswap /swapfile
sudo swapon /swapfile
```

4. **Make it Permanent** (add to /etc/fstab):
```bash
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

5. **Verify Setup**:
```bash
free -h
swapon --show
```

**Types of Swap**:
- **Swap Partition**: Uses a dedicated disk partition, better performance but less flexible
- **Swap File**: Uses a regular file, more flexible for resizing or removal

## Disk Quotas

(No specific information provided in the original document)

## Boot Loaders

Boot loaders like GRUB load the Linux kernel into memory.

**Boot Sequence in systemd:**
1. **BIOS/UEFI**: Initializes hardware and loads the bootloader
2. **Bootloader (GRUB, LILO, Syslinux)**: Loads the Linux kernel into memory
3. **Kernel Initialization**: Linux kernel initializes hardware drivers and mounts the initial RAM disk
4. **Initial RAM Disk (initramfs/initrd)**: Loads necessary drivers and mounts the root filesystem
5. **Device Initialization & Init System**: Kernel starts the init system, determines the default target/runlevel

## Runlevels

(No specific information provided in the original document)

## Linux Shell Basics

### Introduction to Shells

There are two types of commands in Linux shells:

**1. Internal Commands (Built-in)**
- Executed directly by the shell
- No separate program file exists
- Faster because they don't require loading from disk
- Examples: cd, echo, pwd, exit

**2. External Commands (Separate Programs)**
- Stored as separate executable files in /bin, /usr/bin, etc.
- Executed by calling their file path
- Slower because they need to be loaded from disk
- Examples: ls, grep, find

To check if a command is built-in or external:
```bash
type command_name
```

### Shell Programming

**Aliases** in Linux/Unix are shortcuts for frequently used commands. They allow you to define custom, shorter or easier-to-remember names for long or complex commands.

You can add aliases to `~/.bash_profile` which is sourced when a user logs in.

**Exit Codes in Linux**

Every command returns an exit code (0-255) indicating success or failure:
- Exit code 0 means success
- Non-zero exit codes indicate errors

To check the exit code:
```bash
ls /nonexistent
echo $?  # Will show error code, like 2
```

**Environment Variables**

Environment variables store system-wide settings or user-specific configurations:
```bash
# To view all environment variables
env
# To view a specific variable
echo $HOME
```

### Basic Shell Commands

**Commands That Overwrite a Target File Without Prompting**:
- `cp source_file target_file`
- `mv source_file target_file`
- `mv -f source_file target_file`

### Text Editors

**How to exit from vi/vim editors:**

1. **Save and Exit**
   - `:wq` → Save the file and quit
   - `ZZ` → Save the file and quit (only in normal mode)
   - `:x` → Save and quit (only if changes were made)

2. **Exit Without Saving**
   - `:q!` → Quit without saving changes
   - `ZQ` → Force quit without saving

3. **Save Without Exiting**
   - `:w` → Save the file but stay in vi
   - `:w filename` → Save as a new file

4. **Exit If No Changes Were Made**
   - `:q` → Quit only if no changes were made

5. **Force Exit (for Read-Only Files)**
   - `:wq!` → Save changes and exit, even if the file is read-only

### Filesystem Files Search

To find all files containing a specific keyword:
```bash
grep -r "keyword" /path/to/directory/
```

To find which package contains a specific file:
```bash
# For YUM-based systems
yum provides filename
```

### Xargs

(No specific information provided in the original document)

### Working with Archives

To view the contents of an archive file without extracting it:
- `tar -tf`: List contents of .tar archive
- `tar -tzf`: List contents of .tar.gz or .tgz
- `tar -tjf`: List contents of .tar.bz2
- `unzip -l`: List contents of .zip archive
- `unrar l`: List contents of .rar archive
- `7z l`: List contents of .7z archive

## Package Management

### Software Management

**YUM (Yellowdog Updater, Modified)**
- Package manager for RPM-based Linux distributions (RHEL, CentOS, Fedora)
- Helps install, update, remove, and manage software packages
- Resolves dependencies automatically
- Can perform system kernel upgrades
- Commands:
  ```bash
  yum list installed  # Show installed packages
  yum list available  # Show available packages
  yum list all        # Show all packages
  ```

**APT (Advanced Package Tool)**
- Package manager for Debian-based distributions (Ubuntu, Debian, Linux Mint)
- Helps install, update, remove, and manage software packages
- Resolves dependencies automatically
- Can perform system kernel upgrades

**Installing Docker**:

1. **Remove Old Docker Versions**:
```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

2. **Install Dependencies**:
```bash
sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
```

3. **Add Docker's GPG Key**:
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
```

4. **Add the Docker Repository**:
```bash
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

5. **Install Docker**:
```bash
# List available versions
apt-cache madison docker-ce | grep 19.03
# Install specific version
sudo apt-get install -y docker-ce=5:19.03.15~3-0~ubuntu-focal docker-ce-cli=5:19.03.15~3-0~ubuntu-focal containerd.io
# Verify installation
docker --version
```

### Alternatives

(No specific information provided in the original document)

## Systemd/init.d

**Changing Hostname**:

Temporarily (immediately effective):
```bash
sudo hostnamectl set-hostname student
```

Permanently (edit /etc/hostname):
```bash
sudo nano /etc/hostname
# Replace old hostname with "student"
# Save and exit

# Apply changes immediately
sudo systemctl restart systemd-hostnamed
```

**systemctl** is used to manage Linux services (systemd daemons). It can start, stop, restart, and check the status of services.

**Daemons in Linux**:
- A daemon is a background process that runs continuously without user interaction
- Typically starts at boot and keeps running in the background
- Common examples: httpd (web server), sshd (SSH service), crond (task scheduler)
- Daemon names often end with "d"

To start a service manually:
```bash
sudo systemctl start httpd
```

## Crond

**Cron Job**:
- Automated tasks that run at specified intervals
- Managed by the "cron" scheduler service
- Uses include:
  - Automatic backups
  - Cleaning log files
  - Scheduled commands
  - Server maintenance and updates
  - Sending emails
  - Database operations

**Logrotate**:
- Tool to rotate and manage log files
- Prevents logs from growing indefinitely
- Configuration stored in /etc/logrotate.d/

Example NGINX logrotate configuration:
```
/var/log/nginx/*.log {
    weekly               # Weekly rotation
    rotate 4             # Keep last 4 backups
    compress             # Compress old logs
    delaycompress        # Only compress after 2nd rotation
    notifempty           # Don't rotate empty logs
    missingok            # Don't error if log file missing
    create 640 www-data adm  # Permissions for new logs
}
```

To test logrotate configuration:
```bash
sudo logrotate --debug /etc/logrotate.d/nginx
```

To run logrotate manually:
```bash
sudo logrotate /etc/logrotate.conf
```

## JAVA (OpenJDK)

(No specific information provided in the original document)

## Users, Groups, Permissions

### Users and Groups

**Creating a Group**:
```bash
sudo groupadd -g 1050 student_group
# -g 1050: Sets the group ID (GID) to 1050
```

**Creating a User**:
```bash
sudo useradd -u 1040 -g student_group -G cdrom -d /home/student_home -m student
# -u 1040: Sets the user ID (UID) to 1040
# -g student_group: Sets the primary group
# -G cdrom: Adds to supplementary group cdrom
# -d /home/student_home: Sets the home directory
# -m: Creates the home directory if it doesn't exist
```

**Setting a Password**:
```bash
sudo passwd student
```

The UID for the root user is always 0.

To execute a command as a specific user:
```bash
sudo -u username whoami
```

### Permission Model

**Understanding File Permissions**: `-rws--xr-x`
- Regular file
- Owner: Read, Write, Execute with SetUID (rws)
- Group: Execute only (--x)
- Others: Read and Execute (r-x)

**Special Permission: s (SetUID)**
- When set in the owner's execute position, it means SetUID is enabled
- Effect: File executes as the file owner, not the user running it

**Making a File Immutable**:
1. Create the file:
```bash
sudo touch /immutable.txt
```

2. Change ownership and group:
```bash
sudo chown student:cdrom /immutable.txt
```

3. Set file permissions:
```bash
sudo chmod 777 /immutable.txt
```

4. Make the file immutable:
```bash
sudo chattr +i /immutable.txt
```

This prevents the file from being:
- Deleted
- Modified
- Renamed

**Sticky Bit**:
- When set on a directory, it restricts file deletion/renaming
- Only the file owner, directory owner, or root can delete/rename files
- Other users with write permissions cannot delete files they don't own

**Inode**:
- Stores metadata about files but not the filename
- Filename is stored in directory entries that link to inodes
- Allows multiple filenames (hard links) to point to the same inode
- Filesystems have a finite number of inodes

To check inode usage:
```bash
df -i
```

### SELinux

**Security-Enhanced Linux (SELinux)**:
- Controls what processes can access which files, ports, and resources
- Uses security contexts to label files, processes, and network ports
- Works in three modes:
  - **Enforcing** (default): SELinux policies are actively applied
  - **Permissive**: Logs policy violations but doesn't block them
  - **Disabled**: SELinux is completely turned off

## Networking, Remote Access

### Network Configuration

**Changing Hostname**:

Temporarily:
```bash
sudo hostnamectl set-hostname student
```

Permanently (edit /etc/hostname):
```bash
sudo nano /etc/hostname
# Replace content with "student"
```

**Mounting Shared Folders in Vagrant**:
```bash
sudo mount -o uid=1000,gid=1000 -t vboxsf vagrant /vagrant
```

**Adding a Route to a Network**:

Using ip command (modern method):
```bash
sudo ip route add 10.0.0.0/8 dev wlp2s0
```

Using route command (older method):
```bash
sudo route add -net 10.0.0.0/8 dev wlp2s0
```

Check the route:
```bash
ip route show
```

**The mount Command**:
- Makes storage devices accessible in the filesystem
- The initial volume mount table (/etc/fstab) defines how volumes are mounted at boot

### Networking Tools

**netstat (Network Statistics)**:
- Displays active network connections, routing tables, and open ports
- Used to view network-related information

**Default Ports**:
- DNS: Port 53 (UDP and TCP)
- SSH: Port 22 (TCP)

### Firewall.d and IPtables

**iptables**:
```bash
sudo iptables -L
```

Lists all rules for each chain:
- **INPUT Chain**: Controls incoming traffic to the system
- **OUTPUT Chain**: Controls outgoing traffic from the system
- **FORWARD Chain**: Controls packets that are forwarded through the system

### Remote Access

**SSH Keys**:
- Public keys for authorizing SSH users are stored in `~/.ssh/authorized_keys` on the remote server
- Private key is kept secure on the client machine
- During connection, the server checks if the public key matches the client's private key

**SCP (Secure Copy)**:
- Command-line tool for secure file transfers over SSH
- Example: Copy a file to a remote user's home directory:
```bash
scp data.txt targetuser@h1:~
```

**Creating Sudo Rules**:
```bash
sudo visudo -f /etc/sudoers.d/student
```

Example rule:
```
student ALL=(ALL) NOPASSWD: /usr/bin/apt install, /usr/bin/apt-get install
```

This means:
- `student`: User the rule applies to
- `ALL=`: Applies to all machines
- `(ALL)`: Can run commands as any user
- `NOPASSWD:`: No password required for these commands
- `/usr/bin/apt install, /usr/bin/apt-get install`: Only these commands can be run without a password

## Monitoring, Processes Control, Logs

### Process Monitoring

**Zombie Process**:
- Completed process not removed from the process table
- Can be removed by killing the parent process or using wait()
- Zombies do not consume CPU or memory

### Monitoring CPU

(No specific information provided in the original document)

### Monitoring Memory

**Displaying RAM and Swap Usage**:
```bash
free -h  # -h for human-readable format

# For detailed memory information
cat /proc/meminfo

# Real-time monitoring
top
# or
htop
```

### Monitoring Storage

(No specific information provided in the original document)

### Logs

**Log Locations**:
- `/var/log/`: Standard directory for most system and application logs

**Making Scripts Globally Runnable**:
1. Move the script to a directory in $PATH (e.g., /usr/local/bin/)
2. Or create a symbolic link in /usr/local/bin/
