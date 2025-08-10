#!/bin/bash

# Script simple para escanear vulnerabilidades SSH
# Objetivo: 172.26.10.12

TARGET="server.local"
OUTPUT_DIR="./results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🔍 Iniciando escaneo SSH de $TARGET..."
echo "⏰ Timestamp: $TIMESTAMP"
echo ""

# Crear directorio de resultados si no existe
mkdir -p "$OUTPUT_DIR"

# 1. Escaneo básico de puertos SSH
echo "📡 Escaneo básico de puertos SSH..."
nmap -p 22 -sV -sC "$TARGET" -oN "$OUTPUT_DIR/ssh_basic_$TIMESTAMP.txt"

# 2. Escaneo de versiones y scripts de vulnerabilidades SSH
echo "🔐 Escaneo de vulnerabilidades SSH..."
nmap -p 22 --script=ssh* "$TARGET" -oN "$OUTPUT_DIR/ssh_vulns_$TIMESTAMP.txt"

# 3. Escaneo agresivo de SSH (más detallado)
echo "⚡ Escaneo agresivo SSH..."
nmap -p 22 -sV -sC -A --script=ssh* "$TARGET" -oN "$OUTPUT_DIR/ssh_aggressive_$TIMESTAMP.txt"

# 4. Escaneo de fuerza bruta de usuarios SSH (opcional)
echo "👥 Verificando usuarios SSH comunes..."
nmap -p 22 --script=ssh-brute --script-args=userdb=./common_users.txt "$TARGET" -oN "$OUTPUT_DIR/ssh_users_$TIMESTAMP.txt" 2>/dev/null || echo "⚠️  Script de fuerza bruta no disponible o falló"

echo ""
echo "✅ Escaneo SSH completado!"
echo "📁 Resultados guardados en: $OUTPUT_DIR/"
echo "🎯 Objetivo escaneado: $TARGET" 