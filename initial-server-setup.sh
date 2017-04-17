#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

function softinstall {
	echo 'Installing software...'
	
	echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
	echo 'nameserver 77.88.8.8' >> /etc/resolv.conf
	killall -9 httpd

	rpm -Uvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
	yum -y install epel-release
	sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo
	
	echo -e "[mariadb]\nname = MariaDB" > /etc/yum.repos.d/MariaDB.repo
	if [ `uname -m` == 'x86_64' ]; then
		echo -e "baseurl = http://yum.mariadb.org/10.1/centos6-amd64" >> /etc/yum.repos.d/MariaDB.repo
	else
		echo -e "baseurl = http://yum.mariadb.org/10.1/centos6-x86" >> /etc/yum.repos.d/MariaDB.repo
	fi
	echo -e "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\ngpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo

	yum -y update
	yum -y clean all
	
	yum -y install MariaDB-server
	touch /var/log/mysql.log 
        chown mysql:mysql /var/log/mysql.log 
	service mysql start \
	&& chkconfig mysql on	
	
	yum -y install sshguard monit time nano screen git mc rsync screen curl mailx pwgen nginx phpMyAdmin postgresql-libs proftpd psmisc net-tools httpd-itk mod_ssl php gnuplot
	
	if [ `uname -m` == 'x86_64' ]; then
		rpm -Uvh http://repo.x-api.net/centos6/x86_64/mod_rpaf-0.6-2.el6.x86_64.rpm
		#yum install unixODBC
		#rpm -Uhv http://sphinxsearch.com/files/sphinx-2.2.11-2.rhel6.x86_64.rpm
		#  http://centalt.prounixadmin.ru/repository/centos/6/x86_64/mod_rpaf-0.6-2.el6.x86_64.rpm
		yum -y install ftp://linuxsoft.cern.ch/cern/updates/slc6X/x86_64/RPMS/php-pecl-uploadprogress-1.0.1-1.slc6.x86_64.rpm
	else
		rpm -Uvh http://repo.x-api.net/centos6/i386/mod_rpaf-0.6-2.el6.i686.rpm
		#rpm -Uhv http://sphinxsearch.com/files/sphinx-2.0.10-1.rhel6.i386.rpm
		yum -y install ftp://linuxsoft.cern.ch/cern/updates/slc6X/i386/RPMS/php-pecl-uploadprogress-1.0.1-1.slc6.i686.rpm
	fi
	
	cd /tmp
	curl -sS https://getcomposer.org/installer | php  
	mv composer.phar /usr/local/bin/composer  
	
	yum -y install ntp
	chkconfig ntpd on
	ntpdate pool.ntp.org
	/etc/init.d/ntpd start
	
	yum -y clean all
}

function mysqlpostinstall {
	mysqladmin -u root password $MYSQLPASS
	mysql -p$MYSQLPASS -B -N -e "drop database test"
	echo $MYSQLPASS > /root/.mysql-root-password
	echo "MySQL root password is $MYSQLPASS and it stored in /root/.mysql-root-password"
}

function confupdate {
	echo 'Installing or updating conf...'
	
	cd /etc/httpd/conf.d
	wget -N $DLPATH/php.conf
	wget -N $DLPATH/phpMyAdmin.conf
	wget -N $DLPATH/rpaf.conf
	if [ `uname -m` == 'i686' ]; then
		sed -i 's/lib64/lib/g' /etc/httpd/conf.d/rpaf.conf
	fi	
	RPAF_IPS=`ip a | grep inet | awk '{print $2}' | awk -F/ '{print $1}' | sort -u | tr '\n' ' '`
	sed -i "s/IPS/$RPAF_IPS/" /etc/httpd/conf.d/rpaf.conf		

	cd /etc/httpd/conf
	wget -N $DLPATH/httpd.conf
	sed -i "s/#HTTPD=\/usr\/sbin\/httpd.worker/HTTPD=\/usr\/sbin\/httpd.itk/" /etc/sysconfig/httpd
	rm -rf /var/www/html /var/www/error /var/www/icons /var/www/cgi-bin
	if [ ! -d /etc/httpd/conf/vhosts ]; then
		mkdir -p /etc/httpd/conf/vhosts
	fi	
	
	cd /etc
	wget -N $DLPATH/my.cnf
	service mysqld stop
	chown -R mysql:mysql /var/lib/mysql
	touch /var/log/mysql-slow.log
	chown mysql:mysql /var/log/mysql-slow.log
	mv /var/lib/mysql/ib_logfile0 /var/lib/mysql/ib_logfile0.bak
	mv /var/lib/mysql/ib_logfile1 /var/lib/mysql/ib_logfile1.bak
	service mysqld start
	
	wget -N $DLPATH/proftpd.conf
	
	wget -N $DLPATH/php.ini
	touch /var/log/phpmail.log
	chmod 666 /var/log/phpmail.log
	wget -N $DLPATH/php-cli.ini
	echo "#!/bin/bash" > /etc/profile.d/php-cli.sh
	echo 'alias php="php -c /etc/php-cli.ini"' >> /etc/profile.d/php-cli.sh
	
	wget -N $DLPATH/monit.conf
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
        wget --quiet -N $DLPATH/monit-mariadb.conf
        wget --quiet -N $DLPATH/monit-nginx.conf
        wget --quiet -N $DLPATH/monit-sshd.conf
        wget --quiet -N $DLPATH/monit-hddfree.conf
        wget --quiet -N $DLPATH/monit-main.conf
	
	cd /etc/nginx
	wget -N $DLPATH/nginx.conf
	rm -f /etc/nginx/conf.d/*.conf
	HOST=`hostname`
	sed -i "s/HOSTNAME/$HOST/" /etc/nginx/nginx.conf
	setsebool -P httpd_can_network_connect 1
        setsebool -P httpd_can_network_relay 1

	cd /etc/logrotate.d
	wget -N $DLPATH/httpd.logrotate
	wget -N $DLPATH/phpmail.logrotate
	wget -N $DLPATH/btmp.logrotate
	

	#cd /etc/sphinx/
	#wget -N $DLPATH/sphinx-common.conf
	#cat /etc/sphinx/sphinx-common.conf > /etc/sphinx/sphinx.conf
	#chown -R sphinx:sphinx /var/log/sphinx/*
	
	HTUSER="269"
	HTPASS="4389"
	#HTPASS=`pwgen 16 1`
	if [ ! -d /opt/scripts ]; then
		mkdir -p /opt/scripts
	fi	
	htpasswd -b -c /opt/scripts/.htpasswd $HTUSER $HTPASS
	echo "Password (.htpasswd) for user $HTUSER is $HTPASS"
	
	iptables -F
	
	#iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
	#iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
	#iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	#iptables -A INPUT -i lo -j ACCEPT
	#iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
	#iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
	#iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
	#iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
	#iptables -P OUTPUT ACCEPT
	#iptables -P INPUT DROP
	
	#iptables -N sshguard
	#iptables -A INPUT -m multiport -p tcp --destination-ports 21,22 -j sshguard
	
	service iptables save	
	service iptables restart
	
	# disable selinux (optional)
	sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
	
	service httpd restart
	service mysql restart
	service nginx restart
	service proftpd restart
	service searchd restart
	service monit restart

	chkconfig httpd on
	chkconfig mysql on
	chkconfig nginx on
	chkconfig proftpd on
	chkconfig searchd on
	chkconfig monit on

	echo '05 03 * * * /opt/scripts/backup.sh' > /var/spool/cron/root
	#echo '04 03 * * * /usr/bin/indexer --rotate --all' > /var/spool/cron/sphinx
}

function scriptupdate {
	echo 'Installing or updating scripts...'

	if [ ! -d /opt/scripts ]; then
		mkdir -p /opt/scripts
	fi
	
	if [ ! -d /backups/.deleted ]; then
		mkdir -p /backups/.deleted
	fi
	
	cd /opt/scripts

	wget -N $DLPATH/backup.sh
	wget -N $DLPATH/hostadd.sh 
	wget -N $DLPATH/hostdel.sh
	wget -N $DLPATH/hostexport.sh
	wget -N $DLPATH/hostshow.sh
	wget -N $DLPATH/hostdeploy.sh
	wget -N $DLPATH/vhost_template
	#wget -N $DLPATH/sphinxrestart.sh
	wget -N $DLPATH/robots.txt

	chmod +x /opt/scripts/*.sh
	
	if [ ! -d /etc/etc/www.skel ]; then
		mkdir /etc/www.skel /etc/www.skel/public /etc/www.skel/dev /etc/www.skel/logs /etc/www.skel/tmp
	fi
	/opt/scripts/hostadd.sh 000default
	if [ ! -a /var/www/000default/public/index.php ]; then 
		NOW="$(date +'%Y-%m-%d')"
		echo "<?php print '$NOW'; ?>" > /var/www/000default/public/index.php		
	fi
	
	echo '*/3 * * * * root /opt/scripts/hoststat.sh > /dev/null' > /etc/cron.d/hoststat
	echo '*/10 * * * * root /opt/scripts/hostplot.sh > /var/www/000default/public/graph.svg' >> /etc/cron.d/hoststat	

	echo '* * * * * root /opt/scripts/hoststatproc.sh > /dev/null' > /etc/cron.d/hoststatproc
	echo '*/10 * * * * root /opt/scripts/hostplotproc.sh > /var/www/000default/public/graph-proc.svg' >> /etc/cron.d/hoststatproc

	cd /usr/local/share/ && \
	wget -N http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz && \
	tar zxvf drush-7.x-5.9.tar.gz && \
	ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \
	rm -f drush-7.x-5.9.tar.gz
	
        cd /tmp
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer	
}

if grep -q 'CentOS release 6' /etc/redhat-release; then
	echo 'Starting with '`hostname`
	echo 'Press Enter to continue (Ctrl+C to exit)!'
       	read
else
	echo 'Wrong OS!';
	exit 0;
fi

if [ -a /root/.mysql-root-password ]; then 
	MYSQLPASS=`cat /root/.mysql-root-password`	
	echo 'Already set up'
	confupdate
	scriptupdate
else
	softinstall
	MYSQLPASS=`pwgen 16 1`
	mysqlpostinstall
	confupdate
	scriptupdate
fi
