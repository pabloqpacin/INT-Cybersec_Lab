# Scripts de Escaneo con Nmap

Scripts simples y eficientes para escanear vulnerabilidades SSH y HTTP usando nmap.

## 🎯 Objetivo
- **IP objetivo**: 172.26.10.12
- **Servicios**: SSH (puerto 22) y HTTP/HTTPS (puertos 80, 443, 8080, 8443)

## 📁 Estructura
```
kali/nmap/
├── ssh/
│   ├── ssh_scan.sh          # Escaneo SSH
│   └── common_users.txt     # Lista de usuarios para fuerza bruta
├── http/
│   └── http_scan.sh         # Escaneo HTTP
├── full_scan.sh             # Script maestro (ejecuta ambos)
└── README.md                # Este archivo
```

## 🚀 Uso

### Escaneo Individual

#### SSH
```bash
cd kali/nmap/ssh
./ssh_scan.sh
```

#### HTTP
```bash
cd kali/nmap/http
./http_scan.sh
```

### Escaneo Completo
```bash
cd kali/nmap
./full_scan.sh
```

## 📊 Resultados

Los resultados se guardan en:
- **SSH**: `ssh/results/`
- **HTTP**: `http/results/`

Cada archivo incluye timestamp para evitar sobrescrituras.

## ⚠️ Notas Importantes

1. **Requisitos**: Nmap debe estar instalado en Kali Linux
2. **Permisos**: Los scripts ya tienen permisos de ejecución
3. **Objetivo**: Configurado para 172.26.10.12
4. **Puertos**: SSH (22), HTTP (80,443,8080,8443)

## 🔧 Instalación de Nmap

Si nmap no está instalado:
```bash
sudo apt update
sudo apt install nmap
```

## 📝 Scripts Incluidos

### SSH Scan
- Escaneo básico de puerto 22
- Detección de versiones y vulnerabilidades
- Escaneo agresivo con scripts
- Fuerza bruta de usuarios (opcional)

### HTTP Scan
- Escaneo de puertos web
- Detección de vulnerabilidades
- Enumeración de directorios
- Headers de seguridad
- Tecnologías web

### Full Scan
- Ejecuta ambos escaneos secuencialmente
- Verificación de dependencias
- Reporte consolidado 