#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# ssh_scan_new.sh
# -----------------------------------------------------------------------------
# 1. load env vars & get targets from list (all lines but those starting with #)
# 2. scan port 22 for ssh
# 3. if not found, scan all ports for ssh
# 4. run safe scans
# 5. run intrusive scans
# 6. intrusive scans: attempt to break user:password only if enabled
# 7. write results
# -----------------------------------------------------------------------------
# # ls -la /usr/share/nmap/scripts/ssh* && open https://nmap.org/search/?q=ssh
# SAFE_SCRIPTS = (ssh2-enum-algos ssh-hostkey)
# INTRUSIVE_SCRIPTS = (ssh-auth-methods ssh-brute ssh-publickey-acceptance ssh-run)
# -----------------------------------------------------------------------------


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

# NOTE: also scanning for versions (-sV)
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


# -----------------------------------------------------------------------------
# Now, if the safe scripts are ran by default, we don't need to run them again.
# Therefore, we should have outputted said scans and the results innit.
# -----------------------------------------------------------------------------


# ---

if true; then

    do_preparations
    # ping_targets

    scan_port_22
    [[ ${#IS_CLOSED_PORT_22[@]} -gt 0 ]] && scan_all_ports_for_ssh
    print_ssh_port_mapping

    # run_safe_scans
    # run_intrusive_scans
    # write_results

fi
