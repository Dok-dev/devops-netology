#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo service apache2 start

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install

cd /var/www/html
echo "<html><a href="https://s3.eu-central-1.amazonaws.com/biryukov-tv-12.2021/harmony.jpg" allign=center>https://s3.eu-central-1.amazonaws.com/biryukov-tv-12.2021/harmony.jpg</a><p allign=center><img src="https://s3.eu-central-1.amazonaws.com/biryukov-tv-12.2021/harmony.jpg"> </html>" > index.html

sleep 5m
# aws s3 mb s3://biryukov-tv-12.2021
aws s3 cp index.html s3://biryukov-tv-12.2021