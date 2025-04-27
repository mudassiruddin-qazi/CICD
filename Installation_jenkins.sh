#!/bin/bash

set -e

echo "🚀 Starting full setup..."

# Update and upgrade packages
echo "🔄 Updating package lists..."
sudo apt-get update -y
sudo apt-get upgrade -y

# --- Install Java 17 ---
echo "☕ Installing OpenJDK 17..."
if java -version 2>&1 | grep "17" > /dev/null; then
    echo "✅ Java 17 already installed."
else
    sudo apt-get install -y openjdk-17-jdk
fi

# --- Install Git ---
echo "🔧 Installing Git..."
if git --version 2>/dev/null; then
    echo "✅ Git already installed."
else
    sudo apt-get install -y git
fi

# --- Install kubectl ---
echo "☸️ Installing kubectl..."
if kubectl version --client --short 2>/dev/null; then
    echo "✅ kubectl already installed."
else
    sudo apt-get install -y apt-transport-https ca-certificates curl
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | \
      sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
fi

# --- Install NFS common ---
echo "📂 Installing NFS Common..."
if dpkg -l | grep nfs-common > /dev/null; then
    echo "✅ NFS Common already installed."
else
    sudo apt-get install -y nfs-common
fi

# --- Install Google Cloud SDK ---
echo "☁️ Installing Google Cloud SDK..."
if gcloud version 2>/dev/null; then
    echo "✅ Google Cloud SDK already installed."
else
    echo "🛠️ Adding Google Cloud SDK repo..."
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
      sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

    sudo mkdir -p /usr/share/keyrings
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg > /dev/null

    sudo apt-get update
    sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin
fi

# --- Install Jenkins properly (with correct GPG key) ---
echo "👷 Installing Jenkins..."
if systemctl status jenkins 2>/dev/null; then
    echo "✅ Jenkins already installed."
else
    echo "🛠️ Fixing Jenkins repo and GPG key..."

    # Remove old Jenkins repo and key if exist
    sudo rm -f /etc/apt/sources.list.d/jenkins.list
    sudo rm -f /usr/share/keyrings/jenkins-keyring.gpg

    # Add new Jenkins GPG key and repo
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | \
      sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y jenkins

    echo "🔛 Starting and enabling Jenkins service..."
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
fi

echo "✅ Full setup completed successfully!"
