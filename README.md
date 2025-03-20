# DevOps-Cheat
![GIT](/Media/GIT.jpg)
![ROADMAP](/Media/ROADMAP.jpg)
## Infrastructure as Code (IaC)

### **What is IaC?**
- With IaC, we use code to manage and provision infrastructure instead of doing it manually.
- It allows infrastructure to be deployed and maintained in a consistent, repeatable way.
- IaC files are typically stored in Git repositories, making it easy to track changes, collaborate, and roll back to previous configurations.

### **Benefits**
- If your entire infrastructure fails and you lose all servers or your Kubernetes cluster crashes, you can quickly recreate the exact same environment using IaC scripts.
- All the logic and configuration are embedded in scripts, allowing for faster recovery and minimal human error.

# Changing Your DNS for Better Speed, Privacy, and Security

## What is DNS?
DNS (Domain Name System) is the **internet's phonebook**, translating human-readable domain names (e.g., `example.com`) into IP addresses (e.g., `192.168.1.1`). Every time you visit a website, your device queries a DNS server to resolve the domain into an IP address.

Without DNS, we would need to remember IP addresses instead of human-readable domain names.


 # What is TLS?
TLS (Transport Layer Security) is a cryptographic protocol that provides secure communication over a network. It is the successor to SSL (Secure Sockets Layer).

- Ensures encryption, authentication, and data integrity.
- Used in HTTPS, email, and secure messaging applications.
- Latest version: TLS 1.3

  # How to Divide a Network into Subnets? What is /24? What is 255.255.255.0?

## Understanding Subnetting
A **subnet (sub-network)** is a logically segmented portion of a larger network. Subnetting helps improve network organization, security, and efficiency by dividing a network into smaller, more manageable parts.

Each device on a network has an **IP address** consisting of two parts:
1. **Network portion** – Identifies the network.
2. **Host portion** – Identifies devices within the network.

## CIDR Notation (`/24`)
CIDR (Classless Inter-Domain Routing) notation is a shorthand way of writing subnet masks. The `/24` means that the first **24 bits** of the IP address are used for the network, leaving the remaining **8 bits** for host allocation.

- Example: `192.168.1.0/24`
- The first 24 bits (`192.168.1.`) represent the **network part**.
- The last 8 bits (`.X`) represent the **host part**.

A `/24` subnet provides **256 total addresses** (from `192.168.1.0` to `192.168.1.255`), out of which:
- 1 address is reserved for the **network ID** (`192.168.1.0`).
- 1 address is reserved for the **broadcast address** (`192.168.1.255`).(Used to communicate with all hosts in the subnet. When a device sends a packet to the broadcast address, all devices in the subnet receive it. This is useful for network discovery and communication.)
- The remaining **254 addresses** can be assigned to devices.

## What is `255.255.255.0`?
A **subnet mask** determines which portion of an IP address represents the network and which part represents the host.

### Subnet Mask Breakdown
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

## Subnetting Example
Imagine you have a **corporate network** (`192.168.0.0/16`) with thousands of devices. Instead of using one large subnet, you divide it into multiple `/24` subnets:

| **Subnet** | **Network Address** | **Range** | **Broadcast Address** |
| --- | --- | --- | --- |
| **Subnet 1** | `192.168.1.0/24` | `192.168.1.1 - 192.168.1.254` | `192.168.1.255` |
| **Subnet 2** | `192.168.2.0/24` | `192.168.2.1 - 192.168.2.254` | `192.168.2.255` |
| **Subnet 3** | `192.168.3.0/24` | `192.168.3.1 - 192.168.3.254` | `192.168.3.255` |

This structure helps in organizing departments (e.g., `IT`, `HR`, `Sales`), improving security (by isolating sensitive data), and reducing network congestion.

