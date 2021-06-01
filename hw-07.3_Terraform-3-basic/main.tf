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

# Настройки инстансов
resource "aws_instance" "netology-ec2" {

  # количество инстансев (машин) согласно воркспейсу
  count = local.web_instance_count_map[terraform.workspace]

  # ссылка на data с подбором образа
  ami = data.aws_ami.ubuntu.id
  # тип машины согласно воркспейсу
  instance_type = local.web_instance_type_map[terraform.workspace]

  # колличество ядер доступных инстансу
  cpu_core_count = 1
  # поведение при остановке инстанса (по умолчанию stop)
  instance_initiated_shutdown_behavior = "stop"
  # включение защиты от удаления инстанса (по умолчанию false), не спасает от instance_initiated_shutdown_behavior = "terminate"
  disable_api_termination = false
  # расширенный мониторинг
  monitoring = false
  # назначать ли инстансу публичный ip-адрес в VPC
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Netology"

  }
}

# Настройки инстансов через for_each
resource "aws_instance" "netology-for_each" {

  for_each = local.web_instance_each_map[terraform.workspace]

  # ссылка на data с подбором образа
  ami = data.aws_ami.ubuntu.id
  # тип машины согласно воркспейсу
  instance_type = local.web_instance_type_map[terraform.workspace]

  # колличество ядер доступных инстансу
  cpu_core_count = 1
  # поведение при остановке инстанса (по умолчанию stop)
  instance_initiated_shutdown_behavior = "stop"
  # включение защиты от удаления инстанса (по умолчанию false), не спасает от instance_initiated_shutdown_behavior = "terminate"
  disable_api_termination = false
  # расширенный мониторинг
  monitoring = false
  # назначать ли инстансу публичный ip-адрес в VPC
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Server ${each.key}"

  }
}

# Настройка ресурса для S3 бакета (не обязательно)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.region}-state" # название каталога для хранения
  lifecycle {
    # запрет на удаление ресурса
    prevent_destroy = false
  }
  versioning {
    # включение версионирования файла terraform.tfstate на стороне S3-хранилища
    enabled = true
  }
  # настройки шифрования
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  acl = "private"
}

# Настройка таблицы AWS DynamoDB, в которой будет храниться информация о блокировках файла terraform.tfstate (не обязательно)
resource "aws_dynamodb_table" "terraform_locks" {
  name = "${var.region}-locks"
  billing_mode = "PAY_PER_REQUEST" # тип оплаты. Значение PAY_PER_REQUEST позволяет оплачивать по количеству обращений к таблице
  hash_key = "LockID" # указание первичного ключа таблицы
  # A list of attributes that describe the key schema for the table and indexes
  attribute {
    name = "LockID" # Attribute Name
    type = "S" # the attribute is of type String
  }
}


# для получения доступа к данным авторизации (Account ID, User ID, and ARN)
data "aws_caller_identity" "current" {}

# для получения данных о регионе
data "aws_region" "current" {}