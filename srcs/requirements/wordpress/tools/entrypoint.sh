#!/bin/bash
set -e

# Lê o segredo da senha do banco
WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)

# Aguarda o MariaDB estar pronto
until mysqladmin ping -h "$WORDPRESS_DB_HOST" --user="$WORDPRESS_DB_USER" --password="$WORDPRESS_DB_PASSWORD" --silent; do
    echo "Aguardando MariaDB em $WORDPRESS_DB_HOST com o usuário $WORDPRESS_DB_USER..."
    sleep 3
done

cd /var/www/html

# Cria o wp-config.php se não existir
if [ ! -f wp-config.php ]; then
    echo "Configurando wp-config.php..."
    wp config create --allow-root \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST"
fi

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
    
    echo "Criando usuário regular..."
    wp user create --allow-root \
        "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author
fi

echo "Iniciando PHP-FPM..."
exec php-fpm8.2 -F