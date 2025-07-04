# AWS RDS Hands-On Lab: Creating and Connecting to a MySQL Database

This document details the step-by-step solution for creating a managed MySQL database with RDS and connecting to it from an EC2 instance.

---

## Task: Creating and Configuring Amazon RDS MySQL

*This task walks through the process of creating the necessary security groups, launching an RDS MySQL instance and an EC2 instance, and finally connecting from the EC2 instance to the database to verify the setup.*

### Step 1: Task Analysis & Strategy

The objective is to establish a secure connection between a new EC2 instance and a new RDS MySQL database. The core of this task lies in configuring the networking (Security Groups) correctly to allow the EC2 instance to communicate with the RDS instance on the MySQL port (3306), while keeping the database itself isolated from the public internet.

The strategy follows a logical order, creating dependent resources first:

1.  **Create Security Groups:** The instances cannot be launched without their security groups.
    *   First, create the security group for the EC2 instance (`cmtr-zdv1y551-ec2_sg`). This group doesn't need any special inbound rules for this task since we will use SSM Session Manager for access.
    *   Second, create the security group for the RDS instance (`cmtr-zdv1y551-rds_sg`). This is the most critical step. We must configure an **inbound rule** that allows traffic on the `MYSQL/Aurora` port (3306) specifically from the `cmtr-zdv1y551-ec2_sg` security group. This ensures only our EC2 instance can talk to the database.
2.  **Launch RDS Instance:** With the security groups ready, create the RDS instance. This process takes the longest (5-10 minutes), so it's good to start it early. We must be careful to select all the specified options: Free tier, MySQL, the correct VPC, the specific DB subnet group provided, and our new RDS security group. We also need to explicitly **disable encryption**.
3.  **Launch EC2 Instance:** While the RDS instance is provisioning, launch the EC2 instance. Ensure it's in the correct public subnet and attached to the EC2 security group and the provided SSM instance profile.
4.  **Connect and Verify:** Once the RDS instance is in the "Available" state:
    *   Connect to the EC2 instance using Session Manager.
    *   Install the MySQL command-line client.
    *   Retrieve the database endpoint from the RDS console.
    *   Use the `mysql` client on the EC2 instance to connect to the RDS endpoint, using the provided credentials to confirm that the security configuration is working correctly.

### Step 2: Execution via AWS Management Console

The following steps were performed in the `us-east-1` region using the AWS Console.

#### Part A: Create Security Groups

1.  **Navigate to EC2 > Security Groups:**
    *   Go to the **EC2** service dashboard. In the left navigation pane, under "Network & Security", click **Security Groups**.
2.  **Create the EC2 Security Group:**
    *   Click **Create security group**.
    *   **Security group name:** `cmtr-zdv1y551-ec2_sg`.
    *   **Description:** `Security group for the client EC2 instance`.
    *   **VPC:** Select `cmtr-zdv1y551-vpc`.
    *   Leave the default inbound and outbound rules.
    *   Click **Create security group**.
3.  **Create the RDS Security Group:**
    *   Click **Create security group** again.
    *   **Security group name:** `cmtr-zdv1y551-rds_sg`.
    *   **Description:** `Security group for the RDS database instance`.
    *   **VPC:** Select `cmtr-zdv1y551-vpc`.
    *   **Inbound rules:** Click **Add rule**.
        *   **Type:** Select `MYSQL/Aurora` from the dropdown. The protocol and port (TCP 3306) will be set automatically.
        *   **Source:** Click in the source box and start typing `sg-`. A list of security groups will appear. Select `cmtr-zdv1y551-ec2_sg`.
    *   Click **Create security group**.

#### Part B: Create the RDS Instance

1.  **Navigate to the RDS Dashboard:**
    *   Go to the **RDS** service.
    *   In the left pane, click **Databases**, then click **Create database**.
2.  **Configure RDS Instance:**
    *   **Database creation method:** Choose **Standard create**.
    *   **Engine options:**
        *   **Engine type:** `MySQL`.
        *   **Version:** Keep the default.
    *   **Templates:** Select **Free tier**.
    *   **Settings:**
        *   **DB instance identifier:** `cmtr-zdv1y551-rds`.
        *   **Master username:** `cloud_mentor`.
        *   **Master password:** `Cloud_Mentor123`.
        *   **Confirm password:** `Cloud_Mentor123`.
    *   **Connectivity:**
        *   **Virtual private cloud (VPC):** Select `cmtr-zdv1y551-vpc`.
        *   **DB Subnet group:** Select `cmtr-zdv1y551-rds-vpc-stack-privatedbsubnetgroup-ys688f4orwb8`.
        *   **Public access:** `No`.
        *   **VPC security group (firewall):** Choose **Select existing**. Remove the `default` security group by clicking the 'X' next to it, then select `cmtr-zdv1y551-rds_sg` from the dropdown.
        *   **Availability Zone:** No preference.
    *   **Additional configuration:**
        *   Expand this section.
        *   Scroll down to **Encryption** and uncheck the box for **Enable encryption**. This is a required step.
    *   Click **Create database**. The instance will now provision, which will take several minutes.

#### Part C: Launch the EC2 Instance

1.  **Navigate to EC2 > Instances:**
    *   Go to the **EC2** dashboard > **Instances** > **Launch instances**.
2.  **Configure EC2 Instance:**
    *   **Name:** `cmtr-zdv1y551-ec2`.
    *   **Application and OS Images (AMI):** Select `Amazon Linux`, and ensure the AMI is `Amazon Linux 2023 AMI`.
    *   **Instance type:** `t2.micro`.
    *   **Key pair (login):** `Proceed without a key pair`.
    *   **Network settings:** Click **Edit**.
        *   **VPC:** `cmtr-zdv1y551-vpc`.
        *   **Subnet:** Select `cmtr-zdv1y551-public_subnet`.
        *   **Firewall (security groups):** Choose **Select existing security group** and select `cmtr-zdv1y551-ec2_sg`.
    *   **Advanced details:**
        *   **IAM instance profile:** Select `cmtr-zdv1y551-ssm_instance_profile`.
    *   Click **Launch instance**.

### Step 3: Verification

1.  **Wait for RDS Instance and Get Endpoint:**
    *   Navigate back to the **RDS** > **Databases** console.
    *   Wait until the status of the `cmtr-zdv1y551-rds` instance changes from "Creating" to **"Available"**.
    *   Click on the `cmtr-zdv1y551-rds` database identifier to open its details.
    *   Under the **Connectivity & security** tab, find and copy the **Endpoint** value. It will look something like `cmtr-zdv1y551-rds.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com`.

2.  **Connect to EC2 and Install MySQL Client:**
    *   Go to the **EC2** > **Instances** console.
    *   Select the `cmtr-zdv1y551-ec2` instance and click **Connect**.
    *   Select the **Session Manager** tab and click **Connect**. A new browser tab with a shell prompt will open.
    *   In the shell, run the following commands in order to install the MySQL client. The community repository and its GPG key are required for Amazon Linux 2023.
        ```bash
        sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
        sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
        sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
        sudo dnf install mysql-community-client -y
        ```

3.  **Connect to the RDS Database:**
    *   In the same shell, use the MySQL client to connect to your database. Replace `<YOUR_RDS_ENDPOINT>` with the endpoint you copied in the first step.
        ```bash
        mysql -h <YOUR_RDS_ENDPOINT> -u cloud_mentor -p
        ```
    *   The command will prompt you for a password. Enter `Cloud_Mentor123` and press **Enter**.

> **Troubleshooting Note: Access Denied (ERROR 1045)**
> If you receive an "Access denied" error, it means your credentials are incorrect. The fastest way to fix this is to reset the password.
> 1. In the **RDS Console**, select your database (`cmtr-zdv1y551-rds`) and click **Modify**.
> 2. Scroll to "Credentials Settings" and enter a new password (e.g., `Cloud_Mentor123` again).
> 3. Continue to the end, choose **Apply immediately**, and click **Modify DB Instance**.
> 4. Wait for the status to return to "Available" and try connecting again with the new password.

4.  **Confirm Results:**
    *   If the connection is successful, you will see the MySQL welcome message and the `mysql>` prompt.
    *   This confirms that the security groups are configured correctly and the EC2 instance can successfully communicate with the RDS database. You can type `exit` to close the MySQL connection. 