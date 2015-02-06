#!/bin/bash

cat /etc/sphinx/sphinx-main.conf > /etc/sphinx/sphinx.conf

cd /var/www
for DIR in * ; do 
	if [[ -d "/var/www/$DIR" ]] && [[ -f "/var/www/$DIR/.hostconf/.sphinx" ]]; then
		if [[ ! -d "/var/lib/sphinx/$DIR" ]]; then
			mkdir -p "/var/lib/sphinx/$DIR"
			chown sphinx -R "/var/lib/sphinx/$DIR"
		fi;
		rm -rf "/var/www/$DIR/tmp/.sphinx"
		cp "/var/www/$DIR/.hostconf/.sphinx" "/var/www/$DIR/tmp/.sphinx"
		sed -i "s/HOSTUSER/$DIR/g" "/var/www/$DIR/tmp/.sphinx"
		DBNAME=$DIR"_pub"
		sed -i "s/HOSTDBNAME/$DBNAME/g" "/var/www/$DIR/tmp/.sphinx"
		DBPASS=`cat /var/www/$DIR/.hostconf/.password-db`
		sed -i "s/HOSTDBPASS/$DBPASS/g" "/var/www/$DIR/tmp/.sphinx"
		cat "/var/www/$DIR/tmp/.sphinx" >> /etc/sphinx/sphinx.conf
		rm -rf "/var/www/$DIR/tmp/.sphinx"
	fi
done

service searchd restart
