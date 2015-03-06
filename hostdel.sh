#!/bin/bash

usage="To remove user you need to use next parameters:\n\t1). Username. \nFor example:\n\t$0 testuser"

if [ ! $1 ]; then echo -e $usage; exit 0; fi

STORE_DIR='/backups/.deleted/'
MYSQLPWD=`cat /root/.mysql-root-password`
DATE=`date +%Y-%m-%d_%H-%M`
USER=$1

if [ ! -d STORE_DIR ]
then
        mkdir -p $STORE_DIR
fi

if [ ! -d /var/www/$USER ]
then
        echo "Directory /var/www/$USER not exist!"
        exit 0
fi

echo 'Press Enter to continue (Ctrl+C to exit)!'
read

rm -f /etc/httpd/conf/vhosts/$USER.conf
/etc/init.d/httpd restart
tar cfzp $STORE_DIR$USER-$DATE-files.tar.gz /var/www/$USER
for DB in `mysql -u root -p$MYSQLPWD -B -N -e "select Db from mysql.db where user = $USER"`
do
        mysqldump -u root -p$MYSQLPWD $DB | gzip -9 > $STORE_DIR$DB-db-$DATE.sql.gz
        mysql -u root -p$MYSQLPWD -B -N -e "drop database $DB;"
done

killall -9 -u $USER
userdel -r $USER
mysql -u root -p$MYSQLPWD -B -N -e "DROP USER '$USER'@'localhost';"
