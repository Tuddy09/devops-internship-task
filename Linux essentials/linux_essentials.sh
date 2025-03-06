#!/bin/bash

apt update
apt installnano dnsutils netcat-openbsd curl nginx -y
dig tremend.com +short
echo "8.8.8.8 google-dns" >> /etc/hosts
nc -zv google-dns 53
echo "nameserver 8.8.8.8" > /etc/resolv.conf
dig tremend.com +short
nginx &
curl localhost
ss -tuln | grep 80
sed -i 's/listen [0-9]\+;/listen 8080;/g' /etc/nginx/sites-enabled/default # I tried this and did not work, so I maually edited it with nano, thought that was ok, so I did not go on to solve why this does not work
nginx -s reload
ss -tuln | grep 8080
sed -i 's/Welcome to nginx!/I have completed the Linux part of the Tremend DevOps internship project/' /var/www/html/index.nginx-debian.html
curl localhost:8080
