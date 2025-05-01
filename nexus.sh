#!/bin/bash

set -e

echo "Installing Java (OpenJDK 17)..."
sudo apt update
sudo apt install -y openjdk-17-jdk wget tar

echo "Creating nexus user..."
sudo useradd --system --no-create-home --shell /bin/false nexus

echo "Downloading Nexus 3.79.1-04..."
cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-3.79.1-04-linux-x86_64.tar.gz -O nexus.tar.gz
sudo tar -xvzf nexus.tar.gz
sudo mv nexus-3.79.1-04 nexus
sudo chown -R nexus:nexus /opt/nexus

echo "Configuring Nexus to run as a service..."
sudo ln -s /opt/nexus/bin/nexus /etc/init.d/nexus
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc

echo "Creating systemd service for Nexus..."

cat <<EOF | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd and starting Nexus..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

echo "Nexus installation complete."
echo "Access it at: http://<your_server_ip>:8081"
echo "Initial admin password (after startup):"
echo "  /opt/sonatype-work/nexus3/admin.password"
