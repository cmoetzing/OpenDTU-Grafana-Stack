#!/bin/bash

ENV_FILE=.env
SUN_MOON_PLUGIN_VERSION=0.3.3

echo "##### Load settings from $ENV_FILE"
set -o allexport
source "$ENV_FILE"
set +o allexport

if [ -d $DATA_DIR ];  then
  echo "Error: directory $DATA_DIR already exists"
  exit 1
fi
DATA_DIR=$(readlink -f $DATA_DIR)

echo "##### Create data dir ${DATA_DIR}"
mkdir -p ${DATA_DIR}
mkdir -p ${DATA_DIR}/mosquitto/log ${DATA_DIR}/mosquitto/data ${DATA_DIR}/mosquitto/certs
mkdir -p ${DATA_DIR}/influxdb/config ${DATA_DIR}/influxdb/data
GRAFANA_PROVISIONING_DIR=${DATA_DIR}/grafana/provisioning
mkdir -p ${GRAFANA_PROVISIONING_DIR}/{datasources,dashboards} ${DATA_DIR}/grafana/dashboards ${DATA_DIR}/grafana/var/plugins

cp grafana/dashboards.yaml ${GRAFANA_PROVISIONING_DIR}/dashboards/default.yaml
GRAFANA_DATASOURCES_FILE=${GRAFANA_PROVISIONING_DIR}/datasources/default.yaml
cp grafana/datasources.yaml $GRAFANA_DATASOURCES_FILE
GRAFANA_DASHBOARD_FILE=${DATA_DIR}/grafana/dashboards/solar.json
cp grafana/dashboard-solar.json $GRAFANA_DASHBOARD_FILE

curl --silent -L https://grafana.com/api/plugins/fetzerch-sunandmoon-datasource/versions/${SUN_MOON_PLUGIN_VERSION}/download -o fetzerch-sunandmoon-datasource.zip
unzip fetzerch-sunandmoon-datasource.zip -d ${DATA_DIR}/grafana/var/plugins
rm fetzerch-sunandmoon-datasource.zip
sudo chown -R 472:0 ${DATA_DIR}/grafana/var

cp -a mosquitto ${DATA_DIR}/
cp -a telegraf ${DATA_DIR}/

echo "##### Pulling images"
docker-compose pull

echo "##### Configuring mosquitto user - $MQTT_USER"
docker run --rm -v ${DATA_DIR}/mosquitto/config:/mosquitto/config -e MQTT_USER="$(echo "$MQTT_USER" | tr -d '\r')" -e MQTT_PASSWORD="$(echo "$MQTT_PASSWORD" | tr -d '\r')" --entrypoint /bin/sh eclipse-mosquitto:2 -c 'touch /mosquitto/config/password.txt && chmod 0600 /mosquitto/config/password.txt && mosquitto_passwd -b /mosquitto/config/password.txt "${MQTT_USER}" "${MQTT_PASSWORD}"'

echo "##### influx token (wait for influx to start)"
docker-compose up -d influxdb

while ! docker-compose logs influxdb | grep -q "service=tcp-listener transport=http addr=:8086 port=8086"; do
  echo "waiting ..."
  sleep 1s
done

auth_list="$(docker-compose exec influxdb influx auth list -u $INFLUX_USER_NAME)"
auth_token=$(echo "$auth_list" | awk 'NR==2 {print $4}')
echo "##### The user token is: '$auth_token'"

echo "##### Setting token in environment"
sed -i '/^INFLUX_TOKEN=/s/=.*/='"$auth_token"'/' $ENV_FILE
export INFLUX_TOKEN=$auth_token

echo "##### Updating grafana datasource with new values from env"
sed -i 's,\[TOKEN\],'$auth_token', g' $GRAFANA_DATASOURCES_FILE
sed -i 's,\[ORGANIZATION\],'$GRAFANA_ORG_NAME', g' $GRAFANA_DATASOURCES_FILE
sed -i 's,\[LATITUDE\],'$LATITUDE', g' $GRAFANA_DATASOURCES_FILE
sed -i 's,\[LONGITUDE\],'$LONGITUDE', g' $GRAFANA_DATASOURCES_FILE

echo "##### Updating grafana dashboard input values from env"
sed -i 's,\[LONGITUDE\],'$LONGITUDE', g' $GRAFANA_DASHBOARD_FILE
sed -i 's,\[LATITUDE\],'$LATITUDE', g' $GRAFANA_DASHBOARD_FILE
sed -i 's,\[CITY\],'$OPEN_WEATHER_CITY_ID', g' $GRAFANA_DASHBOARD_FILE

echo $"##### Done, Starting the stack with 'docker-compose up -d'"
docker-compose up -d
