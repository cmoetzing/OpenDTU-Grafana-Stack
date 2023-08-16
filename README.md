# Mosquitto-Telegraf-Influx-Grafana Stack

This is WIP.

This is a docker stack created to visualize the topics of a opendDTU (https://github.com/tbnobody/OpenDTU). Mqtt communication with basic auth an let's encrypt certificates. Basically it is the dockerized version of https://github.com/Kraego/OpenDTU-Grafana-Howto.

It consists of:
  * `mosquitto` (mqtt broker)
  * `telegraf` (mqtt -> influxDB2)
  * `influxDB2` (store the timeframes in buckets)
  * `grafana` (monitoring)

## Prequesites

* The following ports must be open on host (so if you have a firewall unblock these ports)
  * `3000` for grafana (webinterface)
  * `8883` or `1883` for mqtt broker (to receive publishes from openDTU)
* if you want **the tls cert stuff** uncomment line 6-8 in the `mosquitto.conf`
* **Install `Certbot` on your Host**
  * update `[YOUR DOMAIN]` and `[DIR MOUNT OF MOSQUITTO CONTAINER ON HOST]` (./mosquitto/certs) in `mosquitto-copy-certs.sh`
  * copy the file `mosquitto-copy-certs.sh` to your certbot renewal hooks dir (on Linux it is: /etc/letsencrypt/renewal-hooks/deploy) and make it executable (`chmod +x mosquitto-copy-certs.sh`)

## How to use it

1. Clone Repo
    ```
    git clone https://github.com/Kraego/OpenDTU-Mosquitto-Telegraf-Influx-Grafana-Stack.git
    ```
2. Go to directory where you have cloned the repo
3. Create a `.env` file from the template
   * rename `.env_template` to `.env`
   * configure the variables with your values 
4. run the init script: `./init.sh`
5. Start up the whole stack
   ```
   docker-compose up -d
   ```
6. Setup grafana over: http://localhost:3000
   * add Datasource
     * Query Language: Flux
     * URL: http://influxdb:8086
     * Basic auth: User and password again from your `.env` file
     * Organization: the same as in your `.env` file
     * Get the token from your `.env` file
       * copy the token to the textbox
7. Add or create Dashboards

**YOUR DONE**

## SELinux

If you have SELinux installed and running, add `:Z` to all `volumes` entries in `docker-compose.yaml`, e.g.

```
  volumes:
    - ./influxdb/data:/var/lib/influxdb2:Z
```

## Improvements

Things I didn't did but would be nice:

* Run certbot internal as service (how to pass the let's encrypt challenge?)
* ....
  
