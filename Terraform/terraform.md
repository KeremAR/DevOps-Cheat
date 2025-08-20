# Terraform Interview Notes

## What is Terraform?
- **IaC Tool**: An "Infrastructure as Code" tool developed by Hashicorp.
- **Declarative**: You define the *desired end state* of your infrastructure, and Terraform figures out how to get there.
- **Idempotent**: Running the same configuration multiple times produces the same result. If infrastructure already matches the desired state, no changes are made.
- **HCL**: Uses the Hashicorp Configuration Language (HCL), designed to be human-readable.
- **Execution Plan**: Creates an execution plan for your approval before making any changes.
- **State Management**: Keeps track of the infrastructure it manages in a "state" file.
- **Multi-Cloud**: Supports a wide range of providers, not just major cloud providers but also services like Kubernetes, Helm, and Vault.

### Understanding Idempotency
- **What it means**: You can run `terraform apply` multiple times safely. If the infrastructure already matches your configuration, Terraform does nothing.
- **Why important**: Prevents unintended changes, enables safe re-runs, and makes automation reliable.
- **Example**: If you run `terraform apply` on a configuration that creates 3 EC2 instances, and those instances already exist, Terraform won't create duplicates.

```bash
# First run: Creates resources
terraform apply
# Plan: 5 to add, 0 to change, 0 to destroy.

# Second run: Does nothing (idempotent)
terraform apply  
# Plan: 0 to add, 0 to change, 0 to destroy.
# Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

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

#### Remote State Sharing
- **terraform_remote_state**: Access outputs from other Terraform state files stored remotely to share data between separate projects.

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use outputs from remote state
resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_id
}
```

### Providers
- **What they are**: Plugins that allow Terraform to interact with a specific API (cloud provider, SaaS provider, etc.).
- **How it works**: You declare a provider in your configuration, and Terraform downloads it during `terraform init`.
- **Version Constraints**: Defined in `versions.tf` to ensure consistency and prevent version-related issues.

```hcl
# versions.tf - Version constraints (recommended practice)
terraform {
  required_version = ">= 1.5.7"  # Minimum Terraform version
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Compatible with 5.x but not 6.x
    }
  }
}

# main.tf - Provider configuration
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

4.  **Environment Variables (TF_VAR_)**
    Automatically load variables from environment variables prefixed with `TF_VAR_`. Useful for secure credential handling and CI/CD integration.
    ```bash
    # Set environment variable
    export TF_VAR_ssh_key="ssh-rsa AAAA..."
    # Terraform automatically uses this as var.ssh_key
    ```

**Precedence Order:**
Terraform loads variables in the following order (later ones override earlier ones):
1.  `default` values inside `variable` blocks.
2.  Values in `terraform.tfvars` and `*.auto.tfvars` files.
3.  Values from environment variables (`TF_VAR_*`).
4.  Values from `-var` and `-var-file` flags on the command line.

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

## Terraform Destroy Deep Dive

### How `terraform destroy` Works
- **Step 1**: Terraform reads the current state file to understand what resources are currently managed.
- **Step 2**: Creates a **destruction plan** showing what will be deleted (like `terraform plan` but for deletion).
- **Step 3**: Asks for confirmation before proceeding (unless `-auto-approve` is used).
- **Step 4**: Deletes resources in **reverse dependency order** (opposite of creation order).
- **Step 5**: Updates the state file to remove deleted resources.

### Destruction Order & Dependencies
- **Dependency Graph Reversal**: Resources are destroyed in reverse order of their dependencies.
- **Example**: If EC2 depends on Security Group, EC2 is destroyed first, then Security Group.
- **Why Important**: Prevents errors like trying to delete a VPC before deleting subnets inside it.

```bash
# Basic destroy command
terraform destroy

# Skip confirmation prompt (dangerous!)
terraform destroy -auto-approve

# Destroy specific resources only
terraform destroy -target=aws_instance.web

# Destroy multiple specific resources
terraform destroy -target=aws_instance.web -target=aws_security_group.web_sg

# Preview destruction plan without executing
terraform plan -destroy
```

### Protection Against Accidental Destruction

**1. Using `lifecycle.prevent_destroy`:**
```hcl
resource "aws_instance" "critical" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  lifecycle {
    prevent_destroy = true  # Prevents this resource from being destroyed
  }
}
```

## Best Practice: Configuration-Driven Resource Removal

### The Preferred Approach: Remove from Configuration + Apply
Instead of using `terraform destroy`, the **recommended approach** is to remove resources from your configuration files and then run `terraform apply`. This is considered a best practice because:

- **Infrastructure as Code**: Your configuration files always represent the desired state
- **Version Control**: Changes are tracked in Git with proper commit messages
- **Code Review**: Team members can review resource removal through pull requests
- **Selective**: More granular control than destroy commands
- **Safer**: Less likely to accidentally remove unintended resources



### Comparison: Configuration Removal vs terraform destroy

| Aspect | Configuration Removal | terraform destroy |
|--------|----------------------|-------------------|
| **Scope** | Specific resources | All or targeted resources |
| **Version Control** | ✅ Tracked in Git | ❌ Not tracked |
| **Code Review** | ✅ Can be reviewed | ❌ Command-line only |
| **Documentation** | ✅ Self-documenting | ❌ No record |
| **Accidents** | ✅ Lower risk | ⚠️ Higher risk |
| **Team Workflow** | ✅ Fits CI/CD | ⚠️ Manual process |


### When to Still Use terraform destroy
- **Development environments**: Quick teardown of test infrastructure
- **Emergency situations**: When configuration files are corrupted
- **Complete environment cleanup**: End-of-project infrastructure removal
- **Troubleshooting**: When normal apply process fails

---

## Advanced State Management

### `terraform state rm` - Removing from State Only
Sometimes you need to remove a resource from Terraform's state without destroying the actual infrastructure. This is useful when moving resources to different Terraform configurations or when a resource was created outside of Terraform.

```bash
# Remove a specific resource from state (keeps actual resource)
terraform state rm aws_instance.web

# Remove multiple resources
terraform state rm aws_instance.web aws_instance.api

# List current state to see what's managed
terraform state list

# Example workflow: Moving a resource to different Terraform config
terraform state rm aws_s3_bucket.data    # Remove from current state
# Then import it in the new Terraform configuration:
# terraform import aws_s3_bucket.data bucket-name
```

⚠️ **Important**: `terraform state rm` only removes from the state file; the actual cloud resource continues to exist and may cause conflicts if not properly managed.

### `terraform import` - Managing Existing Infrastructure
The `terraform import` command is used to bring existing, manually-created infrastructure under Terraform's management. It reads a real-world resource and writes its details into your state file.

**When to use `import`:**
- When you start using Terraform for a project that already has existing infrastructure.
- When a resource was created outside of Terraform (e.g., via the console for an emergency) and you need to manage it with code.
- As part of a recovery process if a state file is lost.

**Important Note:** `import` **does not** generate the configuration code for you. You must write the `resource` block in your `.tf` file *before* you can import the resource into the state.

**Example Workflow:**
1.  An S3 bucket named `my-manually-created-bucket` already exists in your AWS account.

2.  **Write the HCL code** for the resource in your `main.tf` file. The configuration can be minimal at first.
    ```hcl
    resource "aws_s3_bucket" "my_bucket" {
      # The configuration inside can be empty for now.
      # After importing, you'll run a plan to see the real configuration.
    }
    ```

3.  **Run the `import` command** using the resource address (`<resource_type>.<name>`) and the real-world resource ID (for an S3 bucket, it's the bucket name).
    ```bash
    terraform import aws_s3_bucket.my_bucket my-manually-created-bucket
    ```
    Terraform will now populate the state file with the details of the existing bucket.

4.  **Run `terraform plan`**. Terraform will now compare your (empty) HCL configuration with the state file (now populated with real values) and show you a plan to update your HCL code to match the imported resource.

5.  **Update your HCL code** with the actual configuration attributes shown in the plan to achieve a clean state with no planned changes.

## Workspaces
- **What they are**: Allow you to manage different environments (e.g., dev, staging, prod) with the same configuration but with different state files.
- **Purpose**: Each workspace has its own separate state. This allows you to reuse a single configuration without having to configure new backends for different environments.

## State Management Scenarios & Edge Cases

### Scenario: A resource is deleted MANUALLY in the cloud provider console.
- **Problem**: This creates "drift." The state file says a resource should exist, but it's gone from the real world.
- **Result of `terraform apply`**: Terraform will perform a "refresh" before planning. It will detect the discrepancy and plan to **re-create** the missing resource to match the configuration.

### Scenario: A resource block is REMOVED from the configuration file.
- **Problem**: The desired state (code) no longer wants the resource, but the current state (`.tfstate`) still tracks it.
- **Result of `terraform apply`**: Terraform will plan to **destroy** the resource to make the infrastructure match the new desired state. **This is the RECOMMENDED and correct way to remove a resource** (see "Configuration-Driven Resource Removal" section above).

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

## Advanced Terraform Features


### Map Variables
- **What it is**: Key-value data structures for organizing related configuration.
- **Purpose**: Group related settings and enable for_each iteration with meaningful keys.

```hcl
# Basic map variable
variable "environments" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    prod = "t3.large"
  }
}

# Map with object values
variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

# terraform.tfvars
environments = {
  dev  = "t2.micro"
  test = "t2.small"
  prod = "t3.large"
}

subnets = {
  "public-a" = {
    cidr = "10.0.1.0/24"
    az   = "us-east-1a"
  }
  "public-b" = {
    cidr = "10.0.2.0/24"
    az   = "us-east-1b"
  }
}
```

### List Variables
- **What it is**: Ordered collections of values of the same type.
- **Purpose**: Handle multiple similar items, often used with count or for_each.

```hcl
# Basic list variable
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# List of objects
variable "instances" {
  type = list(object({
    name = string
    type = string
  }))
}

# terraform.tfvars
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

instances = [
  {
    name = "web-1"
    type = "t2.micro"
  },
  {
    name = "web-2" 
    type = "t2.small"
  }
]

```

### Map vs List Comparison
- **Use Maps when**: You need meaningful keys, different configurations per item, or stable references
- **Use Lists when**: Items are similar/identical, order matters, or working with count

```hcl
# Good for Maps: Different environments with distinct configs
variable "environments" {
  type = map(object({
    instance_type = string
    min_size      = number
  }))
}

# Good for Lists: Similar items where order matters
variable "subnet_cidrs" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
```

### count Meta-Argument
- **What it is**: Creates multiple resource instances by specifying a number.
- **Purpose**: Simple resource duplication when you need multiple identical resources.

```hcl
# Basic count usage
resource "aws_instance" "web" {
  count = 3  # Creates 3 identical instances
  
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server-${count.index}"  # web-server-0, web-server-1, web-server-2
  }
}

# Conditional resource creation
resource "aws_instance" "backup" {
  count = var.create_backup ? 1 : 0  # Creates 1 instance if true, 0 if false
  
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

# Dynamic count based on variable
variable "instance_count" {
  type    = number
  default = 2
}

resource "aws_instance" "app" {
  count = var.instance_count
  
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "app-server-${count.index + 1}"  # app-server-1, app-server-2
  }
}

# Referencing count resources
output "instance_ips" {
  value = aws_instance.web[*].public_ip  # List of all public IPs
}

output "first_instance_ip" {
  value = aws_instance.web[0].public_ip  # First instance's IP
}
```

### for_each with Maps
- **What it is**: Creates multiple resource instances by iterating over a map.
- **Purpose**: Create resources with different configurations using meaningful keys.

```hcl
# Using map variable with for_each
resource "aws_subnet" "public" {
  for_each = var.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.key  # Uses the map key: "public-a", "public-b"
  }
}

# Create different instances per environment
resource "aws_instance" "app" {
  for_each = var.environments

  ami           = "ami-12345678"
  instance_type = each.value  # Different instance type per environment
  
  tags = {
    Name        = "${each.key}-server"  # dev-server, prod-server
    Environment = each.key
  }
}

# Referencing for_each resources
output "subnet_ids" {
  value = { for k, v in aws_subnet.public : k => v.id }
}
```

### for_each with Lists (Converting to Sets)
- **What it is**: Use for_each with lists by converting them to sets.
- **Purpose**: Iterate over list items while avoiding count's limitations.

```hcl
# Convert list to set for for_each
resource "aws_security_group_rule" "ingress" {
  for_each = toset(["80", "443", "22"])
  
  type        = "ingress"
  from_port   = each.value
  to_port     = each.value
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Using list of objects with for_each
variable "users" {
  type = list(object({
    username = string
    role     = string
  }))
  default = [
    { username = "john", role = "admin" },
    { username = "jane", role = "developer" }
  ]
}

resource "aws_iam_user" "users" {
  for_each = { for user in var.users : user.username => user }
  
  name = each.value.username
  
  tags = {
    Role = each.value.role
  }
}
```

### count vs for_each
- **Use count when**: You need identical resources and the number is known or simple
- **Use for_each when**: Resources have different configurations or you need to reference them by name
- **Important**: Don't mix count and for_each in the same resource, and be careful when changing between them

```hcl
# Good for count: Simple, identical resources
resource "aws_instance" "workers" {
  count = var.worker_count
  # All workers identical except for count.index
}

# Good for for_each: Different configurations
resource "aws_instance" "servers" {
  for_each = var.server_configs  # Each server has different specs
  
  instance_type = each.value.instance_type
  ami           = each.value.ami
}
```

### ⚠️ Important Limitation: No Resource Outputs in count/for_each
**You CANNOT use resource outputs in count or for_each arguments!** This is because Terraform needs to know these values during the planning phase, but resource outputs are only available during the apply phase.

```hcl
# ❌ This WILL NOT WORK!
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "app" {
  count  = aws_vpc.main.enable_dns_hostnames ? 3 : 1  # ERROR!
  vpc_id = aws_vpc.main.id
}

# ❌ This WILL NOT WORK either!
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "dynamic" {
  for_each = aws_availability_zones.available.names  # ERROR!
  vpc_id   = aws_vpc.main.id
}
```

**Solutions:**

```hcl
# ✅ Use data sources instead
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "app" {
  for_each = toset(data.aws_availability_zones.available.names)  # Works!
  vpc_id   = aws_vpc.main.id
}

# ✅ Use variables or locals
variable "subnet_count" {
  type    = number
  default = 3
}

resource "aws_subnet" "app" {
  count  = var.subnet_count  # Works!
  vpc_id = aws_vpc.main.id
}

# ✅ Use locals with conditional logic
locals {
  create_subnets = var.environment == "prod" ? 3 : 1
}

resource "aws_subnet" "app" {
  count  = local.create_subnets  # Works!
  vpc_id = aws_vpc.main.id
}
```

### depends_on - Explicit Dependencies
- **What it is**: Manually specify dependencies when Terraform can't automatically infer them.
- **Purpose**: Force creation order for resources that don't reference each other's attributes.

```hcl
resource "aws_instance" "web" {
  depends_on = [aws_security_group.web_sg]
  # Force instance to wait for security group
}
```

### Built-in Functions
- **templatefile()**: Read external files and substitute variables.
- **jsonencode()**: Convert HCL values to JSON strings inline.
- **base64encode()**: Encode strings to base64 format.
- **path.module**: Reference to the current module's directory path.
- **toset()**: Convert lists to sets for uniqueness.
- **merge()**: Combine multiple maps into one.

```hcl
# External file with variables
policy = templatefile("${path.module}/policy.json", {
  bucket_name = var.bucket_name
})

# Inline JSON
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = { Service = "ec2.amazonaws.com" }
  }]
})

# Base64 encoding for user data
user_data = base64encode(file("${path.module}/user-data.sh"))

# Convert list to set
public_subnet_ids = toset([for subnet in aws_subnet.public : subnet.id])

# Merge maps
all_tags = merge(local.common_tags, { Name = "web-server" })
```






### lifecycle Block
- **What it is**: Control resource lifecycle behavior during updates and destruction.
- **Purpose**: Prevent accidental deletions and manage resource update strategies.

```hcl
resource "aws_instance" "web" {
  lifecycle {
    create_before_destroy = true    # Create new before destroying old
    prevent_destroy       = true    # Prevent accidental deletion
    ignore_changes       = [ami]    # Ignore AMI changes
  }
}
```

### User Data with Heredoc Syntax
- **What it is**: Multi-line string syntax for embedding scripts directly in configuration.
- **Purpose**: Cleaner, readable multi-line content without external files.

```hcl
resource "aws_instance" "web" {
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              EOF
}
```



### Multiple Data Source Filters
- **What it is**: Combine multiple filters to precisely discover existing resources.
- **Purpose**: Find specific resources in complex environments using tags and attributes.

```hcl
data "aws_subnet" "app" {
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
  
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}
```

### For Expressions
- **What it is**: Create collections by transforming and filtering other collections.
- **Purpose**: Generate dynamic values, transform data structures, and create conditional logic.

```hcl
# Transform map to different structure
locals {
  subnet_ids = { for k, v in aws_subnet.main : k => v.id }
}

# Filter and transform list
locals {
  public_subnet_ids = [
    for subnet in aws_subnet.main : subnet.id 
    if subnet.map_public_ip_on_launch
  ]
}

# Complex transformation in outputs
output "instance_info" {
  value = {
    for instance in aws_instance.web : instance.tags.Name => {
      id        = instance.id
      public_ip = instance.public_ip
    }
  }
}

# Using for expressions with toset()
resource "aws_security_group_rule" "egress" {
  for_each = toset(var.allowed_ports)
  
  type        = "egress"
  from_port   = each.value
  to_port     = each.value
  protocol    = "tcp"
}
```

### Dynamic Blocks
- **What it is**: Dynamically generate nested configuration blocks based on complex variables.
- **Purpose**: Avoid repetition when creating multiple similar blocks within a resource.

```hcl
# Variable defining multiple ingress rules
variable "security_group_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Using dynamic blocks to create multiple ingress rules
resource "aws_security_group" "web" {
  name = "web-sg"

  dynamic "ingress" {
    for_each = var.security_group_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

### Resource Meta-Arguments Summary
- **count**: Create multiple instances using a number
- **for_each**: Create multiple instances using a map or set
- **depends_on**: Explicit dependency management
- **lifecycle**: Control resource behavior during updates
- **provider**: Specify which provider instance to use

```hcl
# Example combining multiple meta-arguments
resource "aws_instance" "web" {
  count = var.create_instances ? var.instance_count : 0
  
  depends_on = [aws_security_group.web]
  
  lifecycle {
    create_before_destroy = true
    ignore_changes       = [ami]
  }
  
  provider = aws.us_west_2
}
```

### Complex Variable Types (Advanced Combinations)
- **What it is**: Combine maps, lists, and objects for sophisticated infrastructure patterns.
- **Purpose**: Handle complex real-world scenarios with nested data structures and multiple relationships.

```hcl
# Complex nested structure
variable "application_config" {
  type = map(object({
    instance_type = string
    min_size      = number
    max_size      = number
    subnets       = list(string)
    security_groups = list(string)
    tags = map(string)
  }))
}

# terraform.tfvars for complex structure
application_config = {
  "web" = {
    instance_type   = "t3.medium"
    min_size        = 2
    max_size        = 10
    subnets         = ["subnet-123", "subnet-456"]
    security_groups = ["sg-web", "sg-common"]
    tags = {
      Component = "frontend"
      Owner     = "web-team"
    }
  }
  "api" = {
    instance_type   = "t3.large"
    min_size        = 1
    max_size        = 5
    subnets         = ["subnet-789", "subnet-abc"]
    security_groups = ["sg-api", "sg-common"]
    tags = {
      Component = "backend"
      Owner     = "api-team"
    }
  }
}

# Using complex variables with for_each and dynamic blocks
resource "aws_autoscaling_group" "app" {
  for_each = var.application_config
  
  name                = "${each.key}-asg"
  min_size            = each.value.min_size
  max_size            = each.value.max_size
  vpc_zone_identifier = each.value.subnets
  
  # Dynamic tags using the nested tags map
  dynamic "tag" {
    for_each = each.value.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  
  # Additional static tags
  tag {
    key                 = "Application"
    value               = each.key
    propagate_at_launch = true
  }
}

# Mixing count and complex variables
variable "multi_az_config" {
  type = object({
    azs           = list(string)
    instance_type = string
    count_per_az  = number
  })
  default = {
    azs           = ["us-east-1a", "us-east-1b", "us-east-1c"]
    instance_type = "t2.micro"
    count_per_az  = 2
  }
}

# Create instances across multiple AZs using count
resource "aws_instance" "multi_az" {
  count = length(var.multi_az_config.azs) * var.multi_az_config.count_per_az
  
  ami               = "ami-12345678"
  instance_type     = var.multi_az_config.instance_type
  availability_zone = var.multi_az_config.azs[count.index % length(var.multi_az_config.azs)]
  
  tags = {
    Name = "instance-${count.index + 1}"
    AZ   = var.multi_az_config.azs[count.index % length(var.multi_az_config.azs)]
  }
}
```

