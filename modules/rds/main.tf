resource "aws_security_group" "rds" {
  name   = "${var.project}-rds-sg"
  vpc_id = var.vpc_id
  ingress { from_port = 3306; to_port = 3306; protocol = "tcp"; security_groups = [var.app_sg_id] }
  egress  { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "${var.project}-rds-sg" }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = { Name = "${var.project}-rds-subnet-group" }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = var.allocated_storage
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = false
  final_snapshot_identifier = "${var.project}-db-final-snapshot"
  backup_retention_period = 7
  deletion_protection     = var.deletion_protection
  tags = { Name = "${var.project}-db", Environment = var.environment }
}
