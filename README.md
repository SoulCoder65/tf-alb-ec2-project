
# Terraform AWS Infrastructure Project

This project provides a Terraform configuration to set up a basic AWS infrastructure. The setup includes a Virtual Private Cloud (VPC), public subnets, an Internet Gateway, security groups, EC2 instances, an S3 bucket, and an Application Load Balancer (ALB) with target groups.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Terraform Files](#terraform-files)
- [Variables](#variables)
- [Outputs](#outputs)
- [Usage](#usage)
- [Testing and Validation](#testing-and-validation)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

This Terraform configuration is designed to automate the deployment of a simple web application architecture on AWS. It includes:

- **VPC**: A Virtual Private Cloud to host the infrastructure.
- **Subnets**: Public subnets across two availability zones.
- **Internet Gateway**: To allow internet access to resources in public subnets.
- **Security Groups**: To control inbound and outbound traffic to the EC2 instances.
- **EC2 Instances**: Two instances hosting the application, distributed across the public subnets.
- **S3 Bucket**: A storage bucket for application-related assets.
- **Application Load Balancer (ALB)**: Distributes incoming application traffic across the EC2 instances.
- **Target Groups**: Define the EC2 instances as targets for the load balancer.

## Architecture

Here’s a high-level overview of the architecture:

- **VPC**: 10.0.0.0/16
  - **Public Subnet 1**: 10.0.0.0/24 (AZ: ap-south-1a)
  - **Public Subnet 2**: 10.0.1.0/24 (AZ: ap-south-1b)
  - **Internet Gateway**: Allows internet access for public subnets.
  - **Route Table**: Routes internet traffic through the Internet Gateway.
- **Security Group**: Allows HTTP (80) and SSH (22) traffic from anywhere.
- **EC2 Instances**: Two instances, one in each public subnet, configured to host the application.
- **S3 Bucket**: Stores static assets for the application.
- **ALB**: Distributes traffic across the EC2 instances using HTTP.
- **Target Groups**: Register the EC2 instances to the ALB.

## Prerequisites

Before deploying this infrastructure, ensure you have the following:

- **Terraform**: Installed on your local machine. [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS CLI**: Installed and configured with your AWS credentials. [Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- **AWS Account**: Access to create resources such as VPCs, EC2 instances, and S3 buckets.

## Terraform Files

### `main.tf`

This file contains the primary resources required for the infrastructure, including the VPC, subnets, security groups, EC2 instances, S3 bucket, and ALB.

### `providers.tf`

Defines the required providers for the project, including the AWS and random ID providers.

### `variables.tf`

Contains the variable definitions that can be customized to configure the deployment (e.g., region, instance type, AMI).

### `outputs.tf`

Defines the output variables, such as the DNS name of the ALB.

## Variables

You can customize the following variables in `variables.tf`:

- **region**: AWS region where resources will be deployed. Default: `ap-south-1`.
- **vpc_cidr**: CIDR block for the VPC. Default: `10.0.0.0/16`.
- **tags**: Common tags to apply to all resources.
- **instance_type**: Type of EC2 instance to launch. Default: `t2.micro`.
- **ami**: AMI ID for the EC2 instances. Default: `ami-0ec0e125bb6c6e8ec`.

## Outputs

The following outputs are defined in the `outputs.tf` file:

- **load_balancer_dns_name**: The DNS name of the Application Load Balancer, which can be used to access the application.

## Usage

To deploy the infrastructure:

1. **Clone the Repository**:
   git clone https://github.com/SoulCoder65/tf-alb-ec2-project.git
   cd tf-alb-ec2-project

2. **Initialize Terraform**:

   terraform init

3. **Review the Plan**:

   terraform plan

4. **Apply the Configuration**:

   terraform apply

   Confirm the prompt by typing `yes`.

5. **Access the Application**:
   Once the deployment is complete, use the outputted DNS name of the ALB to access your application.

## Testing and Validation

- **EC2 Connectivity**: Use SSH to connect to the EC2 instances using the public IPs.
- **S3 Bucket**: Upload a file to the S3 bucket and ensure it is accessible.
- **ALB**: Ensure the ALB is correctly routing traffic to the EC2 instances.

## Troubleshooting

If you encounter issues:

- **Check Terraform Logs**: Review the output of `terraform apply` for error messages.
- **AWS Console**: Verify resource configurations and statuses directly in the AWS Management Console.
- **Review Security Groups**: Ensure that security group rules are correctly allowing traffic.

## Cleanup

To remove the deployed infrastructure:

1. **Destroy the Resources**:

   terraform destroy

   Confirm the prompt by typing `yes`.

2. **Remove the Local Files**:
   rm -rf .terraform
   rm terraform.tfstate*
