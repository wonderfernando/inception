*This project has been created as part of the 42 curriculum by fernando*

# Inception

## Description

Inception is a system administration project that teaches how to use Docker and Docker Compose to set up a complete infrastructure. This project deploys a WordPress site with NGINX as a reverse proxy, MariaDB as the database, and php-fpm to handle PHP requests.

## Instructions

### Prerequisites
- Docker Engine
- Docker Compose
- Make

### Build and Run

```bash
make
```

This will:
1. Create the data directories
2. Build all Docker images
3. Start all containers

### Stop

```bash
make down
```

### Clean (removes all containers and volumes)

```bash
make clean
```

### Rebuild

```bash
make re
```

## Usage Examples

### View running containers
```bash
docker compose -f srcs/docker-compose.yml ps
```

### View logs
```bash
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml logs -f nginx
```

### Access the website
- Website: https://ferda-si.42.fr (port 443)
- WordPress Admin: https://ferda-si.42.fr/wp-admin

### Check credentials
```bash
cat secrets/db_password.txt
cat secrets/db_root_password.txt
```

## Technical Choices

- **Base Image**: Debian Bullseye (penultimate stable release)
- **TLS**: TLSv1.2/TLSv1.3 only
- **Reverse Proxy**: NGINX
- **Database**: MariaDB
- **Application**: WordPress with php-fpm
- **Storage**: Docker named volumes with bind mount to host