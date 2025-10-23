# Homebridge Alpine Linux

Een minimale Homebridge Docker container gebaseerd op Alpine Linux met Node.js v22.

## Kenmerken

- **Minimale image**: Gebouwd op Alpine Linux voor een kleine footprint
- **Node.js v22**: Laatste LTS versie van Node.js
- **Homebridge**: Met Homebridge Config UI X voor eenvoudig beheer
- **Geen onnodige dependencies**: ffmpeg en andere grote packages zijn niet geïnstalleerd

## Vereisten

- Docker
- Docker Compose (optioneel, maar aanbevolen)

## Gebruik

### Met Docker Compose (aanbevolen)

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

### Met Docker

1. Build de image:
```bash
docker build -t homebridge-alpine .
```

2. Run de container:
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

## Licentie

MIT
