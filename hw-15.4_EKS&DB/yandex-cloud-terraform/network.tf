
resource "yandex_vpc_network" "vpc-1" {
  name = "vpc-network1"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "nat-vm" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    core_fraction = 20 # % CPU
    memory        = 2
  }

  scheduling_policy {
    preemptible = true # прерываемая
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    # user-data = "${file("meta.txt")}"
  }
}

resource "yandex_vpc_route_table" "vpc-1-rt" {
  name       = "nat-gateway"
  network_id = yandex_vpc_network.vpc-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-vm.network_interface.0.ip_address
  }
}

resource "yandex_vpc_subnet" "public2" {
  name           = "public2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.vpc-1-rt.id
  depends_on     = [yandex_vpc_route_table.vpc-1-rt]
}

resource "yandex_vpc_subnet" "public3" {
  name           = "public3"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.50.0/24"]
  route_table_id = yandex_vpc_route_table.vpc-1-rt.id
  depends_on     = [yandex_vpc_route_table.vpc-1-rt]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.vpc-1-rt.id
}

resource "yandex_vpc_subnet" "private2" {
  name           = "private2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.40.0/24"]
  route_table_id = yandex_vpc_route_table.vpc-1-rt.id
}

output "internal_ip_address_nat-vm" {
  value = yandex_compute_instance.nat-vm.network_interface.0.ip_address
}

