#!/bin/bash

# Zellij Installation Script
# Installs Zellij through Cargo. If Cargo is missing, installs Rust first using rustup defaults.

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

source_cargo_env() {
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        . "$HOME/.cargo/env"
    else
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
}

install_build_prerequisites() {
    if command -v apt-get &> /dev/null; then
        print_status "Installing Zellij build prerequisites with apt..."
        run_sudo apt-get update
        run_sudo apt-get install -y build-essential pkg-config ca-certificates curl
    else
        print_warning "apt-get not found; assuming Cargo build prerequisites are already installed."
    fi
}

install_rust_default_if_needed() {
    source_cargo_env
    if command -v cargo &> /dev/null; then
        return 0
    fi

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -x "$script_dir/rust.sh" ]; then
        print_status "Cargo not found; running local rust.sh first..."
        "$script_dir/rust.sh"
    else
        print_status "Cargo not found; installing Rust with rustup default profile..."
        install_build_prerequisites
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile default
    fi
    source_cargo_env
}

print_header "Installing Zellij Terminal Workspace"

source_cargo_env

if command -v zellij &> /dev/null; then
    print_status "Zellij is already installed."
    zellij --version
    exit 0
fi

install_rust_default_if_needed
install_build_prerequisites

print_status "Installing Zellij with Cargo..."
cargo install --locked zellij
source_cargo_env

print_header "Zellij installation complete!"
zellij --version

echo ""
echo "To start Zellij, run: zellij"
echo "If the command is not found in a new shell, run: source ~/.cargo/env"
echo "========================================="
