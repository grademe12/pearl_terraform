# influxdb variables

variable "influxdb_token" {
  description = "InfluxDB auth token"
  type        = string
  sensitive   = true
}

variable "influxdb_org" {
  description = "value"
  type        = string
  sensitive   = false
}

variable "influx_mqtt_bucket" {
  description = "db bucket for mqtt name"
  type        = string
  sensitive   = false
}

variable "influx_opcua_bucket" {
  description = "db bucket for opcua name"
  type        = string
  sensitive   = false
}

variable "influxdb_username" {
  description = "influxdb username"
  type        = string
  sensitive   = true
}

variable "influxdb_password" {
  description = "influxdb password"
  type        = string
  sensitive   = true
}

# telegraf variables

variable "telegraf_username" {
  description = "telegraf login username"
  type        = string
  sensitive   = true
}

variable "telegraf_password" {
  description = "telegraf login password"
  type        = string
  sensitive   = true
}

# mosquitto variables

variable "mosquitto_port" {
  description = "mosquitto port"
  type        = number
  sensitive   = false
}

# grafana variables

variable "grafana_user" {
  description = "grafana user"
  type        = string
  sensitive   = true
}

variable "grafana_password" {
  description = "grafana password"
  type        = string
  sensitive   = true
}

# aws access key

variable "aws_access_key" {
  description = "aws access key for woosupar"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "aws secret leu fpr woosupar"
  type        = string
  sensitive   = true
}