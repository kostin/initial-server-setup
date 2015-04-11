#!/bin/bash

DATFILE="/var/log/hoststat.dat"
LOGFILE="/var/log/hoststat.dat"

TIME=0
TIMES=58
LINE=""

while [ $TIME -lt $TIMES ]; do
  HTTPDUSG=$(ps -C httpd.itk -o "comm %cpu %mem" --no-headers)
  #LINE="#"${HTTPDUSG}
  if [ -z "${HTTPDUSG}" ]; then
    HTTPDUSG="-0.0 -0.0 0"
  else
    HTTPDUSG=$(echo "${HTTPDUSG}" | grep -v defunc | awk '{a[$1] = $1; b[$1] += $2; c[$1] += $3; count ++} END {for (i in a) printf "%0.1f %0.1f %s\n", b[i], c[i], count}')
  fi
  MYSQLDUSG=$(ps -C mysqld -o "comm %cpu %mem" --no-headers)
  #LINE=${LINE}"\n#"${MYSQLDUSG}
  if [ -z "${MYSQLDUSG}" ]; then
    MYSQLDUSG="-0.0 -0.0"
  else
    MYSQLDUSG=$(echo "${MYSQLDUSG}" | grep -v defunc | awk '{a[$1] = $1; b[$1] += $2; c[$1] += $3} END {for (i in a) printf "%0.1f %0.1f\n", b[i], c[i]}')
  fi
  LINE=${LINE}${TIME}" "${HTTPDUSG}" "${MYSQLDUSG}"\n"
  ((TIME++))
  sleep 1
done

DATE=$(date +'%Y-%m-%d_%H:%M:%S')
AVG=$(echo ${LINE} | awk '{a[$1] = $1; b[$1] += $2; c[$1] += $3; d[$1] += $4; e[$1] += $5; f[$1] += $6; count ++} END {for (i in a) printf "%0.1f %0.1f %s %0.1f %0.1f\n", b[i]/count, c[i]/count, d[i]/count, e[i]/count, f[i]/count}')
LINE=${DATE}" "${AVG}

touch ${DATFILE}
touch ${LOGFILE}

echo "$LINE"
echo "$LINE" >> ${DATFILE}
echo "$LINE" >> ${LOGFILE}

if [ $(cat ${DATFILE} | wc -l) -gt 1500 ]; then
  TMPFILE="/tmp/hoststatproc.$$.tmp"
  cat ${DATFILE} | tail -1500 > $TMPFILE
  cat $TMPFILE > ${DATFILE}
  rm -f $TMPFILE
fi
