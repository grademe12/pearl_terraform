allow_anonymous false
listener ${mosquitto_port}
protocol mqtt

password_file /mosquitto/pwfile

cafile /mosquitto/certs/ca.crt
certfile /mosquitto/certs/server.crt
keyfile /mosquitto/certs/server.key
require_certificate false

log_type all
log_dest stdout