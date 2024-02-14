#!/bin/bash

# Verificar si el script se está ejecutando como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root" 
   exit 1
fi

# Instalar OpenVPN y Easy-RSA
apt update
apt install -y openvpn easy-rsa

# Crear directorio para las claves
mkdir -p /etc/openvpn/easy-rsa
cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa

# Configurar el entorno
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa gen-crl

# Generar claves del servidor
./easyrsa gen-req servidor nopass
./easyrsa sign-req server servidor

# Crear claves de cliente
./easyrsa gen-req cliente1 nopass
./easyrsa sign-req client cliente1

# Copiar las claves y certificados al directorio /etc/openvpn
cp pki/ca.crt pki/private/servidor.key pki/issued/servidor.crt /etc/openvpn/
cp pki/dh.pem pki/crl.pem /etc/openvpn/
mkdir -p /etc/openvpn/ccd

# Configurar el servidor OpenVPN
cat << EOF > /etc/openvpn/server.conf
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
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

# Configurar el firewall
apt install -y iptables-persistent
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# Iniciar y habilitar el servicio OpenVPN
systemctl start openvpn@server
systemctl enable openvpn@server

echo "El servidor OpenVPN ha sido configurado correctamente."
