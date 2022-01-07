terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

provider "yandex" {
  cloud_id  = "b1gpm33d7a0h72fo204t"
  folder_id = "b1gru9vkkhtb29co4kh5"
  zone      = "ru-central1-a"
}


resource "yandex_vpc_network" "vpc-1" {
  name = "vpc-network1"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.vpc-1-rt.id
}

resource "yandex_compute_instance" "nat-vm" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
	core_fraction = 20
    memory = 2
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    # user-data = "${file("meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-pub" {
  name        = "pub-instance"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
	core_fraction = 20
    memory = 2

  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l9qf9lsih4f772meq"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    nat        = true # Provide a public address, for instance, to access the internet over NAT
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_vpc_route_table" "vpc-1-rt" {
  name = "nat-gateway"
  network_id = yandex_vpc_network.vpc-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-vm.network_interface.0.ip_address
  }
}

resource "yandex_compute_instance" "vm-private" {
  name        = "private-instance"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
	core_fraction = 20
    memory = 2
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd8l9qf9lsih4f772meq"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "internal_ip_address_nat-vm" {
  value = yandex_compute_instance.nat-vm.network_interface.0.ip_address
}

output "external_ip_address_vm-pub" {
  value = yandex_compute_instance.vm-pub.network_interface.0.nat_ip_address
}
