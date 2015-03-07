#!/bin/bash

usage="To remove user you need to use next parameters:\n\t1). Username. \nFor example:\n\t$0 testuser"

if [ ! $1 ]; then echo -e $usage; exit 0; fi

STORE_DIR='/backups/.deleted'
MYSQLPWD=`cat /root/.mysql-root-password`
DATE=`date +%Y-%m-%d_%H-%M`
USER=$1

echo 'Press Enter to continue (Ctrl+C to exit)!'
read

if [ -f /etc/httpd/conf/vhosts/$USER.conf ]; then
  rm -f /etc/httpd/conf/vhosts/$USER.conf
  /etc/init.d/httpd restart
fi

for DB in `mysql -u root -p$MYSQLPWD -B -N -e "select Db from mysql.db where user = '$USER'"`
do
  mysqldump -u root -p$MYSQLPWD $DB | gzip > $STORE_DIR/$DB-db-$DATE.sql.gz
  mysql -u root -p$MYSQLPWD -e "drop database $DB;"
done

if test -n "$( mysql -u root -p$MYSQLPWD -B -N -e "select * from mysql.user where User = '$USER'" )" ; then
  mysql -u root -p$MYSQLPWD -e "drop user '$USER'@'localhost'"
fi

DBPUB=$USER"_pub"
DBDEV=$USER"_dev"
if [ -n "$( mysql -u root -p$MYSQLPWD -B -N -e "show databases like '$DBPUB'" )" ]; then
  mysql -u root -p$MYSQLPWD -e "drop database $DBPUB;"
fi
if [ -n "$( mysql -u root -p$MYSQLPWD -B -N -e "show databases like '$DBDEV'" )" ]; then
  mysql -u root -p$MYSQLPWD -e "drop database $DBDEV;"
fi

if [ ! -d /var/www/$USER ]
then
  echo "Directory /var/www/$USER not exist!"
  exit 0
else 
  tar cfzp $STORE_DIR/$USER-$DATE-files.tar.gz /var/www/$USER
  killall -9 -u $USER
  userdel -r $USER
  rm -rf /var/www/$USER
fi
