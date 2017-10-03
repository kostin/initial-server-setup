mkdir -p /var/www/$USER/.hostconf/.ssl

/root/.acme.sh/acme.sh --issue $SSLDOMAINS -w /var/www/certs

/root/.acme.sh/acme.sh --install-cert -d $SSLDOMAINS \
--key-file /var/www/$USER/.hostconf/.ssl/$USER.key
--fullchain-file /var/www/$USER/.hostconf/.ssl/$USER.fullchain.cer \
--reloadcmd "service nginx force-reload"
