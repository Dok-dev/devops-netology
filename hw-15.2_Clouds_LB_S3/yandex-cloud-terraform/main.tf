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

/*-------------------1. Bucket Object Storage --------------------*/

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

// Use keys to create bucket
resource "yandex_storage_bucket" "bucket1" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "android-jones-paintings"
  # acl    = "public-read"
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

/*-------------------2. Instance Group --------------------*/

// Create Instance Group
resource "yandex_compute_instance_group" "group-web" {
  name                = "web-group"
  folder_id           = local.folder_id
  service_account_id  = yandex_iam_service_account.sa.id
  deletion_protection = false

    allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 3 # Одновременное создание
    max_expansion   = 1
    max_deleting    = 1
  }


  instance_template {
    platform_id = "standard-v1"
    service_account_id  = yandex_iam_service_account.sa.id

    resources {
      memory = 1
      cores  = 2
      core_fraction = 5
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 4
      }
    }

    scheduling_policy {
      preemptible = true # Прерываемый инстанс
    }

    network_interface {
      network_id = yandex_vpc_network.vpc-1.id
      subnet_ids = [yandex_vpc_subnet.public.id, yandex_vpc_subnet.public2.id]
      nat        = true # Provide a public address, for instance, to access the internet over NAT
    }

    metadata = {
      user-data = file("./bootstrap.sh")
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }
  // Instances health checking
  health_check {
    interval = 60
    timeout = 2
    tcp_options {
      port = 80
    }
  }

  load_balancer {
    target_group_name = "web-target-group"
  }

  # application_load_balancer =
  depends_on = [yandex_resourcemanager_folder_iam_member.sa-edit1]
}

/*-------------------3. Load balancer--------------------*/

resource "yandex_lb_network_load_balancer" "web" {
  name = "web-network-load-balancer"

  listener {
    name = "web-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.group-web.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = ""
      }
    }
  }
}

/*-------------------*4. Application load balancer--------------------*/

/*resource "yandex_alb_http_router" "tf-router" {
  name      = "my-http-router"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_load_balancer" "app-web" {
  name        = "web-load-balancer"

  network_id  = yandex_vpc_network.vpc-1.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 8080 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}*/

/*-------------------- Outputs -----------------------*/

#output "lb_ip_address" {
#  value = yandex_lb_network_load_balancer.web.? address
#}
