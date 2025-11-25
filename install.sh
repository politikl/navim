#!/bin/bash

# Search - Terminal Web Browser Installer
# https://github.com/politikl/search

set -e

REPO="politikl/search"
INSTALL_DIR="$HOME/.local/bin"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

case "$OS" in
    linux) TARGET="${ARCH}-unknown-linux-gnu" ;;
    darwin) TARGET="${ARCH}-apple-darwin" ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

echo "Detected: $OS $ARCH"
echo "Installing search for $TARGET..."

# Get latest release
LATEST=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
if [ -z "$LATEST" ]; then
    echo "Failed to fetch latest release"
    exit 1
fi

echo "Latest version: $LATEST"

# Download binary
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST/search-$TARGET"
echo "Downloading from: $DOWNLOAD_URL"

mkdir -p "$INSTALL_DIR"
curl -sL "$DOWNLOAD_URL" -o "$INSTALL_DIR/search"
chmod +x "$INSTALL_DIR/search"

echo ""
echo "✓ Search installed to $INSTALL_DIR/search"
echo ""
echo "Add to your PATH by adding this line to your ~/.bashrc or ~/.zshrc:"
echo ""
echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Then restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
echo ""
echo "Usage: search <query>"
echo "       search -h     (view history)"
echo "       search about  (about info)"
