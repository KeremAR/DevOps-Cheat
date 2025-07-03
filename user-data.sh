#!/bin/bash
amazon-linux-extras install -y nginx1
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "WebServer (${PUBLIC_IP}) with ID: ${INSTANCE_ID}" > /usr/share/nginx/html/index.html
systemctl start nginx
systemctl enable nginx
