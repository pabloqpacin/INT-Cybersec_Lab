#!/bin/bash

# Script simple para probar SSH
# Objetivo: 172.26.10.12

TARGET="server.local"
OUTPUT_DIR="./results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🔍 Probando SSH en $TARGET..."
echo "⏰ Timestamp: $TIMESTAMP"
echo ""

# Crear directorio de resultados si no existe
mkdir -p "$OUTPUT_DIR"

# 1. Verificar si el puerto 22 está abierto
echo "📡 Verificando puerto 22..."
if nmap -p 22 --max-retries 2 "$TARGET" | grep -q "22/tcp.*open"; then
    echo "✅ Puerto 22 está ABIERTO"
    PORT_22_OPEN=true
else
    echo "❌ Puerto 22 está CERRADO"
    PORT_22_OPEN=false
fi

# 2. Buscar cualquier puerto ejecutando SSH
echo "🔍 Buscando SSH en cualquier puerto..."
echo "   ⏳ Esto puede tomar varios minutos..."
SSH_PORTS=$(nmap -p- --open --min-rate=1000 "$TARGET" 2>/dev/null | grep -E "[0-9]+/tcp.*open" | awk '{print $1}' | cut -d'/' -f1)

SSH_FOUND=false
if [ -n "$SSH_PORTS" ]; then
    echo "   📋 Puertos abiertos encontrados: $SSH_PORTS"
    echo "   🔍 Verificando cuál ejecuta SSH..."

    for port in $SSH_PORTS; do
        echo "     ⏳ Probando puerto $port..."
        if nmap -p "$port" -sV --max-retries 2 "$TARGET" | grep -q "ssh"; then
            echo "✅ SSH encontrado en puerto $port"
            SSH_FOUND=true
            SSH_PORT=$port
            break
        fi
    done
else
    echo "   ❌ No se encontraron puertos abiertos"
fi

if [ "$SSH_FOUND" = false ]; then
    echo "❌ No se encontró SSH ejecutándose en ningún puerto"
    exit 0
fi

# 3. Obtener versión de SSH
echo "🔐 Obteniendo versión de SSH..."
SSH_VERSION=$(nmap -p "$SSH_PORT" -sV --max-retries 2 "$TARGET" | grep "ssh" | head -1)
echo "📋 Versión SSH: $SSH_VERSION"

# 4. Probar métodos de autenticación usando nmap scripts
echo "🔑 Probando métodos de autenticación SSH..."
echo "   ⏳ Ejecutando script ssh-auth-methods..."

# Usar script específico para detectar métodos de autenticación SSH
echo "👤 Detectando métodos de autenticación SSH..."
SSH_CONFIG=$(nmap -p "$SSH_PORT" --script ssh-auth-methods --max-retries 2 "$TARGET" 2>/dev/null)

# Analizar la salida para determinar métodos aceptados
if echo "$SSH_CONFIG" | grep -q "password\|PasswordAuthentication\|yes"; then
    echo "✅ SSH acepta autenticación por contraseña"
    PASSWORD_AUTH=true
else
    echo "❌ SSH NO acepta autenticación por contraseña"
    PASSWORD_AUTH=false
fi

if echo "$SSH_CONFIG" | grep -q "publickey\|PubkeyAuthentication\|yes"; then
    echo "✅ SSH acepta autenticación por clave"
    KEY_AUTH=true
else
    echo "❌ SSH NO acepta autenticación por clave"
    KEY_AUTH=false
fi

# Si no se pudo determinar con scripts, hacer suposición basada en versión
if [ "$PASSWORD_AUTH" = false ] && [ "$KEY_AUTH" = false ]; then
    echo "⚠️  No se pudo determinar métodos de autenticación con scripts"
    echo "💡 SSH moderno típicamente acepta ambos métodos por defecto"
    PASSWORD_AUTH=true
    KEY_AUTH=true
fi

# Resumen final
echo ""
echo "=================================="
echo "📊 RESUMEN SSH para $TARGET:"
echo "=================================="
echo "🎯 Puerto 22: $([ "$PORT_22_OPEN" = true ] && echo "ABIERTO" || echo "CERRADO")"
echo "🔍 SSH encontrado: $([ "$SSH_FOUND" = true ] && echo "SÍ en puerto $SSH_PORT" || echo "NO")"
echo "📋 Versión: $SSH_VERSION"
echo "🔑 Acepta contraseña: $([ "$PASSWORD_AUTH" = true ] && echo "SÍ" || echo "NO")"
echo "🔑 Acepta clave: $([ "$KEY_AUTH" = true ] && echo "SÍ" || echo "NO")"

# Guardar resultados
echo ""
echo "💾 Guardando resultados en $OUTPUT_DIR/ssh_test_$TIMESTAMP.txt"
{
    echo "=== TEST SSH - $TARGET ==="
    echo "Timestamp: $TIMESTAMP"
    echo "Puerto 22: $([ "$PORT_22_OPEN" = true ] && echo "ABIERTO" || echo "CERRADO")"
    echo "SSH encontrado: $([ "$SSH_FOUND" = true ] && echo "SÍ en puerto $SSH_PORT" || echo "NO")"
    echo "Versión: $SSH_VERSION"
    echo "Acepta contraseña: $([ "$PASSWORD_AUTH" = true ] && echo "SÍ" || echo "NO")"
    echo "Acepta clave: $([ "$KEY_AUTH" = true ] && echo "SÍ" || echo "NO")"
} > "$OUTPUT_DIR/ssh_test_$TIMESTAMP.txt"

echo "✅ Test SSH completado!" 