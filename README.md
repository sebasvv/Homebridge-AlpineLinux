# Homebridge Alpine Linux

[![Build Multi-Arch Docker Image](https://github.com/sebasvv/Homebridge-AlpineLinux/actions/workflows/docker-build.yml/badge.svg)](https://github.com/sebasvv/Homebridge-AlpineLinux/actions/workflows/docker-build.yml)

Een minimale Homebridge Docker container gebaseerd op Alpine Linux met Node.js v22.

## Kenmerken

- **Minimale image**: Gebouwd op Alpine Linux voor een kleine footprint
- **Node.js v22**: Laatste LTS versie van Node.js
- **Homebridge**: Met Homebridge Config UI X voor eenvoudig beheer
- **Geen onnodige dependencies**: ffmpeg en andere grote packages zijn niet geïnstalleerd
- **Multi-architecture**: Ondersteunt AMD64 en ARM64 (Raspberry Pi 4)

## Vereisten

- Docker of Podman
- Docker Compose / Podman Compose (optioneel, maar aanbevolen)

## Gebruik

### Pre-built Images (Raspberry Pi 4 & AMD64)

De makkelijkste manier om te starten is door de pre-built images te gebruiken die automatisch gebouwd worden voor zowel AMD64 als ARM64 (Raspberry Pi 4):

**Voor Raspberry Pi 4 en andere platforms:**

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
    environment:
      - TZ=Europe/Amsterdam
```

2. Start de container:
```bash
docker-compose up -d
```

De juiste image voor jouw platform (ARM64 voor Pi 4, AMD64 voor PC) wordt automatisch gedownload.

### Zelf bouwen met Docker Compose

1. Clone deze repository:
```bash
git clone https://github.com/sebasvv/Homebridge-AlpineLinux.git
cd Homebridge-AlpineLinux
```

2. Start de container:
```bash
docker-compose up -d
```

3. Open de Homebridge UI in je browser:
```
http://localhost:8581
```

### Met Docker (pre-built image)

Direct starten zonder te bouwen:

```bash
docker run -d \
  --name homebridge \
  --network host \
  -v $(pwd)/homebridge:/homebridge \
  -e TZ=Europe/Amsterdam \
  ghcr.io/sebasvv/homebridge-alpinelinux:latest
```

### Zelf bouwen met Docker

1. Clone de repository:
```bash
git clone https://github.com/sebasvv/Homebridge-AlpineLinux.git
cd Homebridge-AlpineLinux
```

2. Build de image:
```bash
docker build -t homebridge-alpine .
```

3. Run de container:
```bash
docker run -d \
  --name homebridge \
  --network host \
  -v $(pwd)/homebridge:/homebridge \
  -e TZ=Europe/Amsterdam \
  homebridge-alpine
```

### Met Podman

Podman is een daemonless container engine die volledig compatibel is met Docker containers. Ideaal voor systemen waar je geen Docker daemon wilt draaien.

#### Podman Run (pre-built image)

```bash
podman run -d \
  --name homebridge \
  --network host \
  -v $(pwd)/homebridge:/homebridge:Z \
  -e TZ=Europe/Amsterdam \
  ghcr.io/sebasvv/homebridge-alpinelinux:latest
```

**Opmerking:** De `:Z` flag bij de volume mount zorgt voor correcte SELinux labels (belangrijk op Fedora/RHEL systemen).

#### Podman Compose

1. Installeer podman-compose (als je dat nog niet hebt):
```bash
# Fedora/RHEL
sudo dnf install podman-compose

# Of via pip
pip3 install podman-compose
```

2. Gebruik dezelfde `docker-compose.yml` zoals hierboven:
```bash
podman-compose up -d
```

#### Podman met Systemd (automatisch starten bij boot)

Voor een productie setup kun je Podman gebruiken met systemd om de container automatisch te starten:

1. Start de container eerst handmatig:
```bash
podman run -d \
  --name homebridge \
  --network host \
  -v $(pwd)/homebridge:/homebridge:Z \
  -e TZ=Europe/Amsterdam \
  ghcr.io/sebasvv/homebridge-alpinelinux:latest
```

2. Genereer een systemd service file:
```bash
podman generate systemd --name homebridge --files --new
```

3. Installeer de service:
```bash
mkdir -p ~/.config/systemd/user/
mv container-homebridge.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable container-homebridge.service
systemctl --user start container-homebridge.service
```

4. Enable lingering (zodat de service blijft draaien na uitloggen):
```bash
loginctl enable-linger $USER
```

**Logs bekijken met Podman:**
```bash
podman logs -f homebridge
```

**Container herstarten met Podman:**
```bash
podman restart homebridge
```

**Container stoppen met Podman:**
```bash
podman stop homebridge
podman rm homebridge
```

## Configuratie

De Homebridge configuratie wordt opgeslagen in de `./homebridge` directory. Bij eerste gebruik wordt deze automatisch aangemaakt.

## Poorten

- **8581**: Homebridge Config UI X
- **51826**: HomeKit Accessory Protocol (HAP)

## Standaard inloggegevens Config UI

Bij eerste gebruik:
- **Gebruikersnaam**: admin
- **Wachtwoord**: admin

⚠️ Wijzig deze inloggegevens direct na eerste gebruik!

## Logs bekijken

Met Docker Compose:
```bash
docker-compose logs -f
```

Met Docker:
```bash
docker logs -f homebridge
```

Met Podman:
```bash
podman logs -f homebridge
```

## Container herstarten

Met Docker Compose:
```bash
docker-compose restart
```

Met Docker:
```bash
docker restart homebridge
```

Met Podman:
```bash
podman restart homebridge
```

## Container stoppen

Met Docker Compose:
```bash
docker-compose down
```

Met Docker:
```bash
docker stop homebridge
docker rm homebridge
```

Met Podman:
```bash
podman stop homebridge
podman rm homebridge
```

## Image grootte

Deze Alpine-gebaseerde image is significant kleiner dan vergelijkbare Debian/Ubuntu-gebaseerde images, wat resulteert in:
- Snellere downloads
- Minder opslagruimte
- Kleinere attack surface

## Ondersteunde Platforms

De pre-built images worden automatisch gebouwd voor:
- **linux/amd64**: Standaard PC's en servers
- **linux/arm64**: Raspberry Pi 4, Raspberry Pi 5, en andere ARM64 devices

De images worden automatisch gebouwd via GitHub Actions bij elke push naar de main branch.

## Licentie

MIT
