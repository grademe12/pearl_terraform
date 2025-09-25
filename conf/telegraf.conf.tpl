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

  [inputs.mqtt_consumer.tags]
    source = "mqtt"
  [[inputs.mqtt_consumer.topic_parsing]]
    topic = "factory/sensor/+"
    tags = "_/_/sensor_type"

[[inputs.opcua]]
  endpoint = "opc.tcp://192.168.45.205:4840/pearl-factory/server"
  security_policy = "None"
  security_mode = "None"

  nodes = [
    {name="temperature", namespace="2", identifier_type="i", identifier="2"},
    {name="pressure", namespace="2", identifier_type="i", identifier="3"},
    {name="humidity", namespace="2", identifier_type="i", identifier="4"},
    {name="vibration", namespace="2", identifier_type="i", identifier="5"},
    {name="production", namespace="2", identifier_type="i", identifier="6"}
  ]

  [inputs.opcua.tags]
    source = "opcua"

[[outputs.influxdb_v2]]
  urls = ["http://influxdb-terra:8086"]
  token = "${influxdb_token}"
  organization = "${influxdb_org}"
  bucket = "${influx_mqtt_bucket}"
  [outputs.influxdb_v2.tagpass]
    source = ["mqtt"]

[[outputs.influxdb_v2]]
  urls = ["http://influxdb-terra:8086"]
  token = "${influxdb_token}"
  organization = "${influxdb_org}"
  bucket = "${influx_opcua_bucket}"
  [outputs.influxdb_v2.tagpass]
    source = ["opcua"]

[[outputs.kinesis]]
  region = "${region}"
  streamname = "${stream_name}"
  data_format = "json"
  [outputs.kinesis.partition]
    method = "static"
    key = "default"
