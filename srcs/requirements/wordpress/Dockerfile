FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-intl \
    php7.4-zip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html \
    && mkdir -p /run/php

RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 \
    && rm /tmp/wordpress.tar.gz

RUN cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

COPY conf/php-fpm.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

CMD ["/entrypoint.sh"]