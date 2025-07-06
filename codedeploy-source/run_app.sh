#!/bin/bash
set -e
# Stop and remove existing container if it exists
if [ "$(docker ps -q -f name=alpine-httpd-app)" ]; then
    docker stop alpine-httpd-app
    docker rm alpine-httpd-app
fi

# Run the new container.
docker run -d --name alpine-httpd-app -p 80:80 156041430087.dkr.ecr.us-east-1.amazonaws.com/cmtr-zdv1y551:alpine-httpd 