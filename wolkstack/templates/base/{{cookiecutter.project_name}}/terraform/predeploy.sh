#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m' # No Color
docker login --username {{ cookiecutter.docker_hub_username }} --password $TF_VAR_docker_hub_password

echo -e "${GREEN}WOLKSTACK: Building dockerfiles...${NC}"
docker build ../apps/frontend -t {{ cookiecutter.docker_hub_username }}/wolkstack:frontend -f ../apps/frontend/Dockerfile
docker build ../apps/backend-t {{ cookiecutter.docker_hub_username }}/wolkstack:backend -f  ../apps/backend/Dockerfile
docker build ../apps/database -t {{ cookiecutter.docker_hub_username }}/wolkstack:database -f  ../apps/database/Dockerfile

echo -e "${GREEN}WOLKSTACK: Tagging dockerfiles...${NC}"
docker tag {{ cookiecutter.docker_hub_username }}/wolkstack:frontend {{ cookiecutter.docker_hub_username }}/wolkstack:frontend
docker tag {{ cookiecutter.docker_hub_username }}/wolkstack:backend {{ cookiecutter.docker_hub_username }}/wolkstack:backend
docker tag {{ cookiecutter.docker_hub_username }}/wolkstack:database {{ cookiecutter.docker_hub_username }}/wolkstack:database

echo -e "${green}WOLKSTACK: Pushing containers...${NC}"
docker push {{ cookiecutter.docker_hub_username }}/wolkstack:frontend
docker push {{ cookiecutter.docker_hub_username }}/wolkstack:backend
docker push {{ cookiecutter.docker_hub_username }}/wolkstack:database

echo -e "${green}WOLKSTACK: SUCCESS - App container pushed!...${NC}"