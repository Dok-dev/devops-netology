
resource "yandex_vpc_network" "vpc-1" {
  name = "vpc-network1"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "public2" {
  name           = "public2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}
