<div align="center">

```
███████╗     ██╗███████╗███╗   ███╗██████╗ ██╗      ██████╗ ██╗    ██╗███████╗██████╗
██╔════╝     ██║██╔════╝████╗ ████║██╔══██╗██║     ██╔═══██╗██║    ██║██╔════╝██╔══██╗
█████╗       ██║█████╗  ██╔████╔██║██████╔╝██║     ██║   ██║██║ █╗ ██║█████╗  ██████╔╝
██╔══╝  ██   ██║██╔══╝  ██║╚██╔╝██║██╔═══╝ ██║     ██║   ██║██║███╗██║██╔══╝  ██╔══██╗
███████╗╚█████╔╝███████╗██║ ╚═╝ ██║██║     ███████╗╚██████╔╝╚███╔███╔╝███████╗██████╔╝
╚══════╝ ╚════╝ ╚══════╝╚═╝     ╚═╝╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝╚══════╝╚═════╝
```

**Servidor web casero con deploy automático vía CI/CD**

[![Status](https://img.shields.io/badge/status-online-00ff88?style=flat-square&logo=statuspage&logoColor=white)](https://ejemploweb.duckdns.org)
[![HTTPS](https://img.shields.io/badge/HTTPS-Let's%20Encrypt-00ff88?style=flat-square&logo=letsencrypt&logoColor=white)](https://ejemploweb.duckdns.org)
[![Docker](https://img.shields.io/badge/Docker-Nginx-2496ED?style=flat-square&logo=docker&logoColor=white)](https://hub.docker.com/_/nginx)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Webhook-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/sergioglezz/EjemploWeb)

🌐 **[ejemploweb.duckdns.org](https://ejemploweb.duckdns.org)**

</div>

---

## ¿Qué es esto?

Un servidor web corriendo en un **PC viejo de casa**, accesible desde internet, con deploy automático cada vez que se hace `git push`. Sin servicios de pago, sin VPS, sin complicaciones.

```
git push
   │
   ▼
GitHub ──webhook──▶ servidor ──▶ git pull + docker compose up
                                        │
                                        ▼
                              https://ejemploweb.duckdns.org ✅
```

---

## Stack

| Capa | Tecnología |
|------|-----------|
| Servidor físico | PC viejo con Ubuntu Server |
| Contenedor | Docker + Docker Compose |
| Web server | Nginx (imagen oficial) |
| CI/CD | GitHub Webhook + script Python |
| DNS dinámico | DuckDNS (actualización cada 5 min) |
| HTTPS | Let's Encrypt via Certbot + dns-duckdns |
| Acceso remoto | SSH |

---

## Estructura del repo

```
EjemploWeb/
├── html/
│   └── index.html        # La web en sí
├── nginx.conf            # Configuración de Nginx (HTTP → HTTPS, SSL)
├── docker-compose.yml    # Definición del contenedor
├── deploy.sh             # Script que ejecuta el servidor al recibir un push
└── README.md
```

---

## Flujo de deploy

Cuando se hace `git push` a `main`:

1. **GitHub** detecta el push y manda una petición `POST` firmada al servidor
2. **webhook.py** (servicio systemd en el servidor) verifica la firma HMAC-SHA256
3. Si es válida, ejecuta **`deploy.sh`**
4. El script hace `git pull` y `docker compose up -d --build`
5. La web se actualiza en segundos sin intervención manual

```bash
# En el servidor, el webhook corre como servicio permanente
sudo systemctl status webhook
# ● webhook.service - GitHub Webhook Listener
#      Active: active (running)
```

---

## Infraestructura del servidor

```
Internet
   │
   │  HTTPS :443
   ▼
Router (port forwarding 80/443 → servidor)
   │
   ▼
Ubuntu Server (PC casero)
   ├── Docker
   │     └── nginx:latest  ← sirve el HTML
   ├── webhook.py           ← escucha pushes de GitHub en :9000
   ├── certbot              ← renueva el certificado SSL automáticamente
   └── duckdns/duck.sh      ← actualiza la IP dinámica cada 5 min
```

---

## HTTPS

Certificado gestionado por **Let's Encrypt** con renovación automática:

```bash
# Comprobar estado del certificado
sudo certbot certificates

# Renovación automática (cron)
0 3 * * * certbot renew --quiet && docker restart ejemploweb-web-1
```

---

## Variables sensibles

Los secretos **no están en el repo**. Viven solo en el servidor:

| Dato | Ubicación en el servidor |
|------|--------------------------|
| Secret del webhook | `~/webhook-server/webhook.py` |
| Token de DuckDNS | `~/duckdns/duck.sh` y `~/.secrets/duckdns.ini` |
| Certificados SSL | `/etc/letsencrypt/` |

---

## Comandos útiles

```bash
# Ver estado de la web
docker compose ps

# Ver logs de nginx en tiempo real
docker logs -f ejemploweb-web-1

# Ver logs del webhook
sudo journalctl -u webhook.service -f

# Ver historial de deploys
tail -f ~/deploy.log

# Forzar deploy manual
bash ~/EjemploWeb/deploy.sh
```

---

## Roadmap

- [x] Servidor web con Docker + Nginx
- [x] Deploy automático con GitHub Webhook
- [x] HTTPS con Let's Encrypt
- [x] DNS dinámico con DuckDNS
- [x] Diseño responsive
- [ ] Cloudflare Tunnel (sin exponer IP)
- [ ] Dominio propio
- [ ] Múltiples servicios con subdominios

---

<div align="center">

Hecho con ☕ y un PC viejo — [@sergioglezz](https://github.com/sergioglezz)

</div>