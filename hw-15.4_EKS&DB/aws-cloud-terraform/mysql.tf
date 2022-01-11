// Создадим политику для пользователя работающего с RDS
resource "aws_iam_user_policy" "policy_rds_all" {
  name = "policy-rds"
  user = "terraform"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["rds:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

// Необходимо создать subnet_group для инстансов DB кластера
resource "aws_db_subnet_group" "az3_subnet_group" {
  name       = "az3_subnet_group_eu1_central"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "3 AZ DB subnet group"
  }
}

// Параметры движка DB
resource "aws_rds_cluster_parameter_group" "mysql-params1" {
  name        = "rds-cluster-pg"
  family      = "aurora-mysql5.7"
  description = "RDS mysql cluster parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

/*----------------- Main DB cluster ---------------------*/

// Создадим MultiAZ объект образующий кластер (not a "global cluster")
resource "aws_rds_cluster" "mysql-cluster1" {
  cluster_identifier           = "mysql-cluster1-${terraform.workspace}"
  engine                       = "aurora-mysql" # С terraform возможно только создание aurora-версии
  engine_version               = "5.7.mysql_aurora.2.10.1"
  availability_zones           = ["eu-central-1a", "eu-central-1b", "eu-central-1c"] # Only MultiAZ, not a "global cluster"
  database_name                = "netology_db"
  master_username              = "administrator"
  master_password              = "goodpaSSword"
  backup_retention_period      = 7
  preferred_maintenance_window = "Mon:00:00-Mon:03:00"
  preferred_backup_window      = "03:00-05:00"

  engine_mode                     = "provisioned" # It is default. Available: multimaster, parallelquery, provisioned, serverless.
  db_subnet_group_name            = aws_db_subnet_group.az3_subnet_group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql-params1.name
  storage_encrypted               = false
  skip_final_snapshot             = true
  vpc_security_group_ids          = [aws_security_group.allow_mysql.id]
  copy_tags_to_snapshot           = true

  tags = {
    "Name" : "mysql-cluster1-${terraform.workspace}"
  }

  # deletion_protection      = terraform.workspace == "prod" ? true : false
  depends_on = [aws_iam_user_policy.policy_rds_all, aws_rds_cluster_parameter_group.mysql-params1]
}

# Можно задать настройки DB
resource "aws_db_parameter_group" "education" {
  name        = "education"
  family      = aws_rds_cluster_parameter_group.mysql-params1.family
  description = "DB instance parameter group"

  parameter {
    name  = "max_connections"
    value = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Задаем параметры инстансов с DB
resource "aws_rds_cluster_instance" "cluster_instance" {
  count                   = 3 # количество инстансов с БД (1 write, 2 read)
  identifier              = "${aws_rds_cluster.mysql-cluster1.cluster_identifier}-${count.index}"
  cluster_identifier      = aws_rds_cluster.mysql-cluster1.id
  instance_class          = "db.t3.small" #lookup(var.db-instance-type, terraform.workspace, "db.t2.micro")
  engine                  = aws_rds_cluster.mysql-cluster1.engine
  engine_version          = aws_rds_cluster.mysql-cluster1.engine_version
  db_subnet_group_name    = aws_db_subnet_group.az3_subnet_group.name
  db_parameter_group_name = aws_db_parameter_group.education.name
  # preferred_maintenance_window = "Mon:00:00-Mon:03:00" # уже установленно в кластере
  # preferred_backup_window      = "03:00-05:00"         # уже установленно в кластере

  tags = {
    "Name" : "bd-instance-${terraform.workspace}-instance-${count.index}"
  }
}

/*resource "aws_rds_cluster_endpoint" "static" {
  cluster_identifier          = aws_rds_cluster.mysql-cluster1.id
  cluster_endpoint_identifier = "static"
  custom_endpoint_type        = "READER"

  static_members = [
    aws_rds_cluster_instance.cluster_instance[1].id,
    aws_rds_cluster_instance.cluster_instance[2].id
  ]
}*/


/*----------------- Cross region read replica DB cluster ---------------------*/
# Для реплики в другом регионе необходимо создать новые сети, security groups и aws_db_subnet_group

/*resource "aws_rds_cluster" "dr_db_cluster" {
  cluster_identifier              = "mysql-dr-cluster1-${terraform.workspace}"
  availability_zones              = ["eu-central-1a", "eu-central-1b"] !
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql-params1.id
  master_username                 = aws_rds_cluster.mysql-cluster1.master_username
  master_password                 = aws_rds_cluster.mysql-cluster1.master_password
  vpc_security_group_ids          = [aws_security_group.allow_mysql.id] !
  db_subnet_group_name            = aws_db_subnet_group.az3_subnet_group.name
  engine_mode                     = "provisioned"
  engine                          = aws_rds_cluster.mysql-cluster1.engine
  engine_version                  = aws_rds_cluster.mysql-cluster1.engine_version
  skip_final_snapshot             = true
  copy_tags_to_snapshot           = true
  backup_retention_period         = 7
  deletion_protection             = false
  replication_source_identifier   = aws_rds_cluster.mysql-cluster1.arn
  preferred_maintenance_window    = "Sun:00:00-Sun:03:00"
  preferred_backup_window         = "03:00-05:00"
  # kms_key_id                      = "arn:aws:kms:eu-west-1:${local.account_number}:key/th6-7ey-t0-m7-h3art"
  # source_region                   = "us-east-1"

  tags = {
    "Name" : "mysql-cluster1-dr-${terraform.workspace}"
  }

  depends_on = [aws_rds_cluster.mysql-cluster1, aws_rds_cluster_instance.cluster_instance]
}

resource "aws_rds_cluster_instance" "dr_cluster_instance" {
  count                        = 2
  identifier                   = "dr-bd-instance-${terraform.workspace}-${count.index}"
  cluster_identifier           = aws_rds_cluster.dr_db_cluster.id
  instance_class               = "db.t3.small" #lookup(var.db-instance-type, terraform.workspace, "db.t2.micro")
  db_subnet_group_name         = aws_db_subnet_group.az3_subnet_group.name
  engine                       = aws_rds_cluster.mysql-cluster1.engine
  engine_version               = aws_rds_cluster.mysql-cluster1.engine_version
  db_parameter_group_name      = aws_db_parameter_group.education.name

  tags = {
    "Name" : "dr-bd-instance-${terraform.workspace}-instance-${count.index}"
  }

  depends_on = [aws_rds_cluster.mysql-cluster1, aws_rds_cluster_instance.cluster_instance]
}*/


/*----------------- Outputs ---------------------*/

output "mysql_cluster_endpoint" {
  value = aws_rds_cluster.mysql-cluster1.endpoint
  # value       = local.is_regional_cluster ? join("", aws_rds_cluster.primary.*.endpoint) : join("", aws_rds_cluster.secondary.*.endpoint)
  description = "The DNS address of the RDS instance"
}
