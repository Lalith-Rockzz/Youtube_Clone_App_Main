#!/bin/bash

# Update the package list to ensure all package sources are up-to-date.
sudo apt update -y

# Install Java (required by Jenkins).
# Download the GPG key for the Adoptium repository for secure package verification.
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /usr/share/keyrings/adoptium.asc > /dev/null

# Add the Adoptium repository for Java installation.
# Dynamically determine the system codename using the /etc/os-release file.
echo "deb [signed-by=/usr/share/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

# Update the package list again to include the new Adoptium repository.
sudo apt update -y

# Install the Temurin JDK version 17 from the Adoptium repository.
sudo apt install temurin-17-jdk -y

# Configure the JAVA_HOME environment variable for system-wide access to Java.
echo "export JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64" >> ~/.bashrc

# Update the PATH variable to include Java binaries and make them accessible globally.
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc

# Apply the changes to the current shell session.
source ~/.bashrc

# Verify Java installation and display its version to ensure it's installed correctly.
java --version

# Install Jenkins.
# Fetch the GPG key for the Jenkins repository and save it for secure package verification.
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add the Jenkins repository for package installation.
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update the package list to include the Jenkins repository.
sudo apt-get update -y

# Install Jenkins package from the newly added repository.
sudo apt-get install jenkins -y

# Start the Jenkins service after installation.
sudo systemctl start jenkins

# Check the status of the Jenkins service to confirm it's running.
sudo systemctl status jenkins

# Restart the Jenkins service to ensure all configurations are applied.
sudo systemctl restart jenkins

# Install Docker and run SonarQube container.
# Install Docker, a containerization tool, to run SonarQube as a container.
sudo apt-get install docker.io -y

# Add the 'ubuntu' user to the 'docker' group to allow non-root Docker usage.
sudo usermod -aG docker ubuntu

# Add the 'jenkins' user to the 'docker' group for Docker access within Jenkins jobs.
sudo usermod -aG docker jenkins

# Refresh group memberships to apply changes without logging out.
newgrp docker

# Grant full permissions on the Docker socket to avoid access issues.
sudo chmod 777 /var/run/docker.sock

# Pull and run the SonarQube container in detached mode.
# Expose the SonarQube service on port 9000 for access.
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# Install Trivy for security scanning.
# Install required dependencies for setting up the Trivy repository.
sudo apt-get install wget apt-transport-https gnupg lsb-release -y

# Download and add the GPG key for the Trivy repository.
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

# Add the Trivy repository to the system's package sources.
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# Update the package list to include the Trivy repository.
sudo apt-get update

# Install Trivy, a tool for container security scanning.
sudo apt-get install trivy -y
