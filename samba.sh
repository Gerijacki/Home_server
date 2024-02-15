#!/bin/bash
apt install samba
# Definir variables
CARPETA_COMPARTIDA="/shared"
USUARIO_SAMBA="jacki"
CONTRASENA_SAMBA="1234"

# Crear la carpeta
mkdir -p "$CARPETA_COMPARTIDA"

# Cambiar el propietario de la carpeta al usuario de Samba
chown "$USUARIO_SAMBA:$USUARIO_SAMBA" "$CARPETA_COMPARTIDA"

# Dar permisos de lectura y escritura solo al propietario
chmod 700 "$CARPETA_COMPARTIDA"

# Configurar Samba para compartir la carpeta
echo "
[$USUARIO_SAMBA]
   path = $CARPETA_COMPARTIDA
   valid users = $USUARIO_SAMBA
   read only = no
   browsable = yes
   guest ok = no
" >> /etc/samba/smb.conf

# Establecer la contraseña de Samba para el usuario
echo -ne "$CONTRASEÑA_SAMBA\n$CONTRASENA_SAMBA\n" | smbpasswd -a -s "$USUARIO_SAMBA"

# Reiniciar el servicio Samba
systemctl restart smbd

echo "La carpeta ha sido creada y compartida con Samba para el usuario $USUARIO_SAMBA."
