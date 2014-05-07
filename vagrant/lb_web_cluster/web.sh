#!/usr/bin/env bash
yum -y install httpd
service httpd start

sleep 5
echo "Server created: $(date)"  > /var/www/html/index.html
