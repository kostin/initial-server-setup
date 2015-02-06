#!/bin/bash

DLPATH='https://github.com/kostin/initial-server-setup/raw/master'

if [ ! `cat /etc/redhat-release | grep 'CentOS release 6'` ]
then
    echo 'Wrong OS!'
    exit 0
fi

MYSQLPASS=""
if [[ -a /root/.mysql-root-password ]];
then 
	MYSQLPASS=`cat /root/.mysql-root-password`	
	echo 'Already set up'
	scriptinstall
	confinstall
else
	MYSQLPASS=`pwgen 16 1`
	scriptinstall
	softinstall
	confinstall
	mysqlpostinstall
fi


function softinstall {

	echo 'Installing software...'
	
	echo 'nameserver 8.8.8.8' > /etc/resolv.conf
	killall -9 httpd

	rpm -Uvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
	yum -y install epel-release
	sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo
	
	yum -y update
	yum -y install nano git mc rsync screen mailx pwgen nginx mysql-server phpMyAdmin proftpd psmisc net-tools httpd-itk mod_ssl php

	if [ `uname -m` == 'x86_64' ]
	then
		rpm -Uvh http://repo.x-api.net/centos6/x86_64/mod_rpaf-0.6-2.el6.x86_64.rpm
		rpm -Uhv http://sphinxsearch.com/files/sphinx-2.0.10-1.rhel6.x86_64.rpm
		#  http://centalt.prounixadmin.ru/repository/centos/6/x86_64/mod_rpaf-0.6-2.el6.x86_64.rpm
		yum -y install ftp://linuxsoft.cern.ch/cern/updates/slc6X/x86_64/RPMS/php-pecl-uploadprogress-1.0.1-1.slc6.x86_64.rpm
	else
		rpm -Uvh http://repo.x-api.net/centos6/i386/mod_rpaf-0.6-2.el6.i686.rpm
		rpm -Uhv http://sphinxsearch.com/files/sphinx-2.0.10-1.rhel5.i386.rpm
		yum -y install ftp://linuxsoft.cern.ch/cern/updates/slc6X/x86_64/RPMS/php-pecl-uploadprogress-1.0.1-1.slc6.i686.rpm
	fi

}

function scriptupdate {

	echo 'Installing or updating scripts...'

	cd /opt/scripts

	wget -N $DLPATH/backup.sh
	wget -N $DLPATH/hostadd.sh 
	wget -N $DLPATH/hostdel.sh
	wget -N $DLPATH/hostexport.sh
	wget -N $DLPATH/hostshow.sh
	wget -N $DLPATH/hostdeploy.sh
	wget -N $DLPATH/vhost_template
	wget -N $DLPATH/sphinxrestart.sh

	chmod +x /opt/scripts/*.sh

	cd /usr/local/share/ && \
	wget http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz && \
	tar zxvf drush-7.x-5.9.tar.gz && \
	ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \
	rm -f drush-7.x-5.9.tar.gz

}

function confupdate {

	echo 'Updating conf...'
	
	cd /etc/httpd/conf.d
	wget -N $DLPATH/rpaf.conf
	wget -N $DLPATH/php.conf
	wget -N $DLPATH/phpMyAdmin.conf

	cd /etc/httpd/conf
	wget -N $DLPATH/httpd.conf

	cd /etc/
	wget -N $DLPATH/php.ini
	wget -N $DLPATH/php-cli.ini
	wget -N $DLPATH/my.cnf
	wget -N $DLPATH/proftpd.conf

	cd /etc/nginx
	wget -N $DLPATH/nginx.conf

	cd /etc/logrotate.d
	wget -N $DLPATH/httpd

	cd /etc/sphinx/
	wget -N $DLPATH/sphinx-common.conf

	mkdir /opt/scripts
	mkdir -p /backups/.deleted	

	chown -R sphinx:sphinx /var/log/sphinx/*
	rm -f /etc/nginx/conf.d/*.conf
	sed -i "s/#HTTPD=\/usr\/sbin\/httpd.worker/HTTPD=\/usr\/sbin\/httpd.itk/" /etc/sysconfig/httpd
	
	rm -rf /var/www/html /var/www/error /var/www/icons /var/www/cgi-bin

	/opt/scripts/hostadd.sh 000default
	echo "<?php print rand(); ?>" > /var/www/000default/public/index.php

	echo "#!/bin/bash" > /etc/profile.d/php-cli.sh
	echo 'alias php="php -c /etc/php-cli.ini"' >> /etc/profile.d/php-cli.sh

	mkdir /etc/httpd/conf/vhosts
	
	RPAF_IPS=`ip a | grep inet | awk '{print $2}' | awk -F/ '{print $1}' | sort -u | tr '\n' ' '`
	sed -i "s/IPS/$RPAF_IPS/" /etc/httpd/conf.d/rpaf.conf
	
	service httpd restart
	service mysqld restart
	service nginx restart
	service proftpd restart
	chkconfig searchd restart
	chkconfig httpd on
	chkconfig mysqld on
	chkconfig nginx on
	chkconfig proftpd on
	chkconfig searchd on

	iptables -F
	service iptables save

	echo '05 03 * * * /opt/scripts/backup.sh' >> /var/spool/cron/root
	echo '04 03 * * * /usr/bin/indexer --rotate --all' >> /var/spool/cron/root

	mkdir /etc/www.skel /etc/www.skel/public /etc/www.skel/dev /etc/www.skel/logs /etc/www.skel/tmp
	
	HTUSER='269'
	HTPASS='4389'
	#HTPASS=`pwgen 16 1`
	htpasswd -b -c /opt/scripts/.htpasswd $HTUSER $HTPASS
	echo "Password (.htpasswd) for user $HTUSER is $HTPASS"
}

function mysqlpostinstall {

	mysqladmin -u root password $MYSQLPASS
	mysql -p$MYSQLPASS -B -N -e "drop database test"
	echo $MYSQLPASS > /root/.mysql-root-password
	echo "MySQL root password is $MYSQLPASS and it stored in /root/.mysql-root-password"	
	
}
