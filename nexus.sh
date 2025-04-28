#!/bin/bash

set -e

# Variables
NEXUS_VERSION="3.43.0-01"   # You can adjust this to newer versions if needed
NEXUS_USER="nexus"
INSTALL_DIR="/opt/nexus"
DATA_DIR="/opt/sonatype-work"
DOWNLOAD_URL="https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz"
JAVA_INSTALL_DIR="/usr/lib/jvm/temurin-11-jdk-amd64"

# Update system
echo "Updating system..."
sudo apt-get update -y
sudo apt-get install -y wget tar apt-transport-https ca-certificates software-properties-common gnupg2

# Install Temurin OpenJDK 11
echo "Installing Temurin OpenJDK 11..."
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /usr/share/keyrings/adoptium-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptium-archive-keyring.gpg] https://packages.adoptium.net/artifactory/deb bullseye main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt-get update -y
sudo apt-get install -y temurin-11-jdk

# Verify Java
echo "Verifying Java version..."
java -version

# Create Nexus user
echo "Creating nexus user..."
sudo id -u ${NEXUS_USER} &>/dev/null || sudo useradd --system --no-create-home --shell /bin/false ${NEXUS_USER}

# Download and install Nexus
echo "Downloading Nexus ${NEXUS_VERSION}..."
wget $DOWNLOAD_URL -O /tmp/nexus.tar.gz

echo "Extracting Nexus..."
sudo mkdir -p $INSTALL_DIR
sudo tar -xzf /tmp/nexus.tar.gz -C $INSTALL_DIR --strip-components=1

# Setup data directory
echo "Setting up Nexus data directory..."
sudo mkdir -p $DATA_DIR
sudo chown -R ${NEXUS_USER}:${NEXUS_USER} $INSTALL_DIR $DATA_DIR

# Configure Nexus to run as specific user
echo "Configuring Nexus run user..."
echo "run_as_user=${NEXUS_USER}" | sudo tee $INSTALL_DIR/bin/nexus.rc

# Set Java 11 explicitly for Nexus
echo "Setting Java 11 for Nexus inside script..."
sudo sed -i "s|#INSTALL4J_JAVA_HOME_OVERRIDE=|INSTALL4J_JAVA_HOME_OVERRIDE=${JAVA_INSTALL_DIR}|" $INSTALL_DIR/bin/nexus

# Create a systemd service
echo "Creating systemd service for Nexus..."

sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=simple
LimitNOFILE=65536
User=${NEXUS_USER}
Group=${NEXUS_USER}
Environment=JAVA_HOME=${JAVA_INSTALL_DIR}
ExecStart=${INSTALL_DIR}/bin/nexus run
WorkingDirectory=${INSTALL_DIR}
Restart=on-failure
TimeoutStartSec=600

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Nexus
echo "Reloading systemd and starting Nexus..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

echo ""
echo "✅ Nexus Repository Manager installation completed successfully!"
echo "🌐 Access it at: http://<your-server-ip>:8081"
