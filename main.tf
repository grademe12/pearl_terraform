terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }
}

provider "docker" {}

resource "null_resource" "create_additional_bucket" {
  depends_on = [docker_container.influxdb]

  provisioner "local-exec" {
    command = <<-EOT
      sleep 10
      docker exec influxdb-terra influx bucket create \
        -n ${var.influx_opcua_bucket} \
        -o ${var.influxdb_org} \
        -t ${var.influxdb_token} \
      EOT
  }
}

resource "docker_network" "IOT" {
  name = "IOT"
}

resource "docker_volume" "influxdb_data" {
  name = "influxdb_data"
}

resource "local_file" "telegraf_config" {
  depends_on = [aws_kinesis_stream.kinesis]
  content = templatefile("/home/woosupar/terraform/conf/telegraf.conf.tpl", {
    influxdb_token      = var.influxdb_token
    influxdb_org        = var.influxdb_org
    influx_mqtt_bucket     = var.influx_mqtt_bucket
    influx_opcua_bucket = var.influx_opcua_bucket
    username            = var.telegraf_username
    password            = var.telegraf_password
    region              = "ap-northeast-2"
    stream_name         = aws_kinesis_stream.kinesis.name
  })
  filename = "/home/woosupar/terraform/conf/telegraf.conf"
}

resource "local_file" "mosquitto_config" {
  content = templatefile("/home/woosupar/terraform/conf/mosquitto.conf.tpl", {
    mosquitto_port = var.mosquitto_port
  })
  filename = "/home/woosupar/terraform/conf/mosquitto.conf"
}

resource "docker_image" "mosquitto" {
  name         = "eclipse-mosquitto:latest"
  keep_locally = false
}

resource "docker_image" "influxdb" {
  name         = "influxdb:latest"
  keep_locally = false
}

resource "docker_image" "telegraf" {
  name         = "telegraf:latest"
  keep_locally = false
}

resource "docker_image" "grafana" {
  name         = "grafana/grafana:latest"
  keep_locally = false
}

resource "docker_container" "mosquitto" {
  image = docker_image.mosquitto.image_id
  name  = "mosquitto-terra"
  ports {
    internal = 8883
    external = 8884
  }
  volumes {
    host_path      = local_file.mosquitto_config.filename
    container_path = "/mosquitto/config/mosquitto.conf"
    read_only      = true
  }
  volumes {
    host_path      = "/home/woosupar/terraform/certs/pwfile"
    container_path = "/mosquitto/pwfile"
    read_only      = false
  }
  volumes {
    host_path      = "/home/woosupar/terraform/certs"
    container_path = "/mosquitto/certs"
    read_only      = true
  }
  networks_advanced {
    name = docker_network.IOT.name
  }
  restart = "unless-stopped"
}

resource "docker_container" "influxdb" {
  image = docker_image.influxdb.image_id
  name  = "influxdb-terra"
  ports {
    internal = 8086
    external = 8087
  }
  volumes {
    volume_name    = docker_volume.influxdb_data.name
    container_path = "/var/lib/influxdb2"
  }
  env = [
    "DOCKER_INFLUXDB_INIT_MODE=setup",
    "DOCKER_INFLUXDB_INIT_USERNAME=${var.influxdb_username}",
    "DOCKER_INFLUXDB_INIT_PASSWORD=${var.influxdb_password}",
    "DOCKER_INFLUXDB_INIT_ORG=${var.influxdb_org}",
    "DOCKER_INFLUXDB_INIT_BUCKET=${var.influx_mqtt_bucket}",
    "DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=${var.influxdb_token}"
  ]
  networks_advanced {
    name = docker_network.IOT.name
  }
  restart = "unless-stopped"
}

resource "docker_container" "grafana" {
  image = docker_image.grafana.image_id
  name  = "grafana-terra"
  user  = "472"
  ports {
    internal = 3000
    external = 3001
  }
  volumes {
    host_path      = "/home/woosupar/terraform/grafana/provisioning"
    container_path = "/etc/grafana/provisioning"
  }
  volumes {
    host_path      = "/home/woosupar/terraform/grafana/dashboards"
    container_path = "/var/lib/grafana/dashboards"
    read_only      = false
  }
  env = [
    "GF_SECURITY_ADMIN_USER=${var.grafana_user}",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_password}"
  ]
  depends_on = [docker_container.influxdb]
  networks_advanced {
    name = docker_network.IOT.name
  }
  restart = "unless-stopped"
}

resource "docker_container" "telegraf" {
  image = docker_image.telegraf.image_id
  name  = "telegraf-terra"
  volumes {
    host_path      = "/home/woosupar/terraform/conf/telegraf.conf"
    container_path = "/etc/telegraf/telegraf.conf"
    read_only      = true
  }
  volumes {
    host_path      = "/home/woosupar/terraform/certs"
    container_path = "/etc/telegraf/certs"
    read_only      = true
  }
  depends_on = [
    docker_container.influxdb,
    docker_container.mosquitto,
    local_file.telegraf_config
  ]
  networks_advanced {
    name = docker_network.IOT.name
  }
  env = [
    "AWS_ACCESS_KEY_ID=${var.aws_access_key}",
    "AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}",
    "AWS_REGION=ap-northeast-2"
  ]
  restart = "unless-stopped"
}
