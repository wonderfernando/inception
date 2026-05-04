# User Documentation

## Services Provided by the Stack
This infrastructure provides a fully functional, containerized web environment consisting of three core services:
- **NGINX**: Acts as the reverse proxy and web server, securely handling HTTPS requests (port 443) and routing them to the correct internal services.
- **WordPress**: A widely used Content Management System (CMS) serving the main website content, utilizing PHP.
- **MariaDB**: A relational database storing all of the WordPress site's persistent data (such as users, posts, and configurations).

## Starting and Stopping the Project
- **Start the project**: Open your terminal, navigate to the project root directory, and run `make`. This command will automatically build the necessary images and launch all containers in the background.
- **Stop the project**: To gracefully stop the running containers without losing persistent data, run `make down`. 
- **Clean the project**: To stop and completely remove all containers, networks, and data volumes, run `make clean`.

## Accessing the Website and Administration Panel
- **Main Website**: Open your web browser and navigate to `https://ferda-si.42.fr`. Note: Since the site uses a self-signed SSL certificate, you may need to explicitly accept the security warning in your browser to proceed.
- **Administration Panel**: Access the WordPress dashboard by navigating to `https://ferda-si.42.fr/wp-admin`.

## Locating and Managing Credentials
Credentials and sensitive information are managed securely using Docker Secrets rather than environment variables.
- The credentials must be physically stored on the host in the `secrets/` directory at the root of the project before building. Specifically:
  - `secrets/db_password.txt`
  - `secrets/db_root_password.txt`
- Inside the containers, these secrets are securely mounted into the `/run/secrets/` directory, preventing them from being exposed in container metadata or environment variables.

## Checking Services Correctly
- **Check container status**: Run `docker compose -f srcs/docker-compose.yml ps` to verify that all containers (`nginx`, `wordpress`, `mariadb`) are listed with the "Up" status.
- **View live logs**: Run `make logs` to view the live output of all services. This is useful for troubleshooting and ensuring no errors are occurring in the background.
