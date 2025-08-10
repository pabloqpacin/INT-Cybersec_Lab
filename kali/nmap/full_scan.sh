#!/bin/bash

# Script maestro para escaneo completo de SSH y HTTP
# Objetivo: 172.26.10.12

TARGET="server.local"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🚀 Iniciando escaneo completo de $TARGET..."
echo "⏰ Timestamp: $TIMESTAMP"
echo "=================================="
echo ""

# Verificar que nmap esté instalado
if ! command -v nmap &> /dev/null; then
    echo "❌ Error: nmap no está instalado"
    echo "💡 Instala nmap con: sudo apt update && sudo apt install nmap"
    exit 1
fi

# Ejecutar escaneo SSH
echo "🔐 Ejecutando escaneo SSH..."
cd "$(dirname "$0")/ssh"
./ssh_scan.sh

echo ""
echo "=================================="

# Ejecutar escaneo HTTP
echo "🌐 Ejecutando escaneo HTTP..."
cd "$(dirname "$0")/http"
./http_scan.sh

echo ""
echo "=================================="
echo "🎉 Escaneo completo finalizado!"
echo "📁 Revisa los resultados en los directorios ssh/results/ y http/results/"
echo "🎯 Objetivo escaneado: $TARGET"
echo "⏰ Completado en: $(date)" 