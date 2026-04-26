variable "project"            { type = string }
variable "environment"        { type = string }
variable "vpc_id"             { type = string }
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "ami_id"             { type = string }
variable "instance_type"      { type = string; default = "t3.medium" }
variable "app_port"           { type = number; default = 8080 }
variable "desired_capacity"   { type = number; default = 2 }
variable "min_size"           { type = number; default = 1 }
variable "max_size"           { type = number; default = 4 }
variable "user_data"          { type = string; default = "" }
