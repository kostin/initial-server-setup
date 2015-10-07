#!/bin/bash
PATH=/usr/sbin:/usr/bin:/sbin:/bin

# MySQL
if [[ $(service mysql status | grep ERROR | wc -l) > 0 ]]
then
  MSG=$(service mysql restart)
  echo "${MSG}" | mail -s "MySQL restarted on $(hostname) at $(date +%H:%M:%S)" smartdesigner@gmail.com
fi
