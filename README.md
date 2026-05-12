*This project has been created as part of the 42 curriculum by ferda-si.*

# Inception

## Description
Inception is a system administration project that teaches how to use Docker and Docker Compose to set up a complete infrastructure. The goal of this project is to broaden your knowledge of system administration by using Docker to set up a robust set of services. It deploys a WordPress site with NGINX as a reverse proxy, MariaDB as the database, and PHP-FPM to handle PHP requests, all orchestrated via Docker Compose.

## Instructions
### Prerequisites
- Docker Engine
- Docker Compose
- Make
- OpenSSL (for certificate generation)

### Compilation and Installation
```bash
make
```

This will:
1. Create the required data directories
2. Build all Docker images
3. Start all containers

### Access
- Website: https://ferda-si.42.fr (port 443 only)
- WordPress Admin: https://ferda-si.42.fr/wp-admin

> ⚠️ The SSL certificate is self-signed. Your browser will show a security warning — proceed anyway.

### Credentials
```bash
cat secrets/db_password.txt
cat secrets/db_root_password.txt
```

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

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://developer.wordpress.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

**AI Usage:** AI was used to format and structure this documentation and to understand Docker concepts for the project design.

## Project Description: Docker and Sources
This project relies entirely on Docker to containerize services. The `srcs/docker-compose.yml` file is the orchestrator, pulling build instructions from custom Dockerfiles located in `srcs/requirements/` for each service (nginx, wordpress, mariadb). All images are built locally — no pre-built images from DockerHub are used.

### Virtual Machines vs Docker
Virtual Machines (VMs) emulate an entire hardware system, running a full guest operating system on top of a hypervisor. This makes VMs heavy and resource-intensive. Docker, on the other hand, uses containerization to run isolated processes sharing the host OS kernel. Containers are much lighter, start almost instantly, and consume significantly fewer resources while ensuring consistency across environments.

### Secrets vs Environment Variables
Environment variables are easy to configure and useful for general settings, but they are often visible to any process running within the environment, posing a security risk for sensitive data. Docker Secrets are specifically designed to handle sensitive information (like database passwords). They are mounted as read-only files in tmpfs within the container (e.g., `/run/secrets/`), ensuring that the sensitive data is not persisted on disk or exposed as an environment variable.

### Docker Network vs Host Network
Using the host network binds container ports directly to the host's network interfaces, removing network isolation and potentially causing port conflicts. A Docker Network (like the bridge network used in this project) creates an isolated, virtual network connecting only the containers assigned to it. This provides better security, isolates inter-container communication, and allows containers to resolve each other's IPs by container name (DNS).

### Docker Volumes vs Bind Mounts
Bind mounts map an exact path from the host machine to a path in the container. While useful for development, they depend on the host's directory structure and permissions. Docker Volumes are managed entirely by Docker, offering better performance, portability, and safety. Volumes are decoupled from the host's filesystem specifics, making them the preferred choice for persisting database data and website files.