#!/bin/bash

# Función para mostrar mensajes de error y salir
function mostrar_error() {
    echo "Error: $1"
    exit 1
}

# Verificar si el script se está ejecutando como root
if [[ $EUID -ne 0 ]]; then
   mostrar_error "Este script debe ejecutarse como root" 
fi

# Solicitar la contraseña para los certificados
read -s -p "Introduce una contraseña para los certificados: " cert_password
echo ""

# Instalar OpenVPN y Easy-RSA
apt update || mostrar_error "No se pudo actualizar el sistema"
apt install -y openvpn easy-rsa || mostrar_error "No se pudo instalar OpenVPN y Easy-RSA"

# Crear directorio para las claves
keys_dir="/etc/openvpn/easy-rsa"
mkdir -p "$keys_dir" || mostrar_error "No se pudo crear el directorio para las claves"
cp -r /usr/share/easy-rsa/* "$keys_dir" || mostrar_error "No se pudo copiar los archivos de Easy-RSA"
cd "$keys_dir" || mostrar_error "No se pudo cambiar al directorio de Easy-RSA"

# Configurar el entorno
./easyrsa init-pki || mostrar_error "No se pudo inicializar el PKI"
echo "$cert_password" | ./easyrsa build-ca || mostrar_error "No se pudo generar el certificado de CA"
echo "$cert_password" | ./easyrsa gen-dh || mostrar_error "No se pudo generar los parámetros de DH"
./easyrsa gen-crl || mostrar_error "No se pudo generar la CRL"

# Generar claves del servidor
echo "$cert_password" | ./easyrsa gen-req servidor || mostrar_error "No se pudo generar la solicitud de certificado del servidor"
echo yes | echo "$cert_password" | ./easyrsa sign-req server servidor || mostrar_error "No se pudo firmar la solicitud de certificado del servidor"

# Crear claves de cliente
echo "$cert_password" | ./easyrsa gen-req cliente1 || mostrar_error "No se pudo generar la solicitud de certificado del cliente"
echo yes | echo "$cert_password" | ./easyrsa sign-req client cliente1 || mostrar_error "No se pudo firmar la solicitud de certificado del cliente"

# Copiar las claves y certificados al directorio /etc/openvpn
cert_dir="/etc/openvpn"
cp pki/ca.crt pki/private/servidor.key pki/issued/servidor.crt "$cert_dir" || mostrar_error "No se pudieron copiar las claves y certificados"
cp pki/dh.pem pki/crl.pem "$cert_dir" || mostrar_error "No se pudieron copiar los parámetros de DH y la CRL"
mkdir -p "$cert_dir/ccd" || mostrar_error "No se pudo crear el directorio de ccd"

# Configurar el servidor OpenVPN
cat << EOF > "$cert_dir/server.conf" || mostrar_error "No se pudo crear el archivo de configuración del servidor"
# Configuración del servidor OpenVPN
port 1194
proto udp
dev tun
ca ca.crt
cert servidor.crt
key servidor.key
dh dh.pem
crl-verify crl.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
client-config-dir ccd
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# Habilitar el reenvío de paquetes
sysctl -w net.ipv4.ip_forward=1 || mostrar_error "No se pudo habilitar el reenvío de paquetes"

# Configurar el firewall
apt install -y iptables-persistent || mostrar_error "No se pudo instalar iptables-persistent"
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE || mostrar_error "No se pudo configurar el firewall"
iptables-save > /etc/iptables/rules.v4 || mostrar_error "No se pudieron guardar las reglas del firewall"

# Iniciar y habilitar el servicio OpenVPN
systemctl start openvpn@server || mostrar_error "No se pudo iniciar el servicio OpenVPN"
systemctl enable openvpn@server || mostrar_error "No se pudo habilitar el servicio OpenVPN"

echo "El servidor OpenVPN ha sido configurado correctamente."
