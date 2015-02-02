#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

wget -N -O /etc/httpd/conf.d/php.conf $DLPATH/php.conf
wget -N -O /etc/httpd/conf.d/phpMyAdmin.conf $DLPATH/phpMyAdmin.conf
wget -N -O /etc/httpd/conf/httpd.conf $DLPATH/httpd.conf
wget -N -O /etc/php.ini $DLPATH/php.ini
wget -N -O /etc/my.cnf $DLPATH/my.cnf
wget -N -O /etc/proftpd.conf $DLPATH/proftpd.conf
wget -N -O /etc/nginx/nginx.conf $DLPATH/nginx.conf
wget -N -O /etc/logrotate.d/httpd $DLPATH/httpd

wget -N -O /etc/php-cli.ini $DLPATH/php-cli.ini
echo "#!/bin/bash" > /etc/profile.d/php-cli.sh
echo "alias php=\"php -c /etc/php-cli.ini\"" >> /etc/profile.d/php-cli.sh

wget -N -O /etc/httpd/conf.d/rpaf.conf $DLPATH/rpaf.conf
RPAF_IPS=`ip a | grep inet | awk '{print $2}' | awk -F/ '{print $1}' | sort -u | tr '\n' ' '`
sed -i "s/IPS/$RPAF_IPS/" /etc/httpd/conf.d/rpaf.conf

echo "<?php print rand(); ?>" > /var/www/000default/public/index.php

service httpd restart
service mysqld restart
service nginx restart
service proftpd restart
