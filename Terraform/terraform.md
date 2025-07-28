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

### How to Set Variable Values
A variable declaration (in `variables.tf`) is like defining a function's parameters; you still need to provide values (arguments) for them. Terraform offers several ways to do this, with a clear order of precedence.

1.  **Variable Definition Files (`.tfvars`) - Recommended Method**
    This is the most common and recommended way to manage variables for different environments (dev, prod) without changing the core code.
    - **`terraform.tfvars`**: If a file with this exact name exists in your directory, Terraform automatically loads it. This is perfect for setting the main variables for a specific deployment.
    - **`*.auto.tfvars`**: Any file ending in `.auto.tfvars` (e.g., `network.auto.tfvars`) will also be loaded automatically.

    **Example `terraform.tfvars` file:**
    ```hcl
    # This file provides values for variables defined in variables.tf
    instance_type = "t2.large"
    # Note: No 'variable' keyword here. Just the name and value.
    ```

2.  **Command-Line Flags**
    You can pass variables directly when running `plan` or `apply`. This is useful for CI/CD pipelines or temporary overrides.
    - **`-var`**: Sets a single variable.
      `terraform apply -var="instance_type=t2.large"`
    - **`-var-file`**: Provides a path to a `.tfvars` file that isn't named `terraform.tfvars`.
      `terraform apply -var-file="production.tfvars"`

3.  **`default` Value in the Declaration**
    As shown in the example above, you can provide a `default` value inside the `variable` block. This value is used if the variable is not set by any other method.

**Precedence Order:**
Terraform loads variables in the following order (later ones override earlier ones):
1.  `default` values inside `variable` blocks.
2.  Values in `terraform.tfvars` and `*.auto.tfvars` files.
3.  Values from `-var` and `-var-file` flags on the command line.

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

### Cross-Referencing & Resource Dependencies
- **What it is**: How Terraform resources, data sources, variables, and local values reference each other to create dependencies and pass data.
- **Purpose**: Enables building complex infrastructure where resources depend on each other's attributes.

#### Reference Types:

**1. Variable References (`var.xxx`)**
- **Source**: `variables.tf` file
- **Usage**: Input parameters from terraform.tfvars or command line
```hcl
# variables.tf
variable "instance_type" {
  type = string
}

# main.tf
resource "aws_instance" "web" {
  instance_type = var.instance_type  # Reference to variable
}
```

**2. Data Source References (`data.xxx.yyy.zzz`)**
- **Source**: External data fetched from APIs
- **Usage**: Access existing resources not managed by current Terraform config
```hcl
# Fetch existing VPC
data "aws_vpc" "existing" {
  default = true
}

# Use in new resource
resource "aws_subnet" "app" {
  vpc_id = data.aws_vpc.existing.id  # Reference to data source
}
```

**3. Resource References (`resource_type.name.attribute`)**
- **Source**: Resources created by current Terraform config
- **Usage**: Use outputs from one resource as inputs to another
```hcl
# Create key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_public_key
}

# Reference it in EC2 instance
resource "aws_instance" "web" {
  ami      = "ami-12345678"
  key_name = aws_key_pair.deployer.key_name  # Reference to resource
}
```

**4. Local Value References (`local.xxx`)**
- **Source**: `locals` block for computed/combined values
- **Usage**: Reusable calculated values or complex expressions
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
  
  instance_name = "${var.project_name}-${var.environment}-web"
}

resource "aws_instance" "web" {
  tags = local.common_tags           # Reference to local value
  
  tags = merge(local.common_tags, {  # Combining local with additional tags
    Name = local.instance_name
  })
}
```

#### Dependency Graph:
- Terraform automatically creates a dependency graph based on these references
- Resources are created/destroyed in the correct order
- Example: VPC → Subnet → Security Group → EC2 Instance

#### Best Practices:
- Use **variables** for user inputs
- Use **data sources** for existing infrastructure
- Use **resource references** for dependencies between new resources  
- Use **locals** for computed values and reducing repetition
- Avoid circular dependencies (A depends on B, B depends on A)

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

