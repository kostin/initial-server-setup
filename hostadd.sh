#!/bin/bash

usage="To create domains structure and configs you need to use next parameters:\n\t1). Username. \n\t2). Domain or domain names (Ex.: \"test.com test2.com\")."

if [ ! $1 ]; then echo -e $usage; exit 0; fi

MYSQLPWD=`cat /root/.mysql-root-password`
USER=$1
HOST=`hostname`

USER_TEST=`echo ${USER} | sed s/[[:punct:]]/x/g`
if [ ! $USER_TEST == $USER ]
then
	echo 'Bad chars in username!'
	exit 0
fi

#Check Virtual Host
if [ -a /etc/httpd/conf/vhosts/$USER.conf ]
then
        echo "Virtual Host already exist!"
        exit 0
fi

#Check User Homedir
if [ -d /var/www/$USER ]
then
        echo "Directory /var/www/$USER already exist!"
        exit 0
fi

#Check system user
if [ "`grep '$USER:x' /etc/passwd`" ]
then
        echo "User $USER already exist in system!"
        exit 0
fi

#Check mysql user
if [ "`mysql -p$MYSQLPWD -B -N -e "select * from mysql.user where user = '$USER'"`" ]
then
        echo "MySQL user $USER already exist!"
        exit 0
fi

#Create user
PWD=`tr -dc a-zA-Z0-9 < /dev/urandom | head -c16 | xargs`
useradd -b /var/www --shell /sbin/nologin --create-home --skel /etc/www.skel $USER
echo $PWD | passwd --stdin $USER

#Create database
MAINDB=$USER"_pub"
DEVDB=$USER"_dev"
DBPWD=`tr -dc a-zA-Z0-9 < /dev/urandom | head -c16 | xargs`
mysql -p$MYSQLPWD -B -N -e "create database $MAINDB; grant all on $MAINDB.* to $USER@localhost identified by '$DBPWD'; create database $DEVDB; grant all on $DEVDB.* to $USER@localhost;"

#Create HTTPD vhost
if [ "$2" ]
then
	touch /var/www/$USER/.domains
	for i in $2
	do
		ALIASES="$ALIASES $i www.$i"
		echo $i >> /var/www/$USER/.domains
	done
else
	ALIASES="www.$USER.$HOST"
fi
cp /opt/scripts/vhost_template /etc/httpd/conf/vhosts/$USER.conf
sed -i "s/USER/$USER/g" /etc/httpd/conf/vhosts/$USER.conf
sed -i "s/ALIASES/$ALIASES/g" /etc/httpd/conf/vhosts/$USER.conf
sed -i "s/HOSTNAME/$HOST/g" /etc/httpd/conf/vhosts/$USER.conf

/etc/init.d/httpd restart

echo "User password: $PWD" 
echo "MySQL password for user $USER: $DBPWD"

echo "PWD=$PWD" > /var/www/$USER/.passwords
echo "DBPWD=$DBPWD" >> /var/www/$USER/.passwords

chmod 600 /var/www/$USER/.passwords

ln -s /opt/scripts/.htpasswd /var/www/$USER/.htpasswd
