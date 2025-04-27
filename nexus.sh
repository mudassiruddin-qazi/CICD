#!/bin/bash

# Update the package list
echo "Updating package list..."
sudo apt update -y

# Install necessary dependencies
echo "Installing necessary dependencies..."
sudo apt install -y wget curl tar

# Install OpenJDK 11 manually from Adoptium
echo "Downloading and installing OpenJDK 11..."

# Download OpenJDK 11
wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.17+8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.17_8.tar.gz

# Extract OpenJDK 11
tar -xvzf OpenJDK11U-jdk_x64_linux_hotspot_11.0.17_8.tar.gz

# Move to /opt directory
sudo mv jdk-11.0.17+8 /opt/

# Set JAVA_HOME and PATH in /etc/environment
echo "Setting up environment variables for Java 11..."
echo "JAVA_HOME=/opt/jdk-11.0.17+8" | sudo tee -a /etc/environment
echo "PATH=\$PATH:/opt/jdk-11.0.17+8/bin" | sudo tee -a /etc/environment

# Reload environment variables
source /etc/environment

# Verify Java installation
echo "Verifying Java installation..."
java -version

# Download Nexus Repository Manager 3.79.1-04
echo "Downloading Nexus Repository Manager version 3.79.1-04..."
wget https://download.sonatype.com/nexus/3/nexus-3.79.1-04-linux-x86_64.tar.gz

# Extract Nexus files
echo "Extracting Nexus..."
tar -xvzf nexus-3.79.1-04-linux-x86_64.tar.gz

# Move Nexus to /opt
sudo mv nexus-3.79.1-04 /opt/nexus

# Create a symlink for Nexus
echo "Creating Nexus symlink..."
sudo ln -s /opt/nexus/bin/nexus /usr/bin/nexus

# Set permissions for Nexus
echo "Setting permissions for Nexus..."
sudo chown -R $USER:$USER /opt/nexus

# Create a Nexus service file
echo "Creating Nexus systemd service..."
cat <<EOL | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=$USER
Group=$USER
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable Nexus service
echo "Enabling Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Verify Nexus service status
echo "Verifying Nexus service..."
sudo systemctl status nexus

echo "Nexus and OpenJDK 11 installation completed."
