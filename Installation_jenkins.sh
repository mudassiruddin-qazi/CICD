#!/bin/bash

# Update package lists
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade -y

# Install prerequisites
sudo apt-get install -y wget curl gnupg apt-transport-https ca-certificates software-properties-common

# Install Git
sudo apt-get install -y git

# Install OpenJDK 17
sudo apt-get install -y openjdk-17-jdk

# Verify Java installation
java -version

# Add Jenkins repository key
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository to sources list
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update and install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Start and enable Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install kubectl
sudo apt-get install -y kubectl

# Install NFS common utilities
sudo apt-get install -y nfs-common

# Install Google Cloud SDK (includes gcloud and auth plugin)
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

sudo apt-get update
sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin

# Verify installations
echo "Installation Complete!"
echo "Java version:"
java -version
echo "Git version:"
git --version
echo "Jenkins status:"
sudo systemctl status jenkins | grep Active
