/*-----------------1. VPC ---------------------*/

# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block = "10.10.0.0/16"
}


/*-----------------2. PUBLIC SUBNET ---------------------*/

# Create subnets
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.10.1.0/24"
  # Specify true to indicate that instances launched into the subnet should be assigned a public IP address
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.10.3.0/24"
  # Specify true to indicate that instances launched into the subnet should be assigned a public IP address
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"
  tags = {
    Name = "public2"
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

# Назначим созданную таблицу главной таблицей для данной сети
resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.vpc1.id
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
    to_port  = -1
    protocol = "icmp"
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

resource "aws_security_group" "allow_http" {
  name        = "allow-necessary"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "HTTP to VPC"
    # Port range
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # Destination
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS to VPC"
    # Port range
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
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
    Name = "allow_http"
  }
}
