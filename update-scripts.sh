#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

rm -rf /opt/scripts/backup.sh
wget -O /opt/scripts/backup.sh $DLPATH/backup.sh

rm -rf /opt/scripts/hostadd.sh
wget -O /opt/scripts/hostadd.sh $DLPATH/hostadd.sh 

rm -rf /opt/scripts/hostdel.sh
wget -O /opt/scripts/hostdel.sh $DLPATH/hostdel.sh

rm -rf /opt/scripts/hostexport.sh
wget -O /opt/scripts/hostexport.sh $DLPATH/hostexport.sh

rm -rf /opt/scripts/hostexport.sh
wget -O /opt/scripts/hostexport.sh $DLPATH/hostshow.sh

rm -rf /opt/scripts/vhost_template
wget -O /opt/scripts/vhost_template $DLPATH/vhost_template

chmod +x /opt/scripts/*.sh

cd /usr/local/share/ && \
wget -N http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz && \
tar zxvf drush-7.x-5.9.tar.gz && \
ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \
rm -f drush-7.x-5.9.tar.gz
