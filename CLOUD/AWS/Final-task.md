# Final Task: Implement Gitea with Docker Compose on AWS using CloudFormation

This document provides a comprehensive, step-by-step guide for deploying a scalable Gitea application on AWS. The entire infrastructure will be provisioned automatically using a CloudFormation template.

---

### Step 1: Task Analysis & Strategy

The objective is to create a robust, highly available, and scalable Gitea service. We will use AWS CloudFormation to automate the provisioning of a complete, production-ready environment. This Infrastructure as Code (IaC) approach ensures consistency, repeatability, and efficient management.

The architecture consists of several key components working together:
- **VPC & Networking:** A custom VPC with public and private subnets across two Availability Zones (`us-east-1a`, `us-east-1b`) provides network isolation and high availability. The public subnets host the Application Load Balancer, while the application and database servers run in the private subnets for security. A NAT Gateway allows services in the private subnets to access the internet for software updates without being publicly exposed.
- **Application Tier:** An Auto Scaling Group manages a fleet of EC2 instances running the Gitea application within Docker containers. This allows the application to scale in or out based on traffic, ensuring performance and cost-efficiency.
- **Load Balancing:** An Application Load Balancer (ALB) sits in front of the EC2 instances, distributing incoming HTTP requests across the available instances and providing a single DNS endpoint for users.
- **Shared Storage:** An Elastic File System (EFS) is used to store Gitea's repository data. By mounting the same EFS volume to all EC2 instances, we ensure that data is consistent and shared across the entire fleet.
- **Database:** An RDS for MySQL instance (`db.t3.micro`) serves as the database for Gitea, storing user information, repository metadata, and other application data. Running the database in private subnets enhances security.
- **Monitoring:** A CloudWatch Dashboard is created to provide real-time visibility into the health and performance of critical resources like the ALB, RDS database, and EFS.

The execution strategy involves three main phases:
1.  **Prepare AWS Environment:** Create an IAM role that grants CloudFormation the necessary permissions to provision resources.
2.  **Deploy Infrastructure:** Launch the CloudFormation stack using the provided `cmtr-zdv1y551-final.yml` template. This single step will build the entire infrastructure stack.
3.  **Configure & Verify Application:** Perform the initial Gitea setup through its web interface and verify that all components are working correctly.

---

### Step 2: Execution: Creating and Deploying the CloudFormation Stack

#### Part 1: Create an IAM Role for CloudFormation

CloudFormation needs explicit permissions to create, modify, and delete AWS resources on your behalf. We will create a dedicated IAM role for this purpose.

1.  Navigate to the **IAM service** in the AWS Management Console.
2.  Go to **Roles** in the left navigation pane and click **Create role**.
3.  For **Trusted entity type**, select **AWS service**.
4.  Under **Use case**, choose **CloudFormation**. Click **Next**.
5.  On the **Add permissions** page, search for and select the `AdministratorAccess` policy. Click **Next**.
6.  For **Role name**, enter `CloudFormationAdminRole`.
7.  Review the details and click **Create role**.

#### Part 2: Prepare the CloudFormation Template

The complete CloudFormation template required for this task is provided below. You can save this content as `cmtr-zdv1y551-final.yml` on your local machine.

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: >
  Deploys a highly available, scalable Gitea application on AWS using CloudFormation.
  This stack provisions a VPC with public and private subnets, an Application Load Balancer,
  an Auto Scaling group of EC2 instances, an RDS MySQL database for data persistence,
  and an EFS file system for shared data storage.

Parameters:
  GiteaDBPassword:
    Type: String
    Description: The password for the Gitea RDS database.
    NoEcho: true
    MinLength: 8
    AllowedPattern: "[a-zA-Z0-9]+"
    ConstraintDescription: must contain only letters and numbers.

Resources:
  # ----------------------------------------------------------------
  # VPC & Networking
  # ----------------------------------------------------------------
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-vpc

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: us-east-1a
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-pub-sub1

  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.2.0/24
      AvailabilityZone: us-east-1b
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-pub-sub2

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.3.0/24
      AvailabilityZone: us-east-1a
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-priv-sub1

  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.4.0/24
      AvailabilityZone: us-east-1b
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-priv-sub2

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-igw

  VPCGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

  ElasticIP:
    Type: AWS::EC2::EIP
    Properties:
      Domain: vpc

  NatGateway:
    Type: AWS::EC2::NatGateway
    Properties:
      AllocationId: !GetAtt ElasticIP.AllocationId
      SubnetId: !Ref PublicSubnet1
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-nat

  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-public-rt1

  PublicRoute:
    Type: AWS::EC2::Route
    DependsOn: VPCGatewayAttachment
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet1
      RouteTableId: !Ref PublicRouteTable

  PublicSubnet2RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet2
      RouteTableId: !Ref PublicRouteTable

  PrivateRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-private-rt1

  PrivateRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PrivateRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NatGateway

  PrivateSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PrivateSubnet1
      RouteTableId: !Ref PrivateRouteTable

  PrivateSubnet2RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PrivateSubnet2
      RouteTableId: !Ref PrivateRouteTable

  # ----------------------------------------------------------------
  # Security Groups
  # ----------------------------------------------------------------
  ALBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: cmtr-zdv1y551-alb-sg
      GroupDescription: "Allow HTTP traffic from anywhere"
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-alb-sg

  EC2SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: cmtr-zdv1y551-ec2-sg
      GroupDescription: "Allow traffic from ALB and SSH"
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          SourceSecurityGroupId: !Ref ALBSecurityGroup
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0 # For simplicity; in production, lock this down
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-ec2-sg

  RDSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: cmtr-zdv1y551-rds-sg
      GroupDescription: "Allow MySQL traffic from EC2 instances"
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          SourceSecurityGroupId: !Ref EC2SecurityGroup
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-rds-sg

  EFSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: cmtr-zdv1y551-efs-sg
      GroupDescription: "Allow NFS traffic from EC2 instances"
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 2049
          ToPort: 2049
          SourceSecurityGroupId: !Ref EC2SecurityGroup
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-efs-sg

  # ----------------------------------------------------------------
  # IAM Role & Profile
  # ----------------------------------------------------------------
  EC2IAMRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: cmtr-zdv1y551-role
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
        - arn:aws:iam::aws:policy/AdministratorAccess # As per task requirement

  EC2InstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      InstanceProfileName: cmtr-zdv1y551-profile
      Roles:
        - !Ref EC2IAMRole

  # ----------------------------------------------------------------
  # EFS (Elastic File System)
  # ----------------------------------------------------------------
  EFSFileSystem:
    Type: AWS::EFS::FileSystem
    Properties:
      Encrypted: true
      PerformanceMode: generalPurpose
      FileSystemTags:
        - Key: Name
          Value: cmtr-zdv1y551-efs

  EFSMountTarget1:
    Type: AWS::EFS::MountTarget
    Properties:
      FileSystemId: !Ref EFSFileSystem
      SubnetId: !Ref PrivateSubnet1
      SecurityGroups:
        - !Ref EFSSecurityGroup

  EFSMountTarget2:
    Type: AWS::EFS::MountTarget
    Properties:
      FileSystemId: !Ref EFSFileSystem
      SubnetId: !Ref PrivateSubnet2
      SecurityGroups:
        - !Ref EFSSecurityGroup

  # ----------------------------------------------------------------
  # RDS Database
  # ----------------------------------------------------------------
  DBSubnetGroup:
    Type: AWS::RDS::DBSubnetGroup
    Properties:
      DBSubnetGroupDescription: "Subnet group for Gitea RDS"
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-rds-subnet-group

  RDSInstance:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: giteadb
      DBName: giteadb
      Engine: mysql
      EngineVersion: '8.0'
      DBInstanceClass: db.t3.micro
      AllocatedStorage: '20'
      MasterUsername: giteaadmin
      MasterUserPassword: !Ref GiteaDBPassword
      VPCSecurityGroups:
        - !Ref RDSSecurityGroup
      DBSubnetGroupName: !Ref DBSubnetGroup
      MultiAZ: false
      PubliclyAccessible: false
      StorageType: gp2
      DeleteAutomatedBackups: true
      Tags:
        - Key: Name
          Value: giteadb
    DeletionPolicy: Delete # For easy cleanup in this task

  # ----------------------------------------------------------------
  # ALB (Application Load Balancer)
  # ----------------------------------------------------------------
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: cmtr-zdv1y551-alb
      Scheme: internet-facing
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
      SecurityGroups:
        - !Ref ALBSecurityGroup
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-alb

  ALBTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    Properties:
      Name: cmtr-zdv1y551-tg
      VpcId: !Ref VPC
      Protocol: HTTP
      Port: 80
      HealthCheckProtocol: HTTP
      HealthCheckPath: /
      Matcher:
        HttpCode: '200,302' # Gitea redirects on /
      TargetType: instance
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-tg

  ALBListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Protocol: HTTP
      Port: 80
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref ALBTargetGroup

  # ----------------------------------------------------------------
  # EC2 Launch Template & Auto Scaling
  # ----------------------------------------------------------------
  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName: cmtr-zdv1y551-launch-template
      LaunchTemplateData:
        InstanceType: t2.micro
        ImageId: ami-05ffe3c48a9991133
        SecurityGroupIds:
          - !Ref EC2SecurityGroup
        IamInstanceProfile:
          Arn: !GetAtt EC2InstanceProfile.Arn
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash -xe
            # Install necessary packages
            yum update -y
            yum install -y docker nfs-utils
            
            # Start and enable Docker
            systemctl start docker
            systemctl enable docker
            usermod -a -G docker ec2-user
            
            # Install Docker Compose
            DOCKER_CONFIG="/usr/local/lib/docker"
            mkdir -p $DOCKER_CONFIG/cli-plugins
            curl -SL https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
            chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

            # Create and mount EFS
            mkdir -p /gitea
            mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${EFSFileSystem}.efs.${AWS::Region}.amazonaws.com:/ /gitea
            echo "${EFSFileSystem}.efs.${AWS::Region}.amazonaws.com:/ /gitea nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
            
            # Set permissions for Gitea container user (UID 1000)
            chown 1000:1000 /gitea -R

            # Create docker-compose.yml
            cat <<EOF > /gitea/docker-compose.yml
            version: "3"
            services:
              gitea:
                image: gitea/gitea:latest
                container_name: gitea
                environment:
                  - USER_UID=1000
                  - USER_GID=1000
                  - GITEA__database__DB_TYPE=mysql
                  - GITEA__database__HOST=${RDSInstance.Endpoint.Address}:${RDSInstance.Endpoint.Port}
                  - GITEA__database__NAME=giteadb
                  - GITEA__database__USER=giteaadmin
                  - GITEA__database__PASSWD=${GiteaDBPassword}
                restart: always
                volumes:
                  - /gitea:/data
                  - /etc/timezone:/etc/timezone:ro
                  - /etc/localtime:/etc/localtime:ro
                ports:
                  - "80:3000"
                  - "2222:22"
            EOF

            # Run docker-compose
            cd /gitea
            docker compose up -d

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber
      MinSize: '2'
      MaxSize: '4'
      DesiredCapacity: '2'
      TargetGroupARNs:
        - !Ref ALBTargetGroup
      Tags:
        - Key: Name
          Value: cmtr-zdv1y551-asg-instance
          PropagateAtLaunch: true

  ScaleUpPolicy:
    Type: AWS::AutoScaling::ScalingPolicy
    Properties:
      AutoScalingGroupName: !Ref AutoScalingGroup
      PolicyType: TargetTrackingScaling
      TargetTrackingConfiguration:
        PredefinedMetricSpecification:
          PredefinedMetricType: ALBRequestCountPerTarget
          ResourceLabel: !Join ['', [!GetAtt ApplicationLoadBalancer.LoadBalancerFullName, '/', !GetAtt ALBTargetGroup.TargetGroupFullName]]
        TargetValue: 10.0

  # ----------------------------------------------------------------
  # CloudWatch Dashboard
  # ----------------------------------------------------------------
  CloudWatchDashboard:
    Type: AWS::CloudWatch::Dashboard
    Properties:
      DashboardName: cmtr-zdv1y551-dashboard
      DashboardBody: !Sub |
        {
          "widgets": [
            {
              "type": "metric",
              "x": 0,
              "y": 0,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${RDSInstance}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${AWS::Region}",
                "title": "RDS CPU Utilization",
                "period": 300
              }
            },
            {
              "type": "metric",
              "x": 12,
              "y": 0,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${RDSInstance}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${AWS::Region}",
                "title": "RDS Database Connections",
                "period": 300
              }
            },
            {
              "type": "metric",
              "x": 0,
              "y": 6,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", "${ApplicationLoadBalancer.LoadBalancerFullName}", "TargetGroup", "${ALBTargetGroup.TargetGroupFullName}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${AWS::Region}",
                "title": "ALB Healthy Host Count",
                "period": 300
              }
            },
            {
              "type": "metric",
              "x": 12,
              "y": 6,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${ApplicationLoadBalancer.LoadBalancerFullName}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${AWS::Region}",
                "title": "ALB Request Count",
                "period": 300
              }
            },
            {
              "type": "metric",
              "x": 0,
              "y": 12,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/EFS", "ClientConnections", "FileSystemId", "${EFSFileSystem}" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${AWS::Region}",
                "title": "EFS Client Connections",
                "period": 300
              }
            }
          ]
        }

Outputs:
  ALBDNSName:
    Description: The DNS name of the Application Load Balancer
    Value: !GetAtt ApplicationLoadBalancer.DNSName
  CloudWatchDashboardURL:
    Description: URL of the CloudWatch Dashboard
    Value: !Sub "https://console.aws.amazon.com/cloudwatch/home?region=${AWS::Region}#dashboards:name=${CloudWatchDashboard}"
```

#### Part 3: Deploy the Stack

Now we will use the template file to launch the stack.

1.  Navigate to the **CloudFormation** service in the AWS Management Console. Make sure you are in the `us-east-1` (N. Virginia) region.
2.  Click **Create stack** and select **With new resources (standard)**.
3.  Under **Prerequisite - Prepare template**, choose **Template is ready**.
4.  Under **Specify template**, select **Upload a template file**.
5.  Click **Choose file** and select the `cmtr-zdv1y551-final.yml` file from your local machine.
6.  Click **Next**.
7.  On the **Specify stack details** page:
    *   **Stack name:** `cmtr-zdv1y551-final`.
    *   **Parameters:** You will see a parameter for `GiteaDBPassword`. Enter a secure password for the database. **This password must be at least 8 characters long and contain only alphanumeric characters (letters and numbers).**
8.  Click **Next**.
9.  On the **Configure stack options** page:
    *   Scroll down to **Permissions** and choose the `CloudFormationAdminRole` you created in Part 1.
    *   Leave all other options as default and click **Next**.
10. Review all the details on the final page. Scroll to the bottom, acknowledge that CloudFormation will create IAM resources by checking the box, and click **Submit**.

The stack creation process will now begin. You can monitor its progress in the **Events** tab. The status will change from `CREATE_IN_PROGRESS` to `CREATE_COMPLETE`. This process can take around **15-20 minutes** as it provisions all the resources, including the RDS database and EC2 instances.

---

### Step 3: Post-Deployment & Gitea Configuration

Once the stack status is `CREATE_COMPLETE`, the infrastructure is ready, and the Gitea application is running.

#### Part 1: Get the Application URL

1.  In the **CloudFormation** console, select your `cmtr-zdv1y551-final` stack.
2.  Go to the **Outputs** tab.
3.  Copy the value for the key `ALBDNSName`. This is the public URL for your Gitea application.

#### Part 2: Gitea Installation

1.  Paste the `ALBDNSName` URL into your web browser. You should see the Gitea installation page.
2.  The CloudFormation `UserData` script has already configured the `docker-compose.yml` file with the correct database credentials. You just need to configure the application's general settings and create an administrator account.
3.  On the installation page, verify the following:
    *   **Database Type:** Should be `MySQL`.
    *   **Host:** Should be pre-filled with the RDS endpoint address.
    *   **User, Password, Database Name:** These should also be pre-filled.
4.  Scroll down to **General Settings**.
    *   **Server Domain:** Enter the `ALBDNSName` you copied from the CloudFormation outputs.
    *   **Gitea Base URL:** Enter `http://` followed by your `ALBDNSName`. For example: `http://cmtr-zdv1y551-alb-123456789.us-east-1.elb.amazonaws.com/`
5.  Scroll down to **Administrator Account Settings**.
    *   Create an administrator account by providing a username, email, and password. This will be the master account for your Gitea instance.
6.  Click the **Install Gitea** button. After a moment, you will be redirected to the login page.

#### Part 3: Complete Final Task Steps

1.  Log in to Gitea using the administrator account you just created.
2.  In the top right corner, click your profile icon, go to **Site Administration** -> **User Accounts**, and click **Create Account**.
3.  Create a new user with the username `epamuser`. Fill in the required details.
4.  Log out from the admin account and log in as `epamuser`.
5.  On the dashboard, click the `+` icon in the top right and select **New Repository**.
6.  Enter `awsgiteaproject` as the repository name and click **Create Repository**.

---

### Step 4: Verification

You have now successfully deployed and configured the Gitea application.
- The application is accessible via the ALB's public DNS name.
- It is running on a scalable and resilient infrastructure managed by an Auto Scaling Group.
- All repository data is persisted on EFS, and application data is stored in the RDS database.
- You can monitor the health of your application by navigating to the **CloudWatch** service and viewing the `cmtr-zdv1y551-dashboard` that was created by the stack.

To complete the lab, use the **Verify task** buttons in your lab environment to have your solution checked.
