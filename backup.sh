#!/bin/bash

PASS=`cat /root/.mysql-root-password`
DATE=`date +%Y-%m-%d_%H-%M`

cd /var/www
for i in `/bin/ls /var/www/ | grep -v 'html\|cgi-bin\|error\|icons'`
do
	if [ ! -d /var/www/$i/.backups ]; then
		mkdir -p /var/www/$i/.backups
	fi
	#tar cfzp /var/www/$i/.backups/$i-files-$DATE.tar.gz /var/www/$i --exclude=/var/www/$i/tmp
	for k in `mysql -p$PASS -B -N -e "show databases" | grep $i`
	do
		mysqldump -p$PASS $k | gzip -9 > /var/www/$i/.backups/$k-db-$DATE.sql.gz
	done
	cd /var/www/$i/.backups
	for j in `find . -mtime +60 -print`
	do
		rm -f $j
	done	
done
