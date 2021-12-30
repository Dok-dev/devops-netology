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

/*===================== 1. IAM + EC2 + S3 =====================*/

/*--------------- 3s bucket -----------------*/

resource "aws_s3_bucket" "bucket1" {
  bucket = "biryukov-tv-12.2021"
  # acl    = "public-read"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

/*--------------- IAM role -----------------*/

# Создадим политику для роли
resource "aws_iam_policy" "policy_s3_write" {
  name = "policy-381966"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Создадим роль разрешающую запись в бакет
resource "aws_iam_role" "s3write" {
  name = "ec2_to_s3_role"

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.policy_s3_write.arn]
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions   = ["sts:AssumeRole"]
  }
}


# Создадим профайл с  для инстансов с ролью
resource "aws_iam_instance_profile" "s3_profile" {
  name = "EC2_to_S3_profile"
  role = aws_iam_role.s3write.name
  depends_on = [aws_iam_policy.policy_s3_write, aws_iam_role.s3write]
}

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
    subnet_id   = aws_subnet.public1.id
  }

  metadata_options {
    http_endpoint = "enabled"
    # http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  #// Добавим профайл
  #iam_instance_profile {
  #  name = aws_iam_instance_profile.s3_profile.name
  #}

  user_data = filebase64("./script.sh")
}


/*----------------- Instance---------------------*/

resource "aws_instance" "web" {
  launch_template {
    id = aws_launch_template.ec2_template1.id
  }

    // Добавим профайл
  iam_instance_profile = aws_iam_instance_profile.s3_profile.name

  tags = {
    Name = "Uploader"
  }
 depends_on = [aws_iam_policy.policy_s3_write, aws_iam_role.s3write, aws_iam_instance_profile.s3_profile]
}

/*----------------- Outputs ---------------------*/

output "bucket_url" {
  value = aws_s3_bucket.bucket1.bucket_regional_domain_name
}

output "aws_instance_ip" {
  value = aws_instance.web.public_ip
}

