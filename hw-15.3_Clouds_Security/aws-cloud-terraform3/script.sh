#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo service apache2 start

cd /var/www/html
echo "<html><body><h1>SSL site version.</h1></body></html>" > index.html
