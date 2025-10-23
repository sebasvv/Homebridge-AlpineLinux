FROM node:22-alpine

# Install Homebridge globally
RUN npm install -g --unsafe-perm homebridge homebridge-config-ui-x

# Create homebridge user and group (without fixed UID/GID to avoid conflicts)
RUN addgroup -S homebridge && \
    adduser -S -G homebridge homebridge && \
    mkdir -p /homebridge && \
    chown -R homebridge:homebridge /homebridge

# Set working directory
WORKDIR /homebridge

# Switch to homebridge user
USER homebridge

# Expose ports
# 8581 - Homebridge UI
# 51826 - HAP (HomeKit Accessory Protocol)
EXPOSE 8581 51826

# Volume for configuration
VOLUME /homebridge

# Start Homebridge
CMD ["homebridge", "-I", "-U", "/homebridge"]
