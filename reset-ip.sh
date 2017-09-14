#!/bin/bash

PUB_IP=`(curl http://169.254.169.254/latest/meta-data/public-ipv4)`
PRI_IP=`(curl http://169.254.169.254/latest/meta-data/local-ipv4)`
OLD_IP=`more /etc/origin/master/master-config.yaml | grep console | grep  publicURL | cut -d ":" -f3 | cut -d "/" -f3`
sed -i "s/$OLD_IP/$PUB_IP/g" /etc/origin/master/master-config.yaml

kill -9 `ps -elf | grep open | grep -v grep | awk '{print $4}'`

echo ""
echo ""
echo ""
echo ""
url=`more /etc/origin/master/master-config.yaml | grep publicURL`
echo $url
