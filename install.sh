#!/bin/bash

# Navim - Terminal Web Browser Installer
# https://github.com/politikl/navim

set -e

REPO="politikl/navim"
INSTALL_DIR="$HOME/.local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}${BOLD}"
echo "                    _            "
echo "  _ __   __ ___   _(_)_ __ ___   "
echo " | '_ \ / _\` \ \ / / | '_ \` _ \  "
echo " | | | | (_| |\ V /| | | | | | | "
echo " |_| |_|\__,_| \_/ |_|_| |_| |_| "
echo -e "${NC}"
echo -e "${BOLD}Terminal Web Browser${NC}"
echo -e "https://github.com/politikl/navim"
echo ""

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) echo -e "${RED}Error: Unsupported architecture: $ARCH${NC}"; exit 1 ;;
esac

case "$OS" in
    linux) TARGET="${ARCH}-unknown-linux-gnu" ;;
    darwin) TARGET="${ARCH}-apple-darwin" ;;
    *) echo -e "${RED}Error: Unsupported OS: $OS${NC}"; exit 1 ;;
esac

echo -e "${BLUE}System:${NC}  $OS ($ARCH)"
echo -e "${BLUE}Target:${NC}  $TARGET"
echo ""

# Get latest release
echo -e "${YELLOW}Fetching latest release...${NC}"
LATEST=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
if [ -z "$LATEST" ]; then
    echo -e "${RED}Error: Failed to fetch latest release${NC}"
    exit 1
fi

echo -e "${BLUE}Version:${NC} $LATEST"
echo ""

# Download binary
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST/navim-$TARGET"
echo -e "${YELLOW}Downloading navim...${NC}"

mkdir -p "$INSTALL_DIR"
if curl -sL "$DOWNLOAD_URL" -o "$INSTALL_DIR/navim"; then
    chmod +x "$INSTALL_DIR/navim"
    echo -e "${GREEN}Download complete!${NC}"
else
    echo -e "${RED}Error: Download failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}${BOLD}============================================${NC}"
echo -e "${GREEN}${BOLD}  Installation Successful!${NC}"
echo -e "${GREEN}${BOLD}============================================${NC}"
echo ""
echo -e "${BLUE}Location:${NC} $INSTALL_DIR/navim"
echo ""

# Check if already in PATH
if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
    echo -e "${GREEN}~/.local/bin is already in your PATH${NC}"
    echo ""
else
    echo -e "${YELLOW}${BOLD}Add to PATH${NC}"
    echo -e "${YELLOW}─────────────────────────────────────────────${NC}"
    echo ""
    echo "Add this line to your ~/.bashrc or ~/.zshrc:"
    echo ""
    echo -e "  ${CYAN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo ""
    echo "Then reload your shell:"
    echo ""
    echo -e "  ${CYAN}source ~/.zshrc${NC}  (or ~/.bashrc)"
    echo ""
fi

echo -e "${YELLOW}${BOLD}Usage${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────${NC}"
echo ""
echo -e "  ${CYAN}navim <query>${NC}      Search the web"
echo -e "  ${CYAN}navim about${NC}        Show about information"
echo -e "  ${CYAN}navim -h${NC}           View browsing history"
echo ""
echo -e "${YELLOW}${BOLD}Examples${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────${NC}"
echo ""
echo -e "  ${CYAN}navim rust programming${NC}"
echo -e "  ${CYAN}navim how to exit vim${NC}"
echo -e "  ${CYAN}navim kubernetes pod restart${NC}"
echo ""
echo -e "${YELLOW}${BOLD}Keybindings${NC}"
echo -e "${YELLOW}─────────────────────────────────────────────${NC}"
echo ""
echo -e "  ${BOLD}i${NC}          Enter insert/browse mode"
echo -e "  ${BOLD}Esc${NC}        Return to normal mode"
echo -e "  ${BOLD}j/k${NC}        Navigate up/down"
echo -e "  ${BOLD}Enter${NC}      Open selected result"
echo -e "  ${BOLD}q${NC}          Quit / Go back"
echo ""
echo -e "${GREEN}Enjoy using Navim!${NC}"
echo ""
