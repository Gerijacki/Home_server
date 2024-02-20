#!/bin/bash

# Instalar Docker y herramientas relacionadas
apt update
apt upgrade -y
apt install -y docker docker-compose curl samba jq net-tools
curl -fsSL https://get.casaos.io | bash


# Instalar Portainer
docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce

# Configurar directorio para datos persistentes
mkdir -p /srv/nextcloud/data

# Configurar contenedor Nextcloud
docker run -d \
  --name nextcloud \
  -p 8080:80 \
  --restart unless-stopped \
  -v /mnt/256GB-DATA/nextcloud/data:/var/www/html/data \
  nextcloud

# Configurar contenedor Apache
docker run -d \
  --name apache \
  -p 80:80 \
  --restart unless-stopped \
  httpd:alpine

# Configurar contenedor Samba
# docker run -d \
#   --name samba \
#   --restart unless-stopped \
#   -p 445:445 \
#   -v /srv/samba:/mount \
#   -e SMB_USER=admin \
#   -e SMB_PASSWORD=admin \
#   dperson/samba



