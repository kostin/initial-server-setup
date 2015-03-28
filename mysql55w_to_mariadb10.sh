#!/bin/bash

MYSQLPASS=`cat /root/.mysql-root-password`

if [ ! -z $MYSQLPASS ]; then
  echo "Wrong password file";
  exit 0;
fi

mysqldump -p${MYSQLPASS} --force --all-databases > /root/mysql-all-db-dump.sql

if [ `uname -m` == 'x86_64' ]; then
cat > /etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
else
  echo "Wrong Arc";
  exit 0;
fi

yum -y update
yum -y clean all

service mysqld stop
cp -ar /var/lib/mysql/* /root/mysql-files-copy

yum -y yum-plugin-replace
yum -y replace mysql55w-server --replace-with MariaDB-server

yum -y install MariaDB-server \
&& service mysql start \
&& mysql_upgrade -p${MYSQLPASS} \
&& chkconfig mysql on
