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

/*===================== 3. SSL + ALB =====================*/


/*--------------- Instances configuration -----------------*/

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

# Создадим шаблон для запуска инстансов c профайлом IAM
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


/*----------------- Autoscaling Group ---------------------*/


resource "aws_autoscaling_group" "ags-web" {
  name                = "terraform-web-asg"
  vpc_zone_identifier = [aws_subnet.public1.id, aws_subnet.public2.id]
  # launch_configuration = aws_launch_configuration.as_conf.name
  desired_capacity = 2
  min_size         = 2
  max_size         = 2

  health_check_grace_period = 60
  health_check_type         = "ELB"
  force_delete              = true

  target_group_arns = [aws_lb_target_group.web-tg.arn] #  A list of aws_alb_target_group ARNs, for use with Application or Network Load Balancing.

  launch_template {
    id = aws_launch_template.ec2_template1.id
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.alb1, aws_lb_target_group.web-tg]
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

resource "aws_lb_listener" "front_end1" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
  depends_on = [aws_lb.alb1, aws_lb_target_group.web-tg]
}

# Добавим TLS listener для LB c ключом
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb1.arn
  port              = "443"
  protocol          = "HTTPS"

  certificate_arn   = "arn:aws:acm:eu-central-1:654371877596:certificate/bd78f67c-80d0-4cea-8c4a-117b139d3f00"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
  depends_on = [aws_lb.alb1, aws_lb_target_group.web-tg]
}

/*----------------- Route 53 ---------------------*/

resource "aws_route53_zone" "travel-pt" {
  name = "travel-pt.ru"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.travel-pt.zone_id
  name    = "www.travel-pt.ru"
  type    = "A"

  alias {
    name                   = aws_lb.alb1.dns_name
    zone_id                = aws_lb.alb1.zone_id
    evaluate_target_health = true
  }
}

/*----------------- Outputs ---------------------*/

output "elb_dns_name" {
  value = aws_lb.alb1.dns_name
}

