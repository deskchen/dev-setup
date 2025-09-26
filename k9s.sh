#!/bin/bash

# A simple script to install k9s on Debian/Ubuntu systems.
# It will exit immediately if any command fails.
set -e

# 1. Install required packages for Homebrew using apt
echo "Updating package list and installing dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential procps curl file git

# 2. Install Homebrew (if it's not already installed)
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    # Run the official installer non-interactively
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to your PATH for this script and for future terminal sessions
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    echo "✅ Homebrew installed."
else
    echo "Homebrew is already installed."
fi

# 3. Install k9s using Homebrew
echo "Installing k9s..."
brew install k9s

echo "--------------------------------------------------"
echo "🚀 k9s installation complete!"
echo "You may need to run 'source ~/.profile' or restart your terminal."
echo "Then, just type 'k9s' to start."