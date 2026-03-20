.PHONY: help build run stop clean scan push logs

help:
	@echo "Docker Production - Available Commands:"
	@echo ""
	@echo "  make build     - Build Docker image"
	@echo "  make run       - Start all services"
	@echo "  make stop      - Stop all services"
	@echo "  make clean     - Remove containers, volumes, images"
	@echo "  make scan      - Run Trivy security scan"
	@echo "  make push      - Push to GHCR"
	@echo "  make logs      - Follow logs"

build:
	docker build -t docker-production-web:latest .

run:
	docker compose up --build -d

stop:
	docker compose down

clean:
	docker compose down -v --rmi all

scan:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image docker-production-web:latest

push:
	@read -p "Enter GitHub username: " user; \
	docker tag docker-production-web:latest ghcr.io/$$user/docker-production-web:latest; \
	docker push ghcr.io/$$user/docker-production-web:latest

logs:
	docker compose logs -f

.DEFAULT_GOAL := help
