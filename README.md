# Attribution:
* Forked from [Kraego/OpenDTU-Grafana-Stack](https://github.com/Kraego/OpenDTU-Grafana-Stack)
* Dashboard and Telegraf files from [smainz/OpenDTU-MQTT-Telegraf-influxdb-integration](https://github.com/smainz/OpenDTU-MQTT-Telegraf-influxdb-integration)

# Mosquitto-Telegraf-Influx-Grafana Stack

[![Check compose file](https://github.com/Kraego/OpenDTU-Grafana-Stack/actions/workflows/yamlcheck.yml/badge.svg)](https://github.com/Kraego/OpenDTU-Grafana-Stack/actions/workflows/yamlcheck.yml)
[![License](https://img.shields.io/badge/License-MIT-blue)](#license "Go to license section")

This is a docker stack created to visualize the topics of a **opendDTU** (https://github.com/tbnobody/OpenDTU). The data from openDTU is transferred over mqtt with basic auth an let's encrypt certificates. The data will be stored up to five years. Basically it is the dockerized version of https://github.com/Kraego/OpenDTU-Grafana-Howto. When used with something different adapt the telegraf mapping to your scenario.

It consists of:
  * `mosquitto` (mqtt broker)
  * `telegraf` (mqtt -> influxDB2)
  * `influxDB2` (store the timeframes in buckets)
  * `grafana` (monitoring)

## Prequesites

* The following ports must be open on host (so if you have a firewall unblock these ports)
  * `3000` for grafana (webinterface)
  * `1883` for mqtt broker (to receive publishes from openDTU)

## How to use it

1. Clone the repo
    ```
    git clone https://github.com/Kraego/OpenDTU-Grafana-Stack.git
    ```
2. Go to directory where you have cloned the repo
    ```
    cd OpenDTU-Grafana-Stack
    ```
4. Create a `.env` file from the template
   * rename `.env_template` to `.env`
   * configure the variables with your values, INFLUX_TOKEN will be set automatic during init
5. Run the init script:
    ```
     ./init.sh
    ```
6. Open grafana: http://localhost:3000
   * Use the credentials configured in the .env file
