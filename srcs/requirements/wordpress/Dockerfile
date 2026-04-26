FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-intl \
    php-zip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html

RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 \
    && rm /tmp/wordpress.tar.gz

RUN cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

COPY conf/php-fpm.conf /etc/php/*/fpm/pool.d/www.conf
# COPY conf/wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

CMD ["/entrypoint.sh"]