# 🏗️ Terraform AWS Infrastructure

Production-grade 3-tier AWS infrastructure built with reusable Terraform modules. Covers VPC, EC2 Auto Scaling, RDS, S3, IAM, and CloudWatch — fully automated, zero-click provisioning.

## Architecture

```
Internet Gateway
      │
  ALB (Public Subnets)
      │
  EC2 ASG (Private Subnets)
      │
  RDS MySQL (DB Subnets)
```

## Modules

| Module | Description |
|--------|-------------|
| `vpc` | VPC, subnets, IGW, NAT Gateway, route tables |
| `ec2` | Launch template, Auto Scaling Group, ALB |
| `rds` | RDS MySQL with Multi-AZ, subnet group |
| `s3` | S3 bucket with versioning, encryption, lifecycle |

## Usage

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Tech Stack
`Terraform` `AWS VPC` `EC2` `ALB` `ASG` `RDS` `S3` `IAM` `CloudWatch`
