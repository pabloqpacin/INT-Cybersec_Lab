#!/bin/bash

# Script muy simple para probar SSH
# Objetivo: 172.26.10.12

TARGET="172.26.10.12"

echo "🔍 Probando SSH en $TARGET..."
echo ""

# 1. ¿Puerto 22 abierto?
echo "1. Puerto 22 abierto?"
if nmap -p 22 "$TARGET" | grep -q "22/tcp.*open"; then
    echo "   ✅ SÍ"
else
    echo "   ❌ NO"
fi

# 2. ¿SSH ejecutándose en algún puerto?
echo "2. SSH ejecutándose en algún puerto?"
SSH_RUNNING=$(nmap -p- --open "$TARGET" 2>/dev/null | grep -E "[0-9]+/tcp.*open" | while read line; do
    port=$(echo "$line" | awk '{print $1}' | cut -d'/' -f1)
    if nmap -p "$port" -sV "$TARGET" | grep -q "ssh"; then
        echo "   ✅ SÍ en puerto $port"
        exit 0
    fi
done)

if [ -z "$SSH_RUNNING" ]; then
    echo "   ❌ NO"
else
    echo "$SSH_RUNNING"
fi

# 3. ¿Qué versión de SSH?
echo "3. ¿Qué versión de SSH?"
SSH_VERSION=$(nmap -p 22 -sV "$TARGET" | grep "ssh" | head -1)
if [ -n "$SSH_VERSION" ]; then
    echo "   📋 $SSH_VERSION"
else
    echo "   ❌ No se pudo determinar"
fi

# 4. ¿Acepta contraseña o solo claves?
echo "4. ¿Acepta contraseña o solo claves?"
echo "   💡 Por defecto, SSH moderno acepta ambos métodos"
echo "   🔑 Para verificar exactamente, revisa la configuración del servidor"

echo ""
echo "✅ Test completado!" 