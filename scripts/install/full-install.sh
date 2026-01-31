#!/bin/bash
# Full Server Installation Script for Ubuntu 22.04
# Usage: sudo bash full-install.sh

set -e  # Exit on error

echo "========================================"
echo "Archive.adgully.com Server Installation"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# Variables
DOMAIN="archive.adgully.com"
WWW_ROOT="/var/www/$DOMAIN"
DB_NAME="archive_db"
DB_USER="archive_user"
echo -n "Enter MySQL root password: "
read -s MYSQL_ROOT_PASS
echo ""
echo -n "Enter database user password: "
read -s DB_PASS
echo ""

echo ""
echo "===== Phase 1: System Update ====="
apt update && apt upgrade -y
apt install -y software-properties-common apt-transport-https ca-certificates \
  curl wget gnupg2 lsb-release ubuntu-keyring git unzip vim htop

echo ""
echo "===== Phase 2: Install Nginx ====="
apt install -y nginx
systemctl start nginx
systemctl enable nginx

echo ""
echo "===== Phase 3: Install PHP 8.2 ====="
add-apt-repository -y ppa:ondrej/php
apt update
apt install -y php8.2-fpm php8.2-cli php8.2-common php8.2-mysql \
  php8.2-mysqli php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml \
  php8.2-zip php8.2-bcmath php8.2-intl php8.2-readline php8.2-opcache \
  php8.2-redis php8.2-mongodb php8.2-tidy php8.2-soap

# Configure PHP
mkdir -p /var/log/php
chown www-data:www-data /var/log/php
chmod 755 /var/log/php

systemctl start php8.2-fpm
systemctl enable php8.2-fpm

echo ""
echo "===== Phase 4: Install MariaDB ====="
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | \
  bash -s -- --mariadb-server-version="mariadb-10.11"
apt update
apt install -y mariadb-server mariadb-client

systemctl start mariadb
systemctl enable mariadb

# Secure MariaDB
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASS';"
mysql -u root -p"$MYSQL_ROOT_PASS" -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p"$MYSQL_ROOT_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -p"$MYSQL_ROOT_PASS" -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p"$MYSQL_ROOT_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -u root -p"$MYSQL_ROOT_PASS" -e "FLUSH PRIVILEGES;"

# Create database and user
mysql -u root -p"$MYSQL_ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p"$MYSQL_ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -u root -p"$MYSQL_ROOT_PASS" -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u root -p"$MYSQL_ROOT_PASS" -e "FLUSH PRIVILEGES;"

echo ""
echo "===== Phase 5: Configure Firewall ====="
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo ""
echo "===== Phase 6: Install Fail2ban ====="
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

echo ""
echo "===== Phase 7: Create Web Directory ====="
mkdir -p $WWW_ROOT/public_html
mkdir -p $WWW_ROOT/logs
chown -R www-data:www-data $WWW_ROOT
chmod -R 755 $WWW_ROOT

# Create test page
cat > $WWW_ROOT/public_html/index.php << 'EOFPHP'
<?php
echo "<h1>Archive.adgully.com - Installation Complete</h1>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<h2>PHP Extensions:</h2><ul>";
$extensions = get_loaded_extensions();
sort($extensions);
foreach ($extensions as $ext) {
    echo "<li>$ext</li>";
}
echo "</ul>";
?>
EOFPHP

chown www-data:www-data $WWW_ROOT/public_html/index.php

echo ""
echo "===== Phase 8: Install Certbot ====="
apt install -y certbot python3-certbot-nginx

echo ""
echo "===== Phase 9: Optional Tools ====="
apt install -y redis-server
systemctl enable redis
systemctl start redis

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Copy configuration files from configs/ directory"
echo "2. Configure Nginx server block"
echo "3. Obtain SSL certificate with: certbot --nginx -d $DOMAIN"
echo "4. Deploy your application"
echo "5. Import database"
echo ""
echo "Database created:"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Password: [hidden]"
echo ""
echo "Web root: $WWW_ROOT/public_html"
echo ""
