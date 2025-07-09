

### Changing Your DNS for Better Speed, Privacy, and Security

#### What is DNS?
DNS (Domain Name System) is the **internet's phonebook**, translating human-readable domain names (e.g., `example.com`) into IP addresses (e.g., `192.168.1.1`). Every time you visit a website, your device queries a DNS server to resolve the domain into an IP address.

Without DNS, we would need to remember IP addresses instead of human-readable domain names.


### What is TLS/SSL?

**TLS (Transport Layer Security)** is a cryptographic protocol designed to provide secure communication across a computer network. It is the modern standard used in `HTTPS` and other secure protocols. SSL (Secure Sockets Layer) is its predecessor; today, the terms are often used interchangeably, but modern systems use TLS.

Its main goals are:
- **Encryption:** Makes data unreadable to eavesdroppers.
- **Authentication:** Verifies the server's identity using a TLS certificate.
- **Integrity:** Ensures data is not tampered with during transit.

### How the TLS Handshake Works

The handshake establishes a secure session in four main steps:

1.  **Negotiation:** The client and server agree on the TLS version (e.g., TLS 1.3) and the **cipher suite** (the set of encryption algorithms) to use.
2.  **Authentication:** The server proves its identity to the client by sending its TLS certificate, which is verified by a trusted Certificate Authority (CA).
3.  **Key Exchange:** Using the server's public key, the client and server securely generate and share a temporary **session key**.
4.  **Secure Communication:** Both parties use this session key to encrypt all further communication for the duration of the session.

### TLS Security Best Practices

- **Automate Certificate Renewal:** Use tools like Let's Encrypt to prevent outages from expired certificates.
- **Use Modern Versions:** Configure servers to use only secure protocols like **TLS 1.2** and **TLS 1.3**.
- **Disable Insecure Protocols:** Actively disable old versions like **TLS 1.0, 1.1, and all SSL versions**.
- **Use Strong Cipher Suites:** Regularly update configurations to use strong, modern ciphers and remove weak ones.

### How to Divide a Network into Subnets? What is /24? What is 255.255.255.0?

#### Understanding Subnetting
A **subnet (sub-network)** is a logically segmented portion of a larger network. Subnetting helps improve network organization, security, and efficiency by dividing a network into smaller, more manageable parts.

Each device on a network has an **IP address** consisting of two parts:
1. **Network portion** – Identifies the network.
2. **Host portion** – Identifies devices within the network.

#### CIDR Notation (`/24`)
CIDR (Classless Inter-Domain Routing) notation is a shorthand way of writing subnet masks. The `/24` means that the first **24 bits** of the IP address are used for the network, leaving the remaining **8 bits** for host allocation.

- Example: `192.168.1.0/24`
- The first 24 bits (`192.168.1.`) represent the **network part**.
- The last 8 bits (`.X`) represent the **host part**.

A `/24` subnet provides **256 total addresses** (from `192.168.1.0` to `192.168.1.255`), out of which:
- 1 address is reserved for the **network ID** (`192.168.1.0`).
- 1 address is reserved for the **broadcast address** (`192.168.1.255`).(Used to communicate with all hosts in the subnet. When a device sends a packet to the broadcast address, all devices in the subnet receive it. This is useful for network discovery and communication.)
- The remaining **254 addresses** can be assigned to devices.

#### What is `255.255.255.0`?
A **subnet mask** determines which portion of an IP address represents the network and which part represents the host.

##### Subnet Mask Breakdown
- `255.255.255.0` in **binary**:
  `11111111.11111111.11111111.00000000`
- The **1s (255)** represent the **network portion**.
- The **0s (0)** represent the **host portion**.

| **Subnet Mask** | **CIDR Notation** | **Hosts per Subnet** |
| --- | --- | --- |
| `255.255.255.0` | `/24` | 254 |
| `255.255.254.0` | `/23` | 510 |
| `255.255.252.0` | `/22` | 1022 |
| `255.255.0.0` | `/16` | 65,534 |

#### Subnetting Example
Imagine you have a **corporate network** (`192.168.0.0/16`) with thousands of devices. Instead of using one large subnet, you divide it into multiple `/24` subnets:

| **Subnet** | **Network Address** | **Range** | **Broadcast Address** |
| --- | --- | --- | --- |
| **Subnet 1** | `192.168.1.0/24` | `192.168.1.1 - 192.168.1.254` | `192.168.1.255` |
| **Subnet 2** | `192.168.2.0/24` | `192.168.2.1 - 192.168.2.254` | `192.168.2.255` |
| **Subnet 3** | `192.168.3.0/24` | `192.168.3.1 - 192.168.3.254` | `192.168.3.255` |

This structure helps in organizing departments (e.g., `IT`, `HR`, `Sales`), improving security (by isolating sensitive data), and reducing network congestion.

### DHCP (Dynamic Host Configuration Protocol)

DHCP is a network management protocol used to automatically assign essential TCP/IP configuration information to devices (clients) on a network. This simplifies network administration as manual configuration is not required for each device.

**Key information assigned by DHCP:**
- **IP Address:** A unique address for the device within the network.
- **Subnet Mask:** Defines the network portion and host portion of the IP address.
- **Default Gateway:** The router address used to reach external networks.
- **DNS Server Addresses:** Servers used to resolve domain names into IP addresses.

**How it Works (DORA):**
1.  **Discover:** A client device joining the network broadcasts a DHCP Discover message.
2.  **Offer:** Available DHCP servers respond with DHCP Offer messages, proposing IP configurations.
3.  **Request:** The client selects an offer and sends a DHCP Request message to that server.
4.  **Acknowledge (ACK):** The selected server confirms the lease with a DHCP Acknowledge message, finalizing the assignment for a specific duration (lease time).

### OSI Model (Open Systems Interconnection Model)

<img src="/Media/OSI-1.jpg" alt="osi" width="500"/>




The OSI Model is a conceptual framework used to understand and standardize the functions of a telecommunication or computing system in terms of network communication. It divides network communication into seven distinct layers. Each layer performs specific functions and relies on the layers below it.

**The 7 Layers of the OSI Model:**

1.  **Layer 1: Physical Layer**
    *   **Function:** Responsible for the physical transmission of raw data bits over a communication medium (e.g., cables, radio waves).
    *   **Concerns:** Voltage levels, pin layouts, cable specifications, data rates, hubs, repeaters, network adapters, host bus adapters.
    *   **PDU (Protocol Data Unit):** Bit

2.  **Layer 2: Data Link Layer**
    *   **Function:** Provides reliable data transfer across the physical link. Manages access to the physical medium, performs error detection and correction (for bits), and defines physical addressing (MAC addresses).
    *   **Concerns:** Framing, MAC addressing, flow control, error control (LLC, MAC sublayers). Switches operate at this layer.
    *   **PDU:** Frame

3.  **Layer 3: Network Layer**
    *   **Function:** Responsible for logical addressing (IP addresses), routing, and path determination across multiple networks. It determines the best path for data packets to travel from source to destination.
    *   **Concerns:** Packet forwarding, routing protocols (e.g., OSPF, BGP), IP addressing (IPv4, IPv6). Routers operate at this layer.
    *   **PDU:** Packet

4.  **Layer 4: Transport Layer**
    *   **Function:** Provides reliable or unreliable end-to-end data delivery between applications on different hosts. Manages segmentation, reassembly, flow control, and error recovery.
    *   **Concerns:** TCP (reliable, connection-oriented), UDP (unreliable, connectionless), port numbers, segmentation, acknowledgments.
    *   **PDU:** Segment (TCP) or Datagram (UDP)

5.  **Layer 5: Session Layer**
    *   **Function:** Establishes, manages, and terminates communication sessions between applications. Handles session synchronization and dialogue control.
    *   **Concerns:** Session establishment, maintenance, termination, authentication, authorization. Examples: NetBIOS, RPC.
    *   **PDU:** Data

6.  **Layer 6: Presentation Layer**
    *   **Function:** Translates data between the application layer and the network format. Handles data encryption, decryption, compression, and character encoding (e.g., ASCII, EBCDIC).
    *   **Concerns:** Data formatting, encryption (e.g., SSL/TLS often associated here, though it can span layers), data compression.
    *   **PDU:** Data

7.  **Layer 7: Application Layer**
    *   **Function:** Provides network services directly to end-user applications. It's the layer users interact with.
    *   **Concerns:** Protocols for specific applications like web browsing (HTTP/HTTPS), email (SMTP, POP3, IMAP), file transfer (FTP, TFTP), DNS.
    *   **PDU:** Data

**Mnemonic:** A common way to remember the layers (from 7 down to 1) is "**A**ll **P**eople **S**eem **T**o **N**eed **D**ata **P**rocessing".

**OSI Model and Linux:**

While the OSI model is conceptual, its layers can be broadly mapped to the Linux operating system architecture:
*   **Layers 7-5 (Application, Presentation, Session):** Generally operate within **Userspace**. Applications (like web browsers, email clients) and libraries handle these functions.
*   **Layers 4-2 (Transport, Network, Data Link):** Primarily handled by the **Kernel Space** networking stack. The kernel manages TCP/IP sockets, routing, packet filtering, and interfacing with network drivers.
*   **Layer 1 (Physical):** Corresponds to the **Hardware** (Network Interface Cards - NICs, cables, physical transceivers) managed by kernel drivers.

![ositcp](/Media/OSI-TCP-PNG)

### Network Configuration



**Network Manager Command Line Tool (`nmcli`)**:
- `nmcli` is the command-line interface for NetworkManager, commonly used on modern CentOS, RHEL, Fedora, and Ubuntu systems for managing network connections persistently.
- **Viewing Connections and Devices:**
  ```bash
  # List all network connection profiles
  nmcli con show

  # List active network connection profiles
  nmcli con show --active

  # List network devices and their status
  nmcli dev status
  ```
- **Modifying Connections:**
  *   Requires the **connection name** (from `nmcli con show`), which might differ from the device name.
  *   Names with spaces must be quoted.
  ```bash
  # Add an IP address to a connection (e.g., named "System eth1")
  sudo nmcli con mod "System eth1" +ipv4.addresses 10.0.0.50/24

  # Set the IPv4 gateway
  sudo nmcli con mod "System eth1" ipv4.gateway 192.168.1.1

  # Set DNS servers (overwrites existing)
  sudo nmcli con mod "System eth1" ipv4.dns "8.8.8.8 8.8.4.4"

  # Add a DNS server (appends to existing)
  sudo nmcli con mod "System eth1" +ipv4.dns 1.1.1.1

  # Set connection to auto-connect on boot
  sudo nmcli con mod "System eth1" connection.autoconnect yes
  ```
- **Applying Changes:**
  *   After modifying a connection, you often need to reactivate it.
  ```bash
  # Bring a connection down and then up (applies changes)
  sudo nmcli con down "System eth1" && sudo nmcli con up "System eth1"

  # Or, more simply, just bring it up (often sufficient)
  sudo nmcli con up "System eth1"
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

**Displaying Routing Table (`ip r` or `ip route show`)**:
- `ip r` (or `ip route show`) → Displays the kernel routing table. This shows how network packets are directed based on destination IP addresses, including the default gateway and routes to specific networks.
will show your default gateway and any networks that you have access to.

**What is a Gateway? (Default Gateway)**
- A **gateway** is typically a router that serves as an access point connecting your local network (subnet) to other networks, such as the internet or another corporate network.
- The **Default Gateway** is the specific router IP address that your computer sends packets to when the destination is *not* on the local network.
- **Importance:** Without a default gateway configured, your device can typically only communicate with other devices *within* its own local subnet. It cannot reach the internet or any external network. DHCP often automatically provides the default gateway address to devices.

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

**SSH Keys (Public Key Authentication)**:

SSH key-based authentication provides a secure and convenient way to log into remote servers without needing to enter a password each time. It relies on a pair of cryptographic keys: a **private key** and a **public key**.

*   **Private Key:**
    *   This key must be kept **secret and secure** on the computer you are connecting *from* (the client machine).
    *   It's like your unique, secret identifier.
    *   By default, often named `id_rsa` (or `id_ed25519`, `id_ecdsa` depending on the algorithm used) and stored in the `~/.ssh/` directory on the client.
    *   The private key file should have strict permissions (e.g., `chmod 600 ~/.ssh/id_rsa`) so only the owner can read it.
    *   It can be optionally protected with a **passphrase** during generation for an extra layer of security. If passphrase-protected, you'll need to enter the passphrase when the key is used (an SSH agent can help manage this).

*   **Public Key:**
    *   This key is derived from the private key and is designed to be **shared publicly** without compromising security.
    *   It's placed on the computer you want to connect *to* (the remote server).
    *   By default, often named `id_rsa.pub` (corresponding to `id_rsa`) and also initially stored in `~/.ssh/` on the client after generation.
    *   The content of the public key file needs to be copied to the remote server.

*   **Generating Keys (`ssh-keygen`)**: 
    *   You generate a key pair on your **client machine** using the `ssh-keygen` command.
    ```bash
    ssh-keygen -t rsa -b 4096 # Or use -t ed25519 for a more modern algorithm
    ```
    *   This command prompts you where to save the keys (usually defaults to `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`) and asks for an optional passphrase.

*   **Authentication Scenario:**
    1.  **Setup:** You copy the *content* of your public key (`~/.ssh/id_rsa.pub`) from your client machine and append it as a new line to the `~/.ssh/authorized_keys` file on the **remote server** in the target user's home directory.
        ```bash
        # Example command to copy public key to server (run from client)
        ssh-copy-id username@remote_host
        # Or manually:
        # cat ~/.ssh/id_rsa.pub | ssh username@remote_host 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
        ```
    2.  **Connection:** When you try to SSH to the remote server (`ssh username@remote_host`), your SSH client tells the server which public key it wants to authenticate with (implicitly based on your private key file).
    3.  **Challenge:** The server finds the corresponding public key in the user's `authorized_keys` file. It then generates a random challenge message and encrypts it using that public key.
    4.  **Response:** The server sends this encrypted challenge back to your client.
    5.  **Decryption:** Only your **private key** can decrypt this message correctly. Your SSH client uses your private key to decrypt the challenge.
    6.  **Verification:** The client sends the decrypted challenge (or a derivative of it) back to the server. If it matches the original challenge the server sent, the server knows you possess the correct private key and grants access without asking for a password.

*   **Security:** This method is generally considered more secure than password authentication because private keys are much harder to guess or brute-force than passwords, and the private key itself is never transmitted over the network.

**SCP (Secure Copy)**:
- Command-line tool for secure file transfers over SSH
- Example: Copy a file to a remote user's home directory:
```bash
scp data.txt targetuser@h1:~
```

### Network Testing Commands

Here are some common commands used for testing network connectivity and diagnosing issues:

| Command             | Description                                  |
| :------------------ | :------------------------------------------- |
| `ping`              | Tests whether a network host is alive (reachable) |
| `traceroute`        | Shows the network path (hops) to a remote host |
| `whois`             | Discovers registration information about a domain or host |
| `dig` (and `nslookup`) | Looks up DNS information (IP addresses, MX records, etc.) |
| `ss`                | Displays socket statistics (port-based network information) |
| `nmap`              | Scans remote hosts for open ports and services |

*(Note: `traceroute` might require installation, e.g., `sudo apt install traceroute` or `sudo yum install traceroute`. `nmap` and `whois` often require installation as well.)*


