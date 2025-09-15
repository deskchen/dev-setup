#!/bin/bash

# Basic Linux Environment Setup Script
# Installs essential packages for development

# --- Exit immediately if a command exits with a non-zero status ---
set -e

echo "========================================="
echo "Setting up basic Linux environment..."
echo "========================================="

# --- Update package lists ---
echo "Updating package lists..."
sudo apt-get update

# --- Install essential packages ---
echo "Installing essential packages..."
sudo apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    vim \
    htop \
    neofetch \
    bat \
    tree

echo "========================================="
echo "Basic setup complete!"
echo "========================================="
echo "Installed packages:"
echo "✅ wget, curl - for downloading files"
echo "✅ git - version control"
echo "✅ build-essential - compilation tools"
echo "✅ Additional utilities: vim, htop, tree, unzip"
echo "========================================="
