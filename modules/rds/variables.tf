variable "project"            { type = string }
variable "environment"        { type = string }
variable "vpc_id"             { type = string }
variable "db_subnet_ids"      { type = list(string) }
variable "app_sg_id"          { type = string }
variable "db_instance_class"  { type = string; default = "db.t3.medium" }
variable "allocated_storage"  { type = number; default = 20 }
variable "db_name"            { type = string }
variable "db_username"        { type = string }
variable "db_password"        { type = string; sensitive = true }
variable "multi_az"           { type = bool; default = true }
variable "deletion_protection" { type = bool; default = true }
