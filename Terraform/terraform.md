# Terraform Interview Notes

## What is Terraform?
- **IaC Tool**: An "Infrastructure as Code" tool developed by Hashicorp.
- **Declarative**: You define the *desired end state* of your infrastructure, and Terraform figures out how to get there.
- **HCL**: Uses the Hashicorp Configuration Language (HCL), designed to be human-readable.
- **Execution Plan**: Creates an execution plan for your approval before making any changes.
- **State Management**: Keeps track of the infrastructure it manages in a "state" file.
- **Multi-Cloud**: Supports a wide range of providers, not just major cloud providers but also services like Kubernetes, Helm, and Vault.

## Why Infrastructure as Code (IaC)?
- **Speed**: Build and replicate entire environments quickly and consistently.
- **Consistency**: Infrastructure is defined in code, which enables version control (Git), code reviews, and testing, reducing human error.
- **Scalability**: Easily manage infrastructure from a single server to large-scale clusters.
- **Cost Savings**: Automation and optimization of infrastructure lead to better cost management.
- **Security**: Enforce security policies as code and prevent configuration drift.

## Terraform vs. Other Tools

### Terraform vs. Ansible/Chef/Puppet
- **Terraform (Provisioning)**: Focuses on creating, modifying, and destroying servers, networks, and other infrastructure components. This is *building the house*.
- **Ansible (Configuration Management)**: Focuses on installing software, managing services, and configuring existing servers. This is *furnishing the house*.
- **Approach**: Terraform is designed for *immutable infrastructure*, where you replace resources with new ones instead of changing them. Configuration tools work with *mutable infrastructure*.

### Terraform vs. CloudFormation/ARM
- **Cloud-Agnostic**: Terraform works with many different cloud providers.
- **Vendor-Locked**: CloudFormation is specific to AWS, and ARM templates are specific to Azure.

## Core Concepts

### Terraform State
- **What it is**: A file (usually `terraform.tfstate`) that stores the mapping between your configuration and the real-world resources. It's a "database" of your managed infrastructure.
- **Purpose**: It tracks what Terraform has created, so it knows what to update or destroy later.
- **Location**:
    - **Local**: The default, but not suitable for teams.
    - **Remote**: Recommended for teams (e.g., using an AWS S3 bucket). Remote state provides locking to prevent concurrent changes and potential corruption.

### Providers
- **What they are**: Plugins that allow Terraform to interact with a specific API (cloud provider, SaaS provider, etc.).
- **How it works**: You declare a provider in your configuration, and Terraform downloads it during `terraform init`.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Resources
- **What they are**: The most important element. Each resource block defines one or more infrastructure objects, such as a VPC, an EC2 instance, or a DNS record.

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Example AMI
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}
```

### Variables
- **What they are**: Input parameters for your configuration, like function arguments. They make your code reusable.
- **How to use**: Declare a variable and then reference it using `var.<VARIABLE_NAME>`.

```hcl
variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type # Using the variable
}
```

### Outputs
- **What they are**: Return values for your configuration, like function return values. They show useful information to the user or pass data to other Terraform configurations.

```hcl
output "instance_ip_addr" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.web_server.public_ip
}
```

### Data Sources
- **What they are**: A way to fetch data from *outside* of Terraform to use in your configuration.
- **Example**: Dynamically fetching the latest Ubuntu AMI ID instead of hardcoding it.

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id # Using the data source
  instance_type = "t2.micro"
}
```

### Modules
- **What they are**: Reusable containers for multiple resources that are used together. They are the primary way to package and reuse resource configurations.
- **How it works**: You call a module and provide variables to it.

```hcl
# In a separate directory (e.g., modules/ec2-instance) or from a registry
# a simple module can have main.tf, variables.tf, outputs.tf files

# Using the module
module "web_server" {
  source        = "./modules/ec2-instance" # Path to the module
  instance_type = "t2.large"
}
```

## Common Terraform Commands (Workflow)
1.  **`terraform init`**: Initializes the working directory. Downloads provider plugins and sets up the backend (state). **Run this first.**
2.  **`terraform validate`**: Checks if the configuration syntax is valid.
3.  **`terraform fmt`**: Rewrites configuration files to a standard format for readability.
4.  **`terraform plan`**: Creates an execution plan. Shows what Terraform will do to reach the desired state (create, change, or destroy). This is a dry run.
5.  **`terraform apply`**: Applies the changes described in the plan to create or update the infrastructure.
6.  **`terraform destroy`**: Removes all resources managed by the configuration.
7.  **`terraform refresh`**: Updates the state file with the real-world state of infrastructure. It does not modify your infrastructure. **Note:** This command is now legacy. `terraform plan` and `terraform apply` automatically perform a refresh action before creating a plan, so you rarely need to run this command by itself.

## Workspaces
- **What they are**: Allow you to manage different environments (e.g., dev, staging, prod) with the same configuration but with different state files.
- **Purpose**: Each workspace has its own separate state. This allows you to reuse a single configuration without having to configure new backends for different environments.

## State Management Scenarios & Edge Cases

### Scenario: A resource is deleted MANUALLY in the cloud provider console.
- **Problem**: This creates "drift." The state file says a resource should exist, but it's gone from the real world.
- **Result of `terraform apply`**: Terraform will perform a "refresh" before planning. It will detect the discrepancy and plan to **re-create** the missing resource to match the configuration.

### Scenario: A resource block is REMOVED from the configuration file.
- **Problem**: The desired state (code) no longer wants the resource, but the current state (`.tfstate`) still tracks it.
- **Result of `terraform apply`**: Terraform will plan to **destroy** the resource to make the infrastructure match the new desired state. This is the correct way to remove a resource.

### Scenario: A resource is MANUALLY DELETED from the state file.
- **Problem**: This is dangerous. You are giving Terraform amnesia about a specific resource.
- **Result of `terraform apply`**: Terraform no longer tracks the resource. It will compare the configuration (which wants the resource) to the state (which has no record of it) and try to **create it again**. This will likely cause an error if the resource already exists in the cloud.

### Scenario: The entire `.tfstate` file is DELETED.
- **Problem**: Complete amnesia. Terraform has lost all knowledge of the infrastructure it was managing.
- **Result of `terraform apply`**: Terraform will assume no resources exist and will try to **create everything from scratch**. This is a critical failure state that can lead to duplicate infrastructure or errors.
- **Recovery**: Use `terraform import` to bring existing resources back under Terraform's management.

### Scenario: The `.terraform` directory is DELETED.
- **Problem**: This directory caches provider plugins and modules. Deleting it removes the code needed for Terraform to function.
- **Result of any command (`plan`, `apply`)**: Commands will fail because providers are missing.
- **Solution**: This is safe and easy to fix. Just run **`terraform init`** again. Terraform will re-download the necessary providers and modules. 

