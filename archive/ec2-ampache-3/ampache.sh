#!/bin/bash
set -e

DB_ROOT_PASSWORD="rootpassword"
DB_AMPACHE_USER="user"
DB_AMPACHE_PASSWORD="password"
DB_NAME="ampachedb"
AMPACHE_ADMIN_PASSWORD="adminpassword"
AMPACHE_PORT=80
PROJECT_DIR="/home/ubuntu/team-5/ec2-ampache-3/ampache"
MUSIC_DIR="${PROJECT_DIR}/music"

sudo apt-get update && apt-get upgrade -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

mkdir -p ${MUSIC_DIR}
chown -R 1000:1000 "${MUSIC_DIR}"
cd ${PROJECT_DIR}

docker compose down -v || true


cat > docker-compose.yml <<EOF

services:
  mariadb:
    image: mariadb:latest
    container_name: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_AMPACHE_USER}
      MYSQL_PASSWORD: ${DB_AMPACHE_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql

  ampache:
    image: ampache/ampache:latest
    container_name: ampache
    restart: always
    ports:
      - "${AMPACHE_PORT}:80"
    environment:
      - "AMPACHE_ADMIN_PASSWORD=${AMPACHE_ADMIN_PASSWORD}"
      - "DB_USER=${DB_AMPACHE_USER}"
      - "DB_PASSWORD=${DB_AMPACHE_PASSWORD}"
      - "DB_NAME=${DB_NAME}"
      - "DB_HOST=mariadb"
    depends_on:
      - mariadb
    volumes:
      - ./music:/media/music:ro

volumes:
  db_data:
EOF

docker compose up -d

