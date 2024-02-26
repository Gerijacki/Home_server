#!/bin/bash

# Función para imprimir mensajes de error y salir
exit_with_error() {
    echo "Error: $1" >&2
    exit 1
}

# Verificar si el script se está ejecutando como root
if [[ $EUID -ne 0 ]]; then
    exit_with_error "Este script debe ejecutarse como root"
fi

# Actualizar e instalar Docker y herramientas relacionadas
apt update && apt upgrade -y || exit_with_error "Error al actualizar e instalar paquetes"
apt install -y docker docker-compose curl samba jq net-tools || exit_with_error "Error al instalar paquetes"

# Instalar CasaOS
curl -fsSL https://get.casaos.io | bash || exit_with_error "Error al instalar CasaOS"

# Instalar Portainer
docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce || exit_with_error "Error al instalar Portainer"

# Configurar directorio para datos persistentes de Nextcloud
mkdir -p /srv/nextcloud/data || exit_with_error "Error al crear el directorio de datos para Nextcloud"

# Configurar contenedor Nextcloud
docker run -d \
  --name nextcloud \
  -p 8080:80 \
  --restart unless-stopped \
  -v /mnt/256GB-DATA/nextcloud/data:/var/www/html/data \
  nextcloud || exit_with_error "Error al configurar el contenedor Nextcloud"

# Configurar contenedor Apache
docker run -d \
  --name apache \
  -p 80:80 \
  --restart unless-stopped \
  httpd:alpine || exit_with_error "Error al configurar el contenedor Apache"

# Configurar contenedor Samba
# docker run -d \
#   --name samba \
#   --restart unless-stopped \
#   -p 445:445 \
#   -v /srv/samba:/mount \
#   -e SMB_USER=admin \
#   -e SMB_PASSWORD=admin \
#   dperson/samba

echo "Configuración completada con éxito."
