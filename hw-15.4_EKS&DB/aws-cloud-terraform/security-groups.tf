
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow-mysql"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "to MySQL DB"
    # Port range
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    # Destination
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_mysql"
  }
}

/*
resource "aws_security_group" "allow_http" {
  name        = "allow-http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id
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
*/
