.PHONY: all build up down clean fclean re start logs

DOMAIN=ferda-si.42.fr

all: build up

build:
	docker compose -f srcs/docker-compose.yml build

up:
	@echo "A adicionar $(DOMAIN) ao /etc/hosts..."
	@sudo sh -c 'grep -q "$(DOMAIN)" /etc/hosts || echo "127.0.0.1 $(DOMAIN)" >> /etc/hosts'
	mkdir -p /home/ferda-si/data/mariadb
	mkdir -p /home/ferda-si/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean: down
	docker compose -f srcs/docker-compose.yml down -v
	rm -rf /home/ferda-si/data

fclean: clean
	-docker stop $$(docker ps -qa) 2>/dev/null
	-docker rm $$(docker ps -qa) 2>/dev/null
	-docker rmi -f $$(docker images -qa) 2>/dev/null
	-docker volume rm $$(docker volume ls -q) 2>/dev/null
	-docker network rm $$(docker network ls -q) 2>/dev/null

re: fclean build up

logs:
	docker compose -f srcs/docker-compose.yml logs -f