# Metasploit

> [!NOTE]
> [YT @VulnHunters: Curso Ciberseguridad Desde Cero 2025 (2:14)](https://www.youtube.com/watch?v=y9NhaYH-FV8&t=8835s)

> [!TIP]
> [/kali_lab/metasploit/101.sh](/kali_lab/metasploit/101.sh)

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

