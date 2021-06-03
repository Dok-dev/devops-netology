# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = "default"
}

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

# Настройки инстансов через модуль
module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "Netology-cluster"
  # количество инстансев (машин) согласно воркспейсу
  instance_count         = local.web_instance_count_map[terraform.workspace]

  # ссылка на data с подбором образа
  ami                    = data.aws_ami.ubuntu.id
  # тип машины согласно воркспейсу
  instance_type          = local.web_instance_type_map[terraform.workspace]
  monitoring             = false

  # Подсеть VPC us-west-2
  subnet_id              = "subnet-3ff45875"

  tags = {
    Terraform   = "true"
    Environment = "test-dev"
  }
}


# для получения доступа к данным авторизации (Account ID, User ID, and ARN)
data "aws_caller_identity" "current" {}

# для получения данных о регионе
data "aws_region" "current" {}