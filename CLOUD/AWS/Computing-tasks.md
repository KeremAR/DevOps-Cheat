# AWS Compute Hands-On Labs

This document details the step-by-step solutions for hands-on labs focused on AWS Compute services like EC2.

---

## Task: Configure an EC2 Instance with SSH Key and Simple Web Server (GUI Method)

*This foundational task walks through the entire process of launching a secure, accessible EC2 instance. It covers creating the necessary permissions (IAM Role), network security rules (Security Group), access credentials (Key Pair), and finally launching the instance and bootstrapping a simple web server using a user data script.*

### Step 1: Task Analysis & Strategy

The objective is to create a fully functional `t2.micro` EC2 instance that serves a basic web page. The key requirements are to use pre-named resources, configure security correctly, and automate the web server installation. Since there is no CLI requirement, the most straightforward approach is to use the AWS Management Console for all steps.

The strategy is to create the prerequisite components first, in a logical order, before launching the instance itself:

1.  **Create IAM Role:** First, create the IAM role and instance profile (`cmtr-zdv1y551-role`) with the required `CloudWatchAgentServerPolicy`. This ensures the permissions are ready to be attached to the EC2 instance during launch.
2.  **Create Security Group:** Next, create the security group (`cmtr-zdv1y551-sg`) within the specified VPC. The rules will allow HTTP traffic from anywhere (for the web server) and SSH traffic only from the user's IP for secure management.
3.  **Create Key Pair:** Create and download the SSH key pair (`cmtr-zdv1y551-key`). This is essential for verifying SSH access later.
4.  **Launch EC2 Instance:** With all prerequisites in place, launch the EC2 instance (`cmtr-zdv1y551-instance`). During launch, attach the IAM role and security group, select the key pair, and most importantly, use a **User Data script** to automate the installation and startup of an Apache web server.

### Step 2: Execution via AWS Management Console

The following steps were performed in the `us-east-1` region using the AWS Console.

1.  **Create IAM Role:**
    *   Navigated to the **IAM** service dashboard.
    *   Clicked on **Roles** in the left navigation pane, then **Create role**.
    *   **Trusted entity type:** Selected **AWS service**.
    *   **Use case:** Selected **EC2**. Clicked **Next**.
    *   In the "Add permissions" search box, typed `CloudWatchAgentServerPolicy` and checked the box next to it. Clicked **Next**.
    *   **Role name:** Entered `cmtr-zdv1y551-role`.
    *   Clicked **Create role**.

2.  **Create Security Group:**
    *   Navigated to the **EC2** service dashboard.
    *   Under "Network & Security", clicked on **Security Groups**, then **Create security group**.
    *   **Security group name:** `cmtr-zdv1y551-sg`.
    *   **Description:** `Allows HTTP and SSH access`.
    *   **VPC:** Selected the `cmtr-zdv1y551-vpc`.
    *   **Inbound rules:**
        *   Clicked **Add rule**.
        *   **Type:** `HTTP`. **Source:** `Anywhere-IPv4` (`0.0.0.0/0`).
        *   Clicked **Add rule** again.
        *   **Type:** `SSH`. **Source:** `My IP` (AWS automatically detected the IP address).
    *   Clicked **Create security group**.

3.  **Create SSH Key Pair:**
    *   In the EC2 dashboard, under "Network & Security", clicked on **Key Pairs**, then **Create key pair**.
    *   **Name:** `cmtr-zdv1y551-key`.
    *   **Key pair type:** `RSA`.
    *   **Private key file format:** `.pem` (for use with OpenSSH on Linux/macOS).
    *   Clicked **Create key pair**. The `.pem` file was automatically downloaded by the browser.

4.  **Launch EC2 Instance:**
    *   Navigated to the EC2 Dashboard and clicked **Launch instances**.
    *   **Name:** `cmtr-zdv1y551-instance`.
    *   **Application and OS Images (AMI):** Selected **Amazon Linux 2 AMI**.
    *   **Instance type:** Selected `t2.micro`.
    *   **Key pair (login):** Selected the `cmtr-zdv1y551-key` from the dropdown.
    *   **Network settings:** Clicked **Edit**.
        *   **VPC:** Selected `cmtr-zdv1y551-vpc`.
        *   **Subnet:** Chose a public subnet within the VPC.
        *   **Auto-assign public IP:** Ensured this was set to **Enable**.
        *   **Firewall (security groups):** Selected **Select existing security group** and chose `cmtr-zdv1y551-sg`.
    *   **Advanced details:**
        *   **IAM instance profile:** Selected `cmtr-zdv1y551-role`.
        *   Scrolled down to the **User data** field and entered the following script to install and start Apache:
            ```bash
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            echo "<h1>EC2 Instance Deployed Successfully</h1>" > /var/www/html/index.html
            ```
    *   Clicked **Launch instance**.

### Step 3: Verification

Verification was performed using multiple methods to confirm all aspects of the task were successful.

1.  **Check EC2 Instance Status:**
    *   Waited for the `cmtr-zdv1y551-instance` to enter the **Running** state with **2/2 status checks passed** in the EC2 console.
    *   Copied the **Public IPv4 address** of the instance for the following tests.

2.  **SSH Connection and Service Status:**
    *   Opened a terminal and used the downloaded `.pem` file to connect to the instance via SSH.
        ```bash
        # Set correct permissions for the key file first
        chmod 400 cmtr-zdv1y551-key.pem
        
        # Connect to the instance
        ssh -i "cmtr-zdv1y551-key.pem" ec2-user@<EC2_PUBLIC_IP>
        ```
    *   Once connected, verified the Apache service was active.
        ```bash
        sudo systemctl status httpd
        ```
    *   The output confirmed the service was **active (running)**.

3.  **Web Browser and `curl` Verification:**
    *   Opened a web browser and navigated to `http://<EC2_PUBLIC_IP>`. The page displayed the message "EC2 Instance Deployed Successfully".
    *   Used the `curl` command from a local terminal to check the HTTP headers.
        ```bash
        curl -I http://<EC2_PUBLIC_IP>
        ```
    *   The command returned the expected **`HTTP/1.1 200 OK`** status code, along with a `Content-Type: text/html` header, confirming the web server was correctly configured and accessible.

---

## Task: Setting Up Communication between EC2 Instances (CLI Method)

*This task demonstrates a critical security best practice: allowing communication between EC2 instances by referencing their security groups rather than their IP addresses. This creates a more dynamic and scalable rule set. The goal is to configure two security groups to allow two-way HTTP and ICMP traffic between them using the AWS CLI.*

### Step 1: Task Analysis & Strategy

The objective is to enable bidirectional HTTP (port 80) and ICMP (ping) traffic between a public and a private EC2 instance by modifying their respective security groups (`cmtr-zdv1y551-ec2-sg-sg-public1_sg` and `cmtr-zdv1y551-ec2-sg-sg-private1_sg`). The task explicitly requires using the AWS CLI and completing the configuration in exactly "four moves".

The strategy is as follows:

1.  **Identify Security Group IDs:** Before rules can be added, the unique IDs for both the public and private security groups must be retrieved. Using security group names in CLI commands is only supported for the default VPC, so using IDs is mandatory here.
2.  **Authorize Ingress from Private to Public:**
    *   **Move 1:** Add a rule to the public security group to allow inbound HTTP (TCP/80) traffic from the private security group.
    *   **Move 2:** Add a rule to the public security group to allow inbound ICMP (All) traffic from the private security group.
3.  **Authorize Ingress from Public to Private:**
    *   **Move 3:** Add a rule to the private security group to allow inbound HTTP (TCP/80) traffic from the public security group.
    *   **Move 4:** Add a rule to the private security group to allow inbound ICMP (All) traffic from the public security group.

This approach uses four `aws ec2 authorize-security-group-ingress` commands, fulfilling the "four moves" requirement and establishing the necessary communication paths.

### Step 2: Execution via AWS CLI

First, the environment was configured with the provided AWS credentials for the CLI.

1.  **Retrieve Security Group IDs:**
    The following command was used to describe the security groups and extract their names and IDs. These IDs are then used in the subsequent commands.
    ```bash
    aws ec2 describe-security-groups \
      --filters Name=group-name,Values=cmtr-zdv1y551-ec2-sg-sg-public1_sg,cmtr-zdv1y551-ec2-sg-sg-private1_sg \
      --query "SecurityGroups[*].{Name:GroupName, ID:GroupId}"
    ```
    *(Let's assume the output gives us `sg-xxxxxxxx` for public and `sg-yyyyyyyy` for private)*

2.  **Add Inbound Rules (The Four Moves):**
    The following four commands were executed to create the security group rules.

    *   **Move 1: Allow HTTP from Private to Public**
        ```bash
        aws ec2 authorize-security-group-ingress \
          --group-id <ID_OF_PUBLIC_SG> \
          --protocol tcp \
          --port 80 \
          --source-group <ID_OF_PRIVATE_SG>
        ```

    *   **Move 2: Allow ICMP from Private to Public**
        ```bash
        aws ec2 authorize-security-group-ingress \
          --group-id <ID_OF_PUBLIC_SG> \
          --protocol icmp \
          --port -1 \
          --source-group <ID_OF_PRIVATE_SG>
        ```

    *   **Move 3: Allow HTTP from Public to Private**
        ```bash
        aws ec2 authorize-security-group-ingress \
          --group-id <ID_OF_PRIVATE_SG> \
          --protocol tcp \
          --port 80 \
          --source-group <ID_OF_PUBLIC_SG>
        ```

    *   **Move 4: Allow ICMP from Public to Private**
        ```bash
        aws ec2 authorize-security-group-ingress \
          --group-id <ID_OF_PRIVATE_SG> \
          --protocol icmp \
          --port -1 \
          --source-group <ID_OF_PUBLIC_SG>
        ```

### Step 3: Verification

Verification was performed by connecting to each instance via EC2 Session Manager and testing connectivity to the other instance's private IP address.

1.  **Connect to Public Instance (`cmtr-zdv1y551-ec2-sg-instance-public1`):**
    *   Using Session Manager, started a shell session.
    *   Retrieved the private IP address of the private instance.
    *   Tested ICMP (ping): `ping -c 3 <private_instance_private_ip>` -> **Success** (received replies).
    *   Tested HTTP: `curl -I http://<private_instance_private_ip>` -> **Success** (received a response, even if it's "Connection refused" it means the traffic was not blocked by the security group).

2.  **Connect to Private Instance (`cmtr-zdv1y551-ec2-sg-instance-private1`):**
    *   Using Session Manager, started a shell session.
    *   Retrieved the private IP address of the public instance.
    *   Tested ICMP (ping): `ping -c 3 <public_instance_private_ip>` -> **Success** (received replies).
    *   Tested HTTP: `curl -I http://<public_instance_private_ip>` -> **Success**.

These tests confirm that two-way ICMP and HTTP traffic is flowing correctly between the instances as a result of the security group rules applied via the CLI.

---

## Task: Configuring EC2 User Data (CLI Method)

*This task demonstrates how to automate instance configuration at launch time using EC2 User Data within a Launch Template. The key is to create a script that dynamically fetches instance-specific information (like its ID and IP address) from the EC2 Instance Metadata Service and uses it to customize the application.*

### Step 1: Task Analysis & Strategy

The objective is to modify an existing Launch Template (`cmtr-zdv1y551-ec2-us-lt`) so that any new instance launched from it will automatically install Nginx and display a custom web page showing its own public IP and instance ID. The task must be completed in exactly "two moves" using the AWS CLI.

The strategy is as follows:

1.  **Prepare the User Data Script:** Create a shell script that performs the following actions:
    *   Installs the Nginx web server.
    *   Fetches the instance's ID and public IPv4 address from the Instance Metadata Service endpoint (`http://169.254.169.254/latest/meta-data/`).
    *   Writes this dynamic information into the `/usr/share/nginx/html/index.html` file.
    *   Starts and enables the Nginx service.

2.  **Execute the Two Moves:**
    *   **Move 1: Create a New Launch Template Version.** Use the `aws ec2 create-launch-template-version` command. This command will take the existing launch template and add our new user data script.
    *   **Move 2: Set the New Version as Default.** A new version isn't used automatically. We must use the `aws ec2 modify-launch-template` command to set the version number we received from Move 1 as the new default version. This ensures the Auto Scaling group will use our updated configuration for all future instances.

3.  **Trigger an Instance Refresh:** After the moves are complete, the Auto Scaling group must be told to replace its existing instances with new ones using the updated launch template. This is done via the `aws autoscaling start-instance-refresh` command.

### Step 2: Execution via AWS CLI

First, the environment was configured with the provided AWS credentials for the CLI.

> **PowerShell Note:** The following commands are tailored for PowerShell. Passing complex JSON data to external programs like `aws.exe` can be tricky due to how PowerShell handles quotes. The most reliable method is to generate the JSON and save it to a file, then reference that file.

1.  **Create the User Data Script File:**
    A local file named `user-data.sh` was created. The single quotes (`@'...'@`) are used to prevent PowerShell from interpreting the `$(...)` expressions inside the script.
    ```powershell
    @'
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    echo "WebServer (${PUBLIC_IP}) with ID: ${INSTANCE_ID}" > /usr/share/nginx/html/index.html
    systemctl start nginx
    systemctl enable nginx
    '@ | Set-Content -Path user-data.sh -Encoding ascii
    ```

2.  **Execute the Two Moves:**

    *   **Move 1: Create New Launch Template Version**
        To avoid PowerShell quoting issues, we first generate a valid JSON file (`template-data.json`) and then pass it to the AWS CLI.

        *   **A) Create `template-data.json` file:**
            ```powershell
            # Read the script and convert to Base64
            $userDataBase64 = [Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes((Get-Content -Path user-data.sh -Raw)))
            # Create a PowerShell object
            $launchTemplateDataObject = @{ UserData = $userDataBase64 }
            # Convert the object to a valid JSON file
            $launchTemplateDataObject | ConvertTo-Json -Compress | Set-Content -Path "template-data.json"
            ```

        *   **B) Create the new launch template version from the file:**
            ```powershell
            aws ec2 create-launch-template-version `
              --launch-template-name cmtr-zdv1y551-ec2-us-lt `
              --source-version '$Latest' `
              --version-description "Nginx user data with instance metadata" `
              --launch-template-data file://template-data.json
            ```
            From the JSON output of this command, the **`VersionNumber`** was noted. (e.g., `3`).

    *   **Move 2: Set New Version as Default**
        Using the version number from the previous step, the following command was run to make the new version the default.
        ```powershell
        aws ec2 modify-launch-template `
          --launch-template-name cmtr-zdv1y551-ec2-us-lt `
          --default-version <NEW_VERSION_NUMBER>
        ```
        *(Replace `<NEW_VERSION_NUMBER>` with the actual number from Move 1's output).*

### Step 3: Verification

1.  **Start Instance Refresh:**
    To apply the changes, an instance refresh was initiated. Note the escaped quotes (`\"`) in the `--preferences` argument, which is necessary for PowerShell to pass a valid JSON string to the AWS CLI.
    ```powershell
    aws autoscaling start-instance-refresh `
      --auto-scaling-group-name cmtr-zdv1y551-ec2-us-asg `
      --preferences '{\"MinHealthyPercentage\": 50}'
    ```
2.  **Check the New Instance:**
    *   Waited for the Auto Scaling group to terminate the old instance and launch a new one.
    *   Retrieved the public IP address of the new `cmtr-zdv1y551-ec2-us-instance-webserver` instance from the EC2 console.
    *   Navigated to the public IP in a web browser.
    *   The page correctly displayed the message in the format `WebServer (18.193.67.243) with ID: i-01b00136a14890932`, with the actual IP and ID of the new instance. This confirmed the user data script ran successfully.
