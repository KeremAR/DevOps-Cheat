# Linux Study Notes

## Table of Contents
- [Linux Introduction](#linux-introduction)
  - [Why Should You Learn about Linux?](#why-should-you-learn-about-linux)
  - [What Makes Linux Great?](#what-makes-linux-great)
  - [What Is a Linux Distribution?](#what-is-a-linux-distribution)
  - [Shell](#shell)
  - [File Systems](#file-systems)
  - [Linux File System and Key Directories](#linux-file-system-and-key-directories)
  - [Disk and Device Naming](#disk-and-device-naming)
  - [Linux Case Sensitivity](#linux-case-sensitivity)
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
  - [Hard Links vs. Symbolic (Soft) Links](#hard-links-vs-symbolic-soft-links)
  - [SELinux](#selinux)
- [LVM (Logical Volume Manager)](#lvm-logical-volume-manager)
- [SWAP](#swap)
- [Monitoring, Processes Control, Logs](#monitoring-processes-control-logs)
  - [Process Monitoring](#process-monitoring)
  - [Monitoring CPU](#monitoring-cpu)
  - [Monitoring Memory](#monitoring-memory)
  - [Monitoring Storage](#monitoring-storage)
  - [Logs](#logs)

## Linux Introduction

### Why Should You Learn about Linux?

Linux is a critical, widespread technology used in everything from web servers and supercomputers to cloud infrastructure and IoT devices. It powers the internet, stock markets, smart TVs, and the top 500 supercomputers. It is predominant in modern data centers alongside Windows. Learning it is essential for interoperability, application development, cloud computing, and career growth due to high demand.

### What Makes Linux Great?

Linux is great because it is open source, provides a powerful command-line interface (CLI) for automation, and is modular by design. Being open source allows transparency and faster innovation. The CLI enables easy automation and remote administration. Its modularity allows it to be anything from a full workstation to a minimized appliance.

### What Is a Linux Distribution?

A Linux distribution is a complete, installable operating system constructed from the Linux kernel combined with supporting user programs and libraries. It solves the challenge of assembling independent components (Kernel, GNU utilities, X Window System, etc.) into a working system. Distributions provide installation methods, software management, and support.

Common examples include:
- **RPM-based**: RHEL, CentOS, Fedora (use YUM/DNF package manager)
- **Debian-based**: Ubuntu, Debian, Kali Linux, Linux Mint (use APT package manager)

### Shell

The shell is the command-line interface that interprets user commands. Common shells include Bash, Zsh, and others.

To check which shell you're currently using:
```bash
echo $SHELL
```

### File Systems

**Linux File Systems: A Comparison**

While there are many Linux file systems, the most common choices for modern systems are ext4, Btrfs, XFS, and ZFS. Each has distinct features suited for different use cases.

- **ext4 (Fourth Extended Filesystem)**
  - **Role:** The default, most widely used, and most stable filesystem for the majority of Linux distributions. It is the successor to ext3.
  - **Key Features:**
    - **Journaling:** Protects against data corruption from crashes by keeping a log (journal) of changes before they are committed.
    - **Stability & Maturity:** Extremely well-tested and reliable. It's the "it just works" choice for desktops and servers.
    - **Good All-Round Performance:** Performs well for a wide variety of workloads, from small files to large ones.
  - **Best For:** General purpose use on desktops, laptops, and application servers where advanced features like snapshots are not a primary requirement.

- **Btrfs (B-tree File System)**
  - **Role:** A modern, feature-rich filesystem designed to address the limitations of older filesystems. Often seen as a "next-generation" choice.
  - **Key Features:**
    - **Copy-on-Write (CoW):** Instead of overwriting data, changes are written to a new location. This is the foundation for its other features.
    - **Snapshots:** Create near-instant, low-space "copies" of the filesystem state. Excellent for backups and safe system updates (you can roll back if something breaks).
    - **Data Integrity:** Uses checksums on data and metadata to detect and report corruption.
    - **Built-in RAID & Volume Management:** Can manage multiple disks in various RAID configurations without needing `mdadm` or LVM.
    - **Transparent Compression:** Can compress files on the fly to save space.
  - **Best For:** Systems where data integrity, snapshots for backups/rollbacks, and flexible volume management are critical. Popular with Arch Linux users and on some NAS devices.

- **XFS (XFS File System)**
  - **Role:** A high-performance 64-bit journaling filesystem created by SGI, now common in enterprise Linux distributions (like RHEL and its derivatives).
  - **Key Features:**
    - **Excellent Large File Performance:** Highly optimized for handling very large files and large filesystems (terabytes to petabytes).
    - **Parallel I/O:** Designed for high concurrency, making it very fast in multi-threaded, parallel I/O operations.
    - **Efficient Metadata Handling:** Scales well as the number of files grows.
  - **Best For:** Enterprise servers, media storage, scientific computing, and any workload involving very large files or high-performance needs.

- **ZFS (Zettabyte File System)**
  - **Role:** A combined filesystem and logical volume manager with an extreme focus on data integrity. Originally from Sun Microsystems, it's available on Linux via the OpenZFS project.
  - **Key Features:**
    - **Unyielding Data Integrity:** Its primary design goal. Uses end-to-end checksums to detect and, if configured with redundancy (RAID-Z), automatically repair "silent" data corruption.
    - **Copy-on-Write (CoW), Snapshots, and Clones:** Similar to Btrfs, it offers powerful snapshotting capabilities.
    - **Built-in RAID (RAID-Z):** Provides a more robust implementation of RAID-5/6 that avoids the "write hole" problem.
    - **Licensing:** Its CDDL license is incompatible with the GPL license of the Linux kernel, so it is not included by default and must be installed separately.
  - **Best For:** Mission-critical data storage, NAS builds, servers, and any environment where protecting data from corruption is the absolute top priority.

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

**Shell Initialization Files**:
- Files executed when a shell session starts, used to set up the user environment (aliases, functions, environment variables, PATH).
- **Login Shells (e.g., SSH login, console login):**
  - `/etc/profile`: System-wide, executed first for all users.
  - `~/.bash_profile`, `~/.bash_login`, `~/.profile`: User-specific, executed in this order; only the first one found is read by Bash.
- **Non-Login Interactive Shells (e.g., opening a new terminal window):**
  - `~/.bashrc`: User-specific, typically executed for every interactive shell.
- **Common Practice:** `~/.bash_profile` often sources `~/.bashrc` (e.g., `if [ -f ~/.bashrc ]; then . ~/.bashrc; fi`) so settings are consistent between login and non-login shells.
- **PATH Variable:** An environment variable listing directories the shell searches for executable commands. Modify it in initialization files (e.g., `export PATH="$PATH:/usr/local/bin"`).

### Basic Shell Commands

**Creating Directories (`mkdir`)**:
- `mkdir [OPTIONS] DIRECTORY...`
- `mkdir new_dir` → Creates a directory named `new_dir`.
- `mkdir -p /tmp/1/2/3/4/5/6/7/8/9` → Creates the directory `/tmp/1/2/3/4/5/6/7/8/9`. The `-p` flag ensures that all necessary parent directories (`/tmp/1`, `/tmp/1/2`, etc.) are created automatically if they don't already exist.

**Manual Pages (`man`)**:
- `man [command_name]` → Displays the manual page (documentation) for a specific command, providing detailed information about its usage, options, and examples. Press `q` to exit the man page viewer.

**Searching Manual Pages (`apropos`)**:
- `apropos [keyword]` → Searches the names and short descriptions of manual pages for a specific keyword. Useful when you don't know the exact command name but know what it does.

**Commands That Overwrite a Target File Without Prompting**:
- `cp source_file target_file`
- `mv source_file target_file`
- `mv -f source_file target_file`
- `cat file1 > file2` → Writes the content of `file1` into `file2`, overwriting any existing content.

**Copying Files and Directories (`cp`)**:
- `cp [OPTIONS] SOURCE DESTINATION`
- `cp file1 file2` → Copies `file1` to `file2`.
- `cp file1 dir1/` → Copies `file1` into directory `dir1`.
- `cp -r dir1 dir2` → Recursively copies directory `dir1` and its contents into directory `dir2`.
- `cp -a SOURCE DESTINATION` → Archive copy. Copies recursively (`-r`), preserves links (`-d`), and preserves all attributes like permissions, ownership, timestamps (`--preserve=all`). Useful for backups.

**Moving/Renaming Files and Directories (`mv`)**:
- `mv [OPTIONS] SOURCE DESTINATION`
- `mv oldname newname` → Renames `oldname` to `newname`.
- `mv file1 dir1/` → Moves `file1` into directory `dir1`.
- `mv /home/bob/lfcs/* /home/bob/new-data/` → Moves all files and directories (`*` wildcard) from inside `/home/bob/lfcs/` to `/home/bob/new-data/`.

**Input/Output (I/O) Redirection**:
- Controls where a command's input comes from and where its output goes.
- **Standard Streams:**
  - `stdin` (Standard Input, file descriptor 0): Default input source (usually keyboard).
  - `stdout` (Standard Output, file descriptor 1): Default output destination (usually screen).
  - `stderr` (Standard Error, file descriptor 2): Default destination for error messages (usually screen).
- **Redirection Operators:**
  - `>`: Redirect `stdout` to a file (overwrites existing file).
    - `ls -l > file_list.txt`
  - `>>`: Redirect `stdout` to a file (appends to existing file).
    - `echo "Log message" >> system.log`
  - `<`: Redirect `stdin` from a file.
    - `sort < unsorted_list.txt`
  - `2>`: Redirect `stderr` to a file.
    - `find / -name "*.conf" 2> find_errors.log`
  - `&>` or `2>&1`: Redirect both `stdout` and `stderr` to the same file.
    - `make &> build.log` (Bash shortcut)
    - `updatedb > update.log 2>&1` (POSIX compliant)
  - `|` (Pipe): Redirect `stdout` of one command to `stdin` of another.
    - `ps aux | grep sshd | sort -k3`
  - `<<<` (Here String): Redirect a string directly to `stdin`.
    - `bc <<< "5 * 4"` (outputs 20)
  - `<<DELIMITER` (Here Document): Redirect multiple lines to `stdin` until `DELIMITER` is found (See `tee` example further down).

**Deleting Files and Directories (`rm`)**:
- `rm [OPTIONS] FILE...`
- `rm file1` → Deletes `file1`.
- `rm -r directory1` → Recursively deletes directory `directory1` and its contents (prompts for confirmation usually).
- `rm -rf directory1` → Forcefully (`-f`) and recursively (`-r`) deletes directory `directory1` and its contents **without prompting**. **Use with extreme caution!**

**Viewing Files (`less`)**:
- `less [filename]` → A pager used to view text files or command output one screenful at a time.
- Allows navigation (Space/Enter/Arrows to scroll, `g`/`G` to go to start/end), searching (`/keyword`), and doesn't load the entire file into memory.
- Commonly used with pipes: `ls -l | less`.
- Press `q` to quit.

**Viewing File Content (`head` and `tail`)**:
- The `head` and `tail` commands display the beginning and the end of a file, respectively.
- By default, these commands display 10 lines of the file.
- Both have a `-n` option to specify a different number of lines.
- `head -n 5 file.txt` → Displays the first 5 lines of `file.txt`.
- `tail -n 20 file.txt` → Displays the last 20 lines of `file.txt`.

**Counting Lines, Words, and Characters (`wc`)**:
- The `wc` command counts lines, words, and characters in a file.
- `wc -l file.txt` → Displays only the number of lines.
- `wc -w file.txt` → Displays only the number of words.
- `wc -c file.txt` → Displays only the number of characters.

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
- `egrep   'http[^s]' file.txt` → Uses `egrep` to search `file.txt` for lines containing 'http' **not** immediately followed by an 's' (using `[^s]` negated character set), useful for finding non-HTTPS URLs.
- `egrep -w '[A-Z][a-z]{2}' /etc/nsswitch.conf > /home/bob/filtered1` → Uses `egrep` to find lines in `/etc/nsswitch.conf` containing **whole words (`-w`)** that start with one uppercase letter `[A-Z]` followed by exactly two lowercase letters `[a-z]{2}` (e.g., "Tcp", "Dns"). The matching lines are **redirected (`>`)** to the file `/home/bob/filtered1`.
- `grep -c '^2' textfile > /home/bob/count` → **Counts (`-c`)** the number of lines in `textfile` that **start (`^`)** with the digit '2'. The resulting count (a number) is **redirected (`>`)** and saved to the file `/home/bob/count`.

**AWK Command (`awk`)**:
- `awk` is a powerful pattern scanning and processing language, particularly useful for working with column-based or field-separated text data.
- It processes input line by line, splitting each line into fields based on a delimiter.
- **Basic Syntax:** `awk [options] 'pattern { action }' filename`
- **Example (Provided): Extract Usernames**
  ```bash
  awk -F ":" '{print $1}' /etc/passwd
  ```
  *   `-F ":"`: Sets the **Field Separator** to a colon (`:`). `/etc/passwd` uses colons to separate fields.
  *   `'{print $1}'`: This is the **action** block. For every line in the input file:
      *   `$1` refers to the **first field** (the username in `/etc/passwd`).
      *   `print $1` prints the value of the first field to standard output.
  *   `/etc/passwd`: The input file to process.

- **Example: Extract Shell Names**
  ```bash
  awk -F "/" '/^\// {print $NF}' /etc/shells | uniq
  ```
  *   `-F "/"`: Sets the field separator to a forward slash (`/`).
  *   `'/^\//'`: This is the **pattern**. It selects only lines that **start with** a forward slash (`^\/`). (The `\` escapes the `/` because `/` also delimits the pattern).
  *   `{print $NF}`: This is the **action** executed for matching lines.
      *   `NF` is a built-in variable holding the **N**umber of **F**ields on the current line.
      *   `$NF` refers to the value of the **last field**.
  *   `/etc/shells`: The input file.
  *   `| uniq`: The output of `awk` (the list of shell names) is **piped (`|`)** to the `uniq` command. `uniq` removes adjacent duplicate lines, ensuring each unique shell name appears only once in the final output.
  *   **Purpose:** For lines in `/etc/shells` starting with `/`, this command extracts the shell name (last part of the path) and then filters the list to show only the unique shell names available.

- **Example: Temperature Conversion (Celsius)**
  ```bash
  # Assumes temps.csv has lines like "Header,Unit" and then "77,F" or "25,C"
  # Might need -F ',' if the file is strictly comma-separated without spaces
  awk 'NR==1; NR>1 {print ($2=="F" ? ($1-32)/1.8 : $1)" C"; }' temps.csv
  ```
  *   This command processes `temps.csv`, assuming the first column is temperature and the second is unit ('F' or 'C').
  *   It uses two pattern-action blocks separated by a semicolon `;`.
  *   **`NR==1;`**: 
      *   `NR` is the current line number.
      *   This pattern matches only the first line (`NR==1`).
      *   No action is specified, so the default action `print $0` (print the whole line) is executed, effectively printing the header.
  *   **`NR>1 {print ($2=="F" ? ($1-32)/1.8 : $1)" C"; }`**:
      *   This pattern matches all lines *after* the first (`NR>1`).
      *   The action `{...}` is executed for these lines:
      *   `($2=="F" ? ($1-32)/1.8 : $1)`: This is a ternary operator.
          *   It checks if the second field (`$2`) is exactly `"F"`.
          *   If true, it calculates Celsius: `($1-32)/1.8`.
          *   If false, it assumes the temperature (`$1`) is already Celsius.
      *   `... " C"`: The calculated Celsius value is concatenated with the string `" C"`.
      *   `print ...`: The final string (e.g., `"25 C"`) is printed.
  *   **Purpose:** To read a file of temperatures, print the header row, and convert all subsequent temperature values to Celsius, displaying them with a " C" suffix.

**Stream Editor (`sed`)**:
- `sed` is a powerful stream editor for filtering and transforming text, often used for find-and-replace operations.
- Basic substitution: `sed 's/old/new/g' filename` → Replaces all (`g`) occurrences of 'old' with 'new' in each line of `filename` and prints the result to standard output.
- In-place editing (modifies the file): `sed -i 's/old/new/g' filename` (Use `-i` with caution).
- Range and case-insensitive replace: `sed -i '500,2000 s/enabled/disabled/gi' filename` → Edits file in-place (`-i`), replacing all (`g`) occurrences of 'enabled' (case-insensitive `i`) with 'disabled' only on lines **between 500 and 2000** inclusive.

**Tee Command (`tee`)**:
- `tee` reads from standard input and writes to *both* standard output and one or more files.
- Useful for capturing the output of a command to a file while still seeing it on the screen.
- `ls -l | tee file_list.txt` → Lists files (`ls -l`), displays the list on the screen, and saves the same list to `file_list.txt`.
- `echo "Important Line" | sudo tee -a /var/log/important.log` → Appends (`-a`) the text "Important Line" to the specified log file (requires `sudo` for system logs) and also displays it.
- Often used with here-documents to write blocks of text to files non-interactively:
  ```bash
  sudo tee /etc/someconfig.conf > /dev/null <<'EOF'
  ConfigSetting1=Value1
  ConfigSetting2=Value2
  EOF
  ```
  *   `> /dev/null`: Redirects the standard output copy to prevent it from showing on the terminal.
  *   `<<'EOF' ... EOF`: Here-document providing input to `tee`.

**Comparing Files (`diff`)**:
- `diff [OPTIONS] file1 file2` → Compares two files line by line and shows the differences.
- Output indicates lines that need to be added (`>`), deleted (`<`), or changed (`c`) to make `file1` identical to `file2`.
- Useful for tracking changes between file versions.

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

To enable a service to start automatically at boot:
```bash
sudo systemctl enable httpd
```
This creates the necessary symbolic links in systemd's target directories.

To both enable and start a service immediately:
```bash
sudo systemctl enable --now httpd
```
This performs the enable action and then immediately starts the service in the current session.

To check the status of a service (running, stopped, failed):
```bash
sudo systemctl status httpd
```

To stop a service:
```bash
sudo systemctl stop httpd
```

To restart a service (stop then start):
```bash
sudo systemctl restart httpd
```

To disable a service from starting automatically at boot:
```bash
sudo systemctl disable httpd
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

**Editing Cron Jobs (`crontab -e`)**:
- Each user (including root) can have their own crontab file listing scheduled jobs.
- `crontab -e` → Opens the current user's crontab file in the default text editor (often `vi` or `nano`). Requires `sudo crontab -e` to edit root's crontab.
- `crontab -l` → Lists the current user's scheduled cron jobs.
- `crontab -r` → Removes the current user's entire crontab file (use with caution!).
- **Crontab Format:** Each line represents a job and has 6 fields:
  ```
  # ┌───────────── minute (0 - 59)
  # │ ┌───────────── hour (0 - 23)
  # │ │ ┌───────────── day of month (1 - 31)
  # │ │ │ ┌───────────── month (1 - 12)
  # │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday=0 or 7)
  # │ │ │ │ │
  # │ │ │ │ │
  # * * * * *  command_to_execute
  ```
- **Examples:**
  - `0 2 * * * /usr/local/bin/backup.sh` → Run `backup.sh` at 2:00 AM every day.
  - `*/15 * * * * /path/to/script.sh` → Run `script.sh` every 15 minutes.
  - `0 8 * * 1-5 /path/to/morning_report.sh` → Run `morning_report.sh` at 8:00 AM every weekday (Monday to Friday).

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

**Creating a System Account**:
- `sudo useradd -r apachedev` → Creates a system account named `apachedev`. System accounts (`-r`) typically get UIDs in a lower range, no home directory created by default, and are intended for running services, not for user logins.

**Pros and Cons of System Accounts**:
*   **Pros (Advantages):**
    *   **Security (Least Privilege):** Significantly enhances security. If a service running under a system account is compromised, the attacker only gains the limited privileges of that account, not root or a regular user's access. This limits potential damage.
    *   **Isolation:** Prevents services from interfering with each other's files or configurations.
    *   **Resource Management:** Allows for tracking and potentially limiting resource usage (CPU, memory) per service.
    *   **Organization:** Provides a clear separation between background system processes and interactive user sessions.
*   **Cons (Disadvantages):**
    *   **Management Overhead:** Requires administrators to create and manage these additional accounts.
    *   **Permission Complexity:** Setting up the precise minimal permissions needed by a service can sometimes be complex.
    *   **Troubleshooting:** Debugging permission-related issues for services can occasionally be more involved than if they ran as root (though the security benefit usually outweighs this).

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
- `sudo usermod -e "" USERNAME` → Removes any previously set account expiration date, making the account non-expiring.

**Unlocking an Account (`passwd -u`)**:
- While `usermod -U` works, `passwd -u` is also commonly used specifically for unlocking.
- `sudo passwd -u USERNAME` → Unlocks the specified user account (removes the `!` or `*` preceding the encrypted password in `/etc/shadow`).

**Removing a User from a Group (`gpasswd`)**:
- `sudo gpasswd -d USERNAME GROUPNAME` → Removes the specified USERNAME from the specified GROUPNAME (must be a supplementary group).

**Modifying a Group (`groupmod`)**:
- `groupmod` is used to modify existing group details.
- `sudo groupmod -n NEW_GROUPNAME OLD_GROUPNAME` → Renames an existing group. keeping the same GID
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
- Prompts interactively for the new password.
- **Non-interactive password setting:**
```bash
echo 'NewPassword123' | sudo passwd --stdin username
```
- Sets the password for `username` to `NewPassword123` directly from standard input. Useful for scripting, but be mindful of command history security.

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

**Switching Users (`su`)**:
- `su` (substitute user) allows you to start a new shell session as a different user.
- `su - <username>` or `su -l <username>`: Starts a **login shell** as `<username>`. This means:
  - You'll be prompted for `<username>`'s password (unless PAM is configured otherwise, e.g., `pam_wheel.so trust`).
  - The environment will be set up as if `<username>` logged in directly (reads `/etc/profile`, `~/.bash_profile`, etc.).
  - The current directory changes to `<username>`'s home directory.
  - `-` or `-l` or `--login` are crucial for a clean environment.
- `su <username>` (without `-`): Starts a shell as `<username>` but **keeps the original user's environment variables** (like `$PATH`, `$HOME`) and **stays in the current directory**. This can lead to unexpected behavior and is generally discouraged for administrative tasks.
- `su -` or `su -l` (no username specified): Switches to the `root` user (requires root password).
- `exit`: Type `exit` to close the `su` shell session and return to your original user.
- **`su` vs `sudo`:**
  - `sudo` executes a *single command* as another user (usually root) after authenticating with *your own* password (if configured in `/etc/sudoers`). Preferred for most administrative tasks.
  - `su` starts a *new interactive shell* as another user, requiring *their* password (typically root's). Less commonly needed than `sudo`.

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

Example rule (Group):
```
%salesteam ALL=(ALL) ALL
```

This means:
- `%salesteam`: The rule applies to all users in the `salesteam` group (the `%` denotes a group).
- `ALL=`: Applies to all machines.
- `(ALL)`: Can run commands as any user (typically meaning as root).
- `ALL`: Can run **any** command.

This means:
- `student`: User the rule applies to
- `ALL=`: Applies to all machines

---

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

### Hard Links vs. Symbolic (Soft) Links

You can create multiple names (links) for the same file.

**1. Hard Links (`ln target link_name`)**
- **Concept:** A hard link is just another name for the same file data. It points directly to the same **inode**.
- **Key Characteristics:**
  - Indistinguishable from the original file (share the same inode number).
  - Share all metadata (permissions, ownership, timestamps). Changing one affects all.
  - Data remains accessible as long as at least one hard link exists.
  - **Limitations:** Cannot link to directories. Cannot cross file systems (must be on the same partition).
- **Verification:**
  - `ls -l`: Check the link count (2nd column). If > 1, the file has hard links.
  - `ls -i`: Check inode numbers. Identical numbers mean they are hard links to the same file.

**2. Symbolic (Soft) Links (`ln -s target link_name`)**
- **Concept:** A special file that points to another file's **path** (like a shortcut). It has its own unique inode.
- **Key Characteristics:**
  - Can link to directories and cross file systems.
  - `ls -l` shows file type `l` and points to the target (`link -> target`).
  - If the target is deleted, the link becomes "dangling" (broken).
  - `cd symlink_to_dir` enters the directory but keeps the symlink name in the path. Use `cd -P` to resolve to the physical path.

**Comparison Summary:**
- **Hard Link:** Points a name to data. (Resilient to original deletion).
- **Soft Link:** Points a name to another name. (Fragile if target moves/deletes).

**Default File Permissions (`umask`)**:
- `umask` (user file-creation mode mask) controls the default permissions set on newly created files and directories.
- It represents the permissions that should be **removed** from the base permissions (666 for files, 777 for directories).
- `umask` → Displays the current mask in octal format (e.g., `0022`).
- `umask -S` → Displays the current mask in symbolic format (e.g., `u=rwx,g=rx,o=rx`).
- **Calculation Example (mask=0022):**
  - Files: Base=666 (`rw-rw-rw-`). Mask=022 (`----w--w-`). Result=644 (`rw-r--r--`).
  - Dirs: Base=777 (`rwxrwxrwx`). Mask=022 (`----w--w-`). Result=755 (`rwxr-xr-x`).
- **Setting the mask:**
  - `umask 0027` → Sets mask to remove write for group and all for others (results in 640 for files, 750 for dirs).
  - Usually set in shell initialization files (`~/.bashrc`, `/etc/profile`).

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

## LVM (Logical Volume Manager)

LVM allows for flexible disk space management by abstracting physical storage. Here's a practical example of setting up an LVM volume for a database team:

**Scenario:** Add an LVM volume using disks `/dev/vdb` and `/dev/vdc` for the Database team, mount it persistently at `/mnt/dba_storage`, and configure permissions for the `dba_users` group.

**Steps:**

1.  **Install LVM Packages (if needed):**
    *   Ensures the necessary LVM tools are available (CentOS/RHEL example).
    ```bash
    sudo yum install -y lvm2
    # Or on newer Fedora/CentOS:
    # sudo dnf install -y lvm2
    ```

2.  **Create Physical Volumes (PVs):**
    *   Marks the physical disks as available for LVM.
    ```bash
    sudo pvcreate /dev/vdb /dev/vdc
    ```
    *   Verify with `sudo pvs`. 

3.  **Create Volume Group (VG):**
    *   Combines the PVs into a single storage pool named `dba_storage`.
    ```bash
    sudo vgcreate dba_storage /dev/vdb /dev/vdc
    ```
    *   Verify with `sudo vgs`.

4.  **Create Logical Volume (LV):**
    *   Creates a logical volume named `volume_1` from the `dba_storage` VG, using all available space.
    ```bash
    # The -l 100%FREE flag uses all available extents in the VG
    sudo lvcreate -l 100%FREE -n volume_1 dba_storage
    ```
    *   The device path will be `/dev/dba_storage/volume_1` or `/dev/mapper/dba_storage-volume_1`.
    *   Verify with `sudo lvs`.

5.  **Format the Logical Volume (XFS Filesystem):**
    *   Creates an XFS filesystem on the new LV.
    ```bash
    sudo mkfs.xfs /dev/dba_storage/volume_1
    ```

6.  **Create the Mount Point Directory:**
    *   Creates the directory where the filesystem will be mounted.
    ```bash
    sudo mkdir -p /mnt/dba_storage
    ```

7.  **Make the Mount Persistent (`/etc/fstab`):**
    *   **a. Get the UUID:** Find the unique identifier for the new filesystem.
        ```bash
        sudo blkid /dev/dba_storage/volume_1
        ```
        *Copy the UUID value (e.g., `UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"`)*
    *   **b. Add Entry to `/etc/fstab`:** Use the UUID to ensure the correct device is mounted even if device names change. Replace `<UUID_FROM_BLKID>` with the actual UUID.
        ```bash
        # Edit using a text editor like nano or vi:
        # sudo nano /etc/fstab
        # Add the following line:
        UUID=<UUID_FROM_BLKID>  /mnt/dba_storage  xfs  defaults  0 0
        
        # Or append using echo/tee (ensure correct syntax):
        # echo 'UUID=<UUID_FROM_BLKID>  /mnt/dba_storage  xfs  defaults  0 0' | sudo tee -a /etc/fstab
        ```
        *   `/etc/fstab` fields: `<Device/UUID> <Mount Point> <FS Type> <Options> <Dump> <Pass>`.
        *   `defaults`: Standard mount options.
        *   `0 0`: No dump, no filesystem check on boot (XFS handles checks differently).
    *   **c. Reload Systemd:** Inform systemd about the `/etc/fstab` changes.
        ```bash
        sudo systemctl daemon-reload
        ```

8.  **Mount the Filesystem:**
    *   Mounts the filesystem based on the new `/etc/fstab` entry.
    ```bash
    sudo mount -a
    # Or specifically:
    # sudo mount /mnt/dba_storage
    ```
    *   Verify with `df -h` or `mount | grep dba_storage`.

9.  **Create the Group:**
    ```bash
    sudo groupadd dba_users
    ```

10. **Add User to the Group:**
    ```bash
    sudo usermod -aG dba_users bob
    ```
    *   Verify with `groups bob`.

11. **Set Ownership and Permissions on Mount Point:**
    *   Allow the `dba_users` group to write to the mounted volume.
    ```bash
    # Set group ownership
    sudo chgrp dba_users /mnt/dba_storage
    
    # Set permissions (Owner=rwx, Group=rwx, Others=---)
    sudo chmod 770 /mnt/dba_storage
    ```

**Important Notes:**
- Always use UUIDs in `/etc/fstab` for reliability.
- Remember to resize the filesystem (e.g., `xfs_growfs`) if you later extend the Logical Volume.

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

## Monitoring, Processes Control, Logs

### Process Monitoring

**Zombie Process**:
- Completed process not removed from the process table
- Can be removed by killing the parent process or using wait()
- Zombies do not consume CPU or memory

**Listing Processes (`ps`)**:
- `ps` displays information about running processes.
- **Common Options:**
  - `ps aux`: BSD-style, shows processes for *all* users (`a`), including those without a controlling terminal (`x`), in user-oriented format (`u`).
  - `ps ef`: System V-style, shows *every* process (`e`) in full format (`f`).
  - `ps -ejH`: Shows processes in a hierarchy (tree view).
  - `ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%cpu`: Custom format (`-eo`) showing specific fields and sorting by CPU usage (descending).

**Sending Signals (`kill`, `pkill`, `killall`)**:
- Signals are used to communicate with processes (e.g., to terminate, reload configuration).
- **Common Signals:**
  - `1` or `SIGHUP`: Hangup (often used to reload configuration).
  - `9` or `SIGKILL`: Force kill (use as last resort, process gets no chance to clean up).
  - `15` or `SIGTERM`: Terminate (default signal for `kill`, allows graceful shutdown).
- **Commands:**
  - `kill <PID>`: Sends SIGTERM (15) to the process with the specified Process ID (PID).
  - `kill -9 <PID>` or `kill -SIGKILL <PID>`: Sends SIGKILL (9) to the process.
  - `kill -1 <PID>` or `kill -SIGHUP <PID>`: Sends SIGHUP (1) to the process.
  - `pkill <process_name>`: Sends SIGTERM to all processes matching the name.
    - `pkill -f <pattern>`: Kills processes matching a full command line pattern.
    - `pkill -u <username>`: Kills processes owned by a specific user.
  - `killall <process_name>`: Similar to `pkill`, sends SIGTERM to processes by name (behavior can vary slightly between systems).

**Job Control (Interactive Shell)**:
- Managing processes started from the current shell.
- `command &`: Runs `command` in the background.
- `jobs`: Lists processes running in the background or stopped in the current shell session.
- `Ctrl+Z`: Suspends (stops) the currently running foreground process.
- `bg [%job_number]`: Resumes a stopped job in the background (e.g., `bg %1`). If no job number is given, uses the most recently stopped job.
- `fg [%job_number]`: Brings a background or stopped job to the foreground (e.g., `fg %1`). If no job number is given, uses the most recently backgrounded/stopped job.

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

### System Information & Hardware

**Viewing CPU Information (`lscpu`)**:
- `lscpu` → Displays detailed information about the CPU architecture, cores, threads, cache sizes, etc.

**Listing Block Devices (`lsblk`)**:
- `lsblk` → Lists information about all available block devices (disks, partitions, LVM volumes) and their mount points in a tree-like format.
  - `lsblk -f`: Includes filesystem type and UUID information.

**Listing PCI Devices (`lspci`)**:
- `lspci` → Lists all PCI buses and devices connected to them (e.g., network cards, graphics cards, controllers).
  - `lspci -v`: Provides more verbose output.
  - `lspci -k`: Shows kernel drivers handling each device.

**Listing USB Devices (`lsusb`)**:
- `lsusb` → Lists all USB hubs and devices connected to them.
  - `lsusb -v`: Provides more verbose output.

**Kernel Messages (`dmesg`)**:
- `dmesg` → Prints the kernel ring buffer messages. Very useful for troubleshooting hardware detection issues, driver errors, or boot problems.
  - `dmesg | less`: View messages page by page.
  - `dmesg -T`: Include human-readable timestamps.
  - `dmesg -f kern`: Filter for kernel-level messages.
  - `dmesg --follow`: Continuously display new messages.

### Log Management

**Systemd Journal (`journalctl`)**:
- Modern Linux systems using systemd store logs in a structured binary journal.
- `journalctl` → Displays the entire journal (usually starting with oldest entries).
- `journalctl -n 20` → Shows the last 20 journal entries.
- `journalctl -f` → Follows the journal, showing new entries in real-time (like `tail -f`).
- `journalctl -u <service_name>` → Shows logs for a specific systemd unit (e.g., `journalctl -u sshd`).
- `journalctl --since "yesterday"` → Shows logs since yesterday.
- `journalctl --since "2 hours ago"` → Shows logs from the last 2 hours.
- `journalctl -p err` → Shows logs with priority "error" or higher (err, crit, alert, emerg).
- `journalctl _PID=<PID>` → Shows logs for a specific process ID.

**Following Text Logs (`tail -f`)**:
- For traditional text log files (often in `/var/log`).
- `tail -f /var/log/syslog` → Continuously displays new lines added to `/var/log/syslog`.
- `tail -n 50 -f /var/log/nginx/access.log` → Displays the last 50 lines and then follows the Nginx access log.