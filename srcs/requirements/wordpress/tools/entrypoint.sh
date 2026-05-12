#!/bin/bash
set -e
# Lê o segredo da senha do banco
WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Espera o MariaDB estar pronto
until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    echo "Aguardando o MariaDB..."
    sleep 2
done




cd /var/www/html


# Instala o WordPress se não estiver instalado
if ! wp core is-installed --allow-root; then

  wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root


    echo "Instalando WordPress..."
    wp core install --allow-root \
        --url="$DOMAIN_NAME" \
        --title="Inception Project" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email

    echo "Criando segundo usuário..."
    wp user create --allow-root \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author
fi

echo "Iniciando PHP-FPM..."
exec php-fpm8.2 -F