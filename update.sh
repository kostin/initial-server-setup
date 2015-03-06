cd /etc \
&& wget -N https://raw.githubusercontent.com/kostin/initial-server-setup/master/my.cnf \
&& touch /var/log/mysql-slow.log \
&& chmod 666 /var/log/mysql-slow.log \
&& service mysqld stop \
&& rm -f /var/lib/mysql/ib_logfile* \
&& service mysqld start
