#!/bin/bash

set -e

 
# Lê o secret com fallback para variável de ambiente
if [ -f /run/secrets/db_password ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
elif [ -n "${WORDPRESS_DB_PASSWORD}" ]; then
    DB_PASSWORD="${WORDPRESS_DB_PASSWORD}"
else
    echo "ERRO: senha do banco não encontrada em /run/secrets/db_password nem em WORDPRESS_DB_PASSWORD"
    exit 1
fi

# Configura o wp-config.php
sed -i "s|database_name_here|${WORDPRESS_DB_NAME}|" /var/www/html/wp-config.php
sed -i "s|username_here|${WORDPRESS_DB_USER}|"      /var/www/html/wp-config.php
sed -i "s|password_here|${DB_PASSWORD}|"            /var/www/html/wp-config.php
sed -i "s|localhost|${WORDPRESS_DB_HOST}|"          /var/www/html/wp-config.php


# Inicia o PHP-FPM
echo "Iniciando PHP-FPM..."
exec php-fpm7.4 -F