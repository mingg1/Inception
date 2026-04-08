# Inception

👩🏻‍💻 This project has been created as part of the 42 curriculum by **michoi**.

🐳 A system administration project that deepens your understanding of **Docker** by building a web infrastructure from scratch entirely inside a virtual machine.

The objective of the project is to containerize a WordPress stack made of three interdependent services. Each service is running in its own dedicated Docker container, all orchestrated by **Docker Compose** (in ``docker-compose.yml`` file). No pre-built images from Docker Hub are used. Every image is built from a custom **Dockerfile** based on the stable version of **Alpine Linux**.

## Project description

### Architecture overview
  
The infrastructure is composed of:

| Service | Role |
|---------|------|
| **NGINX** | Reverse proxy and sole entry point (port 443, TLSv1.2/1.3 only) |
| **WordPress + php-fpm** | Application server (no NGINX inside) |
| **MariaDB** | Database backend (no NGINX inside) |

Two Docker volumes persist data across restarts:
- WordPress database files
- WordPress website files

All services communicate through a custom Docker network. NGINX is the **only** container exposed to the outside world.

### Design choices

#### Virtual machines vs Docker

Virtual Machines emulate a full operating system with dedicated kernel, hardware abstraction, and hypervisor overhead. They are heavy (GBs of disk, minutes to start) but provide strong isolation.

Docker containers share the host kernel and package only the application and its dependencies. They are lightweight (MBs), start in seconds, and are ideal for deploying isolated, reproducible services — which is why they suit this project. However, they offer a lower level of isolation than VMs, which is why this project itself runs *inside* a virtual machine.

#### Secrets vs Environment Variables

Environment variables are convenient but can be exposed through process listings, log output, or Docker inspect commands. For sensitive data (passwords, API keys), **Docker secrets** are the recommended approach: they store values in an in-memory tmpfs, accessible only inside the container at `/run/secrets/`, and never appear in image layers or environment dumps.

This project uses a `.env` file for non-sensitive configuration (domain name, usernames) and Docker secrets (via files in `secrets/`) for passwords and credentials.

#### Docker Network vs Host Network

Using `network: host` removes all network isolation — the container shares the host's network stack directly, which defeats the purpose of containerization and exposes all ports. This is **forbidden** in this project.

A custom **Docker bridge network** is used instead, allowing containers to communicate with each other by service name (DNS resolution) while remaining isolated from the host. NGINX is the only container bound to a host port (443).

#### Docker Volumes vs Bind Mounts

Bind mounts link a host directory directly into the container. They are simple but tightly coupled to the host's filesystem layout.

Docker volumes are managed by Docker itself, stored under `/var/lib/docker/volumes/`, and are more portable and production-friendly. This project uses named volumes (stored at `/home/<login>/data/` on the host via Docker configuration) for both the database and WordPress files, ensuring data persists across container restarts.

## Instructions

### Prerequisites

- A Linux virtual machine (e.g., Debian or Alpine)
- Docker and Docker Compose installed
- `make` installed
- Your login and domain configured in `.env` and `/etc/hosts`

### Setup

1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd <repo-name>
   ```

2. Configure environment variables by editing `srcs/.env`:
   ```env
   DOMAIN_NAME=<your_login>.42.fr
   WORDPRESS_DATABASE_USER=<your_db_user>
   WORDPRESS_DATABASE_NAME=wordpress
   
   # ... (see USER_DOC.md for full list)
   ```

3. Add your domain to `/etc/hosts` on the host machine:
   ```
   127.0.0.1   <your_login>.42.fr
   ```

### Build and Run

```bash
make        # Builds all Docker images and starts the stack
```

### Stop

```bash
make down   # Stops and removes containers
```

### Clean Up

```bash
make clean  # Stops containers and removes volumes
make fclean # Full cleanup including built images
```

### Access

Once running, open your browser and navigate to:
```
https://<your_login>.42.fr
```

> Note: Since TLS uses a self-signed certificate, your browser will show a warning. Accept it to proceed.

## Resources

### Docker & Infrastructure

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [Understanding PID 1 in containers](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)

### Services

- [NGINX documentation](https://nginx.org/en/docs/)
- [Configuring TLS in NGINX](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WordPress CLI (wp-cli)](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [php-fpm configuration](https://www.php.net/manual/en/install.fpm.configuration.php)

### AI Usage

AI tools (ChatGPT, Claude) were used during this project for the following tasks:

- **Understanding concepts**: Clarifying the differences between Docker volumes and bind mounts, Nginx and Wordpress configuration options, and MariaDB initialization flows.
- **Debugging assistance**: Helping interpret Docker error messages and suggest causes for container restart loops.
- **Documentation drafting**: Assisting in drafting initial versions of this README and the accompanying documentation files.

> All AI-generated content was reviewed, tested, and validated before inclusion. No code was copied without full understanding of its behavior.