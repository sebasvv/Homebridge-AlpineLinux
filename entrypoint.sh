#!/bin/sh
set -e

# Default values for configuration if not provided
HB_NAME=${HOMEBRIDGE_NAME:-"Homebridge"}
HB_USERNAME=${HOMEBRIDGE_USERNAME:-"CC:22:3D:E3:CE:30"}
HB_PIN=${HOMEBRIDGE_PIN:-"031-45-154"}
HB_PORT=${HOMEBRIDGE_PORT:-51826}

# Fix ownership of /homebridge directory
if [ -d "/homebridge" ]; then
    # Only fix permissions if they are incorrect to save IO on large dirs
    if [ "$(stat -c %U /homebridge)" != "homebridge" ]; then
        echo "Fixing permissions for /homebridge..."
        chown -R homebridge:homebridge /homebridge
    fi
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
    cat > /homebridge/config.json <<EOF
{
    "bridge": {
        "name": "${HB_NAME}",
        "username": "${HB_USERNAME}",
        "port": ${HB_PORT},
        "pin": "${HB_PIN}"
    },
    "accessories": [],
    "platforms": [
        {
            "platform": "config",
            "name": "Config",
            "port": 8581,
            "bind": "0.0.0.0",
            "sudo": false
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

# Start Homebridge using hb-service (this starts both Homebridge AND Config UI X)
echo "Starting Homebridge with Config UI X..."
echo "Container optimized for: $(node -v)"
exec su-exec homebridge hb-service run --allow-root -U /homebridge
