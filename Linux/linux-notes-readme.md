# Linux Study Notes

## Table of Contents
- [Linux Introduction](#linux-introduction)
  - [Unix-based OS's](#unix-based-oss)
  - [Linux Distributions](#linux-distributions)
  - [Shell](#shell)
  - [File Systems](#file-systems)
  - [Linux File System and Key Directories](#linux-file-system-and-key-directories)
  - [Disk and Device Naming](#disk-and-device-naming)
  - [Linux Case Sensitivity](#linux-case-sensitivity)
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

To check which shell you're currently using:
```bash
echo $SHELL
```

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

### Linux File System and Key Directories

* `/bin` → Contains essential system commands used by all users. Example: ls, cp, mkdir, cat, bash..
* `/var` → Stores variable data such as log files, mail spools, and temporary files.
* `/dev` → Contains device files representing hardware devices and peripherals connected to the system.
* `/mnt` and `/media` → Used for mounted devices; `/mnt` is traditionally for manually mounted filesystems, while `/media` is often used for automatically mounted removable media.
* `/opt` → Used for optional or third-party software packages installed manually or outside the standard package management system.
* `/tmp` → Temporary files that are typically deleted upon system reboot.
* `/etc` → Contains system-wide configuration files and scripts for various programs and services.
* `/home` → Contains user home directories.
* `/root` → The home directory for the root user.
* `/usr` → Contains user programs, libraries, and documentation.
* `/lib` → Contains essential shared libraries needed by system programs.
* `/sbin` → Contains administrative commands used only by root. Example: fdisk, iptables, reboot, shutdown..

### Disk and Device Naming

* `/dev/sda` and `/dev/vda` → Represent disk devices:
  * `sda` refers to SATA, SCSI, or USB disk devices
  * `vda` refers to virtual disks in virtual machines
* `/dev/sda1, sda2, sda3...` → Represents partitions (or volumes) on the disk.
* Modern systems may also use `/dev/nvme0n1` for NVMe SSDs.

### Linux Case Sensitivity

* Linux file names and commands are **case-sensitive**. For example: `Test.txt` is not the same as `test.txt`.
* This applies to commands, filenames, directory names, and variables.

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

**Manual Pages (`man`)**:
- `man [command_name]` → Displays the manual page (documentation) for a specific command, providing detailed information about its usage, options, and examples. Press `q` to exit the man page viewer.

**Searching Manual Pages (`apropos`)**:
- `apropos [keyword]` → Searches the names and short descriptions of manual pages for a specific keyword. Useful when you don't know the exact command name but know what it does.

**Commands That Overwrite a Target File Without Prompting**:
- `cp source_file target_file`
- `mv source_file target_file`
- `mv -f source_file target_file`
- `cat file1 > file2` → Writes the content of `file1` into `file2`, overwriting any existing content.

**Viewing Files (`less`)**:
- `less [filename]` → A pager used to view text files or command output one screenful at a time.
- Allows navigation (Space/Enter/Arrows to scroll, `g`/`G` to go to start/end), searching (`/keyword`), and doesn't load the entire file into memory.
- Commonly used with pipes: `ls -l | less`.
- Press `q` to quit.

**Working with Grep and Pipes**:
- `ls | grep li` → Lists files in the current directory containing "li" (case-sensitive).
- `ls /etc | grep conf` → Search for files containing "conf" in the /etc directory.
- `ls -R | grep li` → Recursive search in subdirectories for files containing "li".
- `ls *.txt | grep report` → Search for specific file extensions containing "report".
- `grep 'CentOS' /etc/os-release` → Searches the `/etc/os-release` file for lines containing the exact string 'CentOS', often used to identify the OS distribution.
- `grep -i 'error' /var/log/syslog` → Searches the `/var/log/syslog` file for lines containing 'error', ignoring case (matches 'error', 'ERROR', 'Error', etc.).
- `grep -v '^#' /etc/fstab` → Displays lines from `/etc/fstab` that **do not** start with `#` (useful for filtering out comments).
- `grep 'sam$' names.txt` → Searches `names.txt` for lines that **end** with the exact string 'sam' (`$` anchors the pattern to the end of the line).
- `grep -r 'c.t' /etc/` → **Recursively (`-r`)** searches all files under `/etc` for lines containing 'c', followed by **any single character (`.`)**, followed by 't' (e.g., matches 'cat', 'cot', 'c_t').
- `grep 'let*' file.txt` → Searches `file.txt` for lines containing 'le' followed by **zero or more (`*`) occurrences** of the letter 't' (matches 'le', 'let', 'lett', 'lettt', etc.).
- `grep '/.*/' filename` → Searches `filename` for lines containing a forward slash `/`, followed by **zero or more of any character (`.*`)**, followed by another forward slash `/` (useful for finding lines that resemble paths).
- `grep '0\{3,\}' file.txt` → Searches `file.txt` for lines containing the digit '0' repeated **three or more times consecutively** (e.g., '000', '0000'). Note: The backslashes `\` are needed for Basic Regular Expression syntax used by default `grep`.
- `grep 'disabled\?' file.txt` → Searches `file.txt` for lines containing 'disable' followed by **zero or one (`\?`) occurrences** of the letter 'd' (matches 'disable' and 'disabled'). Note: The backslash `\` is needed for standard `grep`.
- `grep 'enabled\|disabled' file.txt` → Searches `file.txt` for lines containing either the exact string 'enabled' **OR (`\|`)** the exact string 'disabled'. Note: The backslash `\` before `|` is needed for standard `grep`.
- `grep 'c[au]t' file.txt` → Searches `file.txt` for lines containing 'c' followed by **either an 'a' or a 'u' (`[au]`)**, followed by 't' (matches 'cat' or 'cut').
- `egrep '/dev/[a-z]*[0-9]?' file.txt` → Searches `file.txt` using **Extended Regular Expressions (`egrep`)** for lines containing `/dev/`, followed by **zero or more lowercase letters (`[a-z]*`)**, followed by **zero or one digit (`[0-9]?`)** (e.g., matches `/dev/sda`, `/dev/tty`, `/dev/sda1`). Note: `?` doesn't need escaping with `egrep`.
- `egrep   'http[^s]' file.txt` → Uses `egrep` to search `file.txt` for lines containing 'http' **not** immediately followed by an 1's' (using `[^s]` negated character set), useful for finding non-HTTPS URLs.

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

**User Account Information (`/etc/passwd`)**:
- `/etc/passwd` → A text file containing essential information for each user account.
- `cat /etc/passwd` → Displays the content of this file.
- Each line represents a user and typically contains fields separated by colons (`:`), including: username, encrypted password placeholder (`x`), user ID (UID), group ID (GID), user description (GECOS), home directory, and login shell.

**Deleting a User (`userdel`)**:
- `sudo userdel [username]` → Deletes a user account.
- `sudo userdel -r [username]` → Deletes the user account **and** removes their home directory and mail spool (`-r` flag).

**Modifying a User (`usermod`)**:
- `usermod` is used to modify existing user account details.
- `sudo usermod -l NEW_USERNAME OLD_USERNAME` → Changes the user's login name.
- `sudo usermod -d /new/home/dir -m NEW_USERNAME` → Changes the user's home directory (and moves content with `-m`).
- `sudo usermod -g NEW_PRIMARY_GROUP USERNAME` → Changes the user's primary group.
- `sudo usermod -G SUPPLEMENTARY_GROUP1,GROUP2 USERNAME` → Sets the user's supplementary groups (replaces existing list).
- `sudo usermod -aG SUPPLEMENTARY_GROUP USERNAME` → **Adds** the user to a supplementary group without removing others (`-a` for append).
- `sudo usermod -s /bin/zsh USERNAME` → Changes the user's login shell.
- `sudo usermod -L USERNAME` → **Locks** a user's account by putting a `!` in front of the encrypted password, preventing login.
- `sudo usermod -U USERNAME` → **Unlocks** a previously locked user account.
- `sudo usermod -e YYYY-MM-DD USERNAME` → Sets an expiration date for the user account (in YYYY-MM-DD format). After this date, the account is disabled.

**Removing a User from a Group (`gpasswd`)**:
- `sudo gpasswd -d USERNAME GROUPNAME` → Removes the specified USERNAME from the specified GROUPNAME (must be a supplementary group).

**Modifying a Group (`groupmod`)**:
- `groupmod` is used to modify existing group details.
- `sudo groupmod -n NEW_GROUPNAME OLD_GROUPNAME` → Renames an existing group.
- `sudo groupmod -g NEW_GID GROUPNAME` → Changes the Group ID (GID) of a group.

**Deleting a Group (`groupdel`)**:
- `sudo groupdel GROUPNAME` → Deletes an existing group. Note: You usually cannot delete the primary group of an existing user.

**Displaying/Modifying User Defaults (`useradd -D`)**:
- `useradd -D` (or `useradd --defaults`) → Displays the default values used by `useradd` when creating a new user (e.g., default group, home directory base, default shell, account expiration settings).
- You can also use `useradd -D [options]` to *change* these defaults (requires root privileges).

**Setting a Password**:
```bash
sudo passwd student
```

**Managing Password Aging (`chage`)**:
- The `chage` command modifies user password expiry information.
- `sudo chage -l USERNAME` → Lists the current password aging information for the user.
- `sudo chage -M DAYS USERNAME` → Sets the maximum number of days a password is valid (`-M` for Max days).
- `sudo chage -m DAYS USERNAME` → Sets the minimum number of days required between password changes (`-m` for Min days).
- `sudo chage -W DAYS USERNAME` → Sets the number of days before password expiration that a warning is given (`-W` for Warning days).
- `sudo chage -E YYYY-MM-DD USERNAME` → Sets the date when the user account itself will expire (`-E` for Expire date - same as `usermod -e`).
- `sudo chage -d 0 USERNAME` → Forces the user to change their password on the next login (`-d 0` sets the last change date to the epoch).

**Listing User's Groups (`groups`)**:
- `groups [username]` → Lists all the groups a specific user belongs to (primary and supplementary). If username is omitted, lists groups for the current user.

**Changing Group Ownership (`chgrp`)**:
- `chgrp [NEW_GROUP] [FILE/DIRECTORY]` → Changes the group ownership of a file or directory.
- `chgrp -R [NEW_GROUP] [DIRECTORY]` → Changes group ownership recursively for a directory and its contents.

**Changing User Ownership (`chown`)**:
- `chown [NEW_OWNER] [FILE/DIRECTORY]` → Changes the user owner of a file or directory.
- `chown [NEW_OWNER]:[NEW_GROUP] [FILE/DIRECTORY]` → Changes *both* the user owner and the group owner simultaneously.
- `chown -R [NEW_OWNER]:[NEW_GROUP] [DIRECTORY]` → Changes user and group ownership recursively.
- **Example:** `sudo chown aaron:family family_dog.jpg` → Changes the owner of `family_dog.jpg` to user `aaron` and the group owner to `family`.

The UID for the root user is always 0.

To execute a command as a specific user:
```bash
sudo -u username whoami
```

### Permission Model

**File Type Identifiers** (First character in `ls -l` output):

| Identifier | File Type          | Description                                       |
| :--------- | :----------------- | :------------------------------------------------ |
| `-`        | Regular File       | A normal file containing data (text, binary, etc.) |
| `d`        | Directory          | A file used to store other files and directories. |
| `l`        | Symbolic Link      | A file pointing to another file or directory by path. |
| `c`        | Character Device   | A device file that handles data character by character (e.g., terminal, `/dev/null`). |
| `b`        | Block Device       | A device file that handles data in blocks (e.g., hard drives, `/dev/sda`). |
| `s`        | Socket             | A file used for inter-process communication (IPC). |
| `p`        | Named Pipe (FIFO) | A file used for IPC, acting like a pipe.          |

**Viewing Permissions and Numeric IDs (`ls -ln`)**:
- `ls -l` → Displays files in long format, showing permissions, owner name, group name, size, etc.
- `ls -ln` → Similar to `ls -l`, but displays the **numeric User ID (UID)** and **numeric Group ID (GID)** instead of the owner and group names.

**Changing Permissions (`chmod`)**:
- The `chmod` command modifies the read, write, and execute permissions of files and directories.
- It operates in two main modes: Symbolic and Octal.

*   **Symbolic Mode:** Uses letters to represent users, operations, and permissions.
    *   **Users:** `u` (user/owner), `g` (group), `o` (others), `a` (all - ugo)
    *   **Operations:** `+` (add permission), `-` (remove permission), `=` (set exact permissions)
    *   **Permissions:** `r` (read), `w` (write), `x` (execute)
    *   **Examples:**
        *   `chmod u+x script.sh` → Adds execute permission for the owner.
        *   `chmod g-w config.txt` → Removes write permission for the group.
        *   `chmod o=r notes.txt` → Sets others' permissions to read-only.
        *   `chmod a+r data/` → Adds read permission for everyone (user, group, others).
        *   `chmod ug+rw,o-w file.log` → Adds read/write for user/group, removes write for others.

*   **Octal (Numeric) Mode:** Uses numbers (0-7) to represent permissions for user, group, and others.
    *   `4` = Read (r)
    *   `2` = Write (w)
    *   `1` = Execute (x)
    *   Permissions are added together for each category (user, group, others).
    *   **Examples:**
        *   `chmod 755 script.sh` → `rwxr-xr-x` (Owner: rwx=4+2+1=7, Group: r-x=4+0+1=5, Others: r-x=4+0+1=5)
        *   `chmod 644 config.txt` → `rw-r--r--` (Owner: rw-=4+2+0=6, Group: r--=4+0+0=4, Others: r--=4+0+0=4)
        *   `chmod 700 private_dir/` → `rwx------` (Owner: rwx=7, Group: ---=0, Others: ---=0)

*   **Recursive Option (`-R`):**
    *   `chmod -R [permissions] [directory]` → Applies the permission changes recursively to a directory and all its contents.

**Understanding File Permissions**: `-rws--xr-x`
- Regular file
- Owner: Read, Write, Execute with SetUID (rws)
- Group: Execute only (--x)
- Others: Read and Execute (r-x)

**Special Permission: s (SetUID)**
- When set in the owner's execute position (`ls -l` shows `rws`), it means SetUID is enabled.
- Effect (on executable files): The process executes with the privileges of the **file owner**, not the user running it. Useful for commands that need temporary root privileges.

**Special Permission: s (SetGID)**
- When set in the *group's* execute position (`ls -l` shows `rwxrwsr-x`), it means SetGID is enabled.
- Effect (on executable files): The process executes with the group ID of the **file's group owner**, not the user's primary group.
- Effect (on directories): 
    - Files created *within* this directory inherit the group ownership of the directory itself, regardless of the creator's primary group.
    - Subdirectories created within this directory automatically inherit the SetGID bit.
    - Useful for shared directories where files created by different users need consistent group ownership for collaboration.

**Sticky Bit**:
- When set on a directory, it restricts file deletion/renaming
- Only the file owner, directory owner, or root can delete/rename files
- Other users with write permissions cannot delete files they don't own

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

**Inode**:
- Stores metadata about files (permissions, owner, size, data block locations, etc.) but **not the filename**.
- Filename is stored in directory entries that point to inodes.
- Filesystems have a finite number of inodes.

**Hard Links vs. Symbolic (Soft) Links**:
*   **Hard Link (`ln target link_name`)**:
    *   Creates another directory entry (filename) pointing directly to the **same inode** as the original file.
    *   All hard links share the same inode, meaning they share the same metadata (permissions, owner, etc.).
    *   Changing permissions via one hard link instantly affects all others (because the shared inode is modified).
    *   **Must** reside on the **same filesystem** as the original file/inode.
    *   The actual file data (inode) is deleted only when the link count (number of hard links pointing to it) drops to zero.
    *   Cannot link to directories (usually).
*   **Symbolic Link (`ln -s target link_name`)**:
    *   Creates a **new file** with its **own inode**.
    *   The *data* of this new file is simply the **text path** to the target file or directory.
    *   Acts like a shortcut.
    *   **Can** cross filesystem boundaries (because it stores a path).
    *   If the target is deleted or moved, the symbolic link becomes "broken".
    *   Permissions of the symbolic link itself are usually irrelevant; permissions of the *target* file are checked when accessed via the link.
    *   Deleting the symbolic link does not affect the target.
    *   Can link to directories.

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

**Displaying IP Addresses (`ip a`)**:
- `ip a` (or `ip address show`) → Shows details about all network interfaces on the system, including their IP addresses (IPv4 and IPv6), MAC addresses, and status.

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

*   **Editing Sudo Configuration (`sudo visudo`)**: 
    *   The command `sudo visudo` is the **recommended and safest way** to edit the main sudo configuration file (`/etc/sudoers`).
    *   It locks the sudoers file to prevent simultaneous edits and performs syntax checking before saving changes, preventing you from locking yourself out due to errors.
    *   It's generally preferred to add custom rules in separate files under `/etc/sudoers.d/` rather than editing the main `/etc/sudoers` file directly. Use `sudo visudo -f /etc/sudoers.d/<your_rule_file>` to safely edit these files.

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