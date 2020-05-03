#!/usr/bin/env bash 

# -e flag means exit right away if command exit none 0 status
set -e

# set variable APP_ENV and default to production
env=${APP_ENV:-production}
role=${CONTAINER_ROLE:-app}

echo "environment is $env"

if [ "$env" != "local" ]; then

    echo "Caching configuration"
    (
        cd /var/www/html && 
        php artisan config:cache && 
        php artisan route:cache && 
        php artisan view:cache
    ) 

    echo "Removing XDebug"
    rm -rf /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    rm -rf /usr/local/etc/php/conf.d/xdebug.ini
    #or
    #  rm -rf /usr/local/etc/php/conf.d/{docker-php-ext-xdebug.ini,xdebug.ini}
else    
    echo "Clean up caching configuration"
    (
        cd /var/www/html && 
        php artisan config:clear  && 
        php artisan view:clear && 
        php artisan route:clear
    ) 
fi
# echo "start script ran"

echo "The role is $role "

if [ $role = "app" ]; then
    exec supervisord -c /etc/supervisor/supervisord.conf
    # exec apache2 -DFOREGROUND
elif [ $role = "scheduler" ]; then
    echo "The role is Scheduler"
    while [ true ]
    do
        php /var/www/html/artisan schedule:run --verbose --no-interaction &
        sleep 60
    done
    exit 0
elif [ $role = "queue" ]; then
    echo "The role is Queue"
    exec php /var/www/html/artisan queue:work --verbose --tries=3 --timeout=90
else
    echo "Could not match the container role \"$role\" "
    exit 1
fi
