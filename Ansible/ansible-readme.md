# Ansible Learning Notes

## What is Ansible and Why is it Important?

Ansible is a popular tool used for IT automation. It is developed by Red Hat and is open-source. It can be used without programming knowledge, but since it is based on Python, knowing Python is an advantage. It is used for managing Linux system administration, network devices, cloud services (AWS, Azure), and Windows machines. Being agentless, it allows management over SSH without the need to install additional software on devices. It is free, but its commercial version, "Ansible Tower," offers additional features.

## Why Should We Use Ansible?

It saves time when managing multiple servers. Instead of manually performing the same task on many servers, it automates them through a central control server. It is also suitable for network engineers; it enables managing router and switch configurations from a single point. It is a fundamental automation tool that everyone in IT should learn.

## How Does Ansible Work?

* **Control Node**: At least one machine is designated as the control node.
* **Managed Nodes**: Connects via SSH and sends Ansible modules to the managed nodes.
* **Playbook and Play Concepts**:
   * **Playbook**: YAML files that contain multiple tasks.
   * **Play**: A set of tasks executed on one or more target hosts.
* **Idempotency**: Changes are only applied if necessary; otherwise, the current state is maintained.

## Ansible Galaxy and Ansible Vault

* **Ansible Galaxy**: A large ecosystem of pre-built playbooks and modules.
* **Ansible Vault**: Used to securely store sensitive information (e.g., API keys, passwords) in an encrypted format.

## Ansible Playbook Usage

Instead of running individual commands, Ansible allows defining configurations using Playbooks (YAML files).

**Example Playbook (Installs Nano Editor):**

```yaml
---
- name: I love Nano
  hosts: linux
  tasks:
    - name: Ensure Nano is installed
      yum:
        name: nano
        state: latest
```

To run the Playbook, use the command:

```
ansible-playbook playbook.yml
```

## Where is Ansible Used?

Ansible is commonly used for **IT automation, configuration management, and application deployment**. Here are some common use cases:

1. **Server Setup and Configuration**
   * Automatically install packages, configure settings, and create users when a new server is deployed.
   * Example: Installing **Nginx, MySQL, PHP (LAMP/LEMP stack)** on a new Ubuntu server.

2. **Application Deployment**
   * Deploy web applications or microservices automatically to servers.
   * Example: Deploying a **Django or Node.js** application to a specific server.

3. **Network Device Management**
   * Configure network devices like Cisco and Juniper.
   * Example: **Creating VLANs, setting up firewalls on routers and switches** using Ansible.

4. **Security and Compliance Management**
   * Automatically apply security patches, modify SSH settings, and enforce password policies.
   * Example: **Disabling root login on all servers** and managing sudo access.
