FROM node:24-alpine

# Use optimized Alpine base for Raspberry Pi 4 (ARM64/v7)
# Optimized for stability, low resource usage, and camera support

# Install essential packages
# python3, make, g++: Native module compilation
# git: Git plugins
# tzdata: Timezones
# curl: Healthcheck
# ffmpeg: Hardware accelerated video streaming for Pi 4
# libc6-compat: Compatibility layer for prebuilt glibc binaries on Alpine
# openssl: Security
# su-exec: Privilege drop
RUN apk add --no-cache \
    su-exec \
    python3 \
    make \
    g++ \
    git \
    tzdata \
    curl \
    openssl \
    ffmpeg \
    libc6-compat

# Install Homebridge and Config UI X globally
# Cleaning cache significantly reduces image size
RUN npm install -g --unsafe-perm homebridge homebridge-config-ui-x && \
    npm cache clean --force

# Enable Config UI X (required for Docker environments)
ENV HOMEBRIDGE_CONFIG_UI=1 \
    UIX_CUSTOM_PLUGIN_PATH=/homebridge/node_modules

# Create homebridge user and group
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

# Healthcheck to ensure UI is responsive
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl --fail -s http://localhost:8581/ || exit 1

# Volume for configuration
VOLUME /homebridge

# Use entrypoint script to handle permissions and run as homebridge user
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
