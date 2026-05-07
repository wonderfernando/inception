#!/bin/bash
set -e

echo "Verificando segredos em /run/secrets/..."
ls -la /run/secrets/

# Tenta ler os segredos com verificação de erro
if [ -f /run/secrets/db_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
else
    echo "ERRO: Segredo db_root_password não encontrado!"
    exit 1
fi

if [ -f /run/secrets/db_password ]; then
    WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "ERRO: Segredo db_password não encontrado!"
    exit 1
fi

# Se o banco ainda não foi inicializado
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando MariaDB pela primeira vez..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    echo "Configurando banco e usuários..."
    mysqld --user=mysql --datadir=/var/lib/mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS $WORDPRESS_DB_NAME;
CREATE USER IF NOT EXISTS '$WORDPRESS_DB_USER'@'%' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'%';
FLUSH PRIVILEGES;
EOF
fi

echo "Iniciando MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
