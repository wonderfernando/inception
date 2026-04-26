FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/lib/mysql

RUN chown -R mysql:mysql /var/lib/mysql

COPY tools/init.sql /tmp/init.sql
COPY tools/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["mysqld", "--user=mysql", "--datadir=/var/lib/mysql", "--bind-address=0.0.0.0"]