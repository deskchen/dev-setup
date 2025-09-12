#!/bin/bash

# Go Programming Language Installation Script
# Downloads and installs the latest stable version of Go

# --- Exit immediately if a command exits with a non-zero status ---
set -e

echo "========================================="
echo "Installing Go Programming Language..."
echo "========================================="

# Define Go version (you can update this as needed)
GO_VERSION="1.25.1"
GO_ARCHIVE="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_ARCHIVE}"

echo "Installing Go v${GO_VERSION}..."

# --- Download Go ---
echo "Downloading Go from ${GO_URL}..."
wget "${GO_URL}"

# --- Remove any previous Go installation ---
if [ -d "/usr/local/go" ]; then
    echo "Removing previous Go installation..."
    sudo rm -rf /usr/local/go
fi

# --- Extract Go to /usr/local ---
echo "Installing Go to /usr/local/go..."
sudo tar -C /usr/local -xzf "${GO_ARCHIVE}"

# --- Clean up downloaded archive ---
echo "Cleaning up..."
rm "${GO_ARCHIVE}"

# --- Set up Go environment variables ---
echo "Setting up Go environment variables..."

# Determine which shell config file to use
if [ -f ~/.zshrc ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_NAME="Zsh"
elif [ -f ~/.bashrc ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_NAME="Bash"
else
    SHELL_CONFIG="$HOME/.profile"
    SHELL_NAME="shell profile"
fi

# Check if Go paths are already in the config file
if ! grep -q "# Go environment" "$SHELL_CONFIG" 2>/dev/null; then
    echo "" >> "$SHELL_CONFIG"
    echo "# Go environment" >> "$SHELL_CONFIG"
    echo "export PATH=\$PATH:/usr/local/go/bin" >> "$SHELL_CONFIG"
    echo "export GOPATH=\$HOME/go" >> "$SHELL_CONFIG"
    echo "export PATH=\$PATH:\$GOPATH/bin" >> "$SHELL_CONFIG"
    echo "Go environment variables added to ${SHELL_CONFIG}"
else
    echo "Go environment variables already exist in ${SHELL_CONFIG}"
fi

# --- Create GOPATH directory ---
mkdir -p "$HOME/go/bin"
mkdir -p "$HOME/go/src"
mkdir -p "$HOME/go/pkg"

echo "========================================="
echo "Go installation complete!"
echo "========================================="
echo "✅ Go v${GO_VERSION} installed to /usr/local/go"
echo "✅ Environment variables added to ${SHELL_CONFIG}"
echo "✅ GOPATH directory structure created at ~/go"
echo ""
echo "To start using Go:"
echo "1. Restart your terminal or run: source ${SHELL_CONFIG}"
echo "2. Verify installation: go version"
echo "3. Test with: go env GOPATH"
echo "========================================="
