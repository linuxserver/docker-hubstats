#!/usr/bin/with-contenv bash
set -e

STAMP="/config/.influxdb-setup-complete"

if [ -f ${STAMP} ]; then
  echo "influxdb already configured, nothing to do."
  exit 0
fi

mkdir -p /config/etc/influxdb /config/var/lib/influxdb

cp /etc/influxdb/influxdb.conf /config/etc/influxdb/

sed -i 's/\/var\/lib/\/config\/var\/lib/g' /config/etc/influxdb/influxdb.conf

/usr/bin/influxd -pidfile /var/run/influxdb/influxd.pid -config /config/etc/influxdb/influxdb.conf 2>&1 &

# wait for influxdb to respond to requests
until /usr/bin/influx -execute 'show databases'; do sleep 1; done
/usr/bin/influx -execute 'create database dockerhub_stats'

kill `ps -ef | grep influxd | grep pid | awk {'print $2'}`

touch ${STAMP}
