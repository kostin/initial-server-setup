#!/bin/bash

DATE=$(date +'%Y-%m-%d_%H:%M:%S')

HTTPDUSG=$(ps -C httpd.itk -o "comm %cpu %mem" --no-headers \
| awk '{a[$1] = $1; b[$1] += $2; c[$1] += $3; count ++} END {for (i in a) printf "%0.1f %0.1f %s\n", b[i], c[i], count}')

if [ -z "${HTTPDUSG}" ]; then
  HTTPDUSG="-0.0 -0.0 0"
fi

MYSQLDUSG=$(ps -C mysqld -o "comm %cpu %mem" --no-headers \
| awk '{a[$1] = $1; b[$1] += $2; c[$1] += $3} END {for (i in a) printf "%0.1f %0.1f\n", b[i], c[i]}')

if [ -z "${MYSQLDUSG}" ]; then
  MYSQLDUSG="-0.0 -0.0"
fi

LINE=${DATE}" "${HTTPDUSG}" "${MYSQLDUSG}

touch /var/log/hoststat.dat
touch /var/log/hoststat.log

echo "$LINE"
echo "$LINE" >> /var/log/hoststatproc.log
echo "$LINE" >> /var/log/hoststatproc.dat

TMPFILE="/tmp/hoststatproc.$$.tmp"
cat /var/log/hoststatproc.dat | tail -1500 > $TMPFILE
cat $TMPFILE > /var/log/hoststatproc.dat
rm -f $TMPFILE
