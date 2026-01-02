#!/bin/sh
set -e

echo "🚀 Starting Integration Tests..."

# Cleanup
echo "🧹 Cleaning up previous runs..."
[ -d "tests/vol" ] && docker run --rm -v "$(pwd)/tests/vol:/vol" alpine find /vol -mindepth 1 -delete || true
rm -rf tests/vol
mkdir -p tests/vol
docker compose -f tests/docker-compose.test.yml down -v --remove-orphans > /dev/null 2>&1

# Build
if [ -z "$SKIP_BUILD" ]; then
    echo "🔨 Building image..."
    docker compose -f tests/docker-compose.test.yml build --pull
else
    echo "⏭️  Skipping build (SKIP_BUILD is set)..."
fi

# Start
echo "▶️ Starting container..."
docker compose -f tests/docker-compose.test.yml up -d

# Wait for Healthcheck
echo "⏳ Waiting for Healthcheck to pass (this checks if UI is responsive)..."
MAX_RETRIES=20
COUNT=0

while [ $COUNT -lt $MAX_RETRIES ]; do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' homebridge-test 2>/dev/null || echo "unknown")
    if [ "$STATUS" = "healthy" ]; then
        echo "✅ Container is HEALTHY!"
        break
    fi
    echo "   Status: $STATUS... waiting ($COUNT/$MAX_RETRIES)"
    sleep 5
    COUNT=$((COUNT+1))
done

if [ "$STATUS" != "healthy" ]; then
    echo "❌ Timeout waiting for healthy status."
    docker compose -f tests/docker-compose.test.yml logs
    exit 1
fi

# Verify config.json generation
echo "🔍 Verifying config generation..."
if grep -q "TestBridge" tests/vol/config.json; then
    echo "✅ HOMEBRIDGE_NAME applied correctly."
else
    echo "❌ HOMEBRIDGE_NAME not found in config.json"
    cat tests/vol/config.json
    exit 1
fi

if grep -q "111-22-333" tests/vol/config.json; then
    echo "✅ HOMEBRIDGE_PIN applied correctly."
else
    echo "❌ HOMEBRIDGE_PIN not found in config.json"
    exit 1
fi

# Verify Node Version
echo "🔍 Verifying Node version..."
NODE_VER=$(docker exec homebridge-test node -v)
echo "   Detected Node version: $NODE_VER"
if echo "$NODE_VER" | grep -q "v24"; then
    echo "✅ Node 24 is installed."
else
    echo "❌ Node version mismatch. Expected v24, got $NODE_VER"
    exit 1
fi

# Verify Plugin Auto-Install
echo "🔍 Verifying Plugin Auto-Install..."
if docker exec homebridge-test ls /homebridge/node_modules/homebridge-dummy/package.json >/dev/null 2>&1; then
    echo "✅ Plugin 'homebridge-dummy' auto-installed correctly."
else
    echo "❌ Plugin 'homebridge-dummy' NOT found!"
    exit 1
fi

echo "🎉 All tests passed successfully!"
docker compose -f tests/docker-compose.test.yml down -v
# Clean up root-owned files created by the container (including hidden files)
[ -d "tests/vol" ] && docker run --rm -v "$(pwd)/tests/vol:/vol" alpine find /vol -mindepth 1 -delete || true
rm -rf tests/vol
