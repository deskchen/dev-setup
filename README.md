# Linux Environment Setup Scripts

This collection of shell scripts helps you quickly set up a Linux development environment with essential tools and configurations.

## Scripts Overview

### 🔧 `basic.sh` - Essential Packages
Installs fundamental development tools and utilities:
- **wget** & **curl** - for downloading files
- **git** - version control system
- **build-essential** - compilation tools (gcc, make, etc.)
- **Additional utilities**: vim, htop, tree, unzip, and more
- **Git configuration** - sets up your username and email

### 🐹 `go.sh` - Go Programming Language
Downloads and installs the Go programming language:
- Installs Go v1.21.3 (easily configurable)
- Sets up environment variables (`GOPATH`, `PATH`)
- Creates proper directory structure
- Works with both Bash and Zsh

### 🚀 `omz.sh` - Zsh with Oh My Zsh
Sets up a powerful terminal experience:
- Installs Zsh shell
- Installs Oh My Zsh framework
- Adds useful plugins:
  - `zsh-autosuggestions` - command suggestions
  - `zsh-syntax-highlighting` - syntax highlighting
  - `git`, `sudo`, `colored-man-pages`, `command-not-found`
- Configures aliases and history settings
- Sets Zsh as default shell

### 🔐 `git.sh` - Git with Personal Access Token
Configures Git and manages personal access tokens:
- Interactive Git user configuration
- Personal access token setup for private repositories
- Secure credential storage and management
- Easy private repository cloning

### ☸️ `k8s.sh` - Kubernetes Environment
Sets up Kubernetes development environment:
- Installs Docker and Kubernetes tools (kubectl, kubeadm, kubelet)
- Configures kernel modules and networking
- Optional single-node cluster setup with Flannel CNI
- Kubectl completion and aliases for Zsh
- Docker group configuration

## Quick Start

1. **Clone or download** these scripts to your Linux machine
2. **Make scripts executable**:
   ```bash
   chmod +x *.sh
   ```
3. **Run scripts in order** (recommended):
   ```bash
   ./basic.sh        # Install essential packages first
   ./omz.sh          # Set up your shell environment
   ./git.sh          # Configure Git with personal access token
   ./go.sh           # Install Go (if needed)
   ./k8s.sh          # Install Kubernetes tools (optional)
   ```