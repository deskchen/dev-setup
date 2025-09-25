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

# Function to read input safely (handles piped input)
safe_read() {
    local prompt="$1"
    local var_name="$2"
    
    # Try different methods to read user input
    if [ -t 0 ]; then
        # Standard input is a terminal
        read -p "$prompt" "$var_name"
    else
        # Input is piped, try to restore terminal input
        if [ -t 2 ]; then
            # stderr is connected to terminal, use it for input
            echo -n "$prompt" >&2
            read "$var_name" <&2
        else
            # Last resort: just read from stdin (may hang if truly piped)
            echo -n "$prompt"
            read "$var_name"
        fi
    fi
}

# Function to download and run a script
download_and_run() {
    local script_with_args="$1"
    local script_name=$(echo "$script_with_args" | awk '{print $1}')
    local script_path="$TEMP_DIR/$script_name"
    
    # Create temp directory if it doesn't exist
    mkdir -p "$TEMP_DIR"
    
    # Download the script
    download_file "$RAW_URL/$script_name" "$script_path"
    
    # Run the script with arguments
    run_script "$script_path $(echo "$script_with_args" | cut -d' ' -f2-)"
}

# Function to run script from local file
run_script() {
    local script_with_args="$1"
    local script_path=$(echo "$script_with_args" | awk '{print $1}')
    local script_name=$(basename "$script_path")
    local script_args=$(echo "$script_with_args" | cut -d' ' -f2-)
    
    # If script_args is the same as script_with_args, there are no args
    if [ "$script_args" = "$script_with_args" ]; then
        script_args=""
    fi
    
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        print_status "Running $script_name..."
        # Run the script with proper terminal access
        if [ -c /dev/tty ] 2>/dev/null; then
            bash "$script_path" $script_args < /dev/tty
        else
            bash "$script_path" $script_args
        fi
        print_status "$script_name completed successfully"
    else
        print_warning "$script_name not found, skipping..."
        return 1
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
    echo "8) Exit"
    echo ""
    
    safe_read "Enter your choice (1-8): " choice
    
    case $choice in
        1)
            download_and_run "basic.sh"
            ;;
        2)
            download_and_run "git.sh"
            ;;
        3)
            # Download theme file first for Oh My Zsh
            mkdir -p "$TEMP_DIR"
            download_file "$RAW_URL/personal.zsh-theme" "$TEMP_DIR/personal.zsh-theme"
            download_and_run "omz.sh"
            ;;
        4)
            download_and_run "go.sh"
            ;;
        5)
            download_and_run "k8s.sh -s"
            ;;
        6)
            print_status "Installing all components..."
            download_and_run "basic.sh"
            download_and_run "git.sh"
            # Download theme file first for Oh My Zsh
            mkdir -p "$TEMP_DIR"
            download_file "$RAW_URL/personal.zsh-theme" "$TEMP_DIR/personal.zsh-theme"
            download_and_run "omz.sh"
            download_and_run "go.sh"
            download_and_run "k8s.sh -s"
            ;;
        7)
            echo ""
            print_status "Custom selection mode:"
            
            safe_read "Install basic tools? (y/n): " install_basic
            [ "$install_basic" = "y" ] && download_and_run "basic.sh"
            
            safe_read "Configure Git? (y/n): " install_git
            [ "$install_git" = "y" ] && download_and_run "git.sh"
            
            safe_read "Install Oh My Zsh? (y/n): " install_omz
            if [ "$install_omz" = "y" ]; then
                # Download theme file first for Oh My Zsh
                mkdir -p "$TEMP_DIR"
                download_file "$RAW_URL/personal.zsh-theme" "$TEMP_DIR/personal.zsh-theme"
                download_and_run "omz.sh"
            fi
            
            safe_read "Install Go? (y/n): " install_go
            [ "$install_go" = "y" ] && download_and_run "go.sh"
            
            safe_read "Install Kubernetes tools? (y/n): " install_k8s
            [ "$install_k8s" = "y" ] && download_and_run "k8s.sh -s"
            ;;
        8)
            print_status "Exiting..."
            exit 0
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
    
    # Create temporary directory for theme file
    mkdir -p "$TEMP_DIR"
    
    # Download theme file first for Oh My Zsh
    download_file "$RAW_URL/personal.zsh-theme" "$TEMP_DIR/personal.zsh-theme"
    
    # Download and run all scripts
    download_and_run "basic.sh"
    download_and_run "git.sh"
    download_and_run "omz.sh"
    download_and_run "go.sh"
    download_and_run "k8s.sh -s"
    
    print_header "Non-interactive Installation Complete!"
else
    # Run interactive mode
    main
fi
