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
}

/*------------------- Service accounts and keys --------------------*/

// Create service accounts
resource "yandex_iam_service_account" "cluster_sa" {
  folder_id = local.folder_id
  name      = "cluster-editor-account"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-edit1" {
  folder_id   = local.folder_id
  role        = "k8s.editor" # Permission make ability to create, edit and delete k8s objects
  member      = "serviceAccount:${yandex_iam_service_account.cluster_sa.id}"
  sleep_after = 30
}
resource "yandex_resourcemanager_folder_iam_member" "sa-edit2" {
  folder_id = local.folder_id
  role      = "kms.editor" # Permission make ability to create, edit and delete kms objects
  member    = "serviceAccount:${yandex_iam_service_account.cluster_sa.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "sa-edit3" {
  folder_id = local.folder_id
  # role        = "k8s.cluster-api.editor" // разрешение почему-то не работает
  role        = "editor"
  member      = "serviceAccount:${yandex_iam_service_account.cluster_sa.id}"
  sleep_after = 30
}



// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.cluster_sa.id
  description        = "static access key for object storage"
}

// Create KMS key
resource "yandex_kms_symmetric_key" "key-a" {
  name              = "symetric-key"
  description       = "encryption for bucket"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
  depends_on        = [yandex_resourcemanager_folder_iam_member.sa-edit2]
}


/*------------------- Load balancer--------------------*/

// Подключается автоматически к сервису типа LoadBalancer в Yandex Kubernetis Managed Cloud