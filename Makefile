NAME := Inception
COMPOSE_FILE := ./srcs/docker-compose.yml
VOLUME_DIR := $(HOME)/data
MARIADB_DATA_DIR := $(VOLUME_DIR)/mariadb
WORDPRESS_DATA_DIR := $(VOLUME_DIR)/wordpress

all: volume-setup build up

volume-setup:
	if [ ! -d $(MARIADB_DATA_DIR) ]; then \
		@echo "⚙️ Creating volume for mariadb"
		@mkdir -p $(MARIADB_DATA_DIR)
	fi
	if [ ! -d $(WORDPRESS_DATA_DIR) ]; then \
		@echo "⚙️ Creating volume for wordpress"
		@mkdir -p $(WORDPRESS_DATA_DIR)
	fi
	@echo "✅ Local volume directories are created at $(VOLUME_DIR)"

build:
	docker compose -f $(COMPOSE_FILE) build

# build, (re)create, start, attach to containers for a service
up:
	docker compose -f $(COMPOSE_FILE) up -d
	@echo "Inception: Containers are up and running now :D"

down:
	docker compose -f $(COMPOSE_FILE) down
	@echo "Containers and network have been removed"

stop:
	docker compose -f $(COMPOSE_FILE) stop
	@echo "Containers stopped running"

start:
	docker compose -f $(COMPOSE_FILE) start
	@echo "Containers have started running"

clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all --remove-orphans
	@echo "Container resources have been cleaned up"

#remove build cache
clean-cache:
	docker builder prune -af
	@echo "Docker build cache has been cleared"

fclean: clean
	docker compose -f $(COMPOSE_FILE) down -v
	sudo rm -rf $(VOLUME_DIR)
	@echo "All local data and volumes are successfully removed!"

re: fclean all

.PHONY: all volume-setup build up down stop start clean clean-cache fclean re