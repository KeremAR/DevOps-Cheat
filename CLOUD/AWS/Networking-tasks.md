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

---

## Task 2: Setup Cross-Region VPC Peering and Transit Gateway (GUI Method)

*This advanced task involves connecting three VPCs across three different AWS regions using two distinct methods: a direct VPC Peering connection and a more scalable, hub-and-spoke model using Transit Gateway peering.*

### Step 1: Task Analysis & Strategy

The lab provides pre-configured VPCs and EC2 instances in three regions: `us-east-1` (Region A), `eu-west-1` (Region B), and `ap-south-1` (Region C). Our goal is to establish network connectivity between all of them using the AWS Console.

The strategy will be executed in two main parts:

**Part 1: VPC Peering (Region A <-> Region B)**
1.  **Create Peering Connection:** Initiate a VPC peering connection from VPC-A (`us-east-1`) to VPC-B (`eu-west-1`).
2.  **Accept Connection:** Switch to the `eu-west-1` region and accept the incoming peering request.
3.  **Update Route Tables:** Modify the route tables in both VPC-A and VPC-B to direct traffic destined for the other VPC's CIDR block through the new peering connection.

**Part 2: Transit Gateway Peering (Connecting Region C to A & B)**
1.  **Create Transit Gateways:** Create a new Transit Gateway (TGW) in each of the three regions (A, B, and C).
2.  **Create VPC Attachments:** In each region, create a VPC attachment to connect the local VPC to the local TGW.
3.  **Create TGW Peering Attachments:**
    *   Initiate a peering connection from TGW-C to TGW-A.
    *   Initiate another peering connection from TGW-C to TGW-B.
    *   Switch to regions A and B to accept these TGW peering requests.
4.  **Update TGW Route Tables:** Configure static routes in the TGW route tables. For example, TGW-A's route table needs a route to VPC-C's CIDR pointing to the peering attachment. TGW-C's route table needs routes to both VPC-A and VPC-B.
5.  **Update VPC Route Tables:** Add new routes to the VPC route tables in all three regions to direct traffic to the other VPCs via their local TGW.

### Step 2: Execution via AWS Management Console

This process requires switching between AWS regions frequently. Pay close attention to the region you are working in.

**Part 1: Configure VPC Peering (us-east-1 <-> eu-west-1)**

1.  **Initiate Peering from `us-east-1` (Region A):**
    *   Navigate to the **VPC Dashboard** in the `us-east-1` region.
    *   Go to **Peering connections** and click **Create peering connection**.
    *   **Name:** `vpcA-to-vpcB`
    *   **VPC ID (Requester):** Select `cmtr-zdv1y551-vpc-a`.
    *   **Accepter Account:** My account.
    *   **Accepter Region:** `eu-west-1` (Europe - Ireland).
    *   **VPC ID (Accepter):** Enter the VPC ID for `cmtr-zdv1y551-vpc-b` from the `eu-west-1` region.
    *   Click **Create peering connection**.
2.  **Accept Peering in `eu-west-1` (Region B):**
    *   Switch your region to `eu-west-1`.
    *   Navigate to **Peering connections**. You will see the pending request.
    *   Select it, click **Actions** -> **Accept request**, and confirm.
3.  **Update Route Tables for Peering:**
    *   **In `us-east-1`:**
        *   Go to **Route tables**, select `cmtr-zdv1y551-public-rt-a`.
        *   Go to the **Routes** tab, click **Edit routes**.
        *   **Add route:** Destination `10.1.0.0/16` (VPC-B's CIDR), Target: **Peering Connection**, select the `vpcA-to-vpcB` connection. Save changes.
    *   **In `eu-west-1`:**
        *   Go to **Route tables**, select `cmtr-zdv1y551-public-rt-b`.
        *   **Add route:** Destination `10.0.0.0/16` (VPC-A's CIDR), Target: **Peering Connection**, select the same connection. Save changes.

**Part 2: Configure Transit Gateway (Connecting All Three Regions)**

1.  **Create Transit Gateways in All Regions:**
    *   For each region (`us-east-1`, `eu-west-1`, `ap-south-1`):
        *   Navigate to **Transit gateways** and click **Create transit gateway**.
        *   **Name tag:** `tgw-region-a`, `tgw-region-b`, `tgw-region-c` respectively.
        *   Accept the default settings and click **Create**.
2.  **Create VPC Attachments in All Regions:**
    *   For each region (`us-east-1`, `eu-west-1`, `ap-south-1`):
        *   Navigate to **Transit gateway attachments**, click **Create**.
        *   Select the TGW you just created in that region.
        *   **Attachment type:** VPC.
        *   Select the corresponding VPC for that region (e.g., `cmtr-zdv1y551-vpc-a` in `us-east-1`).
        *   Click **Create attachment**.
3.  **Create TGW Peering Attachments (from `ap-south-1`):**
    *   In the `ap-south-1` region (Region C), go to **Transit gateway attachments** and click **Create**.
    *   **Connection C to A:**
        *   Select `tgw-region-c`. **Attachment type:** Peering Connection.
        *   **Accepter region:** `us-east-1`. **Accepter TGW ID:** Get the TGW ID for `tgw-region-a`.
        *   Create the attachment.
    *   **Connection C to B:**
        *   Repeat the process, this time for `tgw-region-b` in `eu-west-1`.
4.  **Accept TGW Peering Attachments:**
    *   Go to `us-east-1`, find the pending TGW peering attachment, and **Accept** it.
    *   Go to `eu-west-1`, find the pending TGW peering attachment, and **Accept** it.
5.  **Update TGW Route Tables:**
    *   **In `us-east-1` (A):**
        *   Go to **Transit gateway route tables**, select the route table for `tgw-region-a`.
        *   Under **Routes**, click **Create static route**.
        *   **CIDR:** `10.2.0.0/16` (VPC-C). **Choose attachment:** Select the peering attachment to TGW-C.
    *   **In `eu-west-1` (B):**
        *   Repeat the process for `tgw-region-b`, adding a static route for `10.2.0.0/16` pointing to the peering attachment to TGW-C.
    *   **In `ap-south-1` (C):**
        *   For `tgw-region-c`, create **two** static routes:
        *   Route 1: **CIDR** `10.0.0.0/16` (VPC-A) -> Attachment to TGW-A.
        *   Route 2: **CIDR** `10.1.0.0/16` (VPC-B) -> Attachment to TGW-B.
6.  **Update VPC Route Tables for TGW Traffic:**
    *   **In `us-east-1`:** Edit `cmtr-zdv1y551-public-rt-a`. Add route: `10.2.0.0/16` (VPC-C) -> Target: **Transit Gateway**, select `tgw-region-a`.
    *   **In `eu-west-1`:** Edit `cmtr-zdv1y551-public-rt-b`. Add route: `10.2.0.0/16` (VPC-C) -> Target: **Transit Gateway**, select `tgw-region-b`.
    *   **In `ap-south-1`:** Edit `cmtr-zdv1y551-public-rt-c`. Add two routes:
        *   Route 1: `10.0.0.0/16` (VPC-A) -> Target: **Transit Gateway**, select `tgw-region-c`.
        *   Route 2: `10.1.0.0/16` (VPC-B) -> Target: **Transit Gateway**, select `tgw-region-c`.

### Step 3: Verification

1.  Use Session Manager to connect to the EC2 instance in **Region A (`us-east-1`)**.
2.  From this instance, run a ping command to the **private IP address** of the instance in **Region B (`eu-west-1`)**. This should succeed, testing the VPC Peering.
3.  From the same instance (A), run a ping command to the **private IP address** of the instance in **Region C (`ap-south-1`)**. This should succeed, testing the Transit Gateway connection.
4.  Connect to the EC2 instance in **Region C (`ap-south-1`)**.
5.  Ping the private IPs of the instances in Region A and Region B to confirm bidirectional connectivity. 