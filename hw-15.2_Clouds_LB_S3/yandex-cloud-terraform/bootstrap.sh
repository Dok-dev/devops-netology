#!/bin/bash
yum install httpd -y
service httpd start
chkconfig httpd on
cd /var/www/html
echo "<html><a href="https://storage.yandexcloud.net/android-jones-paintings/harmony.jpg" allign=center>https://storage.yandexcloud.net/android-jones-paintings/harmony.jpg</a><p allign=center><img src="https://storage.yandexcloud.net/android-jones-paintings/harmony.jpg"> </html>" > index.html