#!/usr/bin/env bash
NUM=$1
yum -y install httpd lsof
service httpd start

sleep 5
echo "WEB${1}"  > /var/www/html/index.html
