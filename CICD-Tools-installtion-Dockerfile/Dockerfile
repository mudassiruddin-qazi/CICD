# Start with a base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (Git, Docker, Kubectl, Jenkins, Google Cloud SDK, etc.)
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    ca-certificates \
    unzip \
    sudo \
    git \
    docker.io \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    apt-transport-https \
    gnupg2 \
    lsb-release \
    jq \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Add Google's official GPG key for the SDK
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /etc/apt/trusted.gpg.d/google.asc

# Add the Google Cloud SDK to the apt sources list
RUN echo "deb [signed-by=/etc/apt/trusted.gpg.d/google.asc] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install the Google Cloud SDK
RUN apt-get update && apt-get install -y google-cloud-sdk

# Download the latest Jenkins WAR file
RUN curl -fsSL https://get.jenkins.io/war/latest/jenkins.war -o /usr/local/bin/jenkins-cli.jar

# Set up Jenkins-related environment
ENV JENKINS_HOME=/var/jenkins_home

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install other CI/CD tools
RUN pip3 install --upgrade pip \
    && pip3 install awscli ansible

# Set the working directory
WORKDIR /workspace

# Set the default command
CMD ["bash"]
