#!/bin/bash

# Oh My Zsh Installation and Configuration Script
# Installs Zsh, Oh My Zsh, and sets up a nice configuration

# --- Exit immediately if a command exits with a non-zero status ---
set -e

echo "========================================="
echo "Setting up Zsh with Oh My Zsh..."
echo "========================================="

# --- Install Zsh if not already installed ---
if ! command -v zsh &> /dev/null; then
    echo "Installing Zsh..."
    sudo apt-get update
    sudo apt-get install -y zsh
else
    echo "Zsh is already installed"
fi

# --- Install Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed"
fi

# --- Copy custom theme ---
echo "Installing custom theme..."
if [ -f "$(dirname "$0")/personal.zsh-theme" ]; then
    cp "$(dirname "$0")/personal.zsh-theme" "$HOME/.oh-my-zsh/themes/"
    echo "Custom theme copied to Oh My Zsh themes folder"
else
    echo "Warning: personal.zsh-theme not found in script directory"
fi

# --- Install popular plugins ---
echo "Installing useful Oh My Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# --- Configure .zshrc ---
echo "Configuring .zshrc..."

# Backup existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

# Create a new .zshrc configuration
cat > "$HOME/.zshrc" << 'EOF'
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="personal"

# Plugins to load
plugins=(
    git
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    command-not-found
)

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='vim'
export LANG=en_US.UTF-8

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# History configuration
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

EOF

# --- Set Zsh as default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting Zsh as default shell..."
    sudo chsh -s $(which zsh) $USER
    echo "Default shell changed to Zsh. You'll need to log out and back in for this to take effect."
else
    echo "Zsh is already the default shell"
fi

echo "========================================="
echo "Oh My Zsh setup complete!"
echo "========================================="
echo "✅ Zsh installed"
echo "✅ Oh My Zsh installed with personal custom theme"
echo "✅ Useful plugins installed:"
echo "   - zsh-autosuggestions (suggests commands as you type)"
echo "   - zsh-syntax-highlighting (highlights valid commands)"
echo "   - git, sudo, colored-man-pages, command-not-found"
echo "✅ Custom aliases and history settings configured"
echo "✅ Personal custom theme installed and configured"
echo "✅ Zsh set as default shell"
echo ""
echo "To start using your new shell:"
echo "1. Log out and log back in, OR"
echo "2. Run: exec zsh"
echo ""
echo "Your old .zshrc has been backed up"
echo "========================================="
