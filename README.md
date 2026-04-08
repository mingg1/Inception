# Inception

👩🏻‍💻 This project has been created as part of the 42 curriculum by **michoi**.

🐳 A system administration project that deepens your understanding of **Docker** by building a web infrastructure from scratch entirely inside a virtual machine.

The objective of the project is to containerize a WordPress stack made of three interdependent services. Each service is running in its own dedicated Docker container, all orchestrated by **Docker Compose** (in ``docker-compose.yml`` file). No pre-built images from Docker Hub are used. Every image is built from a custom **Dockerfile** based on the stable version of **Alpine Linux**.

## Architecture overview
  
The infrastructure is composed of:
 ## Architecture overview
  
The infrastructure is composed of:

Service

Role

**NGINX**

Reverse proxy and sole entry point (port 443, TLSv1.2/1.3 only)

**WordPress + php-fpm**

Application server (no NGINX inside)

**MariaDB**

Database backend (no NGINX inside)
  ### Virtual machines vs Docker
  ### Secrets vs Environment Variables

### Docker Network vs Host Network

### Docker Volumes vs Bind Mounts

  ## Instructions
  ## Resources