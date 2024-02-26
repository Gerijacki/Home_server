#!/bin/bash

# Variables
WEBHOOK_URL=""
LOG_FOLDER="./logs"
LOG_FILE="$LOG_FOLDER/info_$(date +'%Y-%m-%d_%H-%M-%S').json"

# Crear directorio de logs si no existe
mkdir -p "$LOG_FOLDER" || { echo "Error: No se pudo crear el directorio de logs."; exit 1; }

# Función para obtener la dirección IP pública
get_public_ip() {
    local ip
    ip=$(curl -s ifconfig.me)
    if [ -z "$ip" ]; then
        echo "Error: No se pudo obtener la dirección IP pública."
        exit 1
    fi
    echo "$ip"
}

# Función para obtener información adicional del sistema
get_additional_info() {
    local hostname sistema_operativo usuarios_conectados carga_del_sistema puertos_abiertos contenedores_docker espacio_en_disco
    hostname=$(hostname)
    sistema_operativo=$(uname -a)
    usuarios_conectados=$(who)
    carga_del_sistema=$(uptime)
    puertos_abiertos=$(netstat -tuln)
    contenedores_docker=$(docker ps)
    espacio_en_disco=$(df -h)

    # Formatear la información como un objeto JSON
    cat << EOF
{
  "Direccion_IP_publica": "$(get_public_ip)",
  "Hostname": "$hostname",
  "Sistema_Operativo": "$sistema_operativo",
  "Usuarios_Conectados": "$usuarios_conectados",
  "Carga_del_Sistema": "$carga_del_sistema",
  "Puertos_Abiertos": "$puertos_abiertos",
  "Contenedores_Docker": "$contenedores_docker",
  "Espacio_en_Disco": "$espacio_en_disco"
}
EOF
}

# Obtener información adicional
additional_info=$(get_additional_info)

# Guardar la información en un archivo JSON con formato de fecha y hora
echo "$additional_info" > "$LOG_FILE" || { echo "Error: No se pudo guardar la información en el archivo de logs."; exit 1; }

# Enviar el archivo JSON al webhook de Discord
curl -F "file=@$LOG_FILE" "$WEBHOOK_URL" || { echo "Error: No se pudo enviar la información al webhook de Discord."; exit 1; }

echo "La información se ha enviado correctamente al webhook de Discord."
