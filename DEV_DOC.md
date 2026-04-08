# Developer Documentation for Inception

This document describes how to set up, build, and manage the Inception project from a developer's perspective.

---

## Prerequisites

Before starting, make sure the following are installed on your virtual machine:

- **Docker** (≥ 20.x) — [Install guide](https://docs.docker.com/engine/install/)
- **Docker Compose** (v2 plugin or standalone) — [Install guide](https://docs.docker.com/compose/install/)
- **Make**
- **Git**

Verify your setup:

```bash
docker --version
docker compose version
make --version
```

---

## Project Structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── .env                   # all environment variables used in the project
    ├── .gitignore
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/mariadb_config.cnf          # MariaDB config
        │   └── tools/init.sh                    # DB init scripts
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/nginx.conf                  # site config
        │   └── tools/init.sh                    # entrypoint scripts
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/www.conf                    # php-fpm config
        │   └── tools/init.sh                    # wp-cli setup scripts
```

---

## Environment Setup

### 1. Configure environment variables

All sensitive credentials should be stored and managed in the `./srcs/.env` file and must **never** be committed to Git.
Create `srcs/.env` file with your own values. Except for `DOMAIN_NAME`, you can freely change values of variables.

```env
# Domain name with my login
DOMAIN_NAME=michoi.42.fr

# Wordpress
WORDPRESS_TITLE=michoi_inception
WORDPRESS_DATABASE_NAME=wordpress_db
WORDPRESS_DATABASE_PASSWORD=4242

WORDPRESS_DATABASE_USER=wordpress_user
WORDPRESS_DATABASE_USER_PASSWORD=4242

# Wordpress admin
WORDPRESS_ADMIN=minji
WORDPRESS_ADMIN_PASSWORD=4242
WORDPRESS_ADMIN_EMAIL=michoi@student.hive.fi

# Wordpress user
WORDPRESS_USER=michoi
WORDPRESS_USER_PASSWORD=4242
WORDPRESS_USER_EMAIL=wp-user@hive.fi

# MariaDB
MYSQL_ROOT_PASSWORD=4242
```

> 🔒 Never share these files or commit them to a public repository!
> Make sure `.env` is listed in your `.gitignore`.

### 2. Configure the domain

Add the domain to `/etc/hosts` on your host machine:

```bash
echo "127.0.0.1   michoi.42.fr" | sudo tee -a /etc/hosts
```

### 3. Create the data directories for Docker volumes

Docker volumes are mapped to the host filesystem. Create the mount points:

```bash
mkdir -p ~/data/wordpress
mkdir -p ~/data/mariadb
```

---

## Building and Launching the Project

### Build and start all services

```bash
make
```

This runs `docker compose up --build -d` under the hood. It builds all images from their respective `Dockerfile`s and starts the containers in detached mode.

### Rebuild a single service

```bash
docker compose -f srcs/docker-compose.yml build <service>
docker compose -f srcs/docker-compose.yml up -d <service>
```

---

## Useful Docker Commands

### Container management

```bash
docker ps                          # List running containers
docker ps -a                       # List all containers (including stopped)
docker restart <container_name>    # Restart a container
docker stop <container_name>       # Stop a container
docker rm <container_name>         # Remove a stopped container
```

### Logs

```bash
docker logs <container_name>          # View all logs
docker logs -f <container_name>       # Follow logs in real time
docker logs --tail 50 <container_name>  # Last 50 lines
```

### Exec into a running container

```bash
docker exec -it <container_name> sh    # Open a shell (Alpine)
docker exec -it <container_name> bash  # Open bash (Debian)
```

### Docker Compose shortcuts (from `srcs/`)

```bash
docker compose -f srcs/docker-compose.yml ps         # Status of all services
docker compose -f srcs/docker-compose.yml down        # Stop and remove containers
docker compose -f srcs/docker-compose.yml down -v     # Also remove volumes
```

---

## Makefile Targets

| Target        | Description                               |
| ------------- | ----------------------------------------- |
| `make`        | Build images and start the stack          |
| `make down`   | Stop and remove containers                |
| `make clean`  | Stop containers and remove volumes        |
| `make fclean` | Full cleanup: containers, volumes, images |
| `make re`     | `fclean` + `make` (full rebuild)          |

---

## Data Storage and Persistence

All persistent data is stored in Docker named volumes, which are mapped to the host at:

```
/home/<your_login>/data/wordpress/   → WordPress site files
/home/<your_login>/data/mariadb/     → MariaDB database files
```

Data survives container restarts and `make down`. It is only removed when you explicitly run `make clean` or `docker compose down -v`.

To inspect a volume:

```bash
docker volume inspect <volume_name>
```

---

## TLS / NGINX Configuration

NGINX is the sole entry point for the infrastructure, listening on port **443** only, using **TLSv1.2 or TLSv1.3**.

A self-signed TLS certificate is generated during the image build (or at container startup). It is stored inside the NGINX container and is not shared with other containers.

To regenerate the certificate manually (for debugging):

```bash
docker exec -it nginx openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx.key \
  -out /etc/ssl/certs/nginx.crt \
  -subj "/CN=<your_login>.42.fr"
```

---

## WordPress Database Users

The MariaDB service is initialized with:

- A **root** account (password from `secrets/db_root_password.txt`)
- A **regular user** (from `MYSQL_USER` in `.env`, password from `secrets/db_password.txt`) with access to the WordPress database

WordPress is configured with:

- An **administrator** account (username must not contain `admin` or `administrator`)
- A **regular user** account

Both are created automatically via wp-cli during the WordPress container's first startup.

---

## Common Issues

| Issue                         | Likely Cause                  | Fix                                                         |
| ----------------------------- | ----------------------------- | ----------------------------------------------------------- |
| `Error: No such service`      | Typo in service name          | Check `docker-compose.yml` for exact names                  |
| MariaDB fails to start        | Missing or empty secret file  | Verify `secrets/db_password.txt` exists and is non-empty    |
| WordPress can't connect to DB | MariaDB not ready yet         | The entrypoint script should handle retries; check logs     |
| NGINX returns 502 Bad Gateway | WordPress/php-fpm not running | Check `docker logs wordpress`                               |
| Volume data not persisting    | Wrong mount path              | Check `docker-compose.yml` volume definitions and host path |
| Permission denied on data dir | Wrong owner on `~/data/`      | Run `sudo chown -R $USER:$USER ~/data/`                     |
