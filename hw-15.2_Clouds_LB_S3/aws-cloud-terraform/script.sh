#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo service apache2 start
# chkconfig httpd on
cd /var/www/html
echo "<html><a href="https://s3.eu-central-1.amazonaws.com/biryukov-tv-12.2021/harmony.jpg" allign=center>https://s3.eu-central-1.amazonaws.com/biryukov-tv-12.2021/harmony.jpg</a><p allign=center><img src="https://s3.eu-central-1.amazonaws.com/biryukov-tv-12.2021/harmony.jpg"> </html>" > index.html