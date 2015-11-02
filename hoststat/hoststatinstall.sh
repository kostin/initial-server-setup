#!/bin/bash

yum -y install sysstat gnuplot
cd /opt/scripts/hoststat
chmod +x /opt/scripts/*.sh
touch /var/log/hoststat.dat
touch /var/log/hoststatproc.dat

echo "*/3 * * * * root /opt/scripts/hoststat/hoststat.sh > /dev/null" > /etc/cron.d/hoststat
echo "*/10 * * * * root /opt/scripts/hoststat/hostplot.sh > /var/www/000default/public/graph.svg" >> /etc/cron.d/hoststat
echo "* * * * * root /opt/scripts/hoststat/hoststatproc.sh > /dev/null" > /etc/cron.d/hoststatproc
echo "*/10 * * * * root /opt/scripts/hoststat/hostplotproc.sh > /var/www/000default/public/graph-proc.svg" >> /etc/cron.d/hoststatproc
sed -i 's|*/10|*/3|g' /etc/cron.d/sysstat
service crond restart

cd /etc/logrotate.d/
cp /opt/scripts/hoststat/hoststat.logrotate /etc/logrotate.d/hoststat.logrotate
logrotate --force /etc/logrotate.d/hoststat.logrotate
cp /opt/scripts/hoststat/hoststatproc.logrotate /etc/logrotate.d/hoststatproc.logrotate
logrotate --force /etc/logrotate.d/hoststatproc.logrotate  

/opt/scripts/hoststat/hostplot.sh > /var/www/000default/public/graph.svg
/opt/scripts/hoststat/hostplotproc.sh > /var/www/000default/public/graph-proc.svg  
