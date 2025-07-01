# AWS Networking Hands-On Labs

This document details the step-by-step solutions for hands-on labs focused on AWS Networking services.

---

## Task 1: Create and Configure Your Own VPC (GUI Method)

*This foundational task covers building a secure, isolated network from scratch by creating and configuring all the core components of an Amazon VPC using the AWS Management Console. This visual approach helps in understanding the relationships between components.*

### Step 1: Task Analysis & Strategy

The objective is to construct a complete VPC environment manually through the AWS Console. This visual method helps solidify the understanding of how each component connects. The process involves navigating to the VPC dashboard and creating each resource in sequence, ensuring they are correctly configured and tagged as per the lab requirements.

1.  **Create the VPC:** Use the "Create VPC" function to provision a new VPC (`cmtr-zdv1y551-vpc`) with the specified CIDR block.
2.  **Create Subnets:** Create a Public Subnet and a Private Subnet within the new VPC. The public subnet will be configured to auto-assign public IP addresses.
3.  **Create and Attach Internet Gateway:** Create an Internet Gateway and attach it to the VPC to enable internet communication.
4.  **Create and Configure Route Tables:**
    *   Create a **Public Route Table**, add a default route (`0.0.0.0/0`) pointing to the Internet Gateway, and associate it with the public subnet.
    *   Create a **Private Route Table** and associate it with the private subnet, leaving only the default local route.
5.  **Prepare for Instance Access (IAM):** Create an IAM Role with an instance profile and the `AmazonSSMManagedInstanceCore` policy to allow remote management via Session Manager.
6.  **Launch Instances (EC2):** Launch one public EC2 instance into the public subnet (with the IAM profile) and one private EC2 instance into the private subnet.
7.  **Deploy Application (SSM):** Use Session Manager to connect to the public instance and run a command to install and start the `nginx` web server.

### Step 2: Execution via AWS Management Console

Follow these steps in the AWS Console (`us-east-1` region) to build the infrastructure.

1.  **Navigate to the VPC Dashboard.**
2.  **Create VPC:**
    *   Click **Create VPC**.
    *   Under "Resources to create", select **VPC only**.
    *   **Name tag:** `cmtr-zdv1y551-vpc`
    *   **IPv4 CIDR block:** `10.0.0.0/16`
    *   Click **Create VPC**.
3.  **Create Subnets:**
    *   In the left navigation pane, click **Subnets**, then **Create subnet**.
    *   Select your `cmtr-zdv1y551-vpc`.
    *   **Public Subnet:**
        *   Subnet name: `cmtr-zdv1y551-public_subnet`
        *   IPv4 CIDR block: `10.0.1.0/24`
        *   Click **Create subnet**.
    *   **Private Subnet:**
        *   Click **Create subnet** again.
        *   Subnet name: `cmtr-zdv1y551-private_subnet`
        *   IPv4 CIDR block: `10.0.2.0/24`
        *   Click **Create subnet**.
    *   **Enable Public IP for Public Subnet:** Select the `cmtr-zdv1y551-public_subnet`, click **Actions** -> **Edit subnet settings**, check **Enable auto-assign public IPv4 address**, and click **Save**.
4.  **Create and Attach Internet Gateway:**
    *   In the left navigation pane, click **Internet gateways**, then **Create internet gateway**.
    *   **Name tag:** `cmtr-zdv1y551-internet_gateway`
    *   Click **Create internet gateway**.
    *   With the new IGW selected, click **Actions** -> **Attach to VPC**, select your `cmtr-zdv1y551-vpc`, and click **Attach internet gateway**.
5.  **Create and Configure Route Tables:**
    *   In the left navigation pane, click **Route tables**, then **Create route table**.
    *   **Public Route Table:**
        *   Name: `cmtr-zdv1y551-route_public`, select your `cmtr-zdv1y551-vpc`. Click **Create**.
        *   Select it, go to the **Routes** tab, click **Edit routes**.
        *   Click **Add route**, set Destination to `0.0.0.0/0`, and for Target select **Internet Gateway** and choose your IGW. Click **Save changes**.
        *   Go to the **Subnet associations** tab, click **Edit subnet associations**, select the `cmtr-zdv1y551-public_subnet`, and click **Save associations**.
    *   **Private Route Table:**
        *   Click **Create route table** again.
        *   Name: `cmtr-zdv1y551-route_private`, select your `cmtr-zdv1y551-vpc`. Click **Create**.
        *   Select it, go to the **Subnet associations** tab, click **Edit subnet associations**, select the `cmtr-zdv1y551-private_subnet`, and click **Save associations**.
6.  **Create IAM Role for SSM:**
    *   Navigate to the **IAM** service, click **Roles**, then **Create role**.
    *   **Trusted entity type:** AWS service. **Use case:** EC2. Click **Next**.
    *   Search for and select the `AmazonSSMManagedInstanceCore` policy. Click **Next**.
    *   **Role name:** `SSM-EC2-Role-for-VPC-Task`. Click **Create role**. (The instance profile is created automatically).
7.  **Launch EC2 Instances:**
    *   Navigate to the **EC2** service, click **Launch instances**.
    *   **Public Instance:**
        *   Name: `cmtr-zdv1y551-public`
        *   AMI: Amazon Linux 2 (or the latest Amazon Linux)
        *   Instance type: `t2.micro`
        *   Key pair: Proceed without a key pair.
        *   Network settings: Click **Edit**. Select your `cmtr-zdv1y551-vpc` and the `cmtr-zdv1y551-public_subnet`. Ensure **Auto-assign public IP** is **Enable**.
        *   Under **Advanced details**, for **IAM instance profile**, select the `SSM-EC2-Role-for-VPC-Task` you created.
        *   Click **Launch instance**.
    *   **Private Instance:**
        *   Click **Launch instances** again.
        *   Name: `cmtr-zdv1y551-private`
        *   AMI/Instance Type/Key Pair: Same as above.
        *   Network settings: Click **Edit**. Select your `cmtr-zdv1y551-vpc` and the `cmtr-zdv1y551-private_subnet`.
        *   Click **Launch instance**.
8.  **Install Nginx on Public Instance:**
    *   Wait for the `cmtr-zdv1y551-public` instance's status to become **Running**.
    *   Select it, click **Connect**.
    *   Choose the **Session Manager** tab and click **Connect**.
    *   Once the terminal session starts, run the following command: `sudo amazon-linux-extras install -y nginx1 && sudo systemctl start nginx`

### Step 3: Verification

After creating the resources via the console, the configuration can be verified with the following tests.

1.  **Resource Verification (Console):**
    *   In the **VPC dashboard**, confirm all named resources (VPC, Subnets, Route Tables, IGW) exist with their correct `Name` tags.
    *   In the **EC2 dashboard**, confirm both instances (`public` and `private`) are running in the correct subnets.

2.  **Public Instance Connectivity (EC2 Session Manager):**
    *   Connect to the `cmtr-zdv1y551-public` instance via Session Manager.
    *   Test internet access: `ping 8.8.8.8` (should succeed).
    *   Test web server: `curl localhost` (should return the Nginx welcome page).
    *   Test connectivity to the private instance. Find its private IP (e.g., `10.0.2.x`) from the EC2 console and run: `ping <private_instance_ip>` (should succeed).

3.  **Private Instance Connectivity (EC2 Session Manager):**
    *   Connect to the `cmtr-zdv1y551-private` instance via Session Manager.
    *   Test internet access: `ping 8.8.8.8` (should fail, confirming its isolation). 