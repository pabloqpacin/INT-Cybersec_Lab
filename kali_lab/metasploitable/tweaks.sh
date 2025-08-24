#!/usr/bin/env bash

# Script para ajustar el funcionamiento del contenedor metasploitable2

# Resolver warnings de /dev/console...
if [ ! -c /dev/console ]; then
  mknod /dev/console c 5 1
  chmod 600 /dev/console
fi

# Copiar y ejecutar el services.sh
if [[ ! -f /bin/services.sh.bak ]]; then
  cp /bin/services.sh{,.bak}

  # sed -i '/samba/s/^/#/' /bin/services.sh
  # sed -i '/sysklogd/s/^/#/' /bin/services.sh

  /bin/services.sh
fi

# Mantener el contenedor en ejecución
tail -f /dev/null
