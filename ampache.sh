#!/bin/bash
set -e

#My variables
DB_ROOT_PASSWORD="rootpassword"
DB_AMPACHE_USER="user"
DB_AMPACHE_PASSWORD="password"
DB_NAME="ampachedb"
AMPACHE_ADMIN_PASSWORD="adminpassword"
AMPACHE_PORT=80
PROJECT_DIR="/home/ubuntu/ampache"               
MUSIC_DIR="${PROJECT_DIR}/music"
CONFIG_DIR="${PROJECT_DIR}/config"
CONFIG_FILE="${CONFIG_DIR}/ampache.cfg.php"
S3_BUCKET="ampache_bucket_956789"

#Basic system setup and docker
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings 
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install awscli docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

#Directories
mkdir -p ${PROJECT_DIR}
mkdir -p ${MUSIC_DIR}
mkdir -p "${CONFIG_DIR}"
sudo chown -R 1000:1000 "${MUSIC_DIR}"
cd ${PROJECT_DIR}
cd "${PROJECT_DIR}" || mkdir -p "${PROJECT_DIR}" && cd "${PROJECT_DIR}"
aws s3 cp "s3://${S3_BUCKET}/music/" "${MUSIC_DIR}/" --recursive

#Config file for Ampache
cat > "${CONFIG_FILE}" <<EOF
<?php
\$config['database_hostname'] = 'mariadb';
\$config['database_name'] = '${DB_NAME}';
\$config['database_username'] = '${DB_AMPACHE_USER}';
\$config['database_password'] = '${DB_AMPACHE_PASSWORD}';
\$config['database_port'] = '3306';
\$config['database_type'] = 'mariadb';
\$config['web_path'] = '';
\$config['play_type'] = 'stream';
\$config['admin_password'] = '${AMPACHE_ADMIN_PASSWORD}';
\$config['session_length'] = 7200;
\$config['session_name'] = 'ampache_session';
\$config['debug'] = false;
\$config['log_path'] = '/tmp';
\$config['log_level'] = 'E_ALL';
\$config['catalogs'] = ['/media/music'];
define('INSTALL', true);
EOF


chmod 644 "${CONFIG_FILE}"


#Docker Compose
sudo docker compose down -v || true


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
      - ./config/ampache.cfg.php:/var/www/html/config/ampache.cfg.php:ro


volumes:
  db_data:
EOF

sudo docker compose up -d
