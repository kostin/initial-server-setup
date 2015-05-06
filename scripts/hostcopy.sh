#!/bin/bash

RSERV=$1
RSITE=$2
LPATH="$(pwd)/${RSITE}/"
if [ $3 ]; then LPATH=$3; fi

if [ ! $1 ] || [ ! $2 ]; then 
  echo "You have to set 2 parameters: host and remote site user. Also you can set 3rd parametr with local path for remote files"
  echo "By default they stores in your current path in new dir with remote site name"
  exit 0
fi

ssh root@${RSERV} "test -d /var/www/$RSITE"
RTEST=$?

if [ ${RTEST} -ne 0 ]; then
  echo "Problem with remote server or site"
  exit 1
fi

RSQLPASS=$(ssh root@${RSERV} "cat /root/.mysql-root-password")
RBASES=$(ssh root@${RSERV} "mysql -p${RSQLPASS} -B -N -e \"select Db from mysql.db where user = '${RSITE}'\"")

for DB in ${RBASES}; do
  ssh root@${RSERV} "mysqldump --force -p${RSQLPASS} $DB | gzip > /var/www/${RSITE}/$DB-db.sql.gz"
done

rsync -azh --delete -e ssh root@${RSERV}:/var/www/${RSITE}/ ${LPATH}
