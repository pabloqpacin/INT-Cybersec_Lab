# Typical workflow


1. Nmap first — map the terrain:

```sh
nmap -p- -sV -oX scan.xml target
```

2. Import into Metasploit:
```sh
msfconsole
db_import scan.xml
services
```

3. Switch to Metasploit for targeted vuln checks and exploitation.

```sh
msfconsole
```
