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

/*===================== 2. S3 bucket encryption =====================*/


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

# Применим на бакет политику запрещающую загрузку незашифрованных SSE-S3 объектов.
resource "aws_s3_bucket_policy" "bucket_default_encryption" {
  bucket = aws_s3_bucket.bucket1.id
  policy = <<EOT
  {
    "Version": "2012-10-17",
    "Id": "RequireEncryption",
     "Statement": [
      {
        "Sid": "RequireEncryptedTransport",
        "Effect": "Deny",
        "Action": ["s3:*"],
        "Resource": ["arn:aws:s3:::${aws_s3_bucket.bucket1.bucket}/*"],
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        },
        "Principal": "*"
      },
      {
        "Sid": "RequireEncryptedStorage",
        "Effect": "Deny",
        "Action": ["s3:PutObject"],
        "Resource": ["arn:aws:s3:::${aws_s3_bucket.bucket1.bucket}/*"],
        "Condition": {
          "StringNotEquals": {
            "s3:x-amz-server-side-encryption": "AES256"
          }
        },
        "Principal": "*"
      }
    ]
  }
  EOT
  depends_on = [aws_s3_bucket.bucket1, aws_s3_bucket_object.image]
}


/*# Создадим KMS key на 7 дней в нашем регионе
resource "aws_kms_key" "kms-key" {
  description             = "KMS key 1"
  deletion_window_in_days = 7
  multi_region = false # Default value
}

data "aws_caller_identity" "current" {} # Понадобится id аккаунта

# Применим на бакет политику шифрования
resource "aws_s3_bucket_policy" "bucket_default_encryption" {
  bucket = aws_s3_bucket.bucket1.id
  policy = <<EOT
{
   "Version":"2012-10-17",
   "Id":"PutObjectPolicy",
   "Statement":[{
         "Effect":"Deny",
         "Principal":"*",
         "Action":"s3:PutObject",
         "Resource":"arn:aws:s3:::${aws_s3_bucket.bucket1.bucket}*//*",
         "Condition":{
            "StringNotEquals":{
               "s3:x-amz-server-side-encryption-aws-kms-key-id":"arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.kms-key.id}"
            }
         }
      }
   ]
}
EOT
}*/

resource "aws_s3_bucket_object" "examplebucket_object" {
  key                    = "Encrypted_file.html"
  bucket                 = aws_s3_bucket.bucket1.id
  source                 = "file.html"
  server_side_encryption = "AES256"
  depends_on = [aws_s3_bucket.bucket1, aws_s3_bucket_policy.bucket_default_encryption]
}


/*
resource "aws_s3_bucket" "bucket2" {

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
*/

/*----------------- Outputs ---------------------*/


output "bucket_url" {
  value = aws_s3_bucket.bucket1.bucket_regional_domain_name
}
