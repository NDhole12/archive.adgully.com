# UFW Firewall Rules for Archive.adgully.com
# Apply with: sudo bash ufw-rules.sh

#!/bin/bash

# Reset UFW to default
sudo ufw --force reset

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (CRITICAL - do this first!)
sudo ufw allow 22/tcp comment 'SSH'

# Allow HTTP
sudo ufw allow 80/tcp comment 'HTTP'

# Allow HTTPS
sudo ufw allow 443/tcp comment 'HTTPS'

# Optional: Allow custom SSH port (if you changed it)
# sudo ufw allow CUSTOM_PORT/tcp comment 'Custom SSH'

# Optional: Allow specific IP for MySQL (if remote access needed)
# sudo ufw allow from YOUR_IP_ADDRESS to any port 3306 comment 'MySQL from specific IP'

# Enable UFW
sudo ufw --force enable

# Show status
sudo ufw status verbose

echo "Firewall rules applied successfully!"
