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

---

## Task: Create an S3 Bucket with Versioning and Lifecycle Policy

*This task demonstrates how to create and configure an S3 bucket, focusing on two key features for data management and cost optimization: Versioning and Lifecycle Policies.*

### Step 1: Task Analysis & Strategy

The objective is to create an S3 bucket, enable versioning to protect against accidental data loss, and then configure a lifecycle rule to automatically manage the cost of storing older (noncurrent) versions of objects. The approach will use the AWS Management Console for all steps.

The strategy is as follows:

1.  **Create and Configure S3 Bucket:**
    *   Navigate to the S3 console and begin the bucket creation process.
    *   The bucket name (`cmtr-zdv1y551-bucket-1751548535`) must be globally unique, so using the provided name is critical.
    *   During creation, locate the **Bucket Versioning** setting and explicitly **Enable** it. All other settings, like "Block all public access," should remain at their default (recommended) values.
2.  **Upload Test Files:**
    *   Once the bucket is created, upload two simple, empty `.txt` files to serve as test objects. This fulfills the requirement of the bucket not being empty.
3.  **Create Lifecycle Policy:**
    *   Navigate to the bucket's **Management** tab to create the lifecycle rule.
    *   The rule will be named `cmtr-zdv1y551-rule` and will apply to all objects in the bucket.
    *   The rule actions must be configured precisely:
        *   **Action 1:** Transition **noncurrent versions** to the `Standard-IA` storage class 30 days after they become noncurrent.
        *   **Action 2:** Permanently delete **noncurrent versions** 50 days after they become noncurrent.
    *   It's important to ensure these actions apply only to *noncurrent* versions, not the current object versions.

### Step 2: Execution via AWS Management Console

The following steps were performed in the `us-east-1` region using the AWS Console.

1.  **Create S3 Bucket and Enable Versioning:**
    *   Navigated to the **S3** service dashboard.
    *   Clicked **Create bucket**.
    *   **Bucket name:** Entered `cmtr-zdv1y551-bucket-1751548535`.
    *   **AWS Region:** Confirmed it was `us-east-1`.
    *   Scrolled down to the **Bucket Versioning** section and selected **Enable**.
    *   Kept all other settings at their default values (including "Block all public access" enabled).
    *   Clicked **Create bucket**.

2.  **Upload Files to the Bucket:**
    *   Navigated into the newly created `cmtr-zdv1y551-bucket-1751548535` bucket.
    *   Clicked **Upload**.
    *   On the "Upload" screen, clicked **Add files**.
    *   Selected two locally created empty text files (e.g., `test1.txt`, `test2.txt`).
    *   Clicked **Upload**.

3.  **Create Lifecycle Policy:**
    *   Inside the bucket, clicked on the **Management** tab.
    *   Under "Lifecycle rules", clicked **Create lifecycle rule**.
    *   **Lifecycle rule name:** Entered `cmtr-zdv1y551-rule`.
    *   **Choose a rule scope:** Selected **Apply to all objects in the bucket**.
    *   **Lifecycle rule actions:**
        *   Checked the box for **Transition noncurrent versions of objects between storage classes**.
            *   **Storage class transitions:** `Standard-IA`.
            *   **Days after objects become noncurrent:** `30`.
        *   Checked the box for **Permanently delete noncurrent versions of objects**.
            *   **Number of days after objects become noncurrent:** `50`.
    *   Acknowledged that the rule will apply to all objects.
    *   Clicked **Create rule**.

### Step 3: Verification

1.  **Verify Bucket and Files:**
    *   Confirmed that the bucket `cmtr-zdv1y551-bucket-1751548535` exists in the S3 console.
    *   Navigated into the bucket and confirmed the two `.txt` files are present.

2.  **Verify Versioning:**
    *   Navigated into the bucket and clicked on the **Properties** tab.
    *   Scrolled down to the "Bucket Versioning" card and confirmed its status is **Enabled**.

3.  **Verify Lifecycle Policy:**
    *   Navigated into the bucket and clicked on the **Management** tab.
    *   Under "Lifecycle rules", confirmed that a rule named `cmtr-zdv1y551-rule` exists and its status is **Enabled**.
    *   Clicked on the rule name to review its configuration. Verified that the actions correctly target **noncurrent versions** for transition to Standard-IA at 30 days and permanent deletion at 50 days.

---

## Task: Restore a Deleted File Using S3 Versioning

*This task demonstrates a critical capability of S3 Versioning: recovering an object that was accidentally "deleted" by removing its delete marker.*

### Step 1: Task Analysis & Strategy

The objective is to restore a file named `accidentally_deleted_file.csv` in a version-enabled S3 bucket. Understanding how deletion works with versioning is key to this task.

When you delete an object in a versioned bucket, S3 does not permanently remove the data. Instead, it places a special, zero-byte object called a **delete marker** at the top of the object's version stack. This marker becomes the "current" version, effectively hiding the actual file data from normal view.

The strategy to restore the file is therefore not to "undelete" it, but simply to **delete the delete marker**.

1.  **Navigate to the S3 Bucket:** Go to the specified bucket (`cmtr-zdv1y551-s3-rfuv-bucket-791277`).
2.  **List Object Versions:** The file will not be visible initially. Use the **"Show versions"** toggle switch to reveal all versions of all objects, including delete markers.
3.  **Identify and Select the Delete Marker:** Find the `accidentally_deleted_file.csv` object. You will see two entries for it: the actual previous version and a delete marker. Select **only the delete marker**.
4.  **Permanently Delete the Marker:** Use the "Delete" action to permanently remove the selected delete marker. This action, when applied to a specific version ID (like a delete marker's), is permanent and cannot be undone.
5.  **Verify Restoration:** Once the marker is gone, the previous version of the file automatically becomes the current version again. Turn off the "Show versions" toggle to confirm the file is now visible in the standard bucket view.

### Step 2: Execution via AWS Management Console

The following steps were performed in the `us-east-1` region using the AWS Console.

1.  **Navigate to the Bucket and Show Versions:**
    *   Navigated to the **S3** service dashboard.
    *   Clicked on the bucket named `cmtr-zdv1y551-s3-rfuv-bucket-791277`.
    *   At the top of the object list, toggled the **Show versions** switch to the **on** position.

2.  **Find and Identify the Delete Marker:**
    *   The object list now showed all versions.
    *   Located the two entries for `accidentally_deleted_file.csv`. One had "Delete marker" in the "Type" column. The other was the previous version of the file.

3.  **Delete the Delete Marker:**
    *   Selected the radio button next to the `accidentally_deleted_file.csv` entry that was identified as the **Delete marker**. It is critical to select only this one entry.
    *   Clicked the **Delete** button.

4.  **Confirm Permanent Deletion:**
    *   A new screen appeared asking to confirm the permanent deletion of the object.
    *   In the text box, typed `Permanently delete`.
    *   Clicked the **Delete objects** button.
    *   A confirmation banner appeared at the top, indicating the delete marker was successfully removed.

### Step 3: Verification

1.  **Turn Off "Show Versions":**
    *   In the S3 bucket view, toggled the **Show versions** switch back to the **off** position.
2.  **Confirm File is Restored:**
    *   Observed the object list in the standard view.
    *   Confirmed that the file `accidentally_deleted_file.csv` is now visible, indicating it has been successfully restored.

---

## Task: Trigger Lambda from S3 via SQS (CLI Method)

*This advanced task demonstrates how to build a common event-driven pipeline on AWS. It involves configuring an S3 bucket to send event notifications to an SQS queue, which then triggers a Lambda function for processing. This task must be completed using the AWS CLI.*

### Step 1: Task Analysis & Strategy

The objective is to connect three services in a specific order using the AWS CLI in exactly "three moves":

1.  **S3 -> SQS:** When a `.txt` file is uploaded to the `input/` folder in an S3 bucket, it sends a message to an SQS queue.
2.  **SQS -> Lambda:** A Lambda function polls this SQS queue, and upon receiving a message, it is triggered.
3.  **Lambda -> S3:** The Lambda function processes the file from the message and writes a result back to the `output/` folder in the same S3 bucket.

The strategy is to configure these connections sequentially using the AWS CLI. Given this is a CLI-only task and we are using PowerShell, creating configuration files locally for complex JSON arguments is the most reliable approach.

1.  **Move 1: Create S3 Event Notification.** We will use the `aws s3api put-bucket-notification-configuration` command. This requires a JSON payload specifying the SQS queue's ARN as the destination, the event type (`s3:ObjectCreated:*`), and a filter to only watch the `input/` prefix. We will first fetch the SQS queue's ARN and then dynamically generate this JSON file.
2.  **Move 2: Create the Lambda Trigger.** We will use the `aws lambda create-event-source-mapping` command to link the SQS queue to the Lambda function. This tells Lambda to start polling the queue for messages.
3.  **Move 3: Trigger the Pipeline.** We will create a local test file and upload it to the `s3://<bucket-name>/input/` folder using the `aws s3 cp` command. This action will kick off the entire process.

### Step 2: Execution via AWS CLI (PowerShell)

The following PowerShell commands were used to execute the task. It's assumed the AWS CLI is configured with the provided credentials.

1.  **Define Names and Get Resource ARNs:**
    *   First, define variables for the resource names and retrieve the full ARN for the SQS queue, which is needed for the other commands.
    ```powershell
    # Define resource names
    $bucketName = "cmtr-zdv1y551-s3-snlt-bucket-750236"
    $queueName = "cmtr-zdv1y551-s3-snlt-queue"
    $functionName = "cmtr-zdv1y551-s3-snlt-lambda"

    # Get SQS Queue URL
    $queueUrl = (aws sqs get-queue-url --queue-name $queueName --query "QueueUrl" --output text)

    # Get SQS Queue ARN from its attributes
    $queueArn = (aws sqs get-queue-attributes --queue-url $queueUrl --attribute-names "QueueArn" --query "Attributes.QueueArn" --output text)
    ```

2.  **Move 1: Create S3 Event Notification**
    *   **A) Manually Create `notification.json` file:** To avoid potential formatting issues with PowerShell, it's more reliable to create the JSON file manually. First, get the SQS Queue ARN by running `echo $queueArn` in your terminal. Then, create a file named `notification.json` in your working directory with the following content, replacing the placeholder with your actual queue ARN.
        ```json
        {
            "QueueConfigurations": [
                {
                    "Id": "s3-input-to-sqs-event",
                    "QueueArn": "PASTE_YOUR_QUEUE_ARN_HERE",
                    "Events": [
                        "s3:ObjectCreated:*"
                    ],
                    "Filter": {
                        "Key": {
                            "FilterRules": [
                                {
                                    "Name": "prefix",
                                    "Value": "input/"
                                }
                            ]
                        }
                    }
                }
            ]
        }
        ```
    *   **B) Apply the notification configuration to the bucket:**
        ```powershell
        aws s3api put-bucket-notification-configuration --bucket $bucketName --notification-configuration file://notification.json
        ```

3.  **Move 2: Configure Lambda Trigger from SQS**
    *   This command creates the mapping between the SQS queue and the Lambda function.
    ```powershell
    aws lambda create-event-source-mapping --function-name $functionName --batch-size 10 --event-source-arn $queueArn
    ```

4.  **Move 3: Upload a File to Trigger the Process**
    *   **A) Create a local test file:**
        ```powershell
        "This is a test." | Set-Content -Path "test.txt"
        ```
    *   **B) Upload the file to the S3 bucket's `input/` folder:**
        ```powershell
        aws s3 cp test.txt s3://$bucketName/input/
        ```

### Step 3: Verification

1.  **Navigate to the S3 Bucket:**
    *   In the AWS Management Console, navigate to the **S3** service.
    *   Click on the bucket `cmtr-zdv1y551-s3-snlt-bucket-750236`.
2.  **Check the `output/` Folder:**
    *   Look for a folder named `output/`. It might take a minute or two for the Lambda function to execute and create it.
    *   Navigate into the `output/` folder.
    *   Inside, there should be another subfolder.
    *   Inside the subfolder, you should find a new file. This is the processed output from the Lambda function, confirming the entire pipeline worked successfully.
