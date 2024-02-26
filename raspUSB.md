### Paso 1: Habilitar el módulo USB Gadget en la Raspberry Pi

1. Abre una terminal en tu Raspberry Pi.

2. Edita el archivo de configuración de boot:

    ```bash
    sudo nano /boot/config.txt
    ```

3. Agrega la siguiente línea al final del archivo:

    ```
    dtoverlay=dwc2
    ```

4. Guarda los cambios y cierra el editor.

### Paso 2: Habilitar el módulo del kernel y configurar el archivo de configuración de red

1. Edita el archivo de configuración de módulos:

    ```bash
    sudo nano /etc/modules
    ```

2. Agrega las siguientes líneas al final del archivo:

    ```
    dwc2
    g_ether
    ```

3. Guarda los cambios y cierra el editor.

4. Edita el archivo de configuración de red:

    ```bash
    sudo nano /etc/network/interfaces
    ```

5. Asegúrate de que el archivo contenga las siguientes líneas:

    ```
    auto lo
    iface lo inet loopback

    auto usb0
    iface usb0 inet static
        address 192.168.7.2
        netmask 255.255.255.0
        network 192.168.7.0
        gateway 192.168.7.1
    ```

6. Guarda los cambios y cierra el editor.

### Paso 3: Configuración en la Computadora

1. Conecta tu Raspberry Pi a tu computadora mediante un cable USB.

2. Configura la interfaz de red en tu computadora para usar la dirección IP `192.168.7.1`.

3. Deberías poder acceder a tu Raspberry Pi utilizando la dirección IP `192.168.7.2`.

### Notas Adicionales:

- Puedes utilizar un cliente SSH para acceder a tu Raspberry Pi desde tu computadora después de configurar la conexión USB Ethernet.

- Si estás utilizando Windows, es posible que necesites instalar drivers adicionales para reconocer la Raspberry Pi como un dispositivo USB Ethernet. Estos drivers están disponibles en el sitio web oficial de Raspberry Pi o en la documentación del sistema operativo que estés utilizando en tu Raspberry Pi.

¡Con estos pasos, deberías poder conectar tu Raspberry Pi 2W a tu computadora mediante un cable USB y acceder a ella como si estuvieras conectado a través de Ethernet!

## Windows Linux config

La interfaz de red a configurar en tu computadora es la interfaz de red que se conectará a la Raspberry Pi a través del cable USB. Normalmente, esta interfaz de red se llama `usb0` o `Ethernet` en la mayoría de los sistemas operativos.

Aquí tienes cómo configurar la dirección IP `192.168.7.1` en diferentes sistemas operativos:

### Windows:

1. Haz clic derecho en el icono de red en la barra de tareas y selecciona "Abrir Configuración de Redes e Internet" (en Windows 10/11) o "Abrir Centro de Redes y Recursos Compartidos" (en versiones anteriores de Windows).

2. Haz clic en "Cambiar configuración del adaptador".

3. Encuentra la interfaz de red que corresponde a la conexión USB con la Raspberry Pi (puede aparecer como "Ethernet" o "Conexión de Área Local"). Haz clic derecho sobre ella y selecciona "Propiedades".

4. Selecciona "Protocolo de Internet versión 4 (TCP/IPv4)" y haz clic en "Propiedades".

5. Selecciona "Usar la siguiente dirección IP" y configura la dirección IP como `192.168.7.1`, con una máscara de subred `255.255.255.0`.

6. Haz clic en "Aceptar" para guardar los cambios.

### Linux:

1. Abre una terminal.

2. Ejecuta el siguiente comando para encontrar el nombre de la interfaz de red conectada a la Raspberry Pi:

    ```bash
    ip link
    ```

    Esto mostrará una lista de interfaces de red. Busca la interfaz que corresponde a la conexión USB.

3. Una vez que hayas identificado la interfaz, configura la dirección IP ejecutando el siguiente comando (reemplazando `nombre_de_la_interfaz` con el nombre de tu interfaz):

    ```bash
    sudo ip addr add 192.168.7.1/24 dev nombre_de_la_interfaz
    ```

4. Asegúrate de habilitar el reenvío de paquetes si es necesario:

    ```bash
    sudo sysctl -w net.ipv4.ip_forward=1
    ```

Estos pasos deberían permitirte configurar la interfaz de red de tu computadora para que utilice la dirección IP `192.168.7.1` y establecer una conexión con la Raspberry Pi a través del cable USB.