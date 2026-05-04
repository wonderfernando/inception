*This project has been created as part of the 42 curriculum by ferda-si.*

# Inception

## Description
Inception is a system administration project that teaches how to use Docker and Docker Compose to set up a complete infrastructure. The goal of this project is to broaden your knowledge of system administration by using Docker to set up a robust set of services. It deploys a WordPress site with NGINX as a reverse proxy, MariaDB as the database, and php-fpm to handle PHP requests, all orchestrated via Docker Compose.

## Instructions
### Compilation and Installation
Ensure you have Docker Engine, Docker Compose, and Make installed.
Clone the repository and run the Makefile to build the images and deploy the containers.
```bash
make
```

### Execution
To view the running containers:
```bash
docker compose -f srcs/docker-compose.yml ps
```

To stop the services:
```bash
make down
```

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [NGINX Official Documentation](https://nginx.org/en/docs/)
- [WordPress Docker Hub](https://hub.docker.com/_/wordpress)
- [MariaDB Docker Hub](https://hub.docker.com/_/mariadb)

**AI Usage:** AI was not directly used in the production of the source code, however, it was employed to format and structure this documentation correctly to meet the subject requirements, providing clear explanations for complex technical choices.

## Project Description: Docker and Sources
This project relies entirely on Docker to containerize services. The `srcs/docker-compose.yml` file is the orchestrator, pulling build instructions from custom Dockerfiles located in `srcs/requirements/` for each service (nginx, wordpress, mariadb).

### Virtual Machines vs Docker
Virtual Machines (VMs) emulate an entire hardware system, running a full guest operating system on top of a hypervisor. This makes VMs heavy and resource-intensive. Docker, on the other hand, uses containerization to run isolated processes sharing the host OS kernel. Containers are much lighter, start almost instantly, and consume significantly fewer resources while ensuring consistency across environments.

### Secrets vs Environment Variables
Environment variables are easy to configure and useful for general settings, but they are often visible to any process running within the environment, posing a security risk for sensitive data. Docker Secrets are specifically designed to handle sensitive information (like database passwords). They are mounted as read-only files in tmpfs within the container (e.g., `/run/secrets/`), ensuring that the sensitive data is not persisted on disk or exposed as an environment variable.

### Docker Network vs Host Network
Using the host network binds container ports directly to the host's network interfaces, removing network isolation and potentially causing port conflicts. A Docker Network (like the bridge network used in this project) creates an isolated, virtual network connecting only the containers assigned to it. This provides better security, isolates inter-container communication, and allows containers to resolve each other's IPs by container name (DNS).

### Docker Volumes vs Bind Mounts
Bind mounts map an exact path from the host machine to a path in the container. While useful for development, they depend on the host's directory structure and permissions. Docker Volumes are managed entirely by Docker, offering better performance, portability, and safety. Volumes are decoupled from the host's filesystem specifics, making them the preferred choice for persisting database data and website files.