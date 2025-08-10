#!/bin/bash
# === Docker Installation ===
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ubuntu

# === Jenkins Installation ===
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y openjdk-11-jdk jenkins
usermod -aG docker jenkins

# === Jenkins Auto-Configuration ===
JENKINS_INIT_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# 1. Create config directory
sudo mkdir -p /var/lib/jenkins/init.groovy.d

# 2. Configure Security (Auto-Unlock)
sudo bash -c "cat > /var/lib/jenkins/init.groovy.d/security.groovy" <<EOF
import jenkins.model.*
import hudson.security.*
import jenkins.install.InstallState

def instance = Jenkins.get()

// Skip setup wizard
if(!instance.installState.isSetupComplete()) {
  instance.installState = InstallState.INITIAL_SETUP_COMPLETED
}

// Create admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", '${JENKINS_INIT_PASSWORD}')
instance.setSecurityRealm(hudsonRealm)

// Set authorization strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

// Save configuration
instance.save()
EOF

# 3. Install Required Plugins (Only Essentials)
sudo bash -c "cat > /var/lib/jenkins/init.groovy.d/plugins.groovy" <<EOF
import jenkins.model.*
import java.util.logging.Logger

def logger = Logger.getLogger("")
def plugins = ["workflow-aggregator", "git", "docker-workflow"] 

// Wait until Jenkins is ready
while(true) {
  try {
    def pluginManager = Jenkins.instance.pluginManager
    def updateCenter = Jenkins.instance.updateCenter
    
    plugins.each { plugin ->
      if (!pluginManager.getPlugin(plugin)) {
        logger.info("Installing \${plugin}")
        def installation = updateCenter.getPlugin(plugin).deploy()
        installation.get()
      }
    }
    break
  } catch(Exception e) {
    logger.info("Jenkins not ready, retrying in 10s...")
    Thread.sleep(10000)
  }
}
EOF

# 4. Configure Jenkins URL
sudo bash -c "echo 'JENKINS_URL=http://${PUBLIC_IP}:8080' >> /etc/environment"

# 5. Restart Jenkins
systemctl restart jenkins

# === Verification ===
echo "Waiting for Jenkins to initialize..."
while ! curl -s http://localhost:8080 >/dev/null; do
  sleep 10
done

if curl -s http://localhost:8080/api/json | grep -q 'INITIAL_SETUP_COMPLETED'; then
  echo "Jenkins successfully configured!"
  echo "Access URL: http://${PUBLIC_IP}:8080"
  echo "Admin password: ${JENKINS_INIT_PASSWORD}"
else
  echo "Configuration failed! Manual steps:"
  echo "1. Access http://${PUBLIC_IP}:8080"
  echo "2. Enter password: ${JENKINS_INIT_PASSWORD}"
  echo "3. Install suggested plugins"
fi