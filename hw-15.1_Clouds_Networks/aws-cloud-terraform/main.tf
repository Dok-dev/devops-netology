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

/*-----------------1. VPC ---------------------*/

# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block = "10.10.0.0/16"
}

/*-----------------2. PUBLIC SUBNET ---------------------*/

# Create subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.10.1.0/24"
  # Specify true to indicate that instances launched into the subnet should be assigned a public IP address
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.10.2.0/24"
  tags = {
    Name = "private"
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "internet-gw"
  }
}

# Создадим таблицу маршрутизации, с маршрутом направляющим весь исходящий трафик в Internet gateway
resource "aws_route_table" "public_net_table" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
  tags = {
    Name = "Public net routing table"
  }
}

# Назначим созданную таблицу для публичной сети
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_net_table.id
}

# Создадим Security group для инстансов с разрешающими правилами на SSH и ICMP
resource "aws_security_group" "allow_ssh_icmp" {
  name        = "allow_ssh_icmp"
  description = "Allow SSH and ICMP inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "SSH to VPC"
    # Port range
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # Destination
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP to VPC"
    # All ICMP types [RFC2780]
    from_port = -1
    # All ICMP reply codes
    to_port   = -1
    protocol  = "icmp"
    # Destination
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    # All ports
    from_port = 0
    to_port   = 0
    # All protocols
    protocol = "-1" # equals protocol = "all"
    # Destination
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_icmp"
  }
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

# Подготовим публичный ключ для инстансов
#resource "aws_key_pair" "pub_key_for_aws" {
#  key_name   = "aws_key"
#  public_key = "ubuntu:${file("~/.ssh/aws_key.pub")}"
#}

# Настройки интерфейса инстанса в публичной сети
resource "aws_network_interface" "pub-int" {
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.allow_ssh_icmp.id]
  tags = {
    Name = "primary_network_interface"
  }
  depends_on = [aws_security_group.allow_ssh_icmp]
}

# Инстанс для публичной сети
resource "aws_instance" "netology-pub" {
  # Если нужны спотовые (on demand) инстансы:
  # resource "aws_spot_instance_request" "web" {

  # ссылка на data с подбором образа
  ami = data.aws_ami.ubuntu.id
  # тип машины
  instance_type = "t2.micro"

  # key_name = aws_key_pair.pub_key_for_aws.id
  # как вариант возьмем сразу то же ключ из AWS по имени
  key_name = "aws_key"

  # security_groups = aws_security_group.allow_ssh_icmp.id
  # vpc_security_group_ids = [aws_security_group.allow_ssh_icmp.id]

  network_interface {
    network_interface_id = aws_network_interface.pub-int.id
    device_index         = 0
  }

  tags = {
    Name = "Netology-public"

  }
}

# Зарезервируем внешний ip для NAT-gateway
resource "aws_eip" "ip_for_nat" {
  vpc      = true
}

# Создадим NAT-gateway для инстансов в приватной сети
resource "aws_nat_gateway" "NAT_gw" {
  allocation_id = aws_eip.ip_for_nat.id
  # В случае если интернет за NAT не нужен allocation_id не указывается,а:
  # connectivity_type = "private"
  subnet_id         = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet-gw]
}

/*-----------------3. PRIVATE SUBNET ---------------------*/

# Создадим таблицу маршрутизации для маршрутизации между сетями
resource "aws_route_table" "private_net_table" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_gw.id
  }

  tags = {
    Name = "Private net routing table"
  }
  depends_on = [aws_nat_gateway.NAT_gw]
}

# Ассоциируем приватную подсеть с таблицей маршрутизации
resource "aws_route_table_association" "ba" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_net_table.id
}

# Назначим созданную таблицу главной таблицей для данной сети
resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.vpc1.id
  route_table_id = aws_route_table.private_net_table.id
}

# Настройки интерфейса инстанса в приватной сети
resource "aws_network_interface" "private-int" {
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.allow_ssh_icmp.id]
  tags = {
    Name = "primary_network_interface2"
  }
  depends_on = [aws_security_group.allow_ssh_icmp]
}

# Инстанс для приватной сети
resource "aws_instance" "netology-private" {
  # resource "aws_spot_instance_request" "web" {

  # ссылка на data с подбором образа
  ami = data.aws_ami.ubuntu.id
  # тип машины
  instance_type = "t2.micro"

  # key_name = aws_key_pair.pub_key_for_aws.id
  key_name = "aws_key" # как вариант возьмем сразу то же ключ из AWS


  network_interface {
    network_interface_id = aws_network_interface.private-int.id
    device_index         = 0
  }

  tags = {
    Name = "Netology-private"

  }
}

# Выведем необходимую информацию о полученных адресах (можно перенести в outputs.tf)
output "netology-pub_ip" {
  value = aws_instance.netology-pub.public_ip
}

output "netology-private_ip" {
  value = aws_instance.netology-private.private_ip
}