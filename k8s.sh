#!/bin/bash

# Kubernetes Environment Setup Script
# Installs Docker, Kubernetes tools, and optionally sets up a single-node cluster

# --- Exit immediately if a command exits with a non-zero status ---
set -e

# Configuration
K8S_VERSION="1.28"
SETUP_CLUSTER=false

# Parse command line arguments
while getopts ":hs" opt; do
  case $opt in
    h)
      echo "========================================="
      echo "Kubernetes Environment Setup Script"
      echo "========================================="
      echo "Usage: $0 [-s]"
      echo "  -s        Set up single-node cluster after installation"
      echo "  -h        Show this help message"
      echo ""
      echo "This script installs Docker, Kubernetes tools, and uses Flannel CNI."
      echo ""
      echo "Examples:"
      echo "  $0                    # Install K8s tools only"
      echo "  $0 -s                 # Install and setup cluster with Flannel"
      exit 0
      ;;
    s)
      SETUP_CLUSTER=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Use -h for help"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

echo "========================================="
echo "Setting up Kubernetes environment..."
echo "========================================="

# --- 1. Configure kernel modules and networking ---
echo "Configuring kernel modules and networking..."
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# --- 2. Install prerequisites and update package lists ---
echo "Installing prerequisites and updating package lists..."
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    xdg-utils

# --- 3. Set up Docker repository ---
echo "Setting up Docker repository..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- 4. Set up Kubernetes repository ---
echo "Setting up Kubernetes repository..."
sudo mkdir -p /etc/apt/keyrings
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# --- 5. Update package lists and install Docker + Kubernetes ---
echo "Installing Docker and Kubernetes components..."
sudo apt-get update
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    kubelet \
    kubeadm \
    kubectl

# Hold Kubernetes packages to prevent automatic updates
sudo apt-mark hold kubelet kubeadm kubectl

# --- 6. Configure Docker ---
echo "Configuring Docker..."
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# --- 7. Configure containerd and disable swap ---
echo "Configuring containerd and disabling swap..."
sudo rm -f "/etc/containerd/config.toml"
sudo swapoff -a

# Restart services
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl restart containerd

# Add user to docker group
sudo usermod -aG docker $USER

echo "========================================="
echo "Kubernetes environment setup complete!"
echo "========================================="
echo "✅ Kernel modules and networking configured"
echo "✅ Docker installed and configured"
echo "✅ Kubernetes components installed (kubelet, kubeadm, kubectl)"
echo "✅ Swap disabled"
echo "✅ User added to docker group"
echo ""

# --- 8. Optional cluster setup ---
if [ "$SETUP_CLUSTER" = true ]; then
    echo "========================================="
    echo "Setting up single-node Kubernetes cluster..."
    echo "========================================="
    
    # Clean up any existing cluster
    echo "Cleaning up any existing cluster configuration..."
    sudo rm -f /etc/cni/net.d/*
    
    sudo kubeadm reset -f
    sudo rm -rf $HOME/.kube
    
    # Initialize cluster
    echo "Initializing Kubernetes cluster..."
    sudo kubeadm init --pod-network-cidr 10.244.0.0/17
    
    # Set up kubectl for current user
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Install Flannel CNI
    echo "Installing Flannel CNI..."
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    
    # Allow scheduling pods on control plane (single-node setup)
    echo "Configuring single-node cluster (removing control-plane taint)..."
    kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
    
    # Set up kubectl alias and completion for Zsh
    echo "Setting up kubectl alias and completion for Zsh..."
    if [ -f ~/.zshrc ]; then
        if ! grep -q "kubectl completion" ~/.zshrc 2>/dev/null; then
            echo "" >> ~/.zshrc
            echo "# Kubectl completion and alias" >> ~/.zshrc
            echo "source <(kubectl completion zsh)" >> ~/.zshrc
            echo "alias k='kubectl'" >> ~/.zshrc
            echo "complete -F __start_kubectl k" >> ~/.zshrc
        fi
    else
        echo "Warning: .zshrc not found. Please run oh-my-zsh.sh first to set up Zsh."
        echo "Adding kubectl alias to .bashrc as fallback..."
        if ! grep -q "alias k='kubectl'" ~/.bashrc 2>/dev/null; then
            echo "alias k='kubectl'" >> ~/.bashrc
        fi
    fi
    
    echo "========================================="
    echo "Kubernetes cluster setup complete!"
    echo "========================================="
    echo "✅ Cluster initialized with Flannel CNI"
    echo "✅ Single-node configuration (control-plane taint removed)"
    echo "✅ kubectl configured for current user"
    echo "✅ kubectl alias 'k' added to Zsh"
    echo ""
    echo "Useful commands:"
    echo "  kubectl get nodes                 # Check node status"
    echo "  kubectl get pods -A               # Check all pods"
    echo "  kubectl cluster-info              # Cluster information"
    echo ""
    echo "Note: You may need to restart your shell or run:"
    echo "  source ~/.zshrc"
    echo "========================================="
else
    echo "To set up a cluster later, run: $0 -s"
    echo ""
    echo "Next steps:"
    echo "1. Log out and back in (or run 'newgrp docker')"
    echo "2. Verify Docker: docker run hello-world"
    echo "3. Verify Kubernetes: kubectl version --client"
fi
