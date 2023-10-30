# GitLab AWS Deployment with Terraform

This Terraform configuration deploys an omnibus GitLab server on AWS, creating the necessary VPC, subnet, and security group configurations.

This repository really meant for a lab environment for one or a few users and is not meant for production.

## Prerequisites:

1. Terraform installed.
2. AWS CLI installed and configured.
3. An SSH key pair; the public key should be at `~/.ssh/id_rsa.pub`.

## Steps to Deploy:

1. **Initialization**: Run `terraform init` to initialize the Terraform directory.

2. **Plan**: Execute `terraform plan` to review the changes that will be made.

3. **Apply**: Deploy the resources using `terraform apply`. Confirm with `yes` when prompted.

4. **Access GitLab**: Once deployed, the public IP of the GitLab server will be shown as an output. Use this IP to access GitLab via your web browser.

## Why Not Use an AMI?

You might wonder why this project deploys a server and configures GitLab with Terraform rather than using an Amazon Machine Image (AMI). There are some advantages to this approach:

Flexibility: Using Terraform allows you to easily modify the infrastructure or server configuration as your needs evolve.

Transparency: The Terraform code is transparent and can be reviewed to understand how the infrastructure is created and configured.

Learning Experience: Creating infrastructure as code with Terraform is a learning experience.

Cost Control: You can manage costs more efficiently by only creating and running the server when needed, rather than paying for a running AMI continuously.

## Cleanup:

To remove all resources created by this configuration, run `terraform destroy` and confirm with `yes`.

**Note**: Always review Terraform configurations from third parties and ensure they adhere to your security guidelines.
