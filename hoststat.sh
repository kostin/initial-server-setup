#!/bin/bash

DATE=$(date +'%Y-%m-%d_%H:%M:%S')
MAILQ=$(cat /var/log/phpmail.log | wc -l | awk '{print $1 * 10.0}')
LA1=$(cat /proc/loadavg | cut -d ' ' -f 1 | awk '{print $1 * 100.0}')
LA5=$(cat /proc/loadavg | cut -d ' ' -f 2 | awk '{print $1 * 100.0}')
LA15=$(cat /proc/loadavg | cut -d ' ' -f 3 | awk '{print $1 * 100.0}')
DISKFREEM=$(df -m / | tail -1 | awk '{print $4}')
DISKUSEDP=$(df -m / | tail -1 | awk '{print $(NF - 1)}' | cut -d '%' -f1)
MEMTOTALM=$(free -m | grep 'Mem:' | awk '{print $2}')
MEMUSEDP=$(free -m | grep 'Mem:' | awk '{print $3/$2 * 100.0}')
SWAPUSEDP=$(free -m | grep 'Swap:' | awk '{print $3/$2 * 100.0}')
SWAPUSEDM=$(free -m | grep 'Swap:' | awk '{print $3}')
UPTIMEH=$(cat /proc/uptime | awk '{print $2 / 3600.0}')
IOWAITP=$(sar -u | tail -2 | head -1 | awk '{print $7}')
SWAPAVG=$(sar -S | tail -2 | head -1 | awk '{print $5}')
ROOTDEV=$(mount | grep 'on / type' | awk '{print $1}' | awk -F "/" '{print $NF}')
DISKUTILP=$(sar -p -d | grep "$ROOTDEV" | tail -2 | head -1 | awk '{print $NF}')
CPUUSAGEP=$(sar -u | tail -2 | head -1 | awk '{print 100.0 - $NF}')
# httpd per process memory usage
HTTPDPP=$(ps u -C httpd.itk | awk '{sum += $6; count++} END {count--; print sum/count/1024}')

HTTPDCNT=$(ps u -C httpd.itk | wc -l | awk '{print $1 - 1}')
HTTPDMEMM=$(ps u -C httpd.itk | awk '{sum += $6} END {print sum/1024}')
HTTPDMEMM=$(ps u -C mysqld | awk '{sum += $6} END {print sum/1024}')

RXM=$(sar -n DEV | grep 'eth0' | tail -2 | head -1 | awk '{print $6/1024}')
TXM=$(sar -n DEV | grep 'eth0' | tail -2 | head -1 | awk '{print $7/1024}')

echo "$DATE $CPUUSAGEP $LA5 $MEMUSEDP $SWAPUSEDP $DISKUSEDP $IOWAITP $RXM $TXM $MAILQ"
