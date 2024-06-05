#!/bin/bash

# Update package list
sudo apt update -y

# Install Java 11 JDK
sudo apt install openjdk-11-jdk -y

# Install Maven, wget, and unzip
sudo apt install maven wget unzip -y

# Add Jenkins repository key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list again (to include Jenkins repository)
sudo apt-get update -y

# Install Jenkins
sudo apt-get install jenkins -y

# Enable UFW (Uncomplicated Firewall)
sudo ufw enable

# Allow incoming traffic on port 8080 (Jenkins web interface)
sudo ufw allow 8080/tcp
