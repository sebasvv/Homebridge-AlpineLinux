# Homebridge Alpine Linux (Raspberry Pi 4 Optimized)

[![Build Multi-Arch Docker Image](https://github.com/sebasvv/Homebridge-AlpineLinux/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sebasvv/Homebridge-AlpineLinux/actions/workflows/docker-publish.yml)

Een sterk geoptimaliseerde, minimale Homebridge Docker container gebaseerd op Alpine Linux met **Node.js v24**.
Specifiek getuned voor maximale stabiliteit en performance op een **Raspberry Pi 4**, maar werkt ook perfect op andere systemen.

## 🚀 Kenmerken

- **Minimale footprint**: Gebouwd op Alpine Linux.
- **Node.js v24**: Laatste versie voor maximale performance.
- **Raspberry Pi 4 Optimized**:
  - **Hardware Acceleratie**: Inclusief `ffmpeg` met toegang tot Pi GPU (`/dev/dri`) voor soepele camera streams.
  - **Memory Management**: Getunede Node.js Garbage Collection om de Pi responsief te houden.
  - **SD-Card Friendly**: Gebruikt `tmpfs` (RAM disk) voor tijdelijke bestanden om slijtage aan je SD-kaart te voorkomen.
- **Homebridge + Config UI X**: Volledig beheerbaar via web interface.
- **Broad Compatibility**: Inclusief `python3`, `make`, `g++`, `git` en `openssl` voor correcte installatie van zware plugins (zoals Zigbee2MQTT, Camera UI).
- **Multi-architecture**: Ondersteunt AMD64 en ARM64 (Raspberry Pi 4/5).

## 🛠 Vereisten

- Docker
- Docker Compose (aanbevolen)

## 📦 Snel Starten (Raspberry Pi 4 & AMD64)

De makkelijkste manier is gebruik maken van de pre-built image via `ghcr.io`.

1. Maak een `docker-compose.yml` bestand:

```yaml
version: '3.8'

services:
  homebridge:
    image: ghcr.io/sebasvv/homebridge-alpinelinux:latest
    container_name: homebridge
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./homebridge:/homebridge
    # "Memory Only" operatie: Verlaagt SD-kaart writes
    tmpfs:
      - /tmp:rw,noexec,nosuid,size=100m
      - /run:rw,noexec,nosuid,size=100m
    environment:
      - TZ=Europe/Amsterdam
      - HOMEBRIDGE_CONFIG_UI=1
      # Node.js Tuning voor 1GB/2GB/4GB Pi's
      - NODE_OPTIONS=--max-old-space-size=512 --initial-old-space-size=64
      # Optioneel: Stel je bridge alvast in (handig voor headless setup)
      - HOMEBRIDGE_NAME=MijnHomebridge
      - HOMEBRIDGE_PIN=031-45-154
    # Hardware acceleratie voor camera's (Pi 4)
    devices:
      - /dev/dri:/dev/dri
    logging:
      driver: "json-file"
      options:
        max-size: "5m"
        max-file: "1"
    deploy:
      resources:
        limits:
          cpus: '2.0'   # Voorkom dat Homebridge de hele Pi ophangt
          memory: 1G
        reservations:
          memory: 128M
```

2. Start de container:
```bash
docker-compose up -d
```

3. Open de UI op `http://<jouw-ip>:8581` (Login: `admin` / `admin`).

## ⚙️ Configuratie via Environment Variabelen

Je kunt de initiële `config.json` beïnvloeden met de volgende variabelen. Dit werkt alleen als er nog **geen** `config.json` bestaat.

| Variabele | Standaard | Omschrijving |
|-----------|-----------|--------------|
| `HOMEBRIDGE_CONFIG_UI` | `1` | Zet op `1` om de UI te activeren (verplicht). |
| `HOMEBRIDGE_NAME` | `Homebridge` | Naam van de bridge in HomeKit. |
| `HOMEBRIDGE_PIN` | `031-45-154` | De koppelcode voor HomeKit. |
| `HOMEBRIDGE_USERNAME` | `CC:22:3D:E3:CE:30` | MAC-adres van de bridge. |
| `HOMEBRIDGE_PORT` | `51826` | Poort voor HomeKit protocol. |
| `NODE_OPTIONS` | (zie yaml) | Tuning parameters voor Node.js memory gebruik. |

## 🏗 Zelf Bouwen

Wil je zelf wijzigingen aanbrengen in de image?

1. Clone de repo:
```bash
git clone https://github.com/sebasvv/Homebridge-AlpineLinux.git
cd Homebridge-AlpineLinux
```

2. Pas eventueel `Dockerfile` aan.

3. Bouw en start:
```bash
docker-compose up -d --build
```

## 🛡 Stabiliteit & Performance

Dit project is ontworpen met stabiliteit als prioriteit:
- **Automatic Healthchecks**: Docker herstart de container als de web UI onbereikbaar wordt.
- **Resource Limits**: Harde limieten op CPU en Geheugen voorkomen dat een lekke plugin je hele Pi laat crashen.
- **Timezone Sync**: Correcte tijden in logs dankzij `tzdata` en `TZ` variabele.
- **Rechtenherstel**: `entrypoint.sh` controleert en repareert permissies van `/homebridge` indien nodig.

## Licentie

MIT
