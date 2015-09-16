FROM debian:jessie

MAINTAINER Michel Roca <mroca.dh@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
    php5-fpm \
    php5-curl \
    php5-intl \
    php5-gd \
    php5-mcrypt \
    php-apc \
    nginx \
    git \
    curl \
    tar \
    wget \
    ca-certificates \
 && apt-get autoremove -y && apt-get clean && rm -r /var/lib/apt/lists/*

# Composer
RUN curl -k -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Nginx
RUN mkdir -p /var/lib/nginx /etc/nginx/sites-enabled /etc/nginx/sites-available /var/www
ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default

# PHP
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini && \
    sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini && \
    sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php5/fpm/php-fpm.conf && \
    sed -i 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php5/fpm/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 16M/g' /etc/php5/fpm/php.ini && \
    sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/g' /etc/php5/fpm/php.ini && \
    sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/fpm/php.ini && \
    sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php5/fpm/php.ini && \
    sed -i "s/max_input_time = 60/max_input_time = 300/" /etc/php5/fpm/php.ini && \
    sed -i "s/memory_limit = 128M/memory_limit = 1024M/" /etc/php5/fpm/php.ini && \
    sed -i "s/default_socket_timeout = 60/default_socket_timeout = 300/" /etc/php5/fpm/php.ini && \

    sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php5/fpm/php-fpm.conf && \
    sed -i '/^;error_log/cerror_log = /var/log/php5-fpm.log' /etc/php5/fpm/php-fpm.conf && \

    sed -i '/^;php_admin_value\[error_log\]/cphp_admin_value[error_log] = /var/log/php5-fpm.log' /etc/php5/fpm/pool.d/www.conf && \
    sed -i '/^;php_admin_flag\[log_errors\]/cphp_admin_flag[log_errors] = on' /etc/php5/fpm/pool.d/www.conf

# php-cs-fixer
RUN curl http://get.sensiolabs.org/php-cs-fixer.phar -o php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer

ADD php-cs-fixer-diff-cache.sh /opt/php-cs-fixer-diff-cache.sh

# Start
ADD start.sh /opt/start.sh
RUN chmod +x /opt/*.sh

VOLUME ["/var/www"]
WORKDIR /var/www

EXPOSE 80

CMD ["/opt/start.sh"]
