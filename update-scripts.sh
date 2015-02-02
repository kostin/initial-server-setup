#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

wget -N -O /opt/scripts/backup.sh $DLPATH/backup.sh
wget -N -O /opt/scripts/hostadd.sh $DLPATH/hostadd.sh
wget -N -O /opt/scripts/hostdel.sh $DLPATH/hostdel.sh
wget -N -O /opt/scripts/hostexport.sh $DLPATH/hostexport.sh
wget -N -O /opt/scripts/hostexport.sh $DLPATH/hostshow.sh
wget -N -O /opt/scripts/vhost_template $DLPATH/vhost_template
chmod +x /opt/scripts/*.sh

cd /usr/local/share/ && \
wget -N http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz && \
tar zxvf drush-7.x-5.9.tar.gz && \
ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \
rm -f drush-7.x-5.9.tar.gz
