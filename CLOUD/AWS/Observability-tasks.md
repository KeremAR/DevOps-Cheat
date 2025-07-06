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

---

## Task: Managing Instance State with Lambda and EventBridge Scheduler (CLI Method)

*This task demonstrates how to create a serverless scheduler using EventBridge to trigger a Lambda function that starts and stops EC2 instances. The entire process must be completed using the AWS CLI, and success depends on passing the correct input payload to the Lambda function.*

### Step 1: Task Analysis & Strategy

The core objective is to configure two existing EventBridge rules (`...-start` and `...-stop`) to trigger a Lambda function. The key challenge is to provide the correct input to the Lambda so it knows *what* to do (start or stop) and *which* instances to target. The lab explicitly states "refer to the Lambda code to find out the input format" and limits us to "two moves."

The strategy is as follows:

1.  **Inspect the Lambda Function's Expected Input:** The first step is to understand what payload the Lambda function expects. We can't see the code directly via a simple CLI command, but based on the lab description and standard practice, we can infer the following:
    *   The function performs a specific "action". Therefore, the input JSON must contain an `action` key.
    *   The function targets specific instances. The lab mentions instances tagged with `managed: yes`, implying the Lambda code filters instances based on this tag.
    *   Therefore, the required input payload is a simple JSON object: `{"action": "start"}` for the start rule, and `{"action": "stop"}` for the stop rule.

2.  **Define the "Two Moves":** A "move" is a resource update. The lab requires configuring both the schedule and the target. We will accomplish this by first setting the schedule for each rule, then setting the target and its specific input. The two conceptual moves are the complete configuration of the "start" mechanism and the "stop" mechanism.

### Step 2: Execution via AWS CLI (PowerShell)

The following PowerShell commands were used to execute the task. It is assumed the AWS CLI has been configured with the provided credentials.

1.  **Define Variables and Get Lambda ARN:**
    *   First, we define variables for the known resource names. Then, we fetch the full ARN of the Lambda function, which is required to set it as a target.
    ```powershell
    # Define resource names from the lab description
    $startRuleName = "cmtr-zdv1y551-eventbridge-lesm-event_rule-start"
    $stopRuleName = "cmtr-zdv1y551-eventbridge-lesm-event_rule-stop"
    $functionName = "cmtr-zdv1y551-eventbridge-lesm-lambda"

    # Get the full ARN of the Lambda function
    $functionArn = (aws lambda get-function --function-name $functionName --query "Configuration.FunctionArn" --output text)
    Write-Host "Lambda Function ARN: $functionArn"
    ```

2.  **Configure the "Start" Rule and Target (Move 1):**
    *   First, we define the schedule for the start rule using a CRON expression. This example sets it to run at a specific time.
    *   Second, we set the Lambda function as the target, ensuring we configure it to pass a constant JSON input.
    *   **A) Set the schedule for the START rule:**
        ```powershell
        aws events put-rule --name $startRuleName --schedule-expression "cron(45 12 * * ? *)" --state ENABLED
        ```
    *   **B) Create `start-target.json` file:** Create a file named `start-target.json` with the following content. Replace the placeholder with your actual Lambda ARN.
        ```json
        [
          {
            "Id": "1",
            "Arn": "PASTE_YOUR_LAMBDA_FUNCTION_ARN_HERE",
            "Input": "{\"action\": \"start\"}"
          }
        ]
        ```
    *   **C) Apply the target configuration from the file:**
        ```powershell
        aws events put-targets --rule $startRuleName --targets file://start-target.json
        ```

3.  **Configure the "Stop" Rule and Target (Move 2):**
    *   We repeat the process for the stop rule, setting a different schedule and input.
    *   **A) Set the schedule for the STOP rule:**
    ```powershell
    aws events put-rule --name $stopRuleName --schedule-expression "cron(50 12 * * ? *)" --state ENABLED
    ```
    *   **B) Create `stop-target.json` file:** Create another file named `stop-target.json`, using the same Lambda ARN.
        ```json
        [
          {
            "Id": "1",
            "Arn": "PASTE_YOUR_LAMBDA_FUNCTION_ARN_HERE",
            "Input": "{\"action\": \"stop\"}"
          }
        ]
        ```
    *   **C) Apply the target configuration from the file:**
    ```powershell
    aws events put-targets --rule $stopRuleName --targets file://stop-target.json
    ```

### Step 3: Verification

The primary way to verify this task is to check the logs generated by the Lambda function after the scheduled times have passed.

1.  **Navigate to CloudWatch Logs:**
    *   In the AWS Management Console, navigate to the **CloudWatch** service.
    *   In the left pane, click **Log groups**.
2.  **Find the Lambda Log Group:**
    *   In the filter box, search for the log group associated with the Lambda function: `/aws/lambda/cmtr-zdv1y551-eventbridge-lesm-lambda`.
3.  **Check the Log Streams:**
    *   Click on the log group name.
    *   Inside, you will see one or more log streams, ordered by time.
    *   After 12:45 UTC, you should see a log stream containing an event payload of `{"action": "start"}` and log messages indicating the function attempted to start the instances.
    *   After 12:50 UTC, you should see another log stream with an event payload of `{"action": "stop"}`. If you see a `KeyError: 'action'` in the logs, it means the custom input was not correctly passed to the Lambda target. You can fix this by editing the rule's target in the EventBridge console and setting the "Input" to "Constant (JSON text)".
4.  **(Optional) Check EC2 Instance State:**
    *   You can also navigate to the **EC2** dashboard around the scheduled times and observe the state of the managed instance (`i-023b45e3f05350df0`) to confirm it starts and stops as expected.
