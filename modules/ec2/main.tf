resource "aws_security_group" "alb" {
  name   = "${var.project}-alb-sg"
  vpc_id = var.vpc_id
  ingress { from_port = 80;  to_port = 80;  protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 443; to_port = 443; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0;   to_port = 0;   protocol = "-1";  cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "${var.project}-alb-sg" }
}

resource "aws_security_group" "app" {
  name   = "${var.project}-app-sg"
  vpc_id = var.vpc_id
  ingress { from_port = var.app_port; to_port = var.app_port; protocol = "tcp"; security_groups = [aws_security_group.alb.id] }
  egress  { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "${var.project}-app-sg" }
}

resource "aws_lb" "alb" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "${var.project}-alb" }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.project}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check { path = "/health"; interval = 30; timeout = 5; healthy_threshold = 2; unhealthy_threshold = 3 }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action { type = "forward"; target_group_arn = aws_lb_target_group.app.arn }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }
  user_data = base64encode(var.user_data)
  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project}-app", Environment = var.environment }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.project}-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  tag { key = "Name"; value = "${var.project}-app"; propagate_at_launch = true }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.app.name }
}
