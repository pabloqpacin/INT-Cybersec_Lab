#!/bin/bash

# Script simple para escanear vulnerabilidades HTTP
# Objetivo: 172.26.10.12

TARGET="server.local"
OUTPUT_DIR="./results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🌐 Iniciando escaneo HTTP de $TARGET..."
echo "⏰ Timestamp: $TIMESTAMP"
echo ""

# Crear directorio de resultados si no existe
mkdir -p "$OUTPUT_DIR"

# 1. Escaneo básico de puertos HTTP/HTTPS
echo "📡 Escaneo básico de puertos HTTP/HTTPS..."
nmap -p 80,443,8080,8443 -sV -sC "$TARGET" -oN "$OUTPUT_DIR/http_basic_$TIMESTAMP.txt"

# 2. Escaneo de vulnerabilidades web comunes
echo "🔍 Escaneo de vulnerabilidades web..."
nmap -p 80,443,8080,8443 --script=http* "$TARGET" -oN "$OUTPUT_DIR/http_vulns_$TIMESTAMP.txt"

# 3. Escaneo de directorios y archivos
echo "📁 Escaneo de directorios web..."
nmap -p 80,443,8080,8443 --script=http-enum "$TARGET" -oN "$OUTPUT_DIR/http_dirs_$TIMESTAMP.txt"

# 4. Escaneo de headers de seguridad
echo "🛡️  Verificando headers de seguridad..."
nmap -p 80,443,8080,8443 --script=http-security-headers "$TARGET" -oN "$OUTPUT_DIR/http_headers_$TIMESTAMP.txt"

# 5. Escaneo de tecnologías web
echo "⚙️  Detectando tecnologías web..."
nmap -p 80,443,8080,8443 --script=http-server-header,http-title "$TARGET" -oN "$OUTPUT_DIR/http_tech_$TIMESTAMP.txt"

# 6. Escaneo agresivo completo
echo "⚡ Escaneo agresivo HTTP..."
nmap -p 80,443,8080,8443 -sV -sC -A --script=http* "$TARGET" -oN "$OUTPUT_DIR/http_aggressive_$TIMESTAMP.txt"

echo ""
echo "✅ Escaneo HTTP completado!"
echo "📁 Resultados guardados en: $OUTPUT_DIR/"
echo "🎯 Objetivo escaneado: $TARGET" 