# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region  = var.region
  profile = "default"
}

/*-----------------1. S3 bucket ---------------------*/

resource "aws_s3_bucket" "bucket1" {
  bucket = "biryukov-tv-12.2021"
  # acl    = "public-read"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "image" {
  bucket = aws_s3_bucket.bucket1.id
  key    = "harmony.jpg"       # Имя в бакете
  source = "~/img/harmony.jpg" # Локальный путь для загрузки
  acl    = "public-read"
  # etag = filemd5("path/to/file")
  tags = {
    Name   = "Harmony of Dragons"
    Author = "Android Jones"
  }
  depends_on = [aws_s3_bucket.bucket1]
}

/*-----------------2. Launch configurations ---------------------*/

# Задаем образ для заливки с автоподбором
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Создадим шаблон для запуска инстансов
resource "aws_launch_template" "ec2_template1" {
  name_prefix   = "web-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "aws_key" # RSA ключ
  # vpc_security_group_ids = aws_security_group.allow_necessary.id

  placement {
    availability_zone = var.region
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.allow_http.id, aws_security_group.allow_ssh_icmp.id]
  }

  metadata_options {
    http_endpoint = "enabled"
    # http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = filebase64("./script.sh")
}

/*-----------------3. Autoscaling Group & application LB. ---------------------*/

/*----------------- Autoscaling Group ---------------------*/

resource "aws_autoscaling_group" "ags-web" {
  name                = "terraform-web-asg"
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
  # launch_configuration = aws_launch_configuration.as_conf.name
  desired_capacity = 3
  min_size         = 3
  max_size         = 3

  health_check_grace_period = 60
  health_check_type         = "ELB"
  force_delete              = true

  # load_balancers = [aws_lb.alb1.id]
  target_group_arns = [aws_lb_target_group.web-tg.arn] #  A list of aws_alb_target_group ARNs, for use with Application or Network Load Balancing.

  launch_template {
    id = aws_launch_template.ec2_template1.id
    # version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.alb1, aws_lb_target_group.web-tg]
}

# Создадим политику для увеличения количества инстансов
resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "web_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ags-web.name
}

# Тригер для увеличения масштаба
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ags-web.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_up.arn]
}

# Создадим политику для уменьшения количества инстансов
resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "web_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ags-web.name
}

# Тригер для уменьшения масштаба
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ags-web.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_down.arn]
}

/*----------------- Application LB ---------------------*/

# Создадим target group инстансов для балансировщика
resource "aws_lb_target_group" "web-tg" {
  name                          = "web-lb-tg"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = aws_vpc.vpc1.id
  load_balancing_algorithm_type = "round_robin"
  target_type                   = "instance"

}

# Attach EC2 instances to target group
#resource "aws_lb_target_group_attachment" "web-tg-att" {
#  target_group_arn = aws_lb_target_group.web-tg.arn
#  # target_id        = [for sc in range(2) : data.
#  target_id = aws_lb.alb1.arn
#  port             = 80
# #autoscaling_group_name = aws_autoscaling_group.ags-web.id
#  #alb_target_group_arn = aws_lb_target_group.web-tg.arn
#  depends_on = [aws_lb.alb1, aws_lb_target_group.web-tg]
#}

# Создадим application load balancer
resource "aws_lb" "alb1" {
  name                       = "application-lb1"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_http.id]
  subnets                    = [aws_subnet.public1.id, aws_subnet.public2.id]
  enable_deletion_protection = false
  # enable_cross_zone_load_balancing   = true

  tags = {
    Environment = "production"
  }
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}


/*----------------- Outputs ---------------------*/
/*-------(можно перенести в outputs.tf)----------*/

output "bucket_url" {
  value = aws_s3_bucket.bucket1.bucket_regional_domain_name
}

output "elb_dns_name" {
  value = aws_lb.alb1.dns_name
}
