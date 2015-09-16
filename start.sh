#!/bin/bash
set -e

echo "Setting permissions"
touch /var/log/php5-fpm.log /var/log/nginx/access.log /var/log/nginx/error.log /var/log/blackfire.log
chmod a+r /var/log/php5-fpm.log /var/log/nginx/access.log /var/log/nginx/error.log /var/log/blackfire.log

echo "Injecting app env variable"
VHOST_FILE="/etc/nginx/sites-available/default"
for _curVar in `env | awk -F = '$1 ~ /.+_.+/ {print $1}'`;do
    if [[ ! "${_curVar}" =~ "." ]]; then
        if grep -q "fastcgi_param ${_curVar} " "$VHOST_FILE"; then
            sed -i "s=^        fastcgi_param ${_curVar} .*=        fastcgi_param ${_curVar} ${!_curVar};=g" "$VHOST_FILE"
        else
            sed -i "s=^        # env=        # env\n        fastcgi_param ${_curVar} ${!_curVar};=g" "$VHOST_FILE"
        fi
    fi
done
cat $VHOST_FILE

if [ -f /var/www/app/console ]; then
    echo "Initialize Symfony2"

    cd /var/www/
    setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx app/cache app/logs || true
    setfacl -dR -m u:www-data:rwx -m u:`whoami`:rwx app/cache app/logs || true
fi

echo "/etc/hosts file :"
cat /etc/hosts

echo "IP address :"
ip a | grep "scope global eth0"

/etc/init.d/php5-fpm start
/etc/init.d/nginx start

tail -f /var/log/nginx/error.log
