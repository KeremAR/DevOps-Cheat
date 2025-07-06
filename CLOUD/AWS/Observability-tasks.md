# AWS Observability Hands-On Labs

This document details the step-by-step solutions for hands-on labs focused on AWS Observability services like CloudWatch, SNS, and EC2.

---

## Task: Monitoring EC2 CPU with CloudWatch and SNS for notification (GUI Method)

*This task walks through a fundamental monitoring and alerting workflow using the AWS Management Console. It involves creating an EC2 instance, intentionally stressing its CPU, and configuring a CloudWatch alarm to send an SNS notification when the CPU load is too high.*

### Step 1: Task Analysis & Strategy

The objective is to create a complete monitoring loop: an EC2 instance generates performance metrics, CloudWatch monitors these metrics, and an alarm triggers a notification via SNS if a threshold is breached. The EC2 instance will automatically stress its own CPU using a user data script.

The strategy is to build the components in a logical order of dependency:

1.  **Create Security Group:** The EC2 instance needs a security group to allow network access. For this lab, we will allow SSH access.
2.  **Create SNS Topic & Subscription:** This is the notification channel. We need to create the topic first, then subscribe an email address to it. A crucial part of this step is confirming the subscription via email.
3.  **Launch EC2 Instance:** We will launch the instance with a specific User Data script. This script will install a `stress` tool and run it for 30 minutes to guarantee a CPU utilization spike, which is necessary to trigger our alarm.
4.  **Create CloudWatch Alarm:** This is the final step that connects everything. The alarm will watch the `CPUUtilization` metric from our specific EC2 instance. When the metric exceeds 60%, the alarm will change state and send a message to our pre-configured SNS topic.

### Step 2: Execution via AWS Management Console

The following steps were performed in the `us-east-1` region.

1.  **Create the Security Group:**
    *   Navigate to the **EC2** dashboard.
    *   In the left pane under "Network & Security", click **Security Groups**.
    *   Click **Create security group**.
    *   **Security group name:** `cmtr-zdv1y551-sg`.
    *   **Description:** `Allow SSH access`.
    *   **VPC:** Select the VPC with the name `cmtr-zdv1y551-vpc`.
    *   **Inbound rules:** Click **Add rule**.
        *   **Type:** `SSH`.
        *   **Source:** `0.0.0.0/0` (For a real-world scenario, you should restrict this to your IP address).
    *   Click **Create security group**.

2.  **Create SNS Topic and Subscription:**
    *   Navigate to the **Simple Notification Service (SNS)** dashboard.
    *   In the left pane, click **Topics**, then **Create topic**.
    *   **Type:** Select **Standard**.
    *   **Name:** Enter `cmtr-zdv1y551-sns`.
    *   Scroll to the bottom and click **Create topic**.
    *   Once the topic is created, click the **Subscriptions** tab, then **Create subscription**.
    *   **Protocol:** Select **Email**.
    *   **Endpoint:** Enter `kerem_ar@epam.com`.
    *   Click **Create subscription**.
    *   **Action Required:** You must immediately check your `kerem_ar@epam.com` inbox for an email from "AWS Notifications" and click the **"Confirm subscription"** link. The alarm will not work until the subscription is confirmed.

3.  **Launch the EC2 Instance:**
    *   Navigate to the **EC2** dashboard and click **Launch instances**.
    *   **Name:** `cmtr-zdv1y551-instance`.
    *   **Application and OS Images (AMI):** Select `Amazon Linux`, and ensure the AMI is `Amazon Linux 2023 AMI`.
    *   **Instance type:** `t2.micro`.
    *   **Key pair (login):** Select `Proceed without a key pair`.
    *   **Network settings:** Click **Edit**.
        *   **VPC:** Select `cmtr-zdv1y551-vpc`.
        *   **Auto-assign public IP:** Ensure this is set to **Enable**.
        *   **Firewall (security groups):** Select **Select existing security group** and choose `cmtr-zdv1y551-sg` from the list.
    *   **Advanced details:** Scroll down and expand this section. In the **User data** field, paste the following script. This script will install the `stress` utility and run it for 30 minutes (1800 seconds) to spike the CPU.
        ```bash
        #!/bin/bash
        sudo yum update -y
        sudo amazon-linux-extras install epel -y
        sudo yum install -y stress
        sudo stress --cpu 1 --timeout 1800
        ```
    *   Click **Launch instance**.

4.  **Create the CloudWatch Alarm:**
    *   Navigate to the **CloudWatch** dashboard.
    *   In the left pane, click **Alarms** -> **All alarms**.
    *   Click **Create alarm**.
    *   Click **Select metric**.
    *   Under "Browse", click **EC2** -> **Per-Instance Metrics**.
    *   Find your instance `cmtr-zdv1y551-instance` in the list and select the `CPUUtilization` metric for it. Click **Select metric**.
    *   **Conditions:**
        *   **Threshold type:** **Static**.
        *   **Whenever CPUUtilization is...**: Select **Greater/Equal**.
        *   **than...**: Enter `60`.
    *   **Additional configuration:**
        *   **Datapoints to alarm:** Leave as `1 out of 1`.
    *   Click **Next**.
    *   **Notification:**
        *   **Alarm state trigger:** Select **In alarm**.
        *   **Send a notification to...**: Select **Select an existing SNS topic** and choose `cmtr-zdv1y551-sns` from the dropdown.
    *   Click **Next**.
    *   **Name and description:**
        *   **Alarm name:** `cmtr-zdv1y551-alarm`.
    *   Click **Next**, review the settings, and click **Create alarm**.

### Step 3: Verification

1.  **Initial State:** The alarm will initially show a state of "Insufficient data" for a minute or two while it gathers its first metric datapoints.
2.  **Wait for the Alarm:** The User Data script on the EC2 instance starts stressing the CPU almost immediately after launch. Within 2-3 minutes, the `CPUUtilization` will cross the 60% threshold.
3.  **Check Email:** Once the alarm state changes to `In alarm`, SNS will send a notification. Check your `kerem_ar@epam.com` inbox for an email with a subject like "ALARM: "cmtr-zdv1y551-alarm" in US East (N. Virginia)".
4.  **Check CloudWatch Console:**
    *   Navigate back to **CloudWatch -> Alarms**.
    *   Your `cmtr-zdv1y551-alarm` should now have a red status of **In alarm**.
    *   Click on the alarm name and view the graph. You will see the blue line (CPUUtilization) has clearly risen above the red dotted line (the 60% threshold).

This confirms that all components are working together correctly.
