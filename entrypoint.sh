#!/bin/sh
set -e

# Fix ownership of /homebridge directory
if [ -d "/homebridge" ]; then
    echo "Fixing permissions for /homebridge..."
    chown -R homebridge:homebridge /homebridge
fi

# Create default config.json if it doesn't exist or is empty/invalid
if [ ! -f "/homebridge/config.json" ] || [ ! -s "/homebridge/config.json" ]; then
    echo "Creating default config.json..."
    cat > /homebridge/config.json <<EOF
{
    "bridge": {
        "name": "Homebridge",
        "username": "CC:22:3D:E3:CE:30",
        "port": 51826,
        "pin": "031-45-154"
    },
    "accessories": [],
    "platforms": [
        {
            "name": "Config",
            "port": 8581,
            "platform": "config"
        }
    ]
}
EOF
    chown homebridge:homebridge /homebridge/config.json
    echo "Default config.json created. Access the web UI at http://localhost:8581"
fi

# Switch to homebridge user and run homebridge
exec su-exec homebridge homebridge -I -U /homebridge
