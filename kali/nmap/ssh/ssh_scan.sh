#!/bin/bash

# Script simple para escanear vulnerabilidades SSH
# Objetivo: 172.26.10.12

TARGET="server.local"
OUTPUT_DIR="./results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔍 Iniciando escaneo SSH de $TARGET..."
echo "⏰ Timestamp: $TIMESTAMP"
echo ""

# Crear directorio de resultados si no existe
mkdir -p "$OUTPUT_DIR"

# 1. Escaneo básico de puertos SSH
echo -e "\n📡 Escaneo básico de puertos SSH..."
nmap -p 22 -sV -sC "$TARGET" -oN "$OUTPUT_DIR/ssh_basic_$TIMESTAMP.txt"

# 2. Escaneo completo SSH + OS + scripts de vulnerabilidades
echo -e "\n🔐 Escaneo completo SSH + OS + scripts..."
nmap -p 22 -sV -sC -A --script=ssh* "$TARGET" -oN "$OUTPUT_DIR/ssh_complete_$TIMESTAMP.txt"

# 3. Escaneo de fuerza bruta de usuarios SSH (opcional)
echo -e "\n👥 Verificando usuarios SSH comunes..."
nmap -p 22 --script ssh-brute \
    --script-args userdb=${SCRIPT_DIR}/common_users.txt,passdb=${SCRIPT_DIR}/common_passwords.txt,ssh-brute.timeout=4s \
    "$TARGET" -oN "$OUTPUT_DIR/ssh_users_$TIMESTAMP.txt" 2>/dev/null \
    || echo "⚠️  Script de fuerza bruta no disponible o falló"

echo ""
echo "✅ Escaneo SSH completado!"
echo "📁 Resultados guardados en: $OUTPUT_DIR/"
echo "🎯 Objetivo escaneado: $TARGET" 