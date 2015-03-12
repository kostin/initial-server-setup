#!/bin/bash
DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

if [ "$1" = "mycnf" ]; then
  cd /etc \
  && wget --quiet -N $DLPATH/my.cnf \
  && touch /var/log/mysql-slow.log \
  && chmod 666 /var/log/mysql-slow.log \
  && service mysqld stop \
  && rm -f /var/lib/mysql/ib_logfile* \
  && service mysqld start
fi

if [ "$1" = "scripts" ]; then
  cd /opt/scripts \
  && wget --quiet -N $DLPATH/backup.sh \
  && wget --quiet -N $DLPATH/hostadd.sh \
  && wget --quiet -N $DLPATH/hostdel.sh \
  && wget --quiet -N $DLPATH/hostexport.sh \
  && wget --quiet -N $DLPATH/hostshow.sh \
  && wget --quiet -N $DLPATH/hostdeploy.sh
fi
