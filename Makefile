.PHONY: all build up down clean fclean re start logs

all: build up

build:
	docker compose -f srcs/docker-compose.yml build

up:
	mkdir -p /home/ferda-si/data
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean: down
	docker compose -f srcs/docker-compose.yml down -v
	rm -rf /home/ferda-si/data

fclean: clean
	docker stop $$(docker ps -qa); docker rm $$(docker ps -qa); docker rmi -f $$(docker images -qa); docker volume rm $$(docker volume ls -q); docker network rm $$(docker network ls -q) 2>/dev/null

re: fclean build up

 

logs:
	docker compose -f srcs/docker-compose.yml logs -f