#!/bin/bash

if [ ! "$1" ] && [ ! "$2" ] && [ ! "$3" ];
then
echo "There are 3 agrs local user, remote server, remote user. And 4th optional parameter with domain(s) in quotes";
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
POSTFIX="_pub"
TOBASE=$TOUSER$POSTFIX
echo $TOBASE
ssh root@$TOSERVER "mysql -u root -p$TOSQLPASS $TOBASE < /var/www/$TOUSER/base.sql"

#PWDLINE=$(ssh root@$TOSERVER "grep 'DBPWD' /var/www/$TOUSER/.passwords | tail -1")
#TOSQLUSERPASS=$(echo $PWDLINE | awk -F "=" '/DBPWD/ {print $2}') 

TOSQLUSERPASS=$(ssh root@$TOSERVER "cat /var/www/$TOUSER/.hostconf/.password-db")
ssh root@$TOSERVER "sed -i \"s/^      'database' => '[^']*',/	   'database' => '$TOBASE',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
ssh root@$TOSERVER "sed -i \"s/^      'password' => '[^']*',/	   'password' => '$TOSQLUSERPASS',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
ssh root@$TOSERVER "sed -i \"s/^      'username' => '[^']*',/	   'username' => '$TOUSER',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
