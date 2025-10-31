#!/bin/sh
set -e

# Fix ownership of /homebridge directory
if [ -d "/homebridge" ]; then
    echo "Fixing permissions for /homebridge..."
    chown -R homebridge:homebridge /homebridge
fi

# Switch to homebridge user and run homebridge
exec su-exec homebridge homebridge -I -U /homebridge
