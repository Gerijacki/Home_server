#!/bin/bash

# Función para imprimir en rojo
print_red() {
    echo -e "\e[31m$1\e[0m"
}

# Función para imprimir mensaje de error y salir
exit_with_error() {
    print_red "Error: $1"
    exit 1
}

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
    exit_with_error "Este script debe ejecutarse como root"
fi

# Obtener información del sistema
HOSTNAME=$(hostname) || exit_with_error "No se pudo obtener el nombre del host"
KERNEL=$(uname -r)
UPTIME=$(uptime -p)
MEMORY=$(free -h | awk '/^Mem:/{print $2}') || exit_with_error "No se pudo obtener la información de memoria"
DISK=$(df -h / | awk 'NR==2{print $4}') || exit_with_error "No se pudo obtener la información del disco"
USERS=$(who -q | grep -oP '\d+')
IP=$(hostname -I | awk '{print $1}') || exit_with_error "No se pudo obtener la dirección IP"

# Limpiar el archivo de mensaje del día
truncate -s 0 /etc/motd || exit_with_error "No se pudo limpiar el archivo de mensaje del día"

# Escribir el mensaje del día
print_red "Bienvenido a $HOSTNAME"
print_red "Sistema Operativo: $(lsb_release -ds)"
print_red "Kernel: $KERNEL"
print_red "Usuarios Conectados: $USERS"
print_red "Uptime: $UPTIME"
print_red "Memoria Disponible: $MEMORY"
print_red "Espacio en Disco Disponible: $DISK"
print_red "Dirección IP: $IP"
