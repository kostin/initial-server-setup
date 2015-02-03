#!/bin/bash

PASS=`cat /root/mysql-root-password.txt`
DATE=`date +%Y-%m-%d_%H-%M`

cd /var/www
for i in `/bin/ls /var/www/ | grep -v 'html\|cgi-bin\|error\|icons'`
do
	tar cfzp /backups/$i-files-$DATE.tar.gz $i
	for k in `mysql -p$PASS -B -N -e "show databases" | grep $i`
	do
		mysqldump -p$PASS $k | gzip > /backups/$k-db-$DATE.sql.gz
	done
done

cd /backups
for i in `find . -mtime +60 -print | grep -v 'deleted'`
do
	rm -f $i
done
