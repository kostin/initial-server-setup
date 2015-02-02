#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

wget -O /etc/httpd/conf.d/php.conf $DLPATH/php.conf
wget -O /etc/httpd/conf.d/phpMyAdmin.conf $DLPATH/phpMyAdmin.conf
wget -O /etc/httpd/conf/httpd.conf $DLPATH/httpd.conf
wget -O /etc/php.ini $DLPATH/php.ini
wget -O /etc/my.cnf $DLPATH/my.cnf
wget -O /etc/proftpd.conf $DLPATH/proftpd.conf
wget -O /etc/nginx/nginx.conf $DLPATH/nginx.conf
wget -O /etc/logrotate.d/httpd $DLPATH/httpd

wget -O /etc/php-cli.ini $DLPATH/php-cli.ini
echo "#!/bin/bash" > /etc/profile.d/php-cli.sh
echo "alias php=\"php -c /etc/php-cli.ini\"" >> /etc/profile.d/php-cli.sh

wget -O /etc/httpd/conf.d/rpaf.conf $DLPATH/rpaf.conf
RPAF_IPS=`ip a | grep inet | awk '{print $2}' | awk -F/ '{print $1}' | sort -u | tr '\n' ' '`
sed -i "s/IPS/$RPAF_IPS/" /etc/httpd/conf.d/rpaf.conf

echo "<?php print rand(); ?>" > /var/www/000default/public/index.php

service httpd restart
service mysqld restart
service nginx restart
service proftpd restart

wget -O /opt/scripts/backup.sh $DLPATH/backup.sh
wget -O /opt/scripts/hostadd.sh $DLPATH/hostadd.sh
wget -O /opt/scripts/hostdel.sh $DLPATH/hostdel.sh
wget -O /opt/scripts/hostexport.sh $DLPATH/hostexport.sh
wget -O /opt/scripts/vhost_template $DLPATH/vhost_template
chmod +x /opt/scripts/*.sh

cd /usr/local/share/ && \
wget http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz && \
tar zxvf drush-7.x-5.9.tar.gz && \
ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \
rm -f drush-7.x-5.9.tar.gz
