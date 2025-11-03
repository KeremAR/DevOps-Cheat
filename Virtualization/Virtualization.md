# Virtualization Interview Cheat Sheet

## Core Concept: The Cost of Virtualization

- **What is the main performance cost in virtualization?**
  The primary cost is **CPU context switching**. A CPU must constantly switch between different operating modes (guest user space, guest kernel, hypervisor, host kernel), and each switch introduces performance overhead.

- **How does virtualization increase this cost?**
  It adds extra layers to the process. A standard system only switches between `User Space <-> Kernel`. A virtualized system forces a much longer chain: `Guest User Space <-> Guest Kernel <-> Hypervisor -> Host Kernel -> Hardware`. Every I/O or system call triggers these expensive, multi-layer switches.

---

## Type-1 vs. Type-2 Hypervisors: The Reality

- **What is the practical difference between Type-1 and Type-2?**
  The theoretical distinction is often exaggerated. In practice, **no modern hypervisor is purely "bare-metal"**; all of them involve a host kernel or a kernel-like layer to manage hardware.

- **Explain further.**
  - **Theory**: Type-1 (e.g., ESXi, Hyper-V) runs on hardware; Type-2 (e.g., VMware Workstation, VirtualBox) runs on a host OS.
  - **Reality**:
    - **ESXi** has its own specialized kernel (`vmkernel`).
    - **Hyper-V** places itself under the Windows kernel, turning Windows into a special management VM.
    - **Proxmox** uses the Linux kernel (KVM) as its hypervisor.
  - **Conclusion**: The real difference is that Type-1 hypervisors use a minimal, purpose-built kernel, while Type-2 hypervisors use a general-purpose one. Both still perform the costly context switches between the hypervisor and a kernel.

---

## Hyper-V Deep Dive

- **Is Hyper-V a Type-1 or Type-2 hypervisor?**
  Hyper-V is a **true Type-1 (bare-metal) hypervisor**. When enabled, it installs itself underneath the main Windows operating system.

- **If it's Type-1, why can it feel slow for desktop use?**
  Because Windows itself becomes a special virtual machine (known as the "root partition") running on top of the Hyper-V hypervisor. All guest VM hardware access (like disk and network I/O) is routed through this root partition for security and stability, which adds latency compared to solutions like VMware Workstation that prioritize direct access.

- **What is the relationship between WSL2 and Hyper-V?**
  WSL2 uses the Hyper-V architecture to run a full Linux kernel inside a lightweight, highly integrated virtual machine. This is why enabling WSL2 also enables Hyper-V.

---

## VMware & Hyper-V Conflict

- **Why does VMware Workstation run slower when Hyper-V is enabled?**
  Because Hyper-V takes **exclusive control** of the CPU's virtualization hardware (Intel VT-x/AMD-V).

- **What is the technical impact?**
  - **Without Hyper-V**: VMware uses its own high-performance kernel driver (`vmx86.sys`) to directly access the CPU's virtualization features.
  - **With Hyper-V**: VMware is blocked from this direct access. It is forced to run in a compatibility mode, using Microsoft's **Windows Hypervisor Platform (WHP) API**. This effectively turns VMware into a client running on top of Hyper-V, adding an extra layer of virtualization and significantly reducing performance.

---

## Proxmox VE Architecture

- **What is the core technology behind Proxmox VE?**
  Proxmox uses **KVM (Kernel-based Virtual Machine)**, which is a module built into the Linux kernel, as its hypervisor.

- **How does it work?**
  Proxmox combines two key components:
  1.  **KVM**: The Linux kernel module that provides direct, hardware-accelerated access to the CPU's virtualization features. This is the hypervisor itself.
  2.  **QEMU**: A user-space tool that emulates the rest of the machine hardware (disks, network cards, etc.) for the virtual machine.
- **Conclusion**: Proxmox runs VMs as QEMU processes that are accelerated by the KVM kernel module, achieving near-native performance. It adds its own management layer (web GUI, clustering, backups) on top of this powerful open-source foundation.
