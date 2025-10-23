# Homebridge Alpine Linux

Een minimale Homebridge Docker container gebaseerd op Alpine Linux met Node.js v22.

## Kenmerken

- **Minimale image**: Gebouwd op Alpine Linux voor een kleine footprint
- **Node.js v22**: Laatste LTS versie van Node.js
- **Homebridge**: Met Homebridge Config UI X voor eenvoudig beheer
- **Geen onnodige dependencies**: ffmpeg en andere grote packages zijn niet geïnstalleerd
- **Multi-architecture**: Ondersteunt AMD64 en ARM64 (Raspberry Pi 4)

## Vereisten

- Docker
- Docker Compose (optioneel, maar aanbevolen)

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

```bash
docker-compose logs -f
```

of met Docker:

```bash
docker logs -f homebridge
```

## Container herstarten

```bash
docker-compose restart
```

## Container stoppen

```bash
docker-compose down
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
