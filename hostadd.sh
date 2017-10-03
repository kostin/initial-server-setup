#!/bin/bash
usage="To create domains structure and configs you have to use next parameters:\n\t1). Username (lowercase alphabets and digits only, 14 symbols or less). \n\t2). Domain or domains (Ex.: \"test.com test2.com\")."

if [ ! $1 ]; then echo -e $usage; exit 0; fi

MYSQLPWD=`cat /root/.mysql-root-password`
USER=$1
HOST=`hostname`

#Check username
USER_LEN=${#USER}
if [ $USER_LEN -lt 15 ] && ! [[ "$USER" =~ [^a-z0-9\ ] ]];
then
    	echo "Username set to $USER. It's OK"
else
    	echo "Bad chars in username $USER (must be lowercase alphabets and digits only) or too long username (must be 14 symbols or less)!"
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
        echo "User $USER already exists in system!"
        exit 0
fi

#Check mysql user
if [ -n "$( mysql -u root -p$MYSQLPWD -B -N -e "select * from mysql.user where user = '$USER'" )" ]
then
        echo "MySQL user $USER already exist!"
        exit 0
fi

#Create user
USRPWD=`tr -dc a-zA-Z0-9 < /dev/urandom | head -c16 | xargs`
useradd -b /var/www --shell /sbin/nologin --create-home --skel /etc/www.skel $USER
echo $USRPWD | passwd --stdin $USER
mkdir /var/www/$USER/.hostconf

#Create database
MAINDB=$USER"_pub"
DEVDB=$USER"_dev"
DBPWD=`tr -dc a-zA-Z0-9 < /dev/urandom | head -c16 | xargs`
mysql -u root -p$MYSQLPWD -B -N -e "create user '$USER'@'localhost' identified by '$DBPWD'; create database $MAINDB; grant all on $MAINDB.* to '$USER'@'localhost'; create database $DEVDB; grant all on $DEVDB.* to '$USER'@'localhost';"

#Create HTTPD vhost
ALIASES="www.$USER.$HOST"
if [ "$2" ]; then
	touch /var/www/$USER/.hostconf/.domains
	for i in $2
	do
		ALIASES="$ALIASES $i www.$i"
		echo $i >> /var/www/$USER/.hostconf/.domains
	done
fi
cp /opt/scripts/vhost_template /etc/httpd/conf/vhosts/$USER.conf
sed -i "s/USER/$USER/g" /etc/httpd/conf/vhosts/$USER.conf
sed -i "s/ALIASES/$ALIASES/g" /etc/httpd/conf/vhosts/$USER.conf
sed -i "s/HOSTNAME/$HOST/g" /etc/httpd/conf/vhosts/$USER.conf

/etc/init.d/httpd restart

echo "User password: $USRPWD" 
echo "MySQL password for user $USER: $DBPWD"

echo "$USRPWD" > /var/www/$USER/.hostconf/.password-user
echo "$DBPWD" > /var/www/$USER/.hostconf/.password-db

mkdir -p /var/www/$USER/.hostconf/.ssl

chown -R root:root /var/www/$USER/.hostconf
chmod -R 400 /var/www/$USER/.hostconf
chmod 500 /var/www/$USER/.hostconf

ln -s /opt/scripts/.htpasswd /var/www/$USER/.htpasswd

/root/.acme.sh/acme.sh --issue $SSLDOMAINS -w /var/www/certs

/root/.acme.sh/acme.sh --install-cert -d $SSLDOMAINS \
--key-file /var/www/$USER/.hostconf/.ssl/$USER.key
--fullchain-file /var/www/$USER/.hostconf/.ssl/$USER.fullchain.cer \
--reloadcmd "service nginx force-reload"
