terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
  backend "s3" {
    bucket = "devopswithchaitanya-tfstate"
    key    = "dev/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = { Project = var.project; Environment = var.environment; ManagedBy = "Terraform" } }
}

module "vpc" {
  source               = "../../modules/vpc"
  project              = var.project
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  db_subnet_cidrs      = ["10.0.20.0/24", "10.0.21.0/24"]
  azs                  = ["eu-central-1a", "eu-central-1b"]
}

module "ec2" {
  source             = "../../modules/ec2"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  ami_id             = var.ami_id
  instance_type      = "t3.medium"
  desired_capacity   = 2
  min_size           = 1
  max_size           = 4
}

module "rds" {
  source          = "../../modules/rds"
  project         = var.project
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  db_subnet_ids   = module.vpc.db_subnet_ids
  app_sg_id       = module.ec2.app_sg_id
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  multi_az        = false
}

module "s3" {
  source        = "../../modules/s3"
  project       = var.project
  environment   = var.environment
  bucket_suffix = "app-assets"
}
