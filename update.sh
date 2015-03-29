#!/bin/bash
DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

uptime
free -m

if [ "$1" = "update" ]; then
  yum -y update
  yum -y clean all
fi

if [ "$1" = "mycnf" ]; then
  cd /etc \
  && wget --quiet -N $DLPATH/my.cnf \
  && touch /var/log/mysql-slow.log \
  && chmod 666 /var/log/mysql-slow.log \
  && service mysqld stop \
  && rm -f /var/lib/mysql/ib_logfile* \
  && service mysqld start
fi

if [ "$1" = "scripts" ]; then
  cd /opt/scripts \
  && wget --quiet -N $DLPATH/backup.sh \
  && wget --quiet -N $DLPATH/hostadd.sh \
  && wget --quiet -N $DLPATH/hostdel.sh \
  && wget --quiet -N $DLPATH/hostexport.sh \
  && wget --quiet -N $DLPATH/hostshow.sh \
  && wget --quiet -N $DLPATH/hostdeploy.sh
  wget --quiet -N $DLPATH/mysql55w_to_mariadb10.sh
  chmod +x *.sh
fi

if [ "$1" = "key" ] && [ -f /root/.ssh/authorized_keys ]; then
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvK2bwzvPOHAXnw8F7BYk7nC+f+pdyEys8LybGatrTfoBZUVLmV4qX3kEG9O9jC/pYiZyHqquGpcnr7L9dXmK7OGvE3GU4xMKWR6FJGbgjtg589vMA/w2q2c4OQ8Mfz4ryoLIuo8JEoS/lJJTjbzmfLc4aSwKvsz8nh/rJKmiNSYaCz20hsZ41YSsewFjOa7hdv5xX3u6hq8Bnd4m2Sm88BKT5E9oLg+lMIiYph5dW/GADZKdVppt/+B62iKAFyWZxK0BpefSJdXkrrwoXEJKCoN/+UVxsB0dWnVuhzsYt1yLk3AJgcLF/UP7J4aF+PzHv84vGO3Z/N2El4piB/W16w== root@renter" >> /root/.ssh/authorized_keys
fi

if [ "$1" = "mysql55" ]; then
  service mysqld stop
  rm -rf /etc/my.cnf 
  cd /etc 
  wget --quiet -N $DLPATH/my.cnf 
  rm -f /var/lib/mysql/ib_logfile* 
  service mysqld start 
  rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm 
  yum -y install mysql.`uname -i` yum-plugin-replace 
  yum -y replace mysql --replace-with mysql55w 
  service mysqld restart 
  mysql_upgrade -u root -p`cat /root/.mysql-root-password`   
fi

if [ "$1" = "mysqltuner" ]; then
  rm -rf /root/mysqltuner.pl
  cd /root \
  && wget -N https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl \
  && chmod +x mysqltuner.pl \
  && test -f /root/.mysql-root-password \
  && ./mysqltuner.pl --user root --pass `cat /root/.mysql-root-password`
fi

if [ "$1" = "phpmail" ]; then
  touch /var/log/phpmail.log
  chmod 666 /var/log/phpmail.log
  cd /etc
  wget --quiet -N $DLPATH/php.ini 
  service httpd restart
fi  

if [ "$1" = "installmonit" ]; then
  yum -y install monit
  
  cd /etc
  wget --quiet -N $DLPATH/monit.conf
	
  if [ ! -a /etc/ssl/certs/monit.pem ]; then
    openssl req -new -x509 -days 3650 -nodes -subj '/CN=localhost' -out /etc/ssl/certs/monit.pem -keyout /etc/ssl/certs/monit.pem
  fi
  chmod 600 /etc/ssl/certs/monit.pem
	
  MONITUSER=`hostname -s`
  MONITPASS=`pwgen 32 1`
  if [ -a /root/.monit-password ]; then
    MONITPASS=`cat /root/.monit-password`
  else
    echo $MONITPASS > /root/.monit-password
  fi	
  
  sed -i "s/mytestuser/$MONITUSER/g" /etc/monit.conf
  sed -i "s/mytestpassword/$MONITPASS/g" /etc/monit.conf	
  
  cd /etc/monit.d
  wget --quiet -N $DLPATH/monit-httpd.conf
  wget --quiet -N $DLPATH/monit-mysqld.conf
  wget --quiet -N $DLPATH/monit-nginx.conf
  wget --quiet -N $DLPATH/monit-sshd.conf
  wget --quiet -N $DLPATH/monit-hddfree.conf
  
  service monit restart
  chkconfig monit on
fi
