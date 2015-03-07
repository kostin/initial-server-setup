#!/bin/bash
DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

#cd /etc \
#&& wget -N $DLPATH/my.cnf \
#&& touch /var/log/mysql-slow.log \
#&& chmod 666 /var/log/mysql-slow.log \
#&& service mysqld stop \
#&& rm -f /var/lib/mysql/ib_logfile* \
#&& service mysqld start

cd /opt/scripts \
&& wget -N $DLPATH/backup.sh \
&& wget -N $DLPATH/hostadd.sh \
&& wget -N $DLPATH/hostdel.sh \
&& wget -N $DLPATH/hostexport.sh \
&& wget -N $DLPATH/hostshow.sh \
&& wget -N $DLPATH/hostdeploy.sh
