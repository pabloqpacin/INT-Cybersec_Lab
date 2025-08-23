#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Disable password login for SSH
# -----------------------------------------------------------------------------

# 1. Edit SSH configuration
# 2. Restart SSH service
# -----------------------------------------------------------------------------

sed -i \
    -e 's/^[#]*PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/^PermitRootLogin.*/PermitRootLogin no/' \
    /etc/ssh/sshd_config

systemctl restart ssh

