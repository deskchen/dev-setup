#!/bin/bash

# Dev Setup Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/deskchen/dev-setup/main/install.sh | sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository information
REPO_URL="https://github.com/deskchen/dev-setup"
RAW_URL="https://raw.githubusercontent.com/deskchen/dev-setup/main"
TEMP_DIR="/tmp/dev-setup-$$"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

# Function to download a file
download_file() {
    local url="$1"
    local dest="$2"
    local filename=$(basename "$dest")
    
    print_status "Downloading $filename..."
    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$dest"
    else
        print_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
}

# Function to make script executable and run it
run_script() {
    local script="$1"
    local script_name=$(basename "$script")
    
    if [ -f "$script" ]; then
        chmod +x "$script"
        print_status "Running $script_name..."
        bash "$script"
        print_status "$script_name completed successfully"
    else
        print_warning "$script_name not found, skipping..."
    fi
}

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_status "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set up cleanup on exit (but not for interactive input)
trap cleanup INT TERM

# Main installation function
main() {
    print_header "Development Environment Setup"
    print_status "Starting automated development environment setup..."
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Download all setup scripts
    print_status "Downloading setup scripts from $REPO_URL..."
    
    # List of scripts to download
    scripts=(
        "basic.sh"
        "git.sh"
        "omz.sh"
        "go.sh"
        "k8s.sh"
        "personal.zsh-theme"
    )
    
    # Download each script
    for script in "${scripts[@]}"; do
        download_file "$RAW_URL/$script" "$TEMP_DIR/$script"
    done
    
    print_status "All scripts downloaded successfully"
    
    # Interactive menu for script selection
    echo ""
    print_header "Installation Options"
    echo "Choose which components to install:"
    echo "1) Basic tools and utilities (recommended)"
    echo "2) Git configuration"
    echo "3) Oh My Zsh with custom theme"
    echo "4) Go programming language"
    echo "5) Kubernetes tools (kubectl, helm, etc.)"
    echo "6) Install all components"
    echo "7) Custom selection"
    echo ""
    
    read -p "Enter your choice (1-7): " choice
    
    case $choice in
        1)
            run_script "$TEMP_DIR/basic.sh"
            ;;
        2)
            run_script "$TEMP_DIR/git.sh"
            ;;
        3)
            run_script "$TEMP_DIR/omz.sh"
            ;;
        4)
            run_script "$TEMP_DIR/go.sh"
            ;;
        5)
            run_script "$TEMP_DIR/k8s.sh"
            ;;
        6)
            print_status "Installing all components..."
            run_script "$TEMP_DIR/basic.sh"
            run_script "$TEMP_DIR/git.sh"
            run_script "$TEMP_DIR/omz.sh"
            run_script "$TEMP_DIR/go.sh"
            run_script "$TEMP_DIR/k8s.sh"
            ;;
        7)
            echo ""
            print_status "Custom selection mode:"
            
            read -p "Install basic tools? (y/n): " install_basic
            [ "$install_basic" = "y" ] && run_script "$TEMP_DIR/basic.sh"
            
            read -p "Configure Git? (y/n): " install_git
            [ "$install_git" = "y" ] && run_script "$TEMP_DIR/git.sh"
            
            read -p "Install Oh My Zsh? (y/n): " install_omz
            [ "$install_omz" = "y" ] && run_script "$TEMP_DIR/omz.sh"
            
            read -p "Install Go? (y/n): " install_go
            [ "$install_go" = "y" ] && run_script "$TEMP_DIR/go.sh"
            
            read -p "Install Kubernetes tools? (y/n): " install_k8s
            [ "$install_k8s" = "y" ] && run_script "$TEMP_DIR/k8s.sh"
            ;;
        *)
            print_error "Invalid choice. Exiting."
            exit 1
            ;;
    esac
    
    print_header "Installation Complete!"
    print_status "Your development environment has been set up successfully."
    print_status "You may need to restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to apply all changes."
    
    # Show next steps
    echo ""
    print_status "Next steps:"
    echo "• Restart your terminal or run: exec \$SHELL"
    echo "• If you installed Zsh, log out and back in to use it as default shell"
    echo "• Check that all tools are working: git --version, go version, kubectl version --client"
    echo ""
    
    print_status "For more information, visit: $REPO_URL"
}

# Non-interactive mode for CI/CD or automated setups
if [ "$1" = "--non-interactive" ] || [ "$1" = "--auto" ]; then
    print_status "Running in non-interactive mode - installing all components"
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Download and run all scripts
    scripts=("basic.sh" "git.sh" "omz.sh" "go.sh" "k8s.sh" "personal.zsh-theme")
    
    for script in "${scripts[@]}"; do
        if [ "$script" != "personal.zsh-theme" ]; then
            download_file "$RAW_URL/$script" "$TEMP_DIR/$script"
            run_script "$TEMP_DIR/$script"
        else
            download_file "$RAW_URL/$script" "$TEMP_DIR/$script"
        fi
    done
    
    print_header "Non-interactive Installation Complete!"
else
    # Run interactive mode
    main
fi
