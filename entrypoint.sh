#!/bin/sh
set -e

# Fix ownership of /homebridge directory
if [ -d "/homebridge" ]; then
    echo "Fixing permissions for /homebridge..."
    chown -R homebridge:homebridge /homebridge
fi

# Check if config needs to be created or upgraded
CREATE_CONFIG=0

if [ ! -f "/homebridge/config.json" ] || [ ! -s "/homebridge/config.json" ]; then
    echo "Config.json missing or empty, will create new one..."
    CREATE_CONFIG=1
elif ! grep -q '"bind"' /homebridge/config.json; then
    echo "Old config.json detected (missing bind setting), upgrading..."
    # Backup old config
    cp /homebridge/config.json /homebridge/config.json.backup
    echo "Backup saved to config.json.backup"
    CREATE_CONFIG=1
fi

if [ "$CREATE_CONFIG" = "1" ]; then
    echo "Creating/updating config.json..."
    cat > /homebridge/config.json <<'EOF'
{
    "bridge": {
        "name": "Homebridge",
        "username": "CC:22:3D:E3:CE:30",
        "port": 51826,
        "pin": "031-45-154",
        "advertiser": "avahi"
    },
    "accessories": [],
    "platforms": [
        {
            "name": "Config",
            "port": 8581,
            "bind": "0.0.0.0",
            "auth": "form",
            "theme": "auto",
            "tempUnits": "c",
            "lang": "auto",
            "platform": "config"
        }
    ]
}
EOF
    chown homebridge:homebridge /homebridge/config.json
    echo "============================================"
    echo "Config.json ready!"
    echo "Access the Config UI at: http://<host-ip>:8581"
    echo "Default login: admin / admin"
    echo "============================================"
fi

# Start dbus (required for avahi)
echo "Starting dbus..."
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# Start avahi-daemon for mDNS/Bonjour (required for HomeKit discovery)
echo "Starting avahi-daemon..."
avahi-daemon --daemonize --no-chroot

# Switch to homebridge user and run homebridge
echo "Starting Homebridge..."
exec su-exec homebridge homebridge -U /homebridge
