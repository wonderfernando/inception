#!/bin/bash

set -e

if [ -f /run/secrets/db_password ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
fi

sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/" /var/www/html/wp-config.php
sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php

exec php-fpm