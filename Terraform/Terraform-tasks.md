# Terraform Hands-On Labs

This document provides a detailed solution for the hands-on lab focused on building a foundational AWS network stack using Terraform.

---

## Task: AWS IaC with Terraform: Creating Network Resources

*This task walks through creating a foundational network stack in AWS using Terraform. This involves setting up a custom Virtual Private Cloud (VPC), an internet gateway, public subnets in multiple availability zones, and a routing table to manage traffic flow.*

### Step 1: Task Analysis & Strategy

The objective is to provision a core AWS network infrastructure using Terraform, adhering to best practices like separating variable definitions, using `.tfvars` for input, and modularizing resource definitions.

The strategy is to create a set of Terraform configuration files that logically separate concerns:

1.  **`versions.tf`**: Defines the required Terraform version and the AWS provider version. This ensures a consistent and predictable environment.
2.  **`variables.tf`**: Declares all the necessary input variables with types and descriptions. This serves as the API for our Terraform module. Variables will be defined for the region, VPC details, subnet configurations, and resource names.
3.  **`terraform.tfvars`**: Provides the actual values for the variables defined in `variables.tf`. This allows for easy configuration changes without modifying the core logic.
4.  **`main.tf`**: Contains the provider configuration. It's the entry point that sets up the AWS provider with the specified region.
5.  **`vpc.tf`**: Holds the definitions for all the network resources: the `aws_vpc`, `aws_subnet` resources (created dynamically using a `for_each` loop), `aws_internet_gateway`, `aws_route_table`, the default route, and the associations between the route table and the subnets.
6.  **`outputs.tf`**: Defines the outputs, such as the VPC ID and subnet IDs. This makes it easy to retrieve information about the created resources.

This file structure makes the configuration clean, maintainable, and reusable.

### Step 2: Terraform Configuration

Create the following files in your repository.

#### `versions.tf`
This file locks down the versions of Terraform and the AWS provider.

```terraform
terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

#### `variables.tf`
This file defines the input variables for our configuration.

```terraform
variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnets" {
  description = "A map of public subnets to create. Each object contains the name, availability zone, and CIDR block."
  type = map(object({
    name = string
    az   = string
    cidr = string
  }))
}

variable "igw_name" {
  description = "The name for the Internet Gateway."
  type        = string
}

variable "rt_name" {
  description = "The name for the Route Table."
  type        = string
}
```

#### `terraform.tfvars`
This file provides the values for the variables. All resource names and CIDR blocks are supplied from here as required.

```terraform
aws_region = "us-east-1"

vpc_name = "cmtr-zdv1y551-01-vpc"
vpc_cidr = "10.10.0.0/16"

public_subnets = {
  "a" = {
    name = "cmtr-zdv1y551-01-subnet-public-a"
    az   = "us-east-1a"
    cidr = "10.10.1.0/24"
  },
  "b" = {
    name = "cmtr-zdv1y551-01-subnet-public-b"
    az   = "us-east-1b"
    cidr = "10.10.3.0/24"
  },
  "c" = {
    name = "cmtr-zdv1y551-01-subnet-public-c"
    az   = "us-east-1c"
    cidr = "10.10.5.0/24"
  }
}

igw_name = "cmtr-zdv1y551-01-igw"
rt_name  = "cmtr-zdv1y551-01-rt"
```

#### `main.tf`
This file configures the AWS provider.

```terraform
provider "aws" {
  region = var.aws_region
}
```

#### `vpc.tf`
This file contains the core logic for creating the VPC, subnets, Internet Gateway, and routing.

```terraform
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.value.name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = var.rt_name
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
```

#### `outputs.tf`
This file declares the outputs to be displayed after applying the configuration.

```terraform
output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A map of the public subnet IDs, keyed by their identifier."
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}

output "route_table_id" {
  description = "The ID of the public route table."
  value       = aws_route_table.public.id
}
```

### Step 3: Deployment and Verification

1.  **Configure AWS Credentials**: Before running Terraform, ensure your AWS credentials are configured in your terminal environment as provided by the lab.
    ```bash
    export AWS_ACCESS_KEY_ID="************"
    export AWS_SECRET_ACCESS_KEY="************"
    ```

2.  **Initialize Terraform**: Open a terminal in the directory containing your `.tf` files and run `terraform init`. This command downloads the necessary provider plugins.
    ```bash
    terraform init
    ```

3.  **Format and Validate**: Ensure your code is well-formatted and syntactically valid.
    ```bash
    terraform fmt
    terraform validate
    ```

4.  **Plan the Deployment**: Run `terraform plan` to see an execution plan. This will show you exactly which resources Terraform will create.
    ```bash
    terraform plan
    ```

5.  **Apply the Configuration**: If the plan looks correct, apply the changes to create the resources in AWS.
    ```bash
    terraform apply --auto-approve
    ```

6.  **Verify in AWS Console**:
    *   Navigate to the **VPC** dashboard in the `us-east-1` region.
    *   **VPC**: Verify that a VPC with the name `cmtr-zdv1y551-01-vpc` and CIDR `10.10.0.0/16` exists.
    *   **Subnets**: Check for the three public subnets, ensuring their names, CIDRs, and Availability Zones match the configuration.
    *   **Internet Gateways**: Confirm that the `cmtr-zdv1y551-01-igw` Internet Gateway exists and is attached to your VPC.
    *   **Route Tables**: Examine the `cmtr-zdv1y551-01-rt` route table. Check its **Routes** tab to confirm there is a route for `0.0.0.0/0` pointing to the Internet Gateway. Check the **Subnet Associations** tab to confirm all three public subnets are associated with this route table.
