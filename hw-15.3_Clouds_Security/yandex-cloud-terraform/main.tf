terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

locals {
  folder_id = "b1gru9vkkhtb29co4kh5"
  cloud_id  = "b1gpm33d7a0h72fo204t"
}

provider "yandex" {
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
  zone      = "ru-central1-a"
}

/*-------------------1. KMS encryption for bucket object --------------------*/

// Create SA
resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "tf-editor-account"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-edit1" {
  folder_id = local.folder_id
  role      = "editor" # Permission make ability to create, edit and delete any objects
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Create KMS key
resource "yandex_kms_symmetric_key" "key-a" {
  name              = "symetric-key"
  description       = "encryption for bucket"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}

// Use keys to create bucket
resource "yandex_storage_bucket" "bucket1" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "android-jones-paintings"
  # acl    = "public-read"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

// Upload file to bucket
resource "yandex_storage_object" "picture1" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = yandex_storage_bucket.bucket1.id
  key    = "harmony.jpg"
  source = "~/img/harmony.jpg"
  acl    = "public-read"
}

