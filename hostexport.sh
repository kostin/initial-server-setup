#!/bin/bash

if [ ! "$1" ] && [ ! "$2" ] && [ ! "$3" ];
then
  echo "This script takes 3 agruments: valid local site, remote server, remote site. And 4th optional argument with domain(s) in quotes";
  exit 0;
fi

FROMUSER=$1
TOSERVER=$2
TOUSER=$3
FROMSQLPASS=`cat /root/.mysql-root-password`
TOSQLPASS=`ssh root@$TOSERVER cat /root/.mysql-root-password`

if [ "$4" ];
then
  ssh root@$TOSERVER /opt/scripts/hostadd.sh $TOUSER "$4"
else
  ssh root@$TOSERVER /opt/scripts/hostadd.sh $TOUSER
fi

rsync -azhv -e ssh /var/www/$FROMUSER/public_html/ root@$TOSERVER:/var/www/$TOUSER/public/
ssh root@$TOSERVER chown -R $TOUSER:$TOUSER /var/www/$TOUSER/public/
mysqldump -u root -p$FROMSQLPASS $FROMUSER > /var/www/$FROMUSER/base.sql
rsync -azhv -e ssh /var/www/$FROMUSER/base.sql root@$TOSERVER:/var/www/$TOUSER/
TOBASE=$TOUSER"_pub"
ssh root@$TOSERVER "mysql -u root -p$TOSQLPASS $TOBASE < /var/www/$TOUSER/base.sql"

#PWDLINE=$(ssh root@$TOSERVER "grep 'DBPWD' /var/www/$TOUSER/.passwords | tail -1")

#TOSQLUSERPASS=$(echo $PWDLINE | awk -F "=" '/DBPWD/ {print $2}') 

TOSQLUSERPASS=$(ssh root@$TOSERVER "cat /var/www/$TOUSER/.hostconf/.password-db")

if ssh root@$TOSERVER test -e "/var/www/$TOUSER/public/sites/default/settings.php" ; then
  ssh root@$TOSERVER "sed -i \"s/^[[:space:]]*'database' => '[^']*',/	   'database' => '$TOBASE',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
  ssh root@$TOSERVER "sed -i \"s/^[[:space:]]*'password' => '[^']*',/	   'password' => '$TOSQLUSERPASS',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
  ssh root@$TOSERVER "sed -i \"s/^[[:space:]]*'username' => '[^']*',/	   'username' => '$TOUSER',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
fi

if ssh root@$TOSERVER test -e "/var/www/$TOUSER/public/wp-config.php" ; then
  ssh root@$TOSERVER "sed -i \"s/^define('DB_NAME', '[^']*')/define('DB_NAME', '$TOBASE')/g\" /var/www/$TOUSER/public/wp-config.php"
  ssh root@$TOSERVER "sed -i \"s/^define('DB_PASSWORD', '[^']*')/define('DB_PASSWORD', '$TOSQLUSERPASS')/g\" /var/www/$TOUSER/public/wp-config.php"
  ssh root@$TOSERVER "sed -i \"s/^define('DB_USER', '[^']*')/define('DB_USER', '$TOUSER')/g\" /var/www/$TOUSER/public/wp-config.php"
fi
