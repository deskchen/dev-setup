#!/bin/bash

# Rust Programming Language Installation Script
# Installs Rust through rustup using the default stable toolchain/profile.

set -euo pipefail

print_header() {
    echo "========================================="
    echo "$1"
    echo "========================================="
}

print_status() {
    echo "[INFO] $1"
}

print_warning() {
    echo "[WARNING] $1"
}

run_sudo() {
    if [ "$EUID" -ne 0 ]; then
        if ! command -v sudo &> /dev/null; then
            echo "Error: this script requires root privileges or sudo for package prerequisites."
            exit 1
        fi
        sudo "$@"
    else
        "$@"
    fi
}

detect_shell_config() {
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    else
        SHELL_CONFIG="$HOME/.profile"
    fi
}

install_prerequisites() {
    if command -v apt-get &> /dev/null; then
        print_status "Installing Rust prerequisites with apt..."
        run_sudo apt-get update
        run_sudo apt-get install -y curl build-essential ca-certificates
    else
        print_warning "apt-get not found; assuming curl, a linker, and CA certificates are already installed."
    fi
}

source_cargo_env() {
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.cargo/env"
    else
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
}

ensure_shell_config() {
    detect_shell_config
    if ! grep -q "# Rust/Cargo environment" "$SHELL_CONFIG" 2>/dev/null; then
        {
            echo ""
            echo "# Rust/Cargo environment"
            echo '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'
        } >> "$SHELL_CONFIG"
        print_status "Rust/Cargo environment added to ${SHELL_CONFIG}"
    else
        print_status "Rust/Cargo environment already configured in ${SHELL_CONFIG}"
    fi
}

install_rustup_default() {
    print_status "Installing Rust with rustup default profile..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default
}

print_header "Installing Rust Programming Language"

source_cargo_env

if ! command -v rustup &> /dev/null; then
    install_prerequisites
    install_rustup_default
    source_cargo_env
else
    print_status "rustup is already installed; refreshing the default stable toolchain."
fi

print_status "Setting rustup profile to default and stable as the active toolchain..."
rustup set profile default
rustup default stable
rustup update stable

ensure_shell_config
source_cargo_env

print_header "Rust installation complete!"
rustc --version
cargo --version
rustup show active-toolchain

echo ""
echo "To start using Rust in a new shell:"
echo "1. Restart your terminal, OR"
echo "2. Run: source ${SHELL_CONFIG}"
echo "3. Verify installation: rustc --version && cargo --version"
echo "========================================="
