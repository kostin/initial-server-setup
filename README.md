# initial-server-setup
```
cd /root \
&& wget -N --no-check-certificate https://github.com/kostin/initial-server-setup/raw/master/initial-server-setup-php7.sh \
&& chmod +x initial-server-setup-php7.sh \
&& ./initial-server-setup.sh
```

If you run the script again, it will only be updated configuration files and scripts.

TODO:
1. Generate per user cron files from ./.hostconf/.cron

```
mkdir -p /opt/scripts; \
yum install -y rsync unzip wget \
&& cd /tmp \
&& wget --no-check-certificate -O /tmp/master.zip \
   https://github.com/kostin/initial-server-setup/archive/master.zip \
&& unzip -o master.zip \
&& rsync -a /tmp/initial-server-setup-master/ /opt/scripts/ \
&& chmod +x /opt/scripts/*.sh \
&& chmod +x /opt/scripts/*/*.sh \
&& /opt/scripts/initial-server-setup-php7.sh
```
