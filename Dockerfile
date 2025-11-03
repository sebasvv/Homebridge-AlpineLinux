FROM node:22-alpine

# Install system dependencies
# - su-exec: for dropping privileges
# - avahi: for mDNS/Bonjour service discovery (required for HomeKit)
# - avahi-compat-libdns_sd: compatibility library for Bonjour
# - dbus: required by avahi
RUN apk add --no-cache \
    su-exec \
    avahi \
    avahi-compat-libdns_sd \
    dbus

# Install Homebridge globally
RUN npm install -g --unsafe-perm homebridge homebridge-config-ui-x

# Create homebridge user and group (without fixed UID/GID to avoid conflicts)
RUN addgroup -S homebridge && \
    adduser -S -G homebridge homebridge && \
    mkdir -p /homebridge && \
    chown -R homebridge:homebridge /homebridge

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory
WORKDIR /homebridge

# Expose ports
# 8581 - Homebridge UI
# 51826 - HAP (HomeKit Accessory Protocol)
EXPOSE 8581 51826

# Volume for configuration
VOLUME /homebridge

# Use entrypoint script to handle permissions and run as homebridge user
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
