# Project 17: Multi-Tier AWS Infrastructure with Terraform & LocalStack

This project automates a multi-tier AWS network and application architecture using **Terraform** and tests it locally against a **LocalStack** Docker container on Windows.

## Architecture & Configuration Files

* `provider.tf` — Configures the AWS provider (and supporting providers) pointed at LocalStack (`http://localhost:4566`).
* `variables.tf` — Declares input variables (`region`, `account_no`, `tags`, `name`, `ami`, `keypair`, `master-username`, `master-password`, `enable_pro_services`).
* `vpc.tf` & `subnets.tf` — Defines the VPC, availability zones, and public/private subnets.
* `security.tf` — Defines security groups (`ext-alb-sg`, `int-alb-sg`, `datalayer-sg`).
* `cert.tf` — Configures Route 53 and ACM resources.
* `alb.tf` — Defines External and Internal Application Load Balancers, target groups, listeners, and rules (conditionally toggled via `enable_pro_services`).
* `efs.tf` — Defines KMS key/alias, EFS file system, mount targets, and access points (conditionally toggled via `enable_pro_services`).
* `rds.tf` — Defines the RDS DB subnet group and database instance (conditionally toggled via `enable_pro_services`).
* `terraform.tfvars` — Local variable overrides and non-committed sensitive inputs (excluded via `.gitignore`).

## LocalStack Community vs. Pro Handling

LocalStack Community Edition does not support certain Pro-only APIs (such as `elbv2`, `efs`, and `rds`), which return `501 Not Implemented` errors or place resources into a `failed` state.

* The `enable_pro_services` boolean variable defaults to `false` so core networking and supported resources can be planned and applied locally without Pro-only blockers.
* Resources gated behind `count = var.enable_pro_services ? 1 : 0` are skipped when `enable_pro_services = false`.

## Step-by-Step Local Workflow

1. **Start LocalStack in Docker Desktop** and verify it is listening on `http://localhost:4566`.
2. **Ensure `.gitignore` protects local secrets and state**, including `terraform.tfvars`, `.terraform/`, and `*.tfstate*`.
3. **Initialize and upgrade providers:**
   ```powershell
   terraform init -upgrade


1- Validate HCL syntax and variable references:

PowerShell


terraform validate

2- Preview changes:

PowerShell

terraform plan

3- Apply core resources to LocalStack:

PowerShell


terraform apply --auto-approve



