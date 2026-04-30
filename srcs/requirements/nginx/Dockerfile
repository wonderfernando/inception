FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    nginx \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/nginx/certs

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/key.pem \
    -out /etc/nginx/certs/cert.pem \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=ferda-si.42.fr"


COPY conf/nginx.conf /etc/nginx/nginx.conf
#COPY conf/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 7777

CMD ["nginx", "-g", "daemon off;"]