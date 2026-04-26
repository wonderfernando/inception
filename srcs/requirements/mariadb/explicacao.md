# set -e
Se qualquer comando falhar, o script para imediatamente. Evita que erros silenciosos continuem a execução.

# if [ -z "$(ls -A /var/lib/mysql)" ]; then
Verifica se a pasta /var/lib/mysql está vazia. -z significa "string vazia". ls -A lista todos os ficheiros incluindo ocultos. Se estiver vazia → é a primeira vez que o container arranca.

# mysql_install_db --user=mysql --datadir=/var/lib/mysql
Cria a estrutura inicial de ficheiros que o MariaDB precisa para funcionar — só é necessário uma vez, daí estar dentro do if.

#  sed "s/\[WORDPRESS_DB_PASSWORD\]/$WORDPRESS_DB_PASSWORD/g" /tmp/init.sql \
        > /tmp/init_ready.sql 
        Lê o init.sql, substitui o placeholder [WORDPRESS_DB_PASSWORD] pela password real, e guarda o resultado em init_ready.sql. O \g significa substituir todas as ocorrências, não só a primeira.