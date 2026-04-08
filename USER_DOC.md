# User Documentation for Inception

This document explains how to use, start, stop, and monitor the Inception infrastructure as an end user or administrator.

## Provided services

The Inception stack runs three services:

| Service       | Description                                                                                                              |
| ------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **MariaDB**   | Database that powers WordPress to store blog data. It is running in the background, not directly accessible from outside |
| **WordPress** | Content management system running on **php-fpm** with two user accounts (an admin and a regular user)                    |
| **Nginx**     | Web server and reverse proxy that handles all incoming HTTPS traffic and forwards it to WordPress (TLS 1.2/1.3)          |

All services run as Docker containers on the same virtual machine. They communicate internally through a private Docker network.

---

## Starting and Stopping the Project

⚠️ All commands are run from the **root** of the repository

### Start the stack

```bash
make
```

builds all the Docker images (if not already built) and starts all containers. The first run may take a few minutes.

### Stop the stack

```bash
make stop
```

This stops the running containers. Your data (database and WordPress files) is preserved in the Docker volumes.

### Down the stack

```bash
make down
```

This removes the running containers and network. Your data (database and WordPress files) is preserved in the Docker volumes.

### Full cleanup

```bash
make clean   # Stops containers
make fclean  # Also removes built images and removes volumes (data will be lost)
```

> ⚠️ Running `make fclean` will delete all stored data (posts, users, settings). Use only when you want a fresh start.

---

## Accessing the Website

⚠️ Before any access, ensure the line **`127.0.0.1 michoi.42.fr`** is added to your `/etc/hosts` file.

Once the stack is running, open your browser and go to:

```
https://michoi.42.fr
```

> Your browser may display a security warning because the TLS certificate is self-signed. Click **Advanced** → **Proceed** (or equivalent) to continue.

### WordPress Administration Panel

To access the WordPress admin dashboard:

```
https://michoi.42.fr/wp-admin
```

Log in using the administrator credentials stored in the `./srcs/.env` file (see below).

---

## Credentials and Where to Find Them

All sensitive credentials should be stored and managed in the `./srcs/.env` file. These files are **not** committed to Git. So you should create your own env file.

- **Path**: `./srcs/.env`
- **Includes**: Database root/user info/passwords and WordPress admin/user info/passwords

In your env file, set following environment variables. Except for `DOMAIN_NAME`, you can freely change values of variables.

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
Make sure `.env` is listed in your `.gitignore`.

---

## Checking That Services Are Running

### View running containers

```bash
docker ps
```

You should see three containers listed: `nginx`, `wordpress`, and `mariadb`. Their status should be `Up`.

### View logs for a specific service

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Restart a specific service

```bash
docker restart <service_name>
```

Containers are configured to restart automatically if they crash.

### Check volumes (persistent data)

```bash
docker volume ls
```

You should see two volumes: one for the WordPress database and one for the WordPress website files. Their data is stored on the host at `/home/<your_login>/data/`.

---

## Troubleshooting

| Problem                            | Possible Cause                     | Solution                                      |
| ---------------------------------- | ---------------------------------- | --------------------------------------------- |
| Browser shows "connection refused" | Stack not running                  | Run `make` from the project root              |
| Browser shows TLS error            | Self-signed certificate            | Accept the browser warning manually           |
| WordPress shows database error     | MariaDB not yet ready              | Wait a few seconds and refresh                |
| Domain not resolving               | `/etc/hosts` not configured        | Add `127.0.0.1 <login>.42.fr` to `/etc/hosts` |
| Container keeps restarting         | Misconfiguration or missing secret | Check logs with `docker logs <service>`       |
