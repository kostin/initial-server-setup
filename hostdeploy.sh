#!/bin/bash

if [ ! "$1" ] && [ ! "$2" ];
then
  echo "Script have 2 required agruments: valid site name, script working mode (d2p, p2d)";
  echo "/opt/scripts/hostdeploy.sh mysite d2p - deploy site from dev to production (from ./dev to ./public directory)";
  echo "/opt/scripts/hostdeploy.sh mysite p2d - deploy site from production to dev (from ./public to ./dev directory)";
  echo "Backup of overwritten files and database will be created in both cases automatically and stored in ./backups directory.";
  exit 0;
fi

USER=$1
SQLPASS=`cat /root/.mysql-root-password`

PUBDB=$USER"_pub"
DEVDB=$USER"_dev"

if [ ! -d "/var/www/$USER/backups/" ]; then mkdir /var/www/$USER/backups/; fi

DATE=`date +%Y-%m-%d_%H-%M`
tar cfzp /var/www/$USER/backups/$USER-public-files-$DATE.tar.gz /var/www/$USER/public/
tar cfzp /var/www/$USER/backups/$USER-dev-files-$DATE.tar.gz /var/www/$USER/dev/
mysqldump -u root -p$SQLPASS $PUBDB | gzip > /var/www/$USER/backups/$USER-public-db-$DATE.sql.gz
mysqldump -u root -p$SQLPASS $DEVDB | gzip > /var/www/$USER/backups/$USER-dev-db-$DATE.sql.gz

if [ "$2" == "d2p" ];
then
  rsync -azhv -e ssh /var/www/$USER/dev/ /var/www/$USER/public/
  mysqldump -u root -p$SQLPASS $DEVDB > /var/www/$USER/base.sql
  mysql -u root -p$SQLPASS $PUBDB < /var/www/$USER/base.sql
  sed -i "s/^[[:space:]]*'database' => '[^']*',/      'database' => '$PUBDB',/g" /var/www/$USER/public/sites/default/settings.php
  rm -rf /var/www/$USER/base.sql
elif [ "$2" == "p2d" ];
then
  rsync -azhv -e ssh /var/www/$USER/public/ /var/www/$USER/dev/
  mysqldump -u root -p$SQLPASS $PUBDB > /var/www/$USER/base.sql
  mysql -u root -p$SQLPASS $DEVDB < /var/www/$USER/base.sql
  sed -i "s/^[[:space:]]*'database' => '[^']*',/      'database' => '$DEVDB',/g" /var/www/$USER/dev/sites/default/settings.php
  rm -rf /var/www/$USER/base.sql
else
  echo "Incorrect second argument. Must be one of: d2p, p2d";
fi
