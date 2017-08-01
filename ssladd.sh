#!/bin/bash
usage="To install ssl you have to use next parameters:\n\t1) Site name (like /var/www/site_name). \n\t2) Main domain \n\t3) (Optional) Additional domains (Ex.: \"test.com test2.com\")."

if [ ! -f "/root/.acme.sh/acme.sh" ] ; then
    	echo "acme.sh doesnt install on this server!"
        exit 0
fi

if [ ! $1 ]; then echo -e $usage; exit 0; fi
USER=$1

if [ ! -d /var/www/$USER/.hostconf ]
then
    	echo "Site or his config directory /var/www/$USER/.hostconf doesnt exists!"
        exit 0
fi

if [ ! $2 ]; then echo -e $usage; exit 0; fi
DOMAIN=$2

ALIASES="-d www.${DOMAIN}"
if [ "$3" ]; then
	#touch /var/www/$USER/.hostconf/.domains
	for i in $3
	do
		ALIASES="$ALIASES -d $i -d www.$i"
		#echo $i >> /var/www/$USER/.hostconf/.domains
	done
fi

if [ -f /var/www/${USER}/.hostconf/.nginx ]
then
        echo "nginx conf already exists for this site!"
        exit 0
fi

/root/.acme.sh/acme.sh --issue -d ${DOMAIN} ${ALIASES} -w /var/www/certs

mkdir /var/www/${USER}/.hostconf/.ssl

/root/.acme.sh/acme.sh --install-cert -d ${DOMAIN} ${ALIASES} \
--key-file /var/www/${USER}/.hostconf/.ssl/${DOMAIN}.key \
--fullchain-file /var/www/${USER}/.hostconf/.ssl/${DOMAIN}.fullchain.cer \
--reloadcmd "service nginx force-reload"

cp /opt/scripts/vhost_template_nginx_ssl /var/www/${USER}/.hostconf/.nginx
sed -i "s/USER/${USER}/g" /var/www/${USER}/.hostconf/.nginx
sed -i "s/DOMAIN/${DOMAIN}/g" /var/www/${USER}/.hostconf/.nginx
sed -i "s/ALIASES/${ALIASES}/g" /var/www/${USER}/.hostconf/.nginx

nginx -t && service nginx force-reload
