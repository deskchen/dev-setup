#!/bin/bash

# Docker Data Directory Migration Script
# Moves Docker's data directory from /var/lib/docker to /mnt/docker
# Useful for environments where root partition has limited space (e.g., CloudLab)

# --- Exit immediately if a command exits with a non-zero status ---
set -e

echo "========================================="
echo "Moving Docker data directory to /mnt/docker"
echo "========================================="

# Determine if we need to use sudo
if [ "$EUID" -ne 0 ]; then 
    if ! command -v sudo &> /dev/null; then
        echo "Error: This script requires root privileges and sudo is not available."
        exit 1
    fi
    SUDO="sudo"
    echo "Note: This script requires root privileges. Using sudo for commands."
else
    SUDO=""
fi

# Helper function to run commands with or without sudo
run_cmd() {
    if [ -n "$SUDO" ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if /mnt exists
if [ ! -d "/mnt" ]; then
    echo "Error: /mnt directory does not exist."
    exit 1
fi

# Check if /var/lib/docker exists
if run_cmd test -d /var/lib/docker 2>/dev/null; then
    DOCKER_DIR_EXISTS=true
else
    DOCKER_DIR_EXISTS=false
fi

if [ "$DOCKER_DIR_EXISTS" = "false" ]; then
    echo "Warning: /var/lib/docker does not exist. Docker may not be initialized yet."
    echo "Creating /mnt/docker directory for future use..."
    run_cmd mkdir -p /mnt/docker
    run_cmd chmod 777 /mnt/docker
    run_cmd ln -sf /mnt/docker /var/lib/docker
    echo "✅ Symlink created. Docker will use /mnt/docker when initialized."
    exit 0
fi

# Check if symlink already exists
if run_cmd test -L /var/lib/docker 2>/dev/null; then
    IS_SYMLINK=true
    SYMLINK_TARGET=$(run_cmd readlink -f /var/lib/docker 2>/dev/null || echo 'unknown')
else
    IS_SYMLINK=false
    SYMLINK_TARGET=''
fi

if [ "$IS_SYMLINK" = "true" ]; then
    echo "Warning: /var/lib/docker is already a symlink."
    echo "Current target: $SYMLINK_TARGET"
    if [ -t 0 ]; then
        read -p "Do you want to continue? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
    else
        echo "Non-interactive mode: proceeding..."
    fi
fi

# Stop Docker service
echo "Stopping Docker service..."
run_cmd systemctl stop docker

# Remove /mnt/docker if it exists (to ensure /mnt/docker becomes the docker directory itself)
if run_cmd test -e /mnt/docker 2>/dev/null; then
    echo "Removing existing /mnt/docker to ensure clean migration..."
    run_cmd rm -rf /mnt/docker
fi

# Move Docker data directory to /mnt/docker
# This renames /var/lib/docker to /mnt/docker (since /mnt/docker doesn't exist)
echo "Moving /var/lib/docker to /mnt/docker..."
run_cmd mv /var/lib/docker /mnt/docker

# Set permissions on the moved directory
echo "Setting permissions on /mnt/docker..."
run_cmd chmod 777 /mnt/docker

# Create symlink
echo "Creating symlink from /var/lib/docker to /mnt/docker..."
run_cmd ln -s /mnt/docker /var/lib/docker

# Start Docker service
echo "Starting Docker service..."
run_cmd systemctl start docker

# Wait a moment for Docker to start
sleep 2

# Check Docker status
echo "Checking Docker status..."
run_cmd systemctl status docker --no-pager

echo "========================================="
echo "Docker data directory migration complete!"
echo "========================================="
echo "✅ Docker data moved to /mnt/docker"
echo "✅ Symlink created: /var/lib/docker -> /mnt/docker"
echo "✅ Docker service is running"
echo ""
echo "You can verify the migration with:"
echo "  ls -la /var/lib/docker"
echo "  docker info | grep 'Docker Root Dir'"
echo "========================================="

