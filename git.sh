#!/bin/bash

# Git Authentication Setup
# Choose between personal access token or SSH keys (RSA)

# --- Exit immediately if a command exits with a non-zero status ---
set -e

echo "========================================="
echo "Git Authentication Setup"
echo "========================================="

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please run basic.sh first."
    exit 1
fi

# Basic Git config
echo "Setting up Git..."
read -p "Enter your Git username: " git_user
read -p "Enter your Git email: " git_email

# Configure Git basics
git config --global user.name "$git_user"
git config --global user.email "$git_email"
git config --global init.defaultBranch main

echo ""
echo "Choose authentication method:"
echo "1) Personal Access Token (HTTPS)"
echo "2) SSH Keys (RSA)"
read -p "Enter your choice (1 or 2): " auth_choice

case $auth_choice in
    1)
        echo ""
        echo "--- Personal Access Token Setup ---"
        read -s -p "Enter your personal access token: " git_token
        echo ""
        
        # Configure credential helper and store token
        git config --global credential.helper store
        echo "https://${git_user}:${git_token}@github.com" > ~/.git-credentials
        chmod 600 ~/.git-credentials
        
        echo ""
        echo "✅ Personal access token stored for GitHub"
        echo "✅ You can now clone with: git clone https://github.com/user/repo.git"
        ;;
    2)
        echo ""
        echo "--- SSH Key Setup ---"
        
        # Check if SSH key already exists
        if [ -f ~/.ssh/id_rsa ]; then
            echo "SSH key already exists at ~/.ssh/id_rsa"
            read -p "Do you want to generate a new one? (y/N): " generate_new
            if [[ ! "$generate_new" =~ ^[Yy]$ ]]; then
                echo "Using existing SSH key."
                cat ~/.ssh/id_rsa.pub
                echo ""
                echo "✅ Copy the above public key to your Git provider"
                echo "✅ You can now clone with: git clone git@github.com:user/repo.git"
                exit 0
            fi
        fi
        
        # Generate SSH key
        echo "Generating SSH key with your email: $git_email"
        ssh-keygen -t rsa -b 4096 -C "$git_email" -f ~/.ssh/id_rsa -N ""
        
        # Start ssh-agent and add key
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa
        
        echo ""
        echo "✅ SSH key generated successfully!"
        echo "✅ Your public key:"
        echo ""
        cat ~/.ssh/id_rsa.pub
        echo ""
        echo "📋 Next steps:"
        echo "1. Copy the above public key"
        echo "2. Add it to your Git provider:"
        echo "   • GitHub: Settings → SSH and GPG keys → New SSH key"
        echo "   • GitLab: User Settings → SSH Keys"
        echo "3. Test with: ssh -T git@github.com"
        echo "4. Clone with: git clone git@github.com:user/repo.git"
        ;;
    *)
        echo "Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "========================================="
echo "Git setup complete!"
echo "========================================="
echo "✅ Git configured with your credentials"
echo "✅ Authentication method set up"
echo "✅ You won't need to enter credentials again"
echo "========================================="
