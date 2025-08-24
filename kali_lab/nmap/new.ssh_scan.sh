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

    # Current timestamp for output file
    declare -g -a TIMESTAMP
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    echo "Timestamp: $TIMESTAMP"

    # Output directory
    declare -g -a OUTPUT_DIR
    OUTPUT_DIR="./results"
    echo "Results directory: $OUTPUT_DIR"
    mkdir -p $OUTPUT_DIR

    # Spacing
    echo "--------------------------------"
}

ping_targets() {
    echo "= Pinging targets... ="
    for target in ${TARGETS[*]}; do
        ping -c 1 $target
    done
}

scan_port_22() {
    declare -g -a IS_OPEN_PORT_22
    declare -g -a IS_CLOSED_PORT_22
    declare -g -A SSH_PORTS
    echo "= Scanning port 22... ="
    for target in ${TARGETS[@]}; do
        if nmap -p 22 --max-retries 2 "$target" | grep -q "22/tcp.*open"; then
            IS_OPEN_PORT_22+=("$target")
            SSH_PORTS["$target"]=22
        else
            IS_CLOSED_PORT_22+=("$target")
        fi
    done

    echo "SSH is running on port 22 on ${#IS_OPEN_PORT_22[@]} targets (${IS_OPEN_PORT_22[*]})"
    echo "SSH is NOT running on port 22 on ${#IS_CLOSED_PORT_22[@]} targets (${IS_CLOSED_PORT_22[*]})"
    echo "--------------------------------"
}

scan_all_ports_for_ssh() {
    declare -g -a SSH_ON_OTHER_PORTS
    echo "= Scanning all ports for SSH service... ="

    for target in ${IS_CLOSED_PORT_22[@]}; do
        echo "Scanning targets for SSH on any port... "
        nmap_output=$(nmap -sV -p- --max-retries 2 "$target")
        if echo "$nmap_output" | grep -q "ssh\|SSH"; then
            SSH_ON_OTHER_PORTS+=("$target")
            port=$(echo "$nmap_output" | grep "ssh\|SSH" | head -1 | grep -o "[0-9]*/tcp" | cut -d'/' -f1)
            SSH_PORTS["$target"]="$port"
            echo "  SSH found on $target (on port $port)"
        else
            echo "  no SSH found in default 1000 common ports (TODO: scan all ports with -p-)"
        fi
    done

    echo "--------------------------------"
}

print_ssh_port_mapping() {
    echo "SSH Port Mapping Summary:"
    for target in "${!SSH_PORTS[@]}"; do
        echo "  $target -> SSH on port ${SSH_PORTS[$target]}"
    done
    echo "--------------------------------"
}


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
