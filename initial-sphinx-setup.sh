yum -y install unixODBC
rpm -Uhv http://sphinxsearch.com/files/sphinx-2.2.11-2.rhel6.x86_64.rpm
cp /opt/scripts/sphinx-common.conf /etc/sphinx/sphinx-common.conf
cat /etc/sphinx/sphinx-common.conf > /etc/sphinx/sphinx.conf
chown -R sphinx:sphinx /var/log/sphinx/*
echo '04 03 * * * /usr/bin/indexer --rotate --all' > /var/spool/cron/sphinx
/opt/scripts/sphinxrestart.sh
chkconfig searchd on
