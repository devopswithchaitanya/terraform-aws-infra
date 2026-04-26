variable "project"     { type = string; default = "devops-app" }
variable "environment" { type = string; default = "dev" }
variable "aws_region"  { type = string; default = "eu-central-1" }
variable "ami_id"      { type = string }
variable "db_name"     { type = string; default = "appdb" }
variable "db_username" { type = string; default = "admin" }
variable "db_password" { type = string; sensitive = true }
