#!/bin/bash
set -e
# Lê o segredo da senha do banco
WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
# Espera o MariaDB estar pronto
until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    echo "Aguardando o MariaDB..."
    sleep 2
done




cd /var/www/html

sed -i "s/define( 'DB_NAME', '.*' );/define( 'DB_NAME', '$WORDPRESS_DB_NAME' );/" wp-config.php
sed -i "s/define( 'DB_USER', '.*' );/define( 'DB_USER', '$WORDPRESS_DB_USER' );/" wp-config.php
sed -i "s/define( 'DB_PASSWORD', '.*' );/define( 'DB_PASSWORD', '$WORDPRESS_DB_PASSWORD' );/" wp-config.php
sed -i "s/define( 'DB_HOST', '.*' );/define( 'DB_HOST', 'mariadb' );/" wp-config.php


# Instala o WordPress se não estiver instalado
if ! wp core is-installed --allow-root; then
    echo "Instalando WordPress..."
    wp core install --allow-root \
        --url="$DOMAIN_NAME" \
        --title="Inception Project" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
 
fi

echo "Iniciando PHP-FPM..."
exec php-fpm8.2 -F