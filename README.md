# INT-Cybersec_Lab

- [INT-Cybersec\_Lab](#int-cybersec_lab)
  - [preparar equipos](#preparar-equipos)
  - [operaciones](#operaciones)
    - [nmap](#nmap)
    - [metasploit](#metasploit)


## preparar equipos

- Workstation

```sh
cd Vagrant

vagrant up
```

- Debian VM (**Metasploitable**)

```sh
# vagrant ssh debian-soc-vagrant-vm

cd /lab/metasploitable

sudo su

docker compose up -d && \
docker compose logs -f
```

- Kali VM

```sh
# vagrant ssh kali-soc-vagrant-vm
```

---

## operaciones

### nmap

> [!NOTE]
> [./kali_lab/nmap/readme.md](/kali_lab/nmap/readme.md)


### metasploit

> [!NOTE]
> [./docs/metasploit.md](/docs/metasploit.md)

