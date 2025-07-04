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

---

# AWS RDS Hands-On Lab: Configure a Multi-AZ DB Instance with Read-Replica

This document provides a detailed walkthrough for converting a single-AZ RDS instance to Multi-AZ, creating a read-replica, reconfiguring an application to use it, and validating a failover event.

---

## Task: Configure a Multi-AZ DB Instance with Read-Replica

*This task guides you through enhancing an existing RDS instance for high availability and performance, and ensuring applications can leverage these features and withstand failover events.*

### Step 1: Task Analysis & Strategy

The objective is to create a robust and scalable database architecture. This involves two key concepts:
*   **Multi-AZ:** Provides high availability and disaster recovery by maintaining a synchronous standby replica in a different Availability Zone. The primary purpose is fault tolerance, not performance scaling.
*   **Read Replica:** Provides performance scaling by offloading read-only queries from the primary instance. It is an asynchronous copy of the primary database.

The strategy is to perform the configuration in a logical sequence:

1.  **Enable Multi-AZ:** Modify the primary RDS instance to convert it from a Single-AZ to a Multi-AZ deployment. This is the foundation for high availability.
2.  **Create the Read Replica:** Once the primary instance is configured, create a read-replica from it. This is a critical step for scaling read traffic. The lab has very specific requirements for the replica's name (`db-replica`) and settings (disabling Enhanced Monitoring).
3.  **Reconfigure the `data-collector` Application:** An application designed for reading data (like a reporting or statistics tool) is the perfect candidate to use the read-replica. This offloads the primary instance, allowing it to focus on writes from the `data-generator`. This involves connecting to the EC2 instance, getting the new replica's endpoint, editing the application's configuration file, and restarting the service.
4.  **Trigger and Validate Failover:** Force a failover of the primary Multi-AZ instance. This is the ultimate test. We need to verify that the `data-generator` (the write-intensive application) can survive the brief downtime and automatically reconnect to the new primary instance (the former standby).

### Step 2: Execution via AWS Management Console & EC2

The following steps are performed in the `us-east-1` region.

#### Part A: Configure Multi-AZ for the Primary RDS Instance

1.  **Navigate to the RDS Dashboard:**
    *   Go to the **RDS** service.
    *   In the left pane, click **Databases**.
2.  **Modify the Primary Instance:**
    *   Select the database instance named `cmtr-zdv1y551-rds-madi-rds-7373322-primary`.
    *   Click the **Modify** button.
3.  **Enable Multi-AZ:**
    *   Scroll down to the **Availability & durability** section.
    *   For the "Multi-AZ DB instance" option, select **Create a standby instance**.
4.  **Apply Changes:**
    *   Scroll to the bottom and click **Continue**.
    *   On the summary page, under "Scheduling of modifications", select **Apply immediately**.
    *   Click **Modify DB Instance**.
    *   Wait for the instance's status to change from "Modifying" back to **"Available"**. This may take several minutes.

#### Part B: Create the Read Replica

1.  **Start the Creation Process:**
    *   In the RDS Databases list, ensure the primary instance (`...-primary`) is selected.
    *   Click the **Actions** menu and select **Create read replica**.
2.  **Configure the Read Replica:**
    *   **DB instance identifier:** Enter exactly `db-replica`.
    *   **Instance configuration:** Ensure the "DB instance class" matches the primary instance.
    *   **Connectivity:** Ensure **Public access** is set to `No`.
    *   **Monitoring:** Scroll down and expand the **Additional configuration** section. Find **Enhanced monitoring** and **uncheck** the "Enable Enhanced Monitoring" box.
3.  **Create the Replica:**
    *   Click **Create read replica**.
    *   The creation process will begin. Wait for the new `db-replica` instance's status to become **"Available"**.

#### Part C: Reconfigure the Data Collector Application

1.  **Get the Read Replica Endpoint:**
    *   Once the `db-replica` is "Available", click on its name to open the details page.
    *   Under the **Connectivity & security** tab, find and copy the **Endpoint** value for the replica.
2.  **Connect to the EC2 Instance:**
    *   Navigate to the **EC2** service > **Instances**.
    *   Select the instance `i-0908e5c173f0ed435`, click **Connect**.
    *   Select the **Session Manager** tab and click **Connect**.
3.  **Update the Application Configuration:**
    *   In the Session Manager terminal, run the following command to replace the old endpoint with the new replica endpoint. **Remember to replace `<YOUR_REPLICA_ENDPOINT>` with the actual endpoint you copied.**
        ```bash
        sudo sed -i 's|ENDPOINT=.*|ENDPOINT="<YOUR_REPLICA_ENDPOINT>"|' /usr/local/bin/data-collector
        ```
4.  **Restart the Application Service:**
    *   Apply the changes by restarting the `data-collector` service.
        ```bash
        sudo systemctl restart data-collector
        ```

#### Part D: Trigger and Validate Failover

1.  **Start Tailing Both Log Files:**
    *   To observe the failover in real-time, it's best to have two Session Manager terminals open.
    *   **In Terminal 1:** Tail the `data-generator` log (the write application).
        ```bash
        tail -f /var/log/data-generator.log
        ```
    *   **In Terminal 2:** Tail the `data-collector` log (the read application).
        ```bash
        tail -f /var/log/data-collector.log
        ```
2.  **Trigger the Failover:**
    *   Go back to the **RDS Console**.
    *   Select the **primary** RDS instance (`cmtr-zdv1y551-rds-madi-rds-7373322-primary`).
    *   Click the **Actions** menu and select **Reboot**.
    *   In the reboot confirmation dialog, **check the box for "Reboot with failover?"**. This is the most important step.
    *   Click **Confirm**.
3.  **Observe the Logs:**
    *   Watch the log files in your terminals.
    *   You will see connection errors appear in the `data-generator.log` for about 1-2 minutes while the failover occurs. This is expected.
    *   Crucially, after the failover completes, you should see the `data-generator` log automatically resume showing successful "Data inserted" messages.
    *   The `data-collector.log` should continue to show successful reads from the replica, largely unaffected by the primary's failover.

### Step 3: Verification

1.  **Confirm Database Configuration:**
    *   In the RDS console, click on the primary instance. In the **Configuration** tab, verify that "Multi-AZ" is set to **Yes**.
    *   In the **Connectivity & security** tab, note the Availability Zone. After the failover, this AZ should be different from the original one.
    *   Confirm the `db-replica` instance exists and is in the "Available" state.
2.  **Confirm Application Connectivity:**
    *   Check the `data-collector.log` (`cat /var/log/data-collector.log`). The log entries should show connection attempts to the **read-replica's endpoint**.
3.  **Confirm Failover Validation:**
    *   Check the `data-generator.log` (`cat /var/log/data-generator.log`). You should see a period of errors followed by a resumption of successful "Data inserted" log entries, proving the application's resilience.

This completes the task, demonstrating a fully functional, highly available, and performance-scaled database architecture.

---

# AWS DynamoDB Hands-On Lab: Simple Table Creation and Data Querying

This document provides a detailed walkthrough for creating a DynamoDB table, inserting an item with multiple data types, and querying that item.

---

## Task: Amazon DynamoDB Simple Table Creation and Data Querying

*This task guides you through the fundamental operations of AWS DynamoDB: creating a table, creating a multi-attribute item, and retrieving it.*

### Step 1: Task Analysis & Strategy

The objective is to perform the most basic Create, Read, Update, Delete (CRUD) operations in DynamoDB using the AWS Management Console. The key is to understand how DynamoDB handles schema-less items with different data types.

The strategy is straightforward:

1.  **Create the DynamoDB Table:** First, we'll create the table itself, defining only the essential primary key. DynamoDB is schema-less, so we don't need to define the other attributes (`Name`, `Active`, `Roles`) at the table level.
    *   Table Name: `cmtr-dynamodb-create-table-zdv1y551-mytable` (must be exact).
    *   Partition Key: `id` (Type: `String`).
2.  **Create the Item:** Once the table is active, we'll use the "Explore table items" feature to create a new item. This is where we will define all the attributes for this specific record. The most critical part is correctly setting the data type for each attribute as specified:
    *   `id`: `String`
    *   `Name`: `String`
    *   `Active`: `Boolean`
    *   `Roles`: `List` (of Strings)
3.  **Verify the Item:** After creating the item, we'll use the built-in query functionality within "Explore table items" to retrieve the item using its partition key (`id`) and confirm all data was stored correctly.

### Step 2: Execution via AWS Management Console

The following steps are performed in the `us-east-1` region.

#### Part A: Create the DynamoDB Table

1.  **Navigate to the DynamoDB Dashboard:**
    *   Go to the **DynamoDB** service.
    *   In the left pane, click **Tables**, then click **Create table**.
2.  **Configure Table Details:**
    *   **Table name:** Enter exactly `cmtr-dynamodb-create-table-zdv1y551-mytable`.
    *   **Partition key:**
        *   **Field name:** `id`.
        *   **Data type:** Keep it as `String`.
    *   Leave all other settings as their default values.
3.  **Create the Table:**
    *   Click **Create table**.
    *   Wait for the table status to change from "Creating" to **"Active"**.

#### Part B: Create an Item in the Table

1.  **Explore Table Items:**
    *   In the table list, click on the name of your new table (`cmtr-dynamodb-create-table-zdv1y551-mytable`).
    *   In the left navigation pane for the table, click **Explore table items**.
2.  **Create a New Item:**
    *   On the right side, click the **Create item** button.
3.  **Populate Item Attributes:**
    *   A form will appear. The `id` (partition key) is already there.
    *   **id (String):**
        *   Enter the value `cmtr-zdv1y551`.
    *   **Add Name (String):**
        *   Click **Add new attribute** and select **String**.
        *   For the **Field** name, enter `Name`.
        *   For the **Value**, enter `Dean Winchester`.
    *   **Add Active (Boolean):**
        *   Click **Add new attribute** and select **Boolean**.
        *   For the **Field** name, enter `Active`.
        *   Select the radio button for **true**.
    *   **Add Roles (List of Strings):**
        *   Click **Add new attribute** and select **List**.
        *   For the **Field** name, enter `Roles`.
        *   Two new buttons will appear inside the list. Click **Add new attribute** and select **String**.
        *   Enter the value `Incedent Analyst`.
        *   Click the **Add new attribute** button *inside the list again* and select **String**.
        *   Enter the value `Impala Manager`.
4.  **Save the Item:**
    *   Click the orange **Create item** button at the bottom right.

### Step 3: Verification

1.  **Query the Item:**
    *   You should now be back on the "Explore table items" screen, and your newly created item will be listed.
2.  **Confirm Item Details:**
    *   Click on the item's `id` (`cmtr-zdv1y551`).
    *   A preview panel will open on the right, displaying all the attributes in JSON format.
    *   Verify that the `id`, `Name`, `Active` flag, and the `Roles` list with its two string values are all present and correct. This confirms the task is complete. 