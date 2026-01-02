# Homebridge Alpine Linux (Raspberry Pi 4 Optimized)

[![Build Multi-Arch Docker Image](https://github.com/sebasvv/Homebridge-AlpineLinux/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sebasvv/Homebridge-AlpineLinux/actions/workflows/docker-publish.yml)

A highly optimized, minimal Homebridge Docker container based on Alpine Linux with **Node.js v24**.
Specifically tuned for maximum stability and performance on a **Raspberry Pi 4**, but works perfectly on other systems as well.

## 🚀 Features

- **Minimal Footprint**: Built on Alpine Linux.
- **Node.js v24**: Latest version for maximum performance.
- **Raspberry Pi 4 Optimized**:
  - **Hardware Acceleration**: Includes `ffmpeg` with access to Pi GPU (`/dev/dri`) for smooth camera streams.
  - **Memory Management**: Tuned Node.js Garbage Collection to keep the Pi responsive.
  - **SD-Card Friendly**: Uses `tmpfs` (RAM disk) for temporary files to prevent wear on your SD card.
- **Homebridge + Config UI X**: Fully manageable via web interface.
- **Broad Compatibility**: Includes `python3`, `make`, `g++`, `git`, and `openssl` for correct installation of heavy plugins (like Zigbee2MQTT, Camera UI).
- **Multi-architecture**: Supports AMD64 and ARM64 (Raspberry Pi 4/5).

## 🛠 Requirements

- Docker
- Docker Compose (recommended)

## 📦 Quick Start (Raspberry Pi 4 & AMD64)

The easiest way is to use the pre-built image via `ghcr.io`.

1. Create a `docker-compose.yml` file:

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
    # "Memory Only" operation: Reduces SD card writes
    tmpfs:
      - /tmp:rw,noexec,nosuid,size=100m
      - /run:rw,noexec,nosuid,size=100m
    environment:
      - TZ=Europe/Amsterdam
      - HOMEBRIDGE_CONFIG_UI=1
      # Node.js Tuning for 1GB/2GB/4GB Pi's
      - NODE_OPTIONS=--max-old-space-size=512 --initial-old-space-size=64
      # Optional: Pre-configure your bridge (useful for headless setup)
      - HOMEBRIDGE_NAME=MyHomebridge
      - HOMEBRIDGE_PIN=031-45-154
    # Hardware acceleration for cameras (Pi 4)
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
          cpus: '2.0'   # Prevent Homebridge from hanging the entire Pi
          memory: 1G
        reservations:
          memory: 128M
```

2. Start the container:
```bash
docker-compose up -d
```

3. Open the UI at `http://<your-ip>:8581` (Login: `admin` / `admin`).

## ⚙️ Configuration via Environment Variables

You can influence the initial `config.json` with the following variables. This only works if no `config.json` exists yet.

| Variable | Default | Description |
|-----------|-----------|--------------|
| `HOMEBRIDGE_CONFIG_UI` | `1` | Set to `1` to enable the UI (required). |
| `HOMEBRIDGE_NAME` | `Homebridge` | Name of the bridge in HomeKit. |
| `HOMEBRIDGE_PIN` | `031-45-154` | The pairing code for HomeKit. |
| `HOMEBRIDGE_USERNAME` | `CC:22:3D:E3:CE:30` | MAC address of the bridge. |
| `HOMEBRIDGE_PORT` | `51826` | Port for HomeKit protocol. |
| `NODE_OPTIONS` | (see yaml) | Tuning parameters for Node.js memory usage. |

## 🏗 Build It Yourself

Do you want to make changes to the image yourself?

1. Clone the repo:
```bash
git clone https://github.com/sebasvv/Homebridge-AlpineLinux.git
cd Homebridge-AlpineLinux
```

2. Modify `Dockerfile` if needed.

3. Build and start:
```bash
docker-compose up -d --build
```

## 🛡 Stability & Performance

This project is designed with stability as a priority:
- **Automatic Healthchecks**: Docker restarts the container if the web UI becomes unreachable.
- **Resource Limits**: Hard limits on CPU and Memory prevent a leaking plugin from crashing your entire Pi.
- **Timezone Sync**: Correct times in logs thanks to `tzdata` and `TZ` variable.
- **Permission Recovery**: `entrypoint.sh` checks and repairs permissions of `/homebridge` if necessary.

## License

MIT
