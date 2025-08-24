#!/usr/bin/env bash

# =============================================================================
# SSH SCANNER SCRIPT - Escáner de Seguridad SSH con Nmap
# =============================================================================
#
# DESCRIPCIÓN:
# Script automatizado para realizar escaneos de seguridad SSH en múltiples
# objetivos utilizando Nmap. Incluye detección de puertos, análisis de
# vulnerabilidades y pruebas de fuerza bruta controladas.
#
# FUNCIONALIDADES:
# 1. Carga de variables de entorno y lista de objetivos desde target_list.txt
# 2. Escaneo del puerto 22 (SSH estándar) en todos los objetivos
# 3. Escaneo de todos los puertos si SSH no se encuentra en el puerto 22
# 4. Ejecución de scripts Nmap seguros (no intrusivos)
# 5. Ejecución de scripts Nmap intrusivos (con precaución)
# 6. Pruebas de fuerza bruta SSH solo si la autenticación por contraseña está habilitada
# 7. Generación de reportes detallados con timestamp
#
# SCRIPTS NMAP UTILIZADOS:
# - SEGUROS: ssh2-enum-algos, ssh-hostkey
# - INTRUSIVOS: ssh-auth-methods, ssh-brute, ssh-publickey-acceptance, ssh-run
#
# ARCHIVOS REQUERIDOS:
# - target_list.txt: Lista de objetivos (una IP/hostname por línea)
# - common_users.txt: Lista de usuarios para pruebas de fuerza bruta
# - common_passwords.txt: Lista de contraseñas para pruebas de fuerza bruta
#
# SALIDA:
# - Directorio: ./results/
# - Archivo: ssh_scan-YYYYMMDD_HHMMSS.log
#
# USO:
# ./ssh_scan.sh
#
# NOTAS DE SEGURIDAD:
# ⚠️  Este script ejecuta escaneos intrusivos que pueden ser detectados
# ⚠️  Solo usar en entornos autorizados y de pruebas
# ⚠️  Las pruebas de fuerza bruta pueden causar bloqueos temporales
# =============================================================================
#
# RECURSOS ADICIONALES:
# - Scripts SSH disponibles: ls -la /usr/share/nmap/scripts/ssh*
# - Documentación oficial: https://nmap.org/search/?q=ssh
# - Scripts seguros recomendados: ssh2-enum-algos, ssh-hostkey
# - Scripts intrusivos: ssh-auth-methods, ssh-brute, ssh-publickey-acceptance, ssh-run
# =============================================================================


do_preparations() {
    # Array global para almacenar los objetivos
    declare -g -a TARGETS
    if [[ -f "target_list.txt" ]]; then
        while IFS= read -r line; do
            [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]] && TARGETS+=("$line")
        done < target_list.txt
    else
        echo "WARNING: ./target_list.txt not found. Using default target: scanme.nmap.org"
        TARGETS='scanme.nmap.org'
    fi
    echo "Objetivos cargados: ${#TARGETS[@]} (${TARGETS[*]})"

    # Listas de usuarios y contraseñas
    declare -g -a USERNAMES_LIST
    declare -g -a PASSWORDS_LIST
    if [[ -f "./common_users.txt" ]]; then
        USERNAMES_LIST="./common_users.txt"
    else
        echo -e "WARNING: ./common_users.txt not found. Using default users: root, admin\n"
        USERNAMES_LIST="root, admin"
    fi
    if [[ -f "./common_passwords.txt" ]]; then
        PASSWORDS_LIST="./common_passwords.txt"
    else
        echo -e "WARNING: ./common_passwords.txt not found. Using default passwords: password123, password456\n"
        PASSWORDS_LIST="password123, password, 1234"
    fi

    # Output results
    declare -a OUTPUT_DIR
    declare -a TIMESTAMP
    declare -g -a OUTPUT_FILE
    OUTPUT_DIR="./results"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    OUTPUT_FILE="$OUTPUT_DIR/ssh_scan-$TIMESTAMP.log"
    echo "Output file with results: $OUTPUT_FILE"
    mkdir -p $OUTPUT_DIR

    # Write header to output file
    echo "=== SSH Scan Results - $(date) ===" > "$OUTPUT_FILE"
    echo "Targets: ${TARGETS[*]}" >> "$OUTPUT_FILE"
    echo "--------------------------------" | tee -a "$OUTPUT_FILE"

    # # Array global para categorizar los scripts de nmap
    # declare -g -a SAFE_SCRIPTS
    # declare -g -a INTRUSIVE_SCRIPTS
    # SAFE_SCRIPTS=(ssh2-enum-algos ssh-hostkey)
    # INTRUSIVE_SCRIPTS=(ssh-auth-methods ssh-brute ssh-publickey-acceptance ssh-run)
}

ping_targets() {
    echo "= Pinging targets... ="
    for target in ${TARGETS[*]}; do
        echo "Pinging $target..." | tee -a "$OUTPUT_FILE"
        ping -c 1 $target 2>&1 | tee -a "$OUTPUT_FILE"
    done
    echo "--------------------------------" | tee -a "$OUTPUT_FILE"
}


scan_port_22() {
    declare -g -a IS_OPEN_PORT_22
    declare -g -a IS_CLOSED_PORT_22
    declare -g -A SSH_PORTS
    echo "Scanning port 22..."
    for target in ${TARGETS[@]}; do
        nmap_output=$(nmap -p 22 -sV --max-retries 2 "$target" 2>&1 | tee -a "$OUTPUT_FILE")
        port_status=$(echo "$nmap_output" | grep "22/tcp")
        [[ -n "$port_status" ]] && echo "- $target: $port_status"
        if echo "$nmap_output" | grep -q "22/tcp.*open"; then
            IS_OPEN_PORT_22+=("$target")
            SSH_PORTS["$target"]=22
        else
            IS_CLOSED_PORT_22+=("$target")
        fi
    done

    echo "SSH is running on port 22 on ${#IS_OPEN_PORT_22[@]} targets (${IS_OPEN_PORT_22[*]})"
    echo "SSH is NOT running on port 22 on ${#IS_CLOSED_PORT_22[@]} targets (${IS_CLOSED_PORT_22[*]})"
    echo "--------------------------------" | tee -a "$OUTPUT_FILE"
}

scan_all_ports_for_ssh() {
    declare -g -a SSH_ON_OTHER_PORTS
    echo "Scanning all ports for SSH service..."

    for target in ${IS_CLOSED_PORT_22[@]}; do
        nmap_output=$(nmap -sV -p- --max-retries 2 "$target" 2>&1 | tee -a "$OUTPUT_FILE")
        if echo "$nmap_output" | grep -q "ssh\|SSH"; then
            SSH_ON_OTHER_PORTS+=("$target")
            port=$(echo "$nmap_output" | grep "ssh\|SSH" | head -1 | grep -o "[0-9]*/tcp" | cut -d'/' -f1)
            SSH_PORTS["$target"]="$port"
            ssh_port_status=$(echo "$nmap_output" | grep "ssh\|SSH" | head -1)
            [[ -n "$ssh_port_status" ]] && echo "- $target: $ssh_port_status"
        else
            echo "- $target: no SSH found in any port (1-65535)"
        fi
    done

    echo "--------------------------------" | tee -a "$OUTPUT_FILE"
}

print_ssh_port_mapping() {
    echo "SSH Port Mapping Summary:"
    for target in "${!SSH_PORTS[@]}"; do
        echo "  $target -> SSH on port ${SSH_PORTS[$target]}"
    done
    echo "--------------------------------"
}


run_safe_scripts() {
    echo "Running safe nmap scripts..."
    for target in "${!SSH_PORTS[@]}"; do
        port="${SSH_PORTS[$target]}"
        nmap -p "$port" -sV --script=ssh-hostkey,ssh2-enum-algos --script-args=ssh-hostkey=all "$target" 2>&1 | tee -a "$OUTPUT_FILE"
        echo "  ----------------" | tee -a "$OUTPUT_FILE"
    done
    echo "--------------------------------" | tee -a "$OUTPUT_FILE"
}

run_intrusive_scripts() {
    echo "Running intrusive nmap scripts..."

    for target in "${!SSH_PORTS[@]}"; do
        port="${SSH_PORTS[$target]}"

        # Escaneo de métodos de autenticación SSH
        echo "  Checking SSH authentication methods on $target (port $port)..." | tee -a "$OUTPUT_FILE"
        auth_scan_output=$(nmap -p "$port" -sV --script=ssh-auth-methods "$target" 2>&1 | tee -a "$OUTPUT_FILE")
        echo "$auth_scan_output"

        # Verificar si la autenticación por contraseña está habilitada
        if echo "$auth_scan_output" | grep -q "password"; then
            echo "  ✅ Password authentication enabled - running ssh-brute..." | tee -a "$OUTPUT_FILE"

            # Escaneo de fuerza bruta SSH
            nmap -p "$port" -sV --script=ssh-brute --script-args=userdb=./$USERNAMES_LIST,passdb=./$PASSWORDS_LIST,ssh-brute.timeout=10s "$target" 2>&1 | tee -a "$OUTPUT_FILE"
        else
            echo "  ❌ Password authentication disabled - skipping ssh-brute" | tee -a "$OUTPUT_FILE"
            echo "  💡 SSH only accepts public key authentication" | tee -a "$OUTPUT_FILE"
        fi


        # -----------------------------------------------------------------------------
        # # - ssh-publickey-acceptance (verificación de claves)
        # nmap -p 22 --script=ssh-publickey-acceptance "$TARGET" -oN "$OUTPUT_DIR/ssh_pubkey_acceptance_$TIMESTAMP.txt" 2>/dev/null || echo "   ⚠️  ssh-publickey-acceptance falló"

        # # - ssh-run (opcional, requiere credenciales)
        # nmap -p 22 --script=ssh-run "$TARGET" -oN "$OUTPUT_DIR/ssh_run_$TIMESTAMP.txt" 2>/dev/null || echo "   ⚠️  ssh-run falló (normal sin credenciales)"
        # -----------------------------------------------------------------------------


        echo "  ----------------" | tee -a "$OUTPUT_FILE"
    done

    echo "--------------------------------" | tee -a "$OUTPUT_FILE"
}


# ---

if true; then

    do_preparations
    # ping_targets

    scan_port_22
    [[ ${#IS_CLOSED_PORT_22[@]} -gt 0 ]] && scan_all_ports_for_ssh
    print_ssh_port_mapping

    run_safe_scripts
    run_intrusive_scripts

fi
