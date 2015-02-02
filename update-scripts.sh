#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

wget -q $DLPATH/backup.sh -O /opt/scripts/backup.sh 
wget -q $DLPATH/hostadd.sh -O /opt/scripts/hostadd.sh 
wget -q $DLPATH/hostdel.sh -O /opt/scripts/hostdel.sh 
wget -q $DLPATH/hostexport.sh -O /opt/scripts/hostexport.sh 
wget -q $DLPATH/hostshow.sh -O /opt/scripts/hostexport.sh 
wget -q $DLPATH/vhost_template -O /opt/scripts/vhost_template 
chmod +x /opt/scripts/*.sh

cd /usr/local/share/ && \
wget -N http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz && \
tar zxvf drush-7.x-5.9.tar.gz && \
ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \
rm -f drush-7.x-5.9.tar.gz
