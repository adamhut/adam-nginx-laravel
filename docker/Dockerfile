FROM php:7.3-fpm-stretch

# ENV PHP_XEDBUG_DEFAULT_ENABLE=0 \
#     PHP_XDEBUG_REMOTE_HOST='' \
#     PHP_XEDBUG_REMOTE_AUTOSTART=1 \
#     PHP_XDEBUG_REMOT_PORT=1

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=10000 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=128

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        nginx \
        supervisor \
        procps \
    && docker-php-ext-install pdo_mysql \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug opcache 

# copy the current folder to docker location
ADD . /var/www/html

# add xdebug config into docker 
ADD docker/config/php/conf.d/*.ini /usr/local/etc/php/conf.d/
# ADD the php ini file into contianer
ADD docker/config/php/php.ini /usr/local/etc/php/php.ini

ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/nginx/default /etc/nginx/sites-available/default
ADD docker/config/nginx/h5bp/ /etc/nginx/h5bp
ADD docker/config/php/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

ADD docker/start.sh /usr/local/bin/start

# change the permission to make sure Apache can edit the file docke r
RUN chown -R www-data:www-data /var/www/html \
    && chmod +x /usr/local/bin/start \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["/usr/local/bin/start"] 





