#!/bin/bash

WEBHOOK_URL="https://discord.com/api/webhooks/1207088738581086270/m6Kfd88N_8jKKlaxxLO7D8hD1aHqUmnUuaxez1V2Y0la86KJJSntyS2AZrVMdUHcoDUj"
LOG_FOLDER="./logs"
mkdir -p "$LOG_FOLDER"  # -p flag ensures it doesn't throw an error if folder already exists
LOG_FILE="$LOG_FOLDER/info.json"

# Función para obtener la dirección IP pública
get_public_ip() {
    curl -s ifconfig.me
}

# Función para obtener información adicional
get_additional_info() {
    hostname=$(hostname)
    sistema_operativo=$(uname -a)
    usuarios_conectados=$(who)
    carga_del_sistema=$(uptime)
    puertos_abiertos=$(netstat -tuln)
    contenedores_docker=$(docker ps)
    espacio_en_disco=$(df -h)

    # Formatear la información como un objeto JSON con sangría para una mejor legibilidad
    printf '{\n  "Direccion_IP_publica": "%s",\n  "Hostname": "%s",\n  "Sistema_Operativo": "%s",\n  "Usuarios_Conectados": "%s",\n  "Carga_del_Sistema": "%s",\n  "Procesos_en_Ejecucion": "%s",\n  "Puertos_Abiertos": "%s",\n  "Contenedores_Docker": "%s",\n  "Espacio_en_Disco": "%s"\n}' \
        "$(get_public_ip)" \
        "$hostname" \
        "$sistema_operativo" \
        "$usuarios_conectados" \
        "$carga_del_sistema" \
        "$procesos" \
        "$puertos_abiertos" \
        "$contenedores_docker" \
        "$espacio_en_disco"
}

# Obtener información adicional
additional_info=$(get_additional_info)

# Guardar la información en un archivo JSON con formato de fecha y hora
echo "$additional_info" > "$LOG_FILE"

# Enviar el archivo JSON al webhook de Discord
curl -F "file=@$LOG_FILE" "$WEBHOOK_URL"
