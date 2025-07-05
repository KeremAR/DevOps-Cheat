# Task 1: Setup a Simple ECS Anywhere Cluster

## Lab Description
The goal of this task is to create a simple ECS Anywhere Cluster and register an external Linux OS Virtual Machine to it.

**Region:** `us-east-1`
**Cluster Name:** `cmtr-zdv1y551-cluster`

---

## Step-by-Step Guide

### Prerequisite: Prepare your Local Linux Virtual Machine

This is the most critical step. ECS Anywhere requires an external machine to act as a host.

1.  **Install a Virtualization Software:** Use a tool like [VirtualBox](https://www.virtualbox.org/) or VMware.
2.  **Install a Linux OS:** Download and install a supported Linux distribution. **Ubuntu Server 20.04 LTS** is a great choice.
3.  **Ensure Internet Access:** The VM must be able to connect to the internet to reach AWS endpoints.
4.  **Install `curl`:** Most server distributions have it by default. If not, install it:
    ```bash
    sudo apt update
    sudo apt install curl
    ```

**IMPORTANT:** The following steps will be performed in the AWS Console and inside your local Linux VM.

### Step 1: Create the ECS Anywhere Cluster in AWS

1.  Navigate to the **Elastic Container Service (ECS)** in the AWS Console. Make sure you are in the `us-east-1` (N. Virginia) region.
2.  In the left-hand navigation pane, click **Clusters**.
3.  Click the **Create cluster** button.
4.  For the cluster template, select **Networking only** (this is the template for ECS Anywhere). Click **Next step**.
5.  On the "Configure cluster" page:
    *   **Cluster name:** `cmtr-zdv1y551-cluster`
    *   Leave everything else as default.
6.  Click **Create**. You will see a confirmation that the cluster was created successfully.

### Step 2: Generate the Registration Command

Now we need to tell AWS about our external VM. AWS will give us a special command to run on the VM to "join" it to the cluster.

1.  Go into your newly created `cmtr-zdv1y551-cluster`.
2.  Click the **ECS Instances** tab.
3.  Click the **Register external instances** button.
4.  On the "Register external instances" page:
    *   **Activation key duration (in days):** Leave as `1`.
    *   **Number of instances to register with this key:** Leave as `1`.
    *   **Instance role:** This is the IAM Role the external VM will use to communicate with AWS.
        *   The correct role is `ecsExternalInstanceRole`.
        *   If you see it in the dropdown, select it.
        *   If you don't see it, the console should have a default option or a "Create new" button. **This is the correct option to choose.** It will automatically create the `ecsExternalInstanceRole` with the correct permissions for you.
        *   **Important:** Do NOT select other roles like `AWSServiceRoleForAmazonSSM`.
5.  Click **Next step**.
6.  You will now see a **Registration command**. It will look something like this:
    ```bash
    # THIS IS AN EXAMPLE! Use the command from YOUR console.
    curl -o "ecs-anywhere-install.sh" "https://amazon-ecs-agent.s3.amazonaws.com/ecs-anywhere-install-v1.sh" && \
    sudo bash ecs-anywhere-install.sh \
      --cluster "cmtr-zdv1y551-cluster" \
      --region "us-east-1" \
      --activation-id "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
      --activation-code "xxxxxxxxxx"
    ```
7.  **Click the copy icon** to copy this entire command to your clipboard. This command is only valid for a limited time.

### Step 3: Register your Local VM

Now, switch to your local Linux Virtual Machine's terminal.

1.  **Paste and run the command** you copied from the AWS console in the previous step.
2.  The script will download the necessary components (SSM Agent, ECS Agent), install them, and register your VM with the ECS cluster. You will see output logs showing the progress.

### Step 4: Verify the Registration

1.  Go back to the **AWS Console**.
2.  Navigate back to your ECS cluster: **ECS -> Clusters -> `cmtr-zdv1y551-cluster`**.
3.  Click the **ECS Instances** tab.
4.  You should now see your external instance listed!
    *   The **Container Instance** will have a long ID.
    *   The **Status** should be **ACTIVE**.
    *   The **Registered At** time should be recent.

You have successfully registered an external VM to an ECS Anywhere cluster.

---

# Task 2: Setup a Simple Task in a Custom ECS Anywhere Cluster

## Lab Description
The goal of this task is to create a simple ECS Anywhere task and run it on your local Linux Virtual Machine.

**Region:** `us-east-1`
**Cluster Name:** `cmtr-zdv1y551-cluster`
**Task Family:** `nginx-ecs`
**Container Name:** `zdv1y551-nginx`
**Image:** `nginx`
**Port Mapping:** `8080` (host) -> `80` (container)

---

## Step-by-Step Guide

### Step 1: Re-create the Cluster and Re-register your VM

Since each lab provides a new, empty AWS environment, you must create the cluster again and re-register your VM.

1.  **Create the Cluster:**
    *   Navigate to **ECS** in the `us-east-1` region.
    *   Click **Create cluster**.
    *   **Cluster name:** `cmtr-zdv1y551-cluster`
    *   **Template:** Select **Networking only**.
    *   Click **Create**.
2.  **Get a New Registration Command:**
    *   Go into the new cluster, click the **ECS Instances** tab, and then **Register external instances**.
    *   Follow the prompts to get a new registration command.
3.  **Re-register your VM:**
    *   Switch to your existing local Linux VM.
    *   Run the **new command** you just copied. This will connect your VM to the new cluster.
4.  Verify in the AWS console that your instance appears under the **ECS Instances** tab with an **ACTIVE** status before proceeding.

### Step 2: Create the Task Execution IAM Role

This role allows ECS to pull container images for your tasks.

1.  Navigate to **IAM** in the AWS Console.
2.  Go to **Roles** and click **Create role**.
3.  **Select trusted entity:** Choose **AWS service**.
4.  **Use case:** Under "Common use cases", select **Elastic Container Service**.
5.  Below that, select **Elastic Container Service Task**. Click **Next**.
6.  **Add permissions:** The `AmazonECSTaskExecutionRolePolicy` should already be selected. Click **Next**.
7.  **Name, review, and create:**
    *   **Role name:** `ecsTaskExecutionRole`
    *   Review the details and click **Create role**.
8.  **Important:** After creating the role, click on its name in the role list and **copy its ARN**. You will need it in the next step. It will look like `arn:aws:iam::135808935480:role/ecsTaskExecutionRole`.

### Step 3: Create the Task Definition (Using JSON)

For ECS Anywhere, we must specify `"EXTERNAL"` as the launch type, which is easiest to do via the JSON editor.

1.  In the ECS console, go to **Task Definitions** and click **Create new task definition** -> **Create new task definition with JSON**.
2.  Delete the template JSON in the editor and **paste the following JSON**.
3.  **Crucially, replace `"PASTE_YOUR_EXECUTION_ROLE_ARN_HERE"`** with the ARN you copied in the previous step.

```json
{
    "family": "nginx-ecs",
    "containerDefinitions": [
        {
            "name": "zdv1y551-nginx",
            "image": "nginx",
            "cpu": 256,
            "memory": 512,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 8080,
                    "protocol": "tcp"
                }
            ],
            "essential": true
        }
    ],
    "taskRoleArn": null,
    "executionRoleArn": "PASTE_YOUR_EXECUTION_ROLE_ARN_HERE",
    "networkMode": "bridge",
    "requiresCompatibilities": [
        "EXTERNAL"
    ],
    "cpu": "256",
    "memory": "512"
}
```

4.  Click **Create**.

### Step 4: Create the Service

The service will run and maintain our task on the registered VM.

1.  Navigate back to your cluster: **ECS -> Clusters -> `cmtr-zdv1y551-cluster`**.
2.  Under the **Services** tab, click **Create**.
3.  **Deployment configuration:**
    *   **Launch type:** Select **EXTERNAL**.
    *   **Task Definition Family:** Select `nginx-ecs`. The revision should be `1 (latest)`.
    *   **Service name:** `nginx-service`
    *   **Desired tasks:** `1`
4.  Leave all other settings as default and click **Create**.

### Step 5: Verify the Deployment

1.  The service will now deploy the task to your registered external VM. This can take a minute. You can see the task status under the **Tasks** tab of your cluster. It should eventually show a **RUNNING** status.
2.  Once the task is running, switch to your **local Linux VM's terminal**.
3.  Run the following command to check if the Nginx container is listening on port 8080:
    ```bash
    curl http://localhost:8080
    ```
4.  You should see the HTML source of the **"Welcome to nginx!"** page. This confirms your container is running correctly and the port is mapped.

---

## 💡 Troubleshooting: VM Registration Fails or Instance Not Appearing

If you are re-using a Virtual Machine from a previous lab, you may encounter an issue where the registration script seems to succeed, but the instance never appears in the new AWS account's ECS console.

**Symptom:** The script might time out waiting for the ECS agent, or worse, it might claim to succeed but register itself to the **old AWS Account ID**.

**Cause:** The VM still has configuration files and registered agents from the previous lab. The install script does not automatically clean these up.

**Solution: Perform a Full Manual Cleanup**

Before running the registration command for the new lab, run the following commands on your local Linux VM to completely remove all traces of the old installation.

**1. Stop the Services:**
```bash
sudo systemctl stop ecs
sudo systemctl stop amazon-ssm-agent
```

**2. Purge the Agent Packages:**
This completely removes the applications and their system-wide configuration files.
```bash
sudo apt-get purge -y amazon-ssm-agent
sudo apt-get purge -y amazon-ecs-init
```

**3. Delete Leftover Directories:**
This removes any remaining data, logs, or credentials.
```bash
sudo rm -rf /var/lib/ecs/ /var/log/ecs/ /etc/ecs/
sudo rm -rf /var/lib/amazon/ /var/log/amazon/ /etc/amazon/
```

After these cleanup steps, your VM is in a fresh state. You can now run the new registration command from the current lab, and it will register to the correct AWS account.
