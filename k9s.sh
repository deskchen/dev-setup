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
    
    # Check if Homebrew environment is already configured
    if ! grep -q "# Homebrew environment" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Homebrew environment" >> "$SHELL_CONFIG"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$SHELL_CONFIG"
        echo "Homebrew environment added to ${SHELL_CONFIG}"
    else
        echo "Homebrew environment already configured in ${SHELL_CONFIG}"
    fi
    echo "✅ Homebrew installed."
else
    echo "Homebrew is already installed."
fi

# 3. Install k9s using Homebrew
echo "Installing k9s..."
brew install k9s

echo "--------------------------------------------------"
echo "🚀 k9s installation complete!"
echo "To use k9s and brew commands, either:"
echo "1. Restart your terminal, OR"
echo "2. Run: source ${SHELL_CONFIG:-~/.profile}"
echo ""
echo "Then, just type 'k9s' to start managing your Kubernetes clusters!"