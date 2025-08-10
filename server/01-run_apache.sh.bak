#!/usr/bin/env bash

# NOTE: irrelevant since implemented with ansible

run_apache() {
    if ! sudo docker ps | grep -q apache1; then
        sudo docker run -d \
          --restart unless-stopped \
          --name apache1 -p 80:80 httpd
    fi
}

if true; then
    run_apache
fi
