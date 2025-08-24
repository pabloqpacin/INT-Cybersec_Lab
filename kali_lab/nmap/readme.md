# nmap lab


- Crear máquinas
```sh
vagrant up
```

- Pruebas nmap Kali (resultado: averiguar user:contra de máquina Debian)
```sh
vagrant ssh debian-soc-vagrant-soc
```
```sh
cd /lab/nmap

bash ssh_scan.sh

bat results/ssh_scan-*.log
```

- Ajustes SSH en máquina Debian
```sh
vagrant ssh debian-soc-vagrant-soc
```
```sh
sudo -i

bash /lab/ssh-disable_password_login.sh

# Optionally adjust the port for further testing but careful, Vagrant's NAT mapping will not work
sed -i 's/^[#]*Port 22/Port 2299/g' /etc/ssh/sshd_config && \
systemctl restart ssh
```
