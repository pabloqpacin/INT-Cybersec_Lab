#!/usr/bin/env bash

msfdb_init(){
    if ! sudo msfdb status | grep -q "Active: active"; then
        sudo msfdb init
    fi
}

msfdb_pgcli(){
    MSFDB_PASSWORD=$(grep -m1 "password:" /usr/share/metasploit-framework/config/database.yml | awk '{print $2}')
    echo ${MSFDB_PASSWORD}
    pgcli -h localhost -p 5432 -u msf

    # # Won't work because the password must be URL-encoded... (special chars)
    # pgcli postgres://msf:${MSFDB_PASSWORD}@localhost:5432/msf
}


# ---

if true; then
    msfdb_init
    # msfdb_pgcli

fi

