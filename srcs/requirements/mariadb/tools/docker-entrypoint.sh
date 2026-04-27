#!/bin/bash

set -e

WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
#ROOT_PASSWORD=$(cat /run/secrets/db_root_password.txt)

if [ -z "$(ls -A /var/lib/mysql)" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi
sed "s/\[WORDPRESS_DB_PASSWORD\]/$WORDPRESS_DB_PASSWORD/g" /tmp/init.sql \
        > /tmp/init_ready.sql

exec mysqld --user=mysql --datadir=/var/lib/mysql --init-file=/tmp/init_ready.sql --bind-address=0.0.0.0
