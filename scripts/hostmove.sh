#!/bin/bash

if [ ! "$1" ] && [ ! "$2" ] && [ ! "$3" ] && [ ! "$4" ];
then
  echo "This script takes 4 agruments: remote source server, remote source site, remote destination server, remote destination site. And 5th optional argument with domain(s) in quotes";
  exit 0;
fi

FROMSERVER=$1
FROMUSER=$2
TOSERVER=$3
TOUSER=$4
FROMSQLPASS=$(ssh root@${FROMSERVER} cat /root/.mysql-root-password)
TOSQLPASS=$(ssh root@${TOSERVER} cat /root/.mysql-root-password)

if [ "$5" ];
then
  ssh root@$TOSERVER "/opt/scripts/hostadd.sh $TOUSER \"${5}\""
else
  ssh root@$TOSERVER "/opt/scripts/hostadd.sh $TOUSER"
fi

rm -rf /tmp/${FROMSERVER}
mkdir -p /tmp/${FROMSERVER}/${FROMUSER}

ssh root@${FROMSERVER} "mysqldump -u root -p${FROMSQLPASS} ${FROMUSER}_pub > /var/www/$FROMUSER/public/base_pub.sql"
rsync -azh -e ssh root@${FROMSERVER}:/var/www/$FROMUSER/public/ /tmp/${FROMSERVER}/${FROMUSER}/public/
ssh root@${FROMSERVER} "rm -rf /var/www/$FROMUSER/public/base_pub.sql"
rsync -azh -e ssh /tmp/${FROMSERVER}/${FROMUSER}/public/ root@${TOSERVER}:/var/www/${TOUSER}/public/
#rm -rf /tmp/${FROMSERVER}
ssh root@${TOSERVER} "chown -R ${TOUSER}:${TOUSER} /var/www/${TOUSER}/public/"
ssh root@${TOSERVER} "mysql -u root -p${TOSQLPASS} ${TOUSER}_pub < /var/www/$TOUSER/public/base_pub.sql && rm -rf /var/www/$TOUSER/public/base_bub.sql"

#PWDLINE=$(ssh root@$TOSERVER "grep 'DBPWD' /var/www/$TOUSER/.passwords | tail -1")
#TOSQLUSERPASS=$(echo $PWDLINE | awk -F "=" '/DBPWD/ {print $2}')

TOSQLUSERPASS=$(ssh root@$TOSERVER "cat /var/www/$TOUSER/.hostconf/.password-db")

if ssh root@$TOSERVER test -e "/var/www/$TOUSER/public/sites/default/settings.php" ; then
  ssh root@$TOSERVER "sed -i \"s/^[[:space:]]*'database' => '[^']*',/      'database' => '${TOUSER}_pub',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
  ssh root@$TOSERVER "sed -i \"s/^[[:space:]]*'password' => '[^']*',/      'password' => '$TOSQLUSERPASS',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
  ssh root@$TOSERVER "sed -i \"s/^[[:space:]]*'username' => '[^']*',/      'username' => '$TOUSER',/g\" /var/www/$TOUSER/public/sites/default/settings.php"
fi

if ssh root@$TOSERVER test -e "/var/www/$TOUSER/public/wp-config.php" ; then
  ssh root@$TOSERVER "sed -i \"s/^define('DB_NAME', '[^']*')/define('DB_NAME', '${TOUSER}_pub')/g\" /var/www/$TOUSER/public/wp-config.php"
  ssh root@$TOSERVER "sed -i \"s/^define('DB_PASSWORD', '[^']*')/define('DB_PASSWORD', '$TOSQLUSERPASS')/g\" /var/www/$TOUSER/public/wp-config.php"
  ssh root@$TOSERVER "sed -i \"s/^define('DB_USER', '[^']*')/define('DB_USER', '$TOUSER')/g\" /var/www/$TOUSER/public/wp-config.php"
fi
