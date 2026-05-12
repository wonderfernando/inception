# Developer Documentation

## Setting up the Environment from Scratch

1. **Prerequisites**: Ensure you have Docker Engine, Docker Compose plugin, and Make installed on your system (typically a Linux-based environment like Debian or Ubuntu).
2. **Configuration Files**: An `.env` file must be present in the `srcs/` directory. This file defines essential environment variables required during the container build and runtime phases (such as database names, users, and domain settings).
3. **Secrets Setup**: For security, this project relies on Docker Secrets. Before launching the project, you must create the `secrets/` directory at the project root and populate it with the necessary credential files:
   - `secrets/db_password.txt`: Contains the MariaDB user password.
   - `secrets/db_root_password.txt`: Contains the MariaDB root password.

## Building and Launching the Project

The project is orchestrated using a unified `Makefile` at the root directory for consistency and ease of use.

- **Build the images**: Run `make build`. This command targets the `docker compose build` directive, parsing `srcs/docker-compose.yml` to build the custom images from their respective Dockerfiles located in `srcs/requirements/`.
- **Launch the stack**: Run `make up`. The Makefile first ensures that the host data directory (`/home/ferda-si/data`) is created before executing `docker compose up -d` to start the containers in detached mode.
- **Full setup**: Simply running `make` will execute the `build` and `up` targets sequentially, compiling and launching everything from scratch.

## Managing Containers and Volumes

- **Stop containers**: `make down` executes `docker compose down`, gracefully stopping and removing the currently running containers and the `inception_network` without touching the volumes.
- **Restart from scratch**: `make re` performs a complete restart. It executes `make clean`, followed by `make build` and `make up`.
- **Clean environment**: `make clean` stops the containers, removes them, and specifically targets data persistence by running `docker compose down -v` to delete Docker volumes. Additionally, it forcefully removes the `/home/ferda-si/data` directory on the host to ensure a pristine state.

## Data Storage and Persistence

- **Storage Location**: The project utilizes Docker named volumes (`database` and `wordpress_data`) to decouple data from the container lifecycles. Based on the `docker-compose.yml`, these use the local driver. Additionally, the Makefile explicitly manages `/home/ferda-si/data` to simulate a local bind/storage area commonly required by the curriculum structure.
- **Persistence Mechanism**: When containers (like MariaDB or WordPress) are destroyed or stopped, their respective named volumes ensure that the databases and website files remain intact on the host machine. Upon container recreation, Docker re-attaches these volumes, instantly restoring the exact state of the site.
