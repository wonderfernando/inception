# Inception

42 curriculum Docker project: WordPress stack with NGINX, MariaDB, and PHP-FPM.

## Architecture

```
[Internet:443] → [nginx] → [wordpress:9000] → [mariadb:3306]
```

- **nginx**: Reverse proxy with self-signed TLS (generated at build), serves WordPress
- **wordpress**: PHP-FPM container, WordPress downloaded at build time, config patched at startup
- **mariadb**: Database initialized on first run via `init.sql`

## Commands

```bash
make              # build + up (all services)
make up           # start containers only
make down         # stop containers
make clean        # stop + remove containers + volumes + /home/fernando/data
make re           # clean + build + up
make logs         # tail all logs
docker compose -f srcs/docker-compose.yml ps   # list containers
docker compose -f srcs/docker-compose.yml logs -f nginx  # tail nginx logs
```

## Critical Gotchas

- **Hardcoded paths in Makefile**: `make up` creates `/home/ferda-si/data` (not parameterized). This path is hardcoded and will fail if the user is not `ferda-si` or the home directory differs.

- **Secrets are real**: Files in `secrets/` contain actual credentials (db_password.txt, db_root_password.txt). They are in `.gitignore`.

- **TLS certs generated at build**: NGINX Dockerfile generates self-signed certificates with hardcoded CN `ferda-si.42.fr`. Certificates are NOT persisted in a volume.

- **WordPress config patched at runtime**: `srcs/requirements/wordpress/tools/entrypoint.sh` uses `sed` to modify `wp-config.php` with database credentials from Docker secrets.

- **MariaDB init only runs once**: `srcs/requirements/mariadb/tools/docker-entrypoint.sh` checks if `/var/lib/mysql` is empty before initializing. Deleting the volume triggers re-initialization.

- **Debian Bullseye base**: All containers use `debian:bullseye-slim`.

## Directory Structure

```
srcs/
  docker-compose.yml    # orchestration config
  .env                  # non-sensitive env vars
  requirements/
    nginx/              # nginx container (Dockerfile, conf/)
    wordpress/          # wordpress+php-fpm container (Dockerfile, conf/, tools/)
    mariadb/            # mariadb container (Dockerfile, tools/)
secrets/
  db_password.txt
  db_root_password.txt
```

## Service Configuration

- **NGINX**: Listens on 443 only (no HTTP 80), TLSv1.2/1.3 only
- **WordPress-FPM**: Listens on port 9000 (TCP), receives from nginx
- **MariaDB**: Listens on 0.0.0.0:3306, init via `/tmp/init.sql`

## Access

- Website: https://ferda-si.42.fr (certificate is self-signed, browser will warn)
- WordPress Admin: https://ferda-si.42.fr/wp-admin

## Credentials

```bash
cat secrets/db_password.txt
cat secrets/db_root_password.txt
```

Database user is `fernando_wp` (hardcoded in `init.sql` and `wp-config.php` patching).