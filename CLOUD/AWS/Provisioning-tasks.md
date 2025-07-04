# AWS Provisioning Hands-On Labs

This document details the step-by-step solutions for hands-on labs focused on AWS Provisioning services like CloudFormation.

---

## Task: Create a basic infrastructure with CloudFormation

*This task walks through the process of authoring a complete CloudFormation template to define and deploy a basic, two-tier web architecture. It covers creating the necessary IAM roles, writing the template with parameters and resources, and deploying it as a stack via the AWS Management Console.*

### Step 1: Task Analysis & Strategy

The objective is to use Infrastructure as Code (IaC) principles to automatically provision a VPC containing two public subnets across two Availability Zones (`us-east-1a` and `us-east-1b`). Each subnet will host an EC2 instance running a simple web server. All resources must be tagged with a `Maintainer` tag passed as a parameter.

The strategy follows a logical progression, creating dependencies and authoring the template before deploying the stack:

1.  **Create IAM Role for CloudFormation:** The CloudFormation service needs permissions to create, modify, and delete AWS resources on our behalf. The first step is to create a dedicated IAM role in the console with `AdministratorAccess` and establish a trust relationship with the CloudFormation service.
2.  **Author the CloudFormation Template:** This is the core of the task. We will create a local YAML file (`template.yml`). This file will define:
    *   A `Maintainer` parameter to allow for customizable tagging.
    *   All necessary networking resources: a VPC, two public subnets, an Internet Gateway, and corresponding Route Tables and routes to make the subnets public.
    *   An IAM role and instance profile for the EC2 instances, granting them permissions for SSM access (`AmazonSSMManagedInstanceCore`).
    *   A Security Group to allow inbound HTTP (port 80) and SSH (port 22) traffic.
    *   Two EC2 instances, each placed in a different subnet. Their `UserData` scripts will install the `httpd` web server and create a unique `index.html` file indicating which AZ they are in.
    *   Tags for all resources, including the `Name` tag with the specified lab name and the `Maintainer` tag from the parameter.
3.  **Deploy the CloudFormation Stack:** Using the AWS Management Console, we will create a stack by uploading the `template.yml` file. We will provide the required stack name (`cmtr-zdv1y551-basic-infra`) and confirm the `Maintainer` parameter's default value.
4.  **Verify the Deployment:** After the stack creation completes, we will verify the infrastructure by checking the public endpoints of the EC2 instances and inspecting the tags on the created resources.

### Step 2: Execution via AWS Management Console & Local Template

#### Part A: Create CloudFormation Service Role

1.  Navigate to the **IAM** service dashboard in the AWS Console.
2.  Click on **Roles** > **Create role**.
3.  For **Trusted entity type**, select **AWS service**.
4.  Under **Use cases for other AWS services**, select **CloudFormation**. Click **Next**.
5.  In the permissions policies list, search for and select the `AdministratorAccess` policy. Click **Next**.
6.  **Role name:** Enter a descriptive name like `CloudFormationAdminRole`.
7.  Click **Create role**. *Note: For this lab, the stack might be created using your user's permissions, but creating a service role is the best practice.*

#### Part B: Author the `template.yml` File

Create a new file named `template.yml` on your local machine and paste the following content into it. This template defines all the required resources.

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: >-
  This template deploys a VPC with two public subnets, an Internet Gateway,
  and two EC2 instances running web servers.

Parameters:
  Maintainer:
    Type: String
    Default: Kerem_Ar
    Description: Name of the maintainer to apply as a tag to all resources.
  LatestAmiId:
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'
    Default: '/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2'
    Description: 'The latest Amazon Linux 2 AMI ID.'

Resources:
  # -- NETWORKING --

  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-vpc
        - Key: Maintainer
          Value: !Ref Maintainer

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-igw
        - Key: Maintainer
          Value: !Ref Maintainer

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

  Subnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: "us-east-1a"
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-subnet1
        - Key: Maintainer
          Value: !Ref Maintainer

  Subnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: "us-east-1b"
      CidrBlock: 10.0.2.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-subnet2
        - Key: Maintainer
          Value: !Ref Maintainer

  PublicRouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-public-rt1
        - Key: Maintainer
          Value: !Ref Maintainer

  PublicRoute1:
    Type: AWS::EC2::Route
    DependsOn: AttachGateway
    Properties:
      RouteTableId: !Ref PublicRouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  Subnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref Subnet1
      RouteTableId: !Ref PublicRouteTable1

  PublicRouteTable2:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-public-rt2
        - Key: Maintainer
          Value: !Ref Maintainer

  PublicRoute2:
    Type: AWS::EC2::Route
    DependsOn: AttachGateway
    Properties:
      RouteTableId: !Ref PublicRouteTable2
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  Subnet2RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref Subnet2
      RouteTableId: !Ref PublicRouteTable2

  # -- SECURITY & IAM --

  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: "Allow HTTP and SSH access"
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-sg
        - Key: Maintainer
          Value: !Ref Maintainer

  EC2InstanceRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: cmtr-zdv1y551-role
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service:
                - ec2.amazonaws.com
            Action:
              - 'sts:AssumeRole'
      ManagedPolicyArns:
        - 'arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore'
      Tags:
        - Key: Maintainer
          Value: !Ref Maintainer

  EC2InstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Path: /
      Roles:
        - !Ref EC2InstanceRole

  # -- EC2 INSTANCES --

  Instance1:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      ImageId: !Ref LatestAmiId
      SubnetId: !Ref Subnet1
      SecurityGroupIds:
        - !Ref SecurityGroup
      IamInstanceProfile: !Ref EC2InstanceProfile
      UserData:
        Fn::Base64: |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo "<h1>Hello from Region us-east-1a</h1>" > /var/www/html/index.html
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-instance1
        - Key: Maintainer
          Value: !Ref Maintainer

  Instance2:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      ImageId: !Ref LatestAmiId
      SubnetId: !Ref Subnet2
      SecurityGroupIds:
        - !Ref SecurityGroup
      IamInstanceProfile: !Ref EC2InstanceProfile
      UserData:
        Fn::Base64: |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo "<h1>Hello from Region us-east-1b</h1>" > /var/www/html/index.html
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-instance2
        - Key: Maintainer
          Value: !Ref Maintainer
```

#### Part C: Create the CloudFormation Stack

1.  Navigate to the **CloudFormation** service in the AWS Console.
2.  Click **Create stack** > **With new resources (standard)**.
3.  Under **Prerequisite - Prepare template**, select **Template is ready**.
4.  Under **Specify template**, select **Upload a template file**.
5.  Click **Choose file** and select the `template.yml` file you created locally. Click **Next**.
6.  **Stack name:** Enter `cmtr-zdv1y551-basic-infra`.
7.  **Parameters:** Review the `Maintainer` parameter. It should be pre-filled with `Kerem_Ar`. Click **Next**.
8.  On the **Configure stack options** page, you can leave the defaults. Click **Next**.
9.  On the final review page, scroll to the bottom. You must check the box that says **"I acknowledge that AWS CloudFormation might create IAM resources."** This is required because our template creates an IAM Role and Instance Profile.
10. Click **Create stack**.

### Step 3: Verification

1.  **Monitor Stack Creation:**
    *   In the CloudFormation console, wait for the stack status to change from `CREATE_IN_PROGRESS` to `CREATE_COMPLETE`. This may take a few minutes. If it fails, check the **Events** tab for error messages.

2.  **Verify Web Server on Instance 1:**
    *   Navigate to the **EC2** dashboard > **Instances**.
    *   Find `cmtr-zdv1y551-instance1`. Select it and copy its **Public IPv4 address**.
    *   Open a new browser tab and paste the IP address. You should see the message: **"Hello from Region us-east-1a"**.

3.  **Verify Web Server on Instance 2:**
    *   In the EC2 console, find `cmtr-zdv1y551-instance2`. Select it and copy its **Public IPv4 address**.
    *   Open another browser tab and paste the IP address. You should see the message: **"Hello from Region us-east-1b"**.

4.  **Verify Resource Tagging:**
    *   Navigate to the **VPC** dashboard.
    *   Select the `cmtr-zdv1y551-vpc` VPC.
    *   Click on the **Tags** tab and verify that you see two tags: one with `Key: Name` and `Value: cmtr-zdv1y551-vpc`, and another with `Key: Maintainer` and `Value: Kerem_Ar`.
    *   You can repeat this check for other resources like subnets or the security group to confirm they are also tagged correctly.
