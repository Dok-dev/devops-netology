resource "yandex_mdb_mysql_cluster" "mysql-cl" {
  name        = "my_sql_cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.vpc-1.id
  version     = "8.0"
  # deletion_protection = true # Защита от удаления кластера. НЕ РАБОТАЕТ - "error: Unsupported argument"

  resources {
    resource_preset_id = "b1.medium" # 2x Intel Broadwell - 50% CPU, 4 GB
    disk_type_id       = "network-hdd"
    disk_size          = 20
  }

  mysql_config = {
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections               = 200
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = true
  }

  database {
    name = "netology_db"
  }

  maintenance_window {
    #type = "ANYTIME"
    type = "WEEKLY"
    day  = "SAT"
    hour = 02
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  user {
    name     = "administrator"
    password = "good_password"
    permission {
      database_name = "netology_db"
      roles         = ["ALL"]
    }
  }

  host {
    # name      = "bd-node-a"
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.private.id
    # replication_source_name = "bd_node_b" # When not set then host in HA group.
  }

  host {
    # name      = "bd-node-b"
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.private2.id
    # replication_source_name = "bd_node_a" # When not set then host in HA group.
  }
}


output "db_host_fqdn" {
  value = yandex_mdb_mysql_cluster.mysql-cl.host.0.fqdn
}

output "db_host_fqdn2" {
  value = yandex_mdb_mysql_cluster.mysql-cl.host.1.fqdn
}

output "db_host_addr" {
  value = yandex_mdb_mysql_cluster.mysql-cl.host.0.assign_public_ip
}

output "db_host_addr2" {
  value = yandex_mdb_mysql_cluster.mysql-cl.host.1.assign_public_ip
}
