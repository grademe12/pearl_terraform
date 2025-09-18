[agent]
  interval = "5s"
  flush_interval = "5s"

[[outputs.influxdb_v2]]
  ulrs = ["http://influxdb:8087"]
  token = "${influxdb_token}"
  organization = "${influxdb_org}"
  bucket = "${influxdb_bucket}"

[[inputs.mqtt_consumer]]
  servers = ["ssl://mosquitto:8884"]
  topics = [
	"factory/sensor/temperature",
	"factory/sensor/humidity"
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

  [[inputs.mqtt_consuper.topic_parsing]]
    topic = "factory/sensor/+"
	measurement = "factory_sensors"
	tags = "_/_/sensor_type"



