#!/bin/bash
set -e
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

# Login to ECR and pull the image.
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 156041430087.dkr.ecr.us-east-1.amazonaws.com
docker pull 156041430087.dkr.ecr.us-east-1.amazonaws.com/cmtr-zdv1y551:alpine-httpd 