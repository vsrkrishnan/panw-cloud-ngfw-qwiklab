#!/bin/bash

echo "Updating yum repositories"
sudo yum update -y

echo "Installing Docker"
sudo amazon-linux-extras install docker
sudo yum install docker

echo "Starting Docker"
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo docker info

echo "Downloading the Attack App Server Demo App"
sudo docker container run -itd --rm --name att-svr -p 8888:8888 -p 1389:1389 us.gcr.io/panw-gcp-team-testing/qwiklab/pcc-log4shell/l4s-demo-svr:1.0