#!/bin/bash

# Script simple para escanear vulnerabilidades SSH
# Objetivo: 172.26.10.12

# SAFE_SCRIPTS = (ssh2-enum-algos ssh-hostkey)
# INTRUSIVE_SCRIPTS = (ssh-auth-methods ssh-brute ssh-publickey-acceptance ssh-run)


TARGET="server.local"
OUTPUT_DIR="./results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔍 Iniciando escaneo SSH de $TARGET..."
echo "⏰ Timestamp: $TIMESTAMP"

# Crear directorio de resultados si no existe
mkdir -p "$OUTPUT_DIR"

# 1. Escaneo básico de puertos SSH
echo -e "\n📡 Escaneo básico de puertos SSH..."
nmap -p 22 -sV -sC "$TARGET" -oN "$OUTPUT_DIR/ssh_basic_$TIMESTAMP.txt"

# 2. Scripts SSH individuales para mejor control
echo -e "\n🔐 Ejecutando scripts SSH seguros"

run_safe_scripts(){
    echo -e "\n🔑 Verificando claves del host SSH y enumerando algoritmos..."
    nmap -p 22 \
        --script=ssh-hostkey,ssh2-enum-algos \
        "$TARGET" \
        -oN "$OUTPUT_DIR/ssh_safe_info_$TIMESTAMP.txt"
        # 2>/dev/null || echo "⚠️  ssh-hostkey o ssh2-enum-algos falló"
}

run_intrusive_scripts(){
    echo -e "\n🔑 Verificando métodos de autenticación SSH..."

    nmap -p 22 \
        --script=ssh-auth-methods \
        "$TARGET" \
        -oN "$OUTPUT_DIR/ssh_auth_methods_$TIMESTAMP.txt"

    # Escaneo de fuerza bruta de usuarios SSH (solo si auth por contraseña está habilitado)
    echo "   📋 Usando archivos de credenciales: ${SCRIPT_DIR}/{common_users.txt,common_passwords.txt}"
    if nmap -p 22 --script=ssh-auth-methods "$TARGET" 2>/dev/null | grep -q "password\|PasswordAuthentication\|yes"; then
        echo "   ✅ Autenticación por contraseña habilitada - ejecutando ssh-brute..."
        nmap -p 22 --script=ssh-brute \
            --script-args=userdb=${SCRIPT_DIR}/common_users.txt,passdb=${SCRIPT_DIR}/common_passwords.txt,ssh-brute.timeout=10s \
            "$TARGET" -oN "$OUTPUT_DIR/ssh_users_$TIMESTAMP.txt" 2>/dev/null \
            || echo "   ⚠️  ssh-brute falló"
    else
        echo "   ❌ Autenticación por contraseña deshabilitada - saltando ssh-brute"
        echo "   💡 SSH solo acepta autenticación por clave pública" > "$OUTPUT_DIR/ssh_users_$TIMESTAMP.txt"
    fi

    # # - ssh-publickey-acceptance (verificación de claves)
    # nmap -p 22 --script=ssh-publickey-acceptance "$TARGET" -oN "$OUTPUT_DIR/ssh_pubkey_acceptance_$TIMESTAMP.txt" 2>/dev/null || echo "   ⚠️  ssh-publickey-acceptance falló"

    # # - ssh-run (opcional, requiere credenciales)
    # nmap -p 22 --script=ssh-run "$TARGET" -oN "$OUTPUT_DIR/ssh_run_$TIMESTAMP.txt" 2>/dev/null || echo "   ⚠️  ssh-run falló (normal sin credenciales)"
}


if true; then
    run_safe_scripts
    echo -e "\n--------------------------------"
    run_intrusive_scripts
fi


echo ""
echo "✅ Escaneo SSH completado!"
echo "📁 Resultados guardados en: $OUTPUT_DIR/"
echo "🎯 Objetivo escaneado: $TARGET"
echo ""
echo "📋 Archivos generados:"
ls -la "$OUTPUT_DIR"/*"$TIMESTAMP"* 2>/dev/null | awk '{print "   " $9}' || echo "   No se encontraron archivos de resultados"
