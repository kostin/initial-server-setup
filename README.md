# initial-server-setup
```
cd /root \
&& wget -N --no-check-certificate https://github.com/kostin/initial-server-setup/raw/master/initial-server-setup.sh \
&& chmod +x initial-server-setup.sh \
&& ./initial-server-setup.sh
```

If you run the script again, it will only be updated configuration files and scripts.

TODO:
1. Generate per user cron files from ./.hostconf/.cron

```
cd /root \
&& wget -N --no-check-certificate https://github.com/kostin/initial-server-setup/archive/master.zip \
&& unzip master.zip \
&& cd initial-server-setup-master \
&& cp -arf scripts/* /opt/scripts/
&& chmod +x /opt/scripts/*.sh
```
