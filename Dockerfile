FROM node:22-alpine

# Set working directory
WORKDIR /homebridge

# Install Homebridge globally
RUN npm install -g --unsafe-perm homebridge homebridge-config-ui-x

# Create user and set permissions
RUN addgroup -g 1000 homebridge && \
    adduser -D -u 1000 -G homebridge homebridge && \
    mkdir -p /homebridge && \
    chown -R homebridge:homebridge /homebridge

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
