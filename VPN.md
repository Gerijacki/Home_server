# Configuración del Cliente de VPN

Este documento proporciona instrucciones paso a paso para configurar el cliente de VPN en sistemas Linux y Windows para conectarse a un servidor OpenVPN.

## Configuración en Linux

### 1. Instalación del Cliente OpenVPN

- Asegúrate de tener el cliente OpenVPN instalado en tu sistema. Si no lo tienes instalado, puedes hacerlo ejecutando el siguiente comando en la terminal:

    ```bash
    sudo apt update
    sudo apt install -y openvpn
    ```

### 2. Descarga de los Archivos de Configuración

- Descarga los archivos de configuración del servidor VPN. Estos archivos generalmente incluyen el certificado de CA, el certificado del cliente, la clave del cliente y el archivo de configuración del cliente.

### 3. Configuración del Cliente

- Coloca los archivos de configuración descargados en un directorio conveniente, por ejemplo, `/etc/openvpn/client/`.

- Abre una terminal y navega hasta el directorio que contiene los archivos de configuración del cliente.

- Conéctate al servidor VPN ejecutando el siguiente comando:

    ```bash
    sudo openvpn nombre_del_archivo_de_configuracion.conf
    ```

## Configuración en Windows

### 1. Instalación del Cliente OpenVPN

- Descarga e instala el cliente OpenVPN desde el [sitio oficial](https://openvpn.net/community-downloads/).

### 2. Descarga de los Archivos de Configuración

- Descarga los archivos de configuración del servidor VPN en tu computadora.

### 3. Configuración del Cliente

- Abre el cliente OpenVPN.

- Haz clic en `Importar perfil` y selecciona el archivo de configuración del cliente descargado.

- Haz clic en `Conectar` para establecer la conexión VPN.
