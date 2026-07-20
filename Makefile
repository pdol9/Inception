# build and run Docker containers

.PHONY: all start build stop check clean re setup dir

# Docker Compose configuration
DOCKER:=-f ./srcs/docker-compose.yml
ENV:=--env-file ./srcs/.env

# Host directories used as bind mounts
WP_VOL:=~/data/website
DB_VOL:=~/data/database

# Suppress errors when a resource does not exist
IGN:= ||:

# Build and start the complete stack
all: dir
	docker compose $(DOCKER) $(ENV) up -d --build

start:
	docker compose $(DOCKER) $(ENV) up

build:
	docker compose $(DOCKER) $(ENV) build

stop:
	docker compose $(DOCKER) down

check:
	docker compose $(DOCKER) ps

# Remove every Docker resource created during development
clean: stop
	docker stop $$(docker ps -qa) $(IGN)
	docker rm $$(docker ps -qa) $(IGN)
	docker rmi -f $$(docker images -qa) $(IGN)
	docker volume rm $$(docker volume ls -q) $(IGN)
	docker network rm $$(docker network ls -q) 2>/dev/null $(IGN)

# Perform a complete reset, including persistent data
fclean: clean
	docker system prune -f -a --volumes $(IGN)
	sudo rm -rf ~/data/

# create real env file to store credentials
init-env:
	cp srcs/.env.example srcs/.env

# Create bind mount directories if they do not exist
dir:
	@if test ! -d $(DB_VOL) || test ! -d "$(WP_VOL)"; then \
		mkdir -p $(DB_VOL) $(WP_VOL); \
	fi

# Register the local domain required by the project
setup: dir
	sudo sh -c 'echo "127.0.0.1 pdolinar.42.fr" >> /etc/hosts'

re: clean all

