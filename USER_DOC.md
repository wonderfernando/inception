# User Documentation

## Overview

This project is a self-hosted WordPress infrastructure running in Docker containers. It provides a complete, ready-to-use website with secure connections.

## Services Provided

| Service | Description | Port |
|---------|-------------|------|
| NGINX | Reverse proxy with SSL termination | 443 (HTTPS only) |
| WordPress + PHP-FPM | Content Management System | 9000 (internal) |
| MariaDB | Database server | 3306 (internal) |

## Quick Start

### Starting the Project

```bash
make
```

This command will:
1. Create data directories
2. Build Docker images
3. Start all containers

### Stopping the Project

```bash
make down
```

### Restarting

```bash
make re
```

### Full Clean

```bash
make clean
```

> ⚠️ Warning: `make clean` removes all data including database and uploaded files.

## Accessing the Website

### Website URL
```
https://ferda-si.42.fr
```

### Administration Panel
```
https://ferda-si.42.fr/wp-admin
```

> ⚠️ The SSL certificate is self-signed. Your browser will display a security warning — click "Advanced" and "Proceed to site" to continue.

## Credentials

All credentials are stored in the `secrets/` directory:

| Credential | File | Usage |
|------------|------|-------|
| Database password | `secrets/db_password.txt` | WordPress connection |
| Database root password | `secrets/db_root_password.txt` | MariaDB administration |

### Default WordPress Admin
| Setting | Value |
|---------|-------|
| Username | `ferda_boss` |
| Password | Check `secrets/db_password.txt` |
| Email | `ferda@42.fr` |

### Viewing Credentials

```bash
cat secrets/db_password.txt
cat secrets/db_root_password.txt
```

### Changing Credentials

1. Edit the credential files:
   ```bash
   nano secrets/db_password.txt
   nano secrets/db_root_password.txt
   ```

2. Rebuild and restart:
   ```bash
   make re
   ```

> ⚠️ Changing credentials will require WordPress reconfiguration.

## Checking Services Status

### View All Containers

```bash
docker compose -f srcs/docker-compose.yml ps
```

Expected output:
```
NAME                STATUS
mariadb             Up (healthy)
nginx               Up
wordpress           Up
```

### View Logs

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

### View Specific Service Logs

```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

### Check Container Health

```bash
docker inspect mariadb --format='{{.State.Health.Status}}'
```

Expected output: `healthy`

## Troubleshooting

### Services Not Starting

1. Check if ports are available:
   ```bash
   docker compose -f srcs/docker-compose.yml ps
   ```

2. Verify Docker is running:
   ```bash
   docker info
   ```

### Cannot Access Website

1. Check NGINX is running:
   ```bash
   docker compose -f srcs/docker-compose.yml logs nginx
   ```

2. Verify /etc/hosts entry:
   ```bash
   grep ferda-si.42.fr /etc/hosts
   ```
   Should show: `127.0.0.1 ferda-si.42.fr`

3. Check SSL certificate:
   ```bash
   openssl s_client -connect ferda-si.42.fr:443
   ```

### Database Connection Issues

1. Verify MariaDB is healthy:
   ```bash
   docker exec mariadb mysqladmin ping -h localhost
   ```

2. Check WordPress can reach MariaDB:
   ```bash
   docker exec wordpress ping -c 2 mariadb
   ```

### Volume Data Location

Persistent data is stored at:
```
/home/ferda-si/data/mariadb
/home/ferda-si/data/wordpress
```

## Security Notes

- Only HTTPS (port 443) is enabled — HTTP (port 80) is disabled
- TLS 1.2 and 1.3 are the only allowed protocols
- Credentials are managed via Docker Secrets
- Database is only accessible within the internal Docker network
