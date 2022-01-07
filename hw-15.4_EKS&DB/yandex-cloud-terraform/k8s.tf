
# Создадим группу мастеров (control plane nodes)
resource "yandex_kubernetes_cluster" "rl_cluster_1" {
  name        = "kubernetes-cluster1"
  description = "regional k8s cluster"

  network_id = yandex_vpc_network.vpc-1.id

  master {
    version   = "1.21"
    public_ip = true

    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.public.zone
        subnet_id = yandex_vpc_subnet.public.id
      }

      location {
        zone      = yandex_vpc_subnet.public2.zone
        subnet_id = yandex_vpc_subnet.public2.id
      }

      location {
        zone      = yandex_vpc_subnet.public3.zone
        subnet_id = yandex_vpc_subnet.public3.id
      }
    }

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "01:00"
        duration   = "3h"
      }

      maintenance_window {
        day        = "friday"
        start_time = "02:00"
        duration   = "4h30m"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.cluster_sa.id
  node_service_account_id = yandex_iam_service_account.cluster_sa.id

  labels = {
    my_label = "my_label1"
  }

  //Ключ Yandex KMS для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи (так называемые secrets).
  kms_provider {
    key_id = yandex_kms_symmetric_key.key-a.id
  }

  release_channel = "STABLE"

  depends_on = [
    yandex_resourcemanager_folder_iam_member.sa-edit1,
    yandex_resourcemanager_folder_iam_member.sa-edit3
  ]
}


# Создадим worker nodes
resource "yandex_kubernetes_node_group" "node_group1" {
  cluster_id  = yandex_kubernetes_cluster.rl_cluster_1.id
  name        = "node-group1"
  description = "worker nodes"
  version     = "1.21"

  labels = {
    "key" = "value"
  }

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat = true # Provide a public address, for instance, to access the internet over NAT
      # В группе с автоматическим масштабированием возможна только одна зона доступности
      subnet_ids = [yandex_vpc_subnet.public.id]
    }

    resources {
      memory        = 1
      cores         = 2
      core_fraction = 5 # % CPU
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true # Прерываемый инстанс
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

  }

  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }


  allocation_policy {
    location {
      zone = yandex_vpc_subnet.public.zone
    }
    /* #  В группе с автоматическим масштабированием возможна только одна зона доступности
    location {
      zone      = yandex_vpc_subnet.public2.zone
    }

    location {
      zone      = yandex_vpc_subnet.public3.zone
    }*/
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "5:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "1:00"
      duration   = "4h30m"
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.sa-edit1,
    yandex_resourcemanager_folder_iam_member.sa-edit3
  ]
}


# Получаем конфиг для подключения к кластеру
locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${yandex_kubernetes_cluster.rl_cluster_1.master[0].external_v4_endpoint}
    certificate-authority-data: ${base64encode(yandex_kubernetes_cluster.rl_cluster_1.master[0].cluster_ca_certificate)}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: ${yandex_iam_service_account.cluster_sa.name}
  name: ycmk8s
current-context: ycmk8s
users:
- name: ${yandex_iam_service_account.cluster_sa.name}
  user:
    exec:
      command: yc
      apiVersion: client.authentication.k8s.io/v1beta1
      interactiveMode: Never
      args:
      - k8s
      - create-token
KUBECONFIG
}

output "kubeconfig" {
  value = local.kubeconfig
}