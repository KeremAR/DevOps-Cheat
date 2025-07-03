# AWS Storage Hands-On Labs

This document details the step-by-step solutions for hands-on labs focused on AWS Storage services like EFS.

---

## Task: Configure an EFS and Attach It to Two EC2 Instances

*This task walks through the process of creating an Elastic File System (EFS), launching two EC2 instances in different Availability Zones, and mounting the shared file system on both to demonstrate shared data access.*

### Step 1: Task Analysis & Strategy

The objective is to create a shared EFS file system that can be simultaneously accessed by two EC2 instances residing in separate Availability Zones (`us-east-1a` and `us-east-1b`). This setup is a common pattern for building highly available applications that require a shared storage layer. The most direct way to accomplish this without CLI requirements is through the AWS Management Console.

The strategy follows a logical progression, creating dependencies first:

1.  **Create Security Groups:**
    *   First, create a security group for the EFS file system (`cmtr-zdv1y551-efs-sg`) that allows inbound NFS traffic (port 2049) from the EC2 instances.
    *   Second, create the security group for the EC2 instances (`cmtr-zdv1y551-ec2-sg`). For this lab, it won't need specific inbound rules as we will use SSM Session Manager for access.
2.  **Create IAM Role:** Create the IAM role (`cmtr-zdv1y551-role`) with the `AmazonSSMManagedInstanceCore` policy. This is essential for allowing Session Manager to connect to our instances without needing open SSH ports.
3.  **Create and Configure EFS:** Create the EFS file system (`cmtr-zdv1y551-efs`). During creation, it's crucial to define mount targets in the correct subnets (`us-east-1a` and `us-east-1b`) and attach the EFS security group to them.
4.  **Launch EC2 Instances:**
    *   Launch the first instance (`cmtr-zdv1y551-instance1`) in `us-east-1a`.
    *   Launch the second instance (`cmtr-zdv1y551-instance2`) in `us-east-1b`.
    *   For both instances, attach the IAM role and EC2 security group. We will connect and mount the EFS manually using Session Manager to better understand the process.
5.  **Verify Shared Access:** Connect to both instances via Session Manager. Mount the EFS, create a file from the first instance, and then verify its existence and content from the second instance.

### Step 2: Execution via AWS Management Console

The following steps were performed in the `us-east-1` region using the AWS Console.

1.  **Create IAM Role:**
    *   Navigated to the **IAM** service dashboard.
    *   Clicked on **Roles** > **Create role**.
    *   **Trusted entity type:** Selected **AWS service**.
    *   **Use case:** Selected **EC2**. Clicked **Next**.
    *   **Permissions policies:** Searched for and selected `AmazonSSMManagedInstanceCore`. Clicked **Next**.
    *   **Role name:** Entered `cmtr-zdv1y551-role`.
    *   Clicked **Create role**.

2.  **Create Security Groups:**
    *   Navigated to the **EC2** service dashboard > **Security Groups**.
    *   **Create EFS Security Group (`cmtr-zdv1y551-efs-sg`):**
        *   Clicked **Create security group**.
        *   **Security group name:** `cmtr-zdv1y551-efs-sg`.
        *   **Description:** `Allow NFS access for EFS`.
        *   **VPC:** Selected `cmtr-zdv1y551-vpc`.
        *   **Inbound rules:** Clicked **Add rule**.
            *   **Type:** `NFS`. The protocol and port (TCP 2049) will be set automatically.
            *   **Source:** `10.0.0.0/16` as specified in the lab description.
        *   Clicked **Create security group**.
    *   **Create EC2 Security Group (`cmtr-zdv1y551-ec2-sg`):**
        *   Clicked **Create security group** again.
        *   **Security group name:** `cmtr-zdv1y551-ec2-sg`.
        *   **Description:** `EC2 instance security group`.
        *   **VPC:** Selected `cmtr-zdv1y551-vpc`.
        *   Left the inbound rules empty, as SSM will be used for access.
        *   Clicked **Create security group**.

3.  **Create EFS File System:**
    *   Navigated to the **EFS** service dashboard.
    *   Clicked **Create file system**.
    *   **Name:** `cmtr-zdv1y551-efs`.
    *   **VPC:** Selected `cmtr-zdv1y551-vpc`.
    *   Clicked **Customize**.
    *   On the "Network access" page, under **Mount targets**, for both the `us-east-1a` and `us-east-1b` Availability Zones, clicked the `X` to remove the `default` security group and added the `cmtr-zdv1y551-efs-sg` security group.
    *   Clicked **Next**, then **Create**.
    *   Once the file system is created, selected it and noted its **File system ID** (e.g., `fs-xxxxxxxxxxxxxxxx`).

4.  **Launch EC2 Instances:**
    *   Navigated to the **EC2** dashboard > **Instances** > **Launch instances**.
    *   **Launch Instance 1 (`cmtr-zdv1y551-instance1`):**
        *   **Name:** `cmtr-zdv1y551-instance1`.
        *   **AMI:** Selected `Amazon Linux 2 AMI`.
        *   **Instance type:** `t2.micro`.
        *   **Key pair (login):** `Proceed without a key pair`.
        *   **Network settings:** Clicked **Edit**.
            *   **VPC:** `cmtr-zdv1y551-vpc`.
            *   **Subnet:** Selected the public subnet in `us-east-1a`.
            *   **Firewall (security groups):** Chose **Select existing security group** and selected `cmtr-zdv1y551-ec2-sg`.
        *   **Advanced details:**
            *   **IAM instance profile:** Selected `cmtr-zdv1y551-role`.
        *   Clicked **Launch instance**.
    *   **Launch Instance 2 (`cmtr-zdv1y551-instance2`):**
        *   Followed the exact same steps as for Instance 1, but set the **Name** to `cmtr-zdv1y551-instance2` and chose the public subnet in **`us-east-1b`**.

### Step 3: Verification

> **Troubleshooting Note:** If the **Connect** button for an instance is disabled in the console, it usually means the IAM role was not attached correctly. To fix this, select the instance, go to **Actions > Security > Modify IAM role**, and attach the `cmtr-zdv1y551-role`. The button should become active after a minute or two.

1.  **Connect to Instances and Mount EFS:**
    *   Waited for both instances to be in the **Running** state.
    *   Selected `cmtr-zdv1y551-instance1` and clicked **Connect** > **Session Manager** > **Connect**.
    *   In the new shell tab, executed the following commands to install the EFS utilities and mount the file system.
        ```bash
        # Become root user
        sudo su
        # Install EFS utilities
        yum install -y amazon-efs-utils
        # Create a directory to mount to
        mkdir /mnt/efs
        # Mount the EFS file system (replace with your EFS ID)
        mount -t efs fs-xxxxxxxxxxxxxxxx:/ /mnt/efs
        ```

    > **Troubleshooting Note:** If the `mount` command fails with a `Failed to resolve` error, it means your VPC is not configured to resolve DNS names. To fix this:
    > 1. Go to the **VPC** console.
    > 2. Select your VPC (`cmtr-zdv1y551-vpc`).
    > 3. Click **Actions** > **Edit VPC settings**.
    > 4. Check the box for **Enable DNS hostnames**.
    > 5. Click **Save changes**. Wait a minute and try the `mount` command again.

    *   Opened a new browser tab and connected to `cmtr-zdv1y551-instance2` using Session Manager, and ran the same commands to mount the EFS.

2.  **Test File Sharing:**
    *   **On `instance1`'s session:** Created a test file in the shared EFS mount.
        ```bash
        # This command is run as root from the previous step
        echo "Hello, World!" > /mnt/efs/test-file.txt
        ```

    *   **On `instance2`'s session:** Verified that the file created by instance1 exists and is readable.
        ```bash
        # Become root if not already
        sudo su
        # List files in the EFS mount
        ls -l /mnt/efs
        # Read the content of the test file
        cat /mnt/efs/test-file.txt
        ```

3.  **Confirm Results:**
    *   The `ls` command on instance2 correctly listed `test-file.txt`.
    *   The `cat` command on instance2 correctly displayed "Hello, World!".
    *   This confirms that the EFS file system is successfully shared and mounted between the two EC2 instances in different Availability Zones.
