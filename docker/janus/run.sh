#!/bin/bash

#Enable admin api
sed -i "s/admin_http = no/admin_http = yes/g" /opt/janus/etc/janus/janus.transport.http.cfg
sed -i "s/8088/80/g" /opt/janus/etc/janus/janus.transport.http.cfg

#Set free RTP port seat
for i in $(seq 20000 20100)
do
  seat=$(curl  -s  http://consul:8500/v1/kv/rtp/$i | jq .[].Value | base64 -di)
  if [ "$seat" == "avaliable" ]
  then
    echo "It's there!"
    curl -s --request PUT --data "busy" http://consul:8500/v1/kv/rtp/$i
    echo $i
    sed -i "s/20000-40000/$i/g" /opt/janus/etc/janus/janus.*
    break
  fi
done

#Run with admin api enabled
/opt/janus/bin/janus  -C /opt/janus/etc/janus/janus.cfg -A
