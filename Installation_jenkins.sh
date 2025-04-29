#!/bin/bash

set -e  # Exit on any error

echo "Updating packages and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y wget curl apt-transport-https ca-certificates gnupg git

echo "Installing OpenJDK 17 from Adoptium..."
sudo mkdir -p /etc/apt/keyrings
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
CODENAME=$(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release)
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $CODENAME main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sudo apt install -y openjdk-17-jdk

echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins

echo "Installing Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Adding Jenkins user to Docker group..."
sudo usermod -aG docker jenkins

echo "Installing kubectl, nfs-common, and GCP SDK plugin..."
sudo apt-get install -y kubectl nfs-common google-cloud-sdk-gke-gcloud-auth-plugin

echo "System setup completed. Reboot recommended."
