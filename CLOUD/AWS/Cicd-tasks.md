# Task: Configure Service Deployment with CodeBuild and CodeDeploy

This guide provides a step-by-step walkthrough for configuring a full CI/CD pipeline to deploy a Dockerized application using AWS CodeBuild and AWS CodeDeploy.

**Lab Architecture:**

1.  **Local Files:** You will create several configuration files: `Dockerfile`, `buildspec.yml`, `appspec.yml`, and deployment scripts.
2.  **CodeBuild:**
    *   The `Dockerfile` and `buildspec.yml` are uploaded to an S3 bucket.
    *   CodeBuild uses these files to build a Docker image.
    *   The resulting image is pushed to a private ECR repository.
3.  **CodeDeploy:**
    *   The `appspec.yml` and deployment scripts are uploaded to the S3 bucket.
    *   An EC2 instance is launched with the CodeDeploy agent installed.
    *   CodeDeploy pulls the artifact from S3, runs the scripts on the EC2 instance, which in turn pulls the Docker image from ECR and runs it.

---

## Part 0: Prerequisites (Local File Creation)

Before heading to the AWS console, create the following files on your local machine. This will make the process smoother.

### 1. CodeBuild Source Files

Create a directory named `codebuild-source`. Inside it, create these two files:

**`Dockerfile`**
This file defines our simple web server application. Note the use of `apache2`, which is the correct package name for Alpine Linux.

```dockerfile
FROM alpine
RUN apk update && apk add apache2
EXPOSE 80
RUN echo "cmtr-zdv1y551" > /var/www/localhost/htdocs/index.html
CMD ["httpd", "-D", "FOREGROUND"]
```

**`buildspec.yml`**
This file tells CodeBuild how to build the Docker image and push it to ECR. Note how we dynamically get the Account ID.

```yaml
version: 0.2
phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      # The AWS_ACCOUNT_ID variable is not automatically available in CodeBuild.
      # We retrieve it using the AWS CLI and store it in a variable.
      - AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
      - docker build -t cmtr-zdv1y551:alpine-httpd .
      - docker tag cmtr-zdv1y551:alpine-httpd $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cmtr-zdv1y551:alpine-httpd
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cmtr-zdv1y551:alpine-httpd
```

### 2. CodeDeploy Source Files

Create another directory named `codedeploy-source`. Inside it, create these three files:

**`install_dependencies.sh`**
This script installs Docker on the EC2 instance and pulls the image from ECR.

```bash
#!/bin/bash
set -e
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

# Login to ECR and pull the image. Replace <ACCOUNT_ID> with your AWS Account ID.
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 156041430087.dkr.ecr.us-east-1.amazonaws.com
docker pull 156041430087.dkr.ecr.us-east-1.amazonaws.com/cmtr-zdv1y551:alpine-httpd
```

**`run_app.sh`**
This script runs the Docker container. It's written to handle re-deployments safely.

```bash
#!/bin/bash
set -e
# Stop and remove existing container if it exists
if [ "$(docker ps -q -f name=alpine-httpd-app)" ]; then
    docker stop alpine-httpd-app
    docker rm alpine-httpd-app
fi

# Run the new container. Replace <ACCOUNT_ID> with your AWS Account ID.
docker run -d --name alpine-httpd-app -p 80:80 156041430087.dkr.ecr.us-east-1.amazonaws.com/cmtr-zdv1y551:alpine-httpd
```

**`appspec.yml`**
This is the **correct and final version** of the file. It orchestrates the deployment by running scripts directly from the deployment bundle, avoiding lifecycle timing issues.

```yaml
version: 0.0
os: linux
# The 'files' section is removed because we will run the scripts directly
# from the bundle, which is a cleaner approach and avoids lifecycle hook timing issues.
hooks:
  BeforeInstall:
    # This hook runs BEFORE files are copied.
    # We point to the script's location relative to the root of the zip bundle.
    - location: install_dependencies.sh
      timeout: 300
      runas: root
  ApplicationStart:
    # This hook runs AFTER the 'Install' phase.
    # We will also run this from the bundle for consistency.
    - location: run_app.sh
      timeout: 300
      runas: root
```

### 3. Zip the Artifacts


**Correct Method (GUI):**
1.  Go **inside** the `codebuild-source` folder.
2.  Select all files (`Dockerfile`, `buildspec.yml`).
3.  Right-click and "Send to > Compressed (zipped) folder". Name it `codebuild-source.zip`.
4.  Repeat the same process for the files inside the `codedeploy-source` folder to create `codedeploy-artifact.zip`.

---

## Part 1: CodeBuild - Build and Push Docker Image

**Goal:** Build the Docker image and push it to a private ECR repository.

1.  **Create ECR Repository:**
    *   Navigate to the **ECR** service in the AWS Console.
    *   Create a new **private** repository named `cmtr-zdv1y551`.

2.  **Create S3 Bucket:**
    *   Navigate to the **S3** service.
    *   Create a new bucket. The name must be globally unique (e.g., `cmtr-zdv1y551-artifacts-` followed by random characters). Note this name for later.
    *   Upload the `codebuild-source.zip` file to this bucket.

3.  **Create IAM Role for CodeBuild:**
    *   Navigate to the **IAM** service.
    *   Go to **Roles** and click **Create role**.
    *   **Trusted entity type:** AWS service.
    *   **Use case:** **CodeBuild**.
    *   **Permissions:** Attach the `AdministratorAccess` policy (as required by the lab).
    *   **Role name:** `cmtr-zdv1y551-cb`.

4.  **Create CodeBuild Project:**
    *   Navigate to the **CodeBuild** service.
    *   Click **Create build project**.
    *   **Project name:** `cmtr-zdv1y551-project`.
    *   **Source:** Select **Amazon S3**.
    *   **Bucket:** Choose the S3 bucket you created in step 2.
    *   **S3 object key:** Enter the name of your zip file, `codebuild-source.zip`.
    *   **Buildspec:** Select **Use a buildspec file**. (If a name is requested, leave it as `buildspec.yml`).
    *   **Environment:**
        *   Environment image: **Managed image**.
        *   Operating system: **Amazon Linux 2**.
        *   Runtime: **Standard**.
        *   Image: Choose a recent version like `aws/codebuild/standard:5.0`.
        *   **Check the "Privileged" box.** This is required to build Docker images.
    *   **Service role:** Choose **Existing service role** and select `cmtr-zdv1y551-cb`.
    *   Leave other settings as default and click **Create build project**.

5.  **Run the Build:**
    *   Once the project is created, click **Start build**.
    *   Monitor the build logs. If successful, you will see it pushing the image to ECR.
    *   Verify by going to your ECR repository and checking that the `alpine-httpd` image exists.

---

## Part 2: CodeDeploy - Deploy Application to EC2

**Goal:** Deploy the Docker container from ECR onto a running EC2 instance.

1.  **Create IAM Roles for EC2 and CodeDeploy:**
    *   **EC2 Role:**
        *   Create a new role for the **EC2** use case.
        *   Attach the following AWS managed policies: `AmazonSSMManagedInstanceCore`, `AmazonEC2ContainerRegistryReadOnly`, and `AmazonS3ReadOnlyAccess`. The S3 access is for the CodeDeploy agent to pull the deployment files.
        *   Name the role something descriptive, like `EC2-SSM-ECR-S3-Role`. (Note: The lab may have pre-created this role).
    *   **CodeDeploy Role:**
        *   Create a new role for the **CodeDeploy** use case.
        *   Select the **CodeDeploy** use case from the list.
        *   Attach the `AWSCodeDeployRole` policy.
        *   Name the role `CodeDeployRole`.

2.  **Launch EC2 Instance:**
    *   Navigate to the **EC2** service.
    *   Click **Launch instances**.
    *   **Name and tags:** Add two tags:
        *   **Key:** `Name`, **Value:** `cmtr-zdv1y551-instance`.
        *   **Key:** `app`, **Value:** `alpine-httpd`.
    *   **AMI:** Amazon Linux 2 (ensure it's a standard one).
    *   **Instance type:** `t2.micro` is sufficient.
    *   **Key pair:** Proceed without a key pair (we will use Session Manager).
    *   **Network settings:**
        *   VPC: Select the `cmtr-zdv1y551-vpc` or similar lab VPC.
        *   Subnet: `cmtr-zdv1y551-public_subnet`.
        *   Auto-assign public IP: **Enable**.
        *   Firewall (security groups): Create a new security group that allows **HTTP** traffic from anywhere (`0.0.0.0/0`) so you can test the web server.
    *   **Advanced details:**
        *   **IAM instance profile:** Select the EC2 role you created (`EC2-SSM-ECR-S3-Role`).
        *   Scroll down to **User data** and paste the following script. This installs the CodeDeploy agent on boot.
        ```bash
        #!/bin/bash
        yum update -y
        yum install -y ruby wget
        cd /home/ec2-user
        wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
        chmod +x ./install
        ./install auto
        service codedeploy-agent start
        ```
    *   Launch the instance.

3.  **Upload CodeDeploy Artifact to S3:**
    *   Go back to your S3 bucket.
    *   Upload the `codedeploy-artifact.zip` file.

4.  **Create CodeDeploy Application:**
    *   Navigate to the **CodeDeploy** service.
    *   Click **Create application**.
    *   **Application name:** `cd-alpine-httpd`.
    *   **Compute platform:** **EC2/On-Premises**.
    *   Click **Create application**.

5.  **Create Deployment Group:**
    *   Inside your new application, click **Create deployment group**.
    *   **Deployment group name:** `cd-alpine-httpd`.
    *   **Service role:** Select the `CodeDeployRole` you created.
    *   **Deployment type:** **In-place**.
    *   **Environment configuration:**
        *   Select **Amazon EC2 instances**.
        *   **Key:** `app`, **Value:** `alpine-httpd`. This tag is how CodeDeploy finds your instance.
    *   **Deployment settings:** Leave `CodeDeployDefault.OneAtATime`.
    *   **Load Balancer:** Uncheck "Enable load balancing".
    *   Click **Create deployment group**.

6.  **Create and Run the Deployment:**
    *   Click **Create deployment**.
    *   **Deployment group:** `cd-alpine-httpd` should be selected.
    *   **Revision type:** **My application is stored in Amazon S3**.
    *   **Revision location:** `s3://<YOUR_BUCKET_NAME>/codedeploy-artifact.zip`. Replace `<YOUR_BUCKET_NAME>` with the name of your bucket. (Tip: Copy the S3 URI directly from the S3 console to avoid typos).
    *   Click **Create deployment**.

---

## Part 3: Verification and Cleanup

1.  **Monitor Deployment:** Watch the deployment progress in the CodeDeploy console. It should go through the hooks defined in `appspec.yml` and eventually succeed.

2.  **Verify Application:**
    *   Navigate to the **EC2** console, select your instance, and copy its **Public IPv4 address**.
    *   Paste this IP address into your web browser. You should see the text `cmtr-zdv1y551`.
    *   Alternatively, you can connect to the instance using **Session Manager** and run `curl localhost:80`.

3.  **Cleanup:**
    *   Follow the lab instructions to delete all created resources (CodeDeploy application, CodeBuild project, ECR repository, S3 bucket contents and bucket, IAM roles, and the EC2 instance) to avoid incurring costs.
