[agent]
  interval = "5s"
  flush_interval = "5s"

[[inputs.mqtt_consumer]]
  servers = ["ssl://mosquitto-terra:8883"]
  topics = [
	"factory/sensor/temperature",
	"factory/sensor/humidity",
	"factory/sensor/vibration",
	"factory/sensor/pressure",
	"factory/sensor/production"
  ]

  qos = 0
  data_format = "json"
  tag_keys = [
	"sensor_id",
	"sensor_type",
  ]

  username = "${username}"
  password = "${password}"
  tls_ca = "/etc/telegraf/certs/ca.crt"
  insecure_skip_verify = true

  [[inputs.mqtt_consumer.topic_parsing]]
    topic = "factory/sensor/+"
    tags = "_/_/sensor_type"

[[outputs.influxdb_v2]]
  urls = ["http://influxdb-terra:8086"]
  token = "${influxdb_token}"
  organization = "${influxdb_org}"
  bucket = "${influxdb_bucket}"
