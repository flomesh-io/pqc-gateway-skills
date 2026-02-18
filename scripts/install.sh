#!/bin/bash
# pqc-gateway install script

set -e

INSTALL_DIR="${HOME}/pqc-gateway"
VERSION="${1:-latest}"

echo "Installing PQC Gateway to ${INSTALL_DIR}..."

# Check dependencies
echo "Checking dependencies..."

if ! command -v pipy &> /dev/null; then
    echo "Error: pipy not found. Install from: https://github.com/flomesh-io/pipy"
    exit 1
fi

OPENSSL_VERSION=$(openssl version | grep -oP 'OpenSSL \K[0-9]+\.[0-9]+')
OPENSSL_MAJOR=$(echo $OPENSSL_VERSION | cut -d. -f1)
OPENSSL_MINOR=$(echo $OPENSSL_VERSION | cut -d. -f2)

if [ "$OPENSSL_MAJOR" -lt 3 ] || ([ "$OPENSSL_MAJOR" -eq 3 ] && [ "$OPENSSL_MINOR" -lt 5 ]; then
    echo "Warning: OpenSSL 3.5+ required for PQC. Current: $(openssl version)"
fi

# Clone repository
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "Cloning pqc-gateway..."
    git clone https://github.com/pqfif-oss/pqc-gateway.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Initialize submodules
echo "Initializing submodules..."
git submodule update --init

# Build
echo "Building..."
make

# Install
echo "Installing..."
sudo make install

# Verify
echo "Verifying installation..."
gw -v

echo ""
echo "Installation complete!"
echo "Usage: gw -c <config-file>"
