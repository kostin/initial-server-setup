#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

function softinstall {
	echo 'Installing software...'
	
	echo 'nameserver 8.8.8.8' > /etc/resolv.conf
	echo 'nameserver 77.88.8.8' >> /etc/resolv.conf
	killall -9 httpd

	rpm -Uvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
	yum -y install epel-release
	sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo
	
	yum -y update
	yum -y install sshguard nano git mc rsync screen mailx pwgen nginx mysql mysql-server postgresql-libs phpMyAdmin proftpd psmisc net-tools httpd-itk mod_ssl php
	
	if [ `uname -m` == 'x86_64' ]; then
		rpm -Uvh http://repo.x-api.net/centos6/x86_64/mod_rpaf-0.6-2.el6.x86_64.rpm
		rpm -Uhv http://sphinxsearch.com/files/sphinx-2.0.10-1.rhel6.x86_64.rpm
		#  http://centalt.prounixadmin.ru/repository/centos/6/x86_64/mod_rpaf-0.6-2.el6.x86_64.rpm
		yum -y install ftp://linuxsoft.cern.ch/cern/updates/slc6X/x86_64/RPMS/php-pecl-uploadprogress-1.0.1-1.slc6.x86_64.rpm
	else
		rpm -Uvh http://repo.x-api.net/centos6/i386/mod_rpaf-0.6-2.el6.i686.rpm
		rpm -Uhv http://sphinxsearch.com/files/sphinx-2.0.10-1.rhel6.i386.rpm
		yum -y install ftp://linuxsoft.cern.ch/cern/updates/slc6X/i386/RPMS/php-pecl-uploadprogress-1.0.1-1.slc6.i686.rpm
	fi
	
	yum clean all
	service mysqld start
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
	
	cd /etc/
	wget -N $DLPATH/my.cnf
	wget -N $DLPATH/proftpd.conf
	wget -N $DLPATH/php.ini
	wget -N $DLPATH/php-cli.ini
	echo "#!/bin/bash" > /etc/profile.d/php-cli.sh
	echo 'alias php="php -c /etc/php-cli.ini"' >> /etc/profile.d/php-cli.sh
	
	cd /etc/nginx
	wget -N $DLPATH/nginx.conf
	rm -f /etc/nginx/conf.d/*.conf
	HOST=`hostname`
	sed -i "s/HOSTNAME/$HOST/" /etc/nginx/nginx.conf

	cd /etc/logrotate.d
	wget -N $DLPATH/httpd

	cd /etc/sphinx/
	wget -N $DLPATH/sphinx-common.conf
	cat /etc/sphinx/sphinx-common.conf > /etc/sphinx/sphinx.conf
	#chown -R sphinx:sphinx /var/log/sphinx/*
	
	HTUSER='269'
	HTPASS='4389'
	#HTPASS=`pwgen 16 1`
	htpasswd -b -c /opt/scripts/.htpasswd $HTUSER $HTPASS
	echo "Password (.htpasswd) for user $HTUSER is $HTPASS"
	
	iptables -F
	
	iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
	iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
	iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
	iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P INPUT DROP
	
	iptables -N sshguard
	iptables -A INPUT -m multiport -p tcp --destination-ports 21,22 -j sshguard
	
	service iptables save	
	service iptables restart
	
	service httpd restart
	service mysqld restart
	service nginx restart
	service proftpd restart
	service searchd restart

	chkconfig httpd on
	chkconfig mysqld on
	chkconfig nginx on
	chkconfig proftpd on
	chkconfig searchd on

	echo '05 03 * * * /opt/scripts/backup.sh' > /var/spool/cron/root
	echo '04 03 * * * /usr/bin/indexer --rotate --all' > /var/spool/cron/sphinx
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
	wget -N $DLPATH/sphinxrestart.sh
	wget -N $DLPATH/robots.txt

	chmod +x /opt/scripts/*.sh
	
	if [ ! -d /etc/etc/www.skel ]; then
		mkdir /etc/www.skel /etc/www.skel/public /etc/www.skel/dev /etc/www.skel/logs /etc/www.skel/tmp
	fi
	/opt/scripts/hostadd.sh 000default
	if [ ! -a /var/www/000default/public/index.php ]; then 
		NOW="$(date +'%Y-%m-%d %H:%i:%s')"
		echo "<?php print 'Running since $DATE'; ?>" > /var/www/000default/public/index.php		
	fi

	cd /usr/local/share/ && \
	wget -N http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz && \
	tar zxvf drush-7.x-5.9.tar.gz && \
	ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \
	rm -f drush-7.x-5.9.tar.gz
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
