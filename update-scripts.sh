#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

cd /opt/scripts/
wget -N $DLPATH/backup.sh
wget -N $DLPATH/hostadd.sh 
wget -N $DLPATH/hostdel.sh
wget -N $DLPATH/hostexport.sh
wget -N $DLPATH/hostshow.sh
wget -N $DLPATH/hostdeploy.sh
wget -N $DLPATH/vhost_template

chmod +x /opt/scripts/*.sh

cd /usr/local/share/ && \
wget -N http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz && \
tar zxvf drush-7.x-5.9.tar.gz && \
ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \
rm -f drush-7.x-5.9.tar.gz
