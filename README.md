# Inception

## Overview

This project deploys a complete WordPress stack using Docker Compose. Each service runs in its own container, following the principle of one process per container. The stack consists of:

* **NGINX** — reverse proxy and HTTPS endpoint
* **WordPress** — PHP-FPM application
* **MariaDB** — relational database

The services communicate through an isolated Docker network while exposing only the NGINX container to the host.

## Architecture

NGINX is the only container accessible from outside the Docker network. It listens on **port 443** and terminates TLS connections before forwarding PHP requests to the WordPress container running **PHP-FPM** on **port 9000**.

The WordPress container stores and retrieves application data from the MariaDB container, which listens on the default **port 3306**. MariaDB is not exposed to the host and is reachable only by containers on the internal Docker network.

```
                 HTTPS (443)
                      │
                      ▼
              +---------------+
              |     NGINX     |
              +---------------+
                      │
              FastCGI (9000)
                      │
                      ▼
              +---------------+
              |   WordPress   |
              |    PHP-FPM    |
              +---------------+
                      │
               MariaDB (3306)
                      │
                      ▼
              +---------------+
              |    MariaDB    |
              +---------------+
```

## Container Build Strategy

Each service is built from its own Dockerfile using Docker Compose.

Where appropriate, the images use **multi-stage builds** to separate build-time dependencies from the final runtime image. This reduces image size, decreases the attack surface, and produces cleaner production images by excluding unnecessary tools, package caches, and intermediate artifacts.

The project avoids pre-built application images and instead builds the required services from base Linux distributions, providing full control over installed packages, configuration, and startup behavior.

---

## Configuration

Application configuration is provided through environment variables stored in `srcs/.env`.

> [!NOTE]
> For security reasons, the actual `.env` file is **not** tracked by Git, as it may contain credentials and other machine-specific configuration. Instead, the repository includes `srcs/.env.example`, which serves as a template with placeholder values.

Generate the configuration file by running:

```sh
make init-env
```

This copies `srcs/.env.example` to `srcs/.env`.

Before starting the project, edit `srcs/.env` and replace the placeholder values with your own configuration.

| Variable | Description |
|----------|-------------|
| `DB_ROOT_PASS` | MariaDB root password |
| `DB_HOST` | MariaDB service hostname (normally `mariadb`) |
| `WP_DB_NAME` | WordPress database name |
| `WP_DB_USER` | Database user |
| `WP_DB_PASS` | Database user password |
| `WP_TITLE` | WordPress site title |
| `WP_ADMIN_USER` | WordPress administrator username |
| `WP_ADMIN_PASS` | WordPress administrator password |
| `WP_ADMIN_EMAIL` | WordPress administrator email |
| `WP_USER` | Default WordPress user |
| `WP_USER_PASS` | Default WordPress password |
| `WP_USER_EMAIL` | Default WordPress email |

---

## Installation

### Prerequisites

- Docker
- Docker Compose
- GNU Make

### Clone the repository

```sh
git clone https://github.com/pdol9/Inception.git
cd Inception
```

### Initial setup

Create the directories used as bind mounts and register the local domain:

```sh
make setup
```

This target:

- creates the host directories used for persistent WordPress and MariaDB data (`~/data/website` and `~/data/database`)
- adds `127.0.0.1 <login>.42.fr` to `/etc/hosts` so the site can be accessed using the required domain

### Build and start

```sh
make
```

or

```sh
make all
```

This builds all Docker images and starts the containers.

Visit:

```
<login>.42.fr: if the login in Makefile has been changed
https://pdolinar.42.fr: default
```

## Make targets

| Target | Description |
|---------|-------------|
| `make` / `make all` | Build images and start the stack in detached mode |
| `make start` | Start the services in the foreground |
| `make build` | Build images only |
| `make stop` | Stop the containers |
| `make check` | Display running containers |
| `make clean` | Remove containers, images, networks and volumes |
| `make fclean` | Perform a complete Docker cleanup and remove persistent data |
| `make re` | Rebuild the entire project |
