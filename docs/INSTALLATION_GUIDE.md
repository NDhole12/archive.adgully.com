# Installation Guide - Ubuntu 22.04 + Nginx + PHP 8.2 + MariaDB

This guide provides **exact commands** for setting up your new production server.

---

## 📋 Prerequisites

- [ ] Pre-migration checklist completed
- [ ] Fresh Ubuntu 22.04 LTS server (minimal install)
- [ ] Root or sudo access
- [ ] Server accessible via SSH
- [ ] Static IP address assigned

---

## 🚀 Phase 1: Initial Server Setup

### 1.1 Update System
```bash
# Update package list and upgrade existing packages
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y software-properties-common apt-transport-https ca-certificates \
  curl wget gnupg2 lsb-release ubuntu-keyring git unzip vim htop

# Reboot if kernel was updated
sudo reboot
```

### 1.2 Configure Hostname
```bash
# Set hostname
sudo hostnamectl set-hostname archive.adgully.com

# Update /etc/hosts
sudo bash -c 'cat >> /etc/hosts << EOF
127.0.0.1 archive.adgully.com archive
EOF'

# Verify
hostnamectl
```

### 1.3 Create Non-Root User (if not exists)
```bash
# Create deployment user
sudo adduser deploy
sudo usermod -aG sudo deploy

# Set up SSH key for deploy user
sudo mkdir -p /home/deploy/.ssh
sudo cp /root/.ssh/authorized_keys /home/deploy/.ssh/ # If applicable
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys

# Switch to deploy user for remaining steps
su - deploy
```

### 1.4 Configure Timezone
```bash
# Set timezone (adjust as needed)
sudo timedatectl set-timezone Asia/Kolkata  # Or your timezone

# Verify
timedatectl
```

---

## 🔐 Phase 2: Security Hardening

### 2.1 Configure UFW Firewall
```bash
# Allow SSH before enabling firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose
```

### 2.2 Install and Configure Fail2ban
```bash
# Install fail2ban
sudo apt install -y fail2ban

# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Edit configuration
sudo tee /etc/fail2ban/jail.local > /dev/null << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = admin@adgully.com
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]
enabled = true
port = 22
logpath = %(sshd_log)s
backend = %(sshd_backend)s

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-noscript]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log

[nginx-badbots]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2

[nginx-noproxy]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 2
EOF

# Start and enable fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status
```

### 2.3 Harden SSH
```bash
# Backup original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Apply secure settings
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH
sudo systemctl restart sshd
```

---

## 🌐 Phase 3: Install Nginx

### 3.1 Install Nginx
```bash
# Install Nginx from Ubuntu repos
sudo apt install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Check version
nginx -v

# Check status
sudo systemctl status nginx
```

### 3.2 Configure Nginx
```bash
# Backup default config
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Create optimized nginx.conf
sudo tee /etc/nginx/nginx.conf > /dev/null << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 2048;
    multi_accept on;
    use epoll;
}

http {
    ##
    # Basic Settings
    ##
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    client_max_body_size 64M;

    # Timeouts
    client_body_timeout 30;
    client_header_timeout 30;
    send_timeout 30;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';

    ##
    # Logging Settings
    ##
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml font/truetype font/opentype 
               application/vnd.ms-fontobject image/svg+xml;
    gzip_disable "msie6";

    ##
    # Virtual Host Configs
    ##
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

## 🐘 Phase 4: Install PHP 8.2

### 4.1 Add PHP Repository
```bash
# Add Ondrej PHP PPA
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
```

### 4.2 Install PHP 8.2 and Extensions
```bash
# Install PHP 8.2 FPM and all required extensions
sudo apt install -y php8.2-fpm php8.2-cli php8.2-common php8.2-mysql \
  php8.2-mysqli php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml \
  php8.2-zip php8.2-bcmath php8.2-intl php8.2-readline php8.2-opcache \
  php8.2-redis php8.2-mongodb php8.2-tidy php8.2-soap

# Verify installation
php -v
php -m | grep -E 'mysqli|pdo_mysql|curl|gd|mbstring|opcache|redis'

# Check PHP-FPM status
sudo systemctl status php8.2-fpm
```

### 4.3 Configure PHP 8.2
```bash
# Backup original configs
sudo cp /etc/php/8.2/fpm/php.ini /etc/php/8.2/fpm/php.ini.backup
sudo cp /etc/php/8.2/cli/php.ini /etc/php/8.2/cli/php.ini.backup

# Configure PHP-FPM
sudo tee /etc/php/8.2/fpm/conf.d/99-custom.ini > /dev/null << 'EOF'
; Performance Settings
memory_limit = 256M
max_execution_time = 300
max_input_time = 300
max_input_vars = 3000

; Upload Settings
upload_max_filesize = 64M
post_max_size = 64M

; Error Handling (Production)
display_errors = Off
display_startup_errors = Off
log_errors = On
error_log = /var/log/php/error.log
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; Security
expose_php = Off
allow_url_fopen = On
allow_url_include = Off

; Session
session.cookie_httponly = 1
session.cookie_secure = 1
session.use_strict_mode = 1

; OPcache Settings
opcache.enable = 1
opcache.enable_cli = 0
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 10000
opcache.max_wasted_percentage = 5
opcache.use_cwd = 1
opcache.validate_timestamps = 1
opcache.revalidate_freq = 60
opcache.save_comments = 1

; Timezone
date.timezone = Asia/Kolkata
EOF

# Create PHP log directory
sudo mkdir -p /var/log/php
sudo chown www-data:www-data /var/log/php
sudo chmod 755 /var/log/php

# Configure PHP-FPM pool
sudo tee /etc/php/8.2/fpm/pool.d/www.conf > /dev/null << 'EOF'
[www]
user = www-data
group = www-data
listen = /run/php/php8.2-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Process Manager
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500

; Performance
request_terminate_timeout = 300
rlimit_files = 1024
rlimit_core = 0

; Logging
php_admin_value[error_log] = /var/log/php/fpm-error.log
php_admin_flag[log_errors] = on
slowlog = /var/log/php/fpm-slow.log
request_slowlog_timeout = 10s

; Security
php_admin_value[disable_functions] = exec,passthru,shell_exec,system,proc_open,popen
php_admin_flag[allow_url_fopen] = on
EOF

# Test PHP-FPM configuration
sudo php-fpm8.2 -t

# Restart PHP-FPM
sudo systemctl restart php8.2-fpm
sudo systemctl enable php8.2-fpm
```

---

## 🗄️ Phase 5: Install MariaDB

### 5.1 Add MariaDB Repository
```bash
# Add MariaDB official repository (version 10.11 LTS)
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | \
  sudo bash -s -- --mariadb-server-version="mariadb-10.11"

sudo apt update
```

### 5.2 Install MariaDB
```bash
# Install MariaDB server
sudo apt install -y mariadb-server mariadb-client

# Start and enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Check version
mysql -V

# Check status
sudo systemctl status mariadb
```

### 5.3 Secure MariaDB Installation
```bash
# Run mysql_secure_installation
sudo mysql_secure_installation

# Answer prompts as follows:
# - Enter current password for root: [Press Enter]
# - Switch to unix_socket authentication: N
# - Change the root password: Y (set a strong password)
# - Remove anonymous users: Y
# - Disallow root login remotely: Y
# - Remove test database: Y
# - Reload privilege tables: Y
```

### 5.4 Configure MariaDB
```bash
# Create custom configuration
sudo tee /etc/mysql/mariadb.conf.d/99-custom.cnf > /dev/null << 'EOF'
[mysqld]
# Character Set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Performance
max_connections = 200
connect_timeout = 10
wait_timeout = 600
max_allowed_packet = 64M
thread_cache_size = 128
sort_buffer_size = 4M
bulk_insert_buffer_size = 16M
tmp_table_size = 64M
max_heap_table_size = 64M

# Query Cache (deprecated in newer versions, use with caution)
# query_cache_size = 0

# Logging
slow_query_log = 1
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time = 2
log_error = /var/log/mysql/error.log

# InnoDB Settings
innodb_buffer_pool_size = 512M
innodb_log_file_size = 128M
innodb_file_per_table = 1
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 2

[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4
EOF

# Restart MariaDB
sudo systemctl restart mariadb

# Verify character set
mysql -u root -p -e "SHOW VARIABLES LIKE 'character_set%';"
mysql -u root -p -e "SHOW VARIABLES LIKE 'collation%';"
```

### 5.5 Create Database and User
```bash
# Login to MySQL
sudo mysql -u root -p

# Run these SQL commands:
```

```sql
-- Create database
CREATE DATABASE IF NOT EXISTS archive_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user (change password!)
CREATE USER 'archive_user'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD_HERE';

-- Grant privileges
GRANT ALL PRIVILEGES ON archive_db.* TO 'archive_user'@'localhost';

-- Flush privileges
FLUSH PRIVILEGES;

-- Verify
SHOW DATABASES;
SELECT User, Host FROM mysql.user WHERE User = 'archive_user';

-- Exit
EXIT;
```

---

## 🌍 Phase 6: Configure Web Application

### 6.1 Create Web Root
```bash
# Create directory structure
sudo mkdir -p /var/www/archive.adgully.com/public_html
sudo mkdir -p /var/www/archive.adgully.com/logs

# Set ownership
sudo chown -R www-data:www-data /var/www/archive.adgully.com
sudo chmod -R 755 /var/www/archive.adgully.com
```

### 6.2 Create Nginx Server Block
```bash
# Create server block configuration
sudo tee /etc/nginx/sites-available/archive.adgully.com > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name archive.adgully.com www.archive.adgully.com;

    root /var/www/archive.adgully.com/public_html;
    index index.php index.html index.htm;

    # Logging
    access_log /var/www/archive.adgully.com/logs/access.log;
    error_log /var/www/archive.adgully.com/logs/error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Main location block
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP-FPM configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_read_timeout 300;
    }

    # Static file caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Deny access to specific files
    location ~ /\.(htaccess|htpasswd|env) {
        deny all;
    }
}
EOF

# Enable the site
sudo ln -s /etc/nginx/sites-available/archive.adgully.com /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### 6.3 Create Test PHP File
```bash
# Create phpinfo test file
sudo tee /var/www/archive.adgully.com/public_html/info.php > /dev/null << 'EOF'
<?php
phpinfo();
?>
EOF

# Create index test file
sudo tee /var/www/archive.adgully.com/public_html/index.php > /dev/null << 'EOF'
<?php
echo "<h1>Archive.adgully.com - Server Ready</h1>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";

// Test database connection
$servername = "localhost";
$username = "archive_user";
$password = "STRONG_PASSWORD_HERE";  // Change this
$dbname = "archive_db";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "<p style='color: green;'>✓ Database connection successful</p>";
} catch(PDOException $e) {
    echo "<p style='color: red;'>✗ Database connection failed: " . $e->getMessage() . "</p>";
}
?>
EOF

# Set proper permissions
sudo chown -R www-data:www-data /var/www/archive.adgully.com/public_html
sudo chmod -R 644 /var/www/archive.adgully.com/public_html/*.php
sudo chmod 755 /var/www/archive.adgully.com/public_html
```

---

## 🔒 Phase 7: Install SSL Certificate

### 7.1 Install Certbot
```bash
# Install Certbot for Nginx
sudo apt install -y certbot python3-certbot-nginx
```

### 7.2 Obtain SSL Certificate
```bash
# Get certificate (change email)
sudo certbot --nginx -d archive.adgully.com -d www.archive.adgully.com \
  --email admin@adgully.com --agree-tos --no-eff-email --redirect

# Test auto-renewal
sudo certbot renew --dry-run

# Check certificate
sudo certbot certificates
```

### 7.3 Configure Auto-Renewal
```bash
# Certbot creates a systemd timer automatically
sudo systemctl status certbot.timer

# Manually test renewal
sudo certbot renew --dry-run
```

---

## 📦 Phase 8: Additional Tools

### 8.1 Install Composer (if needed)
```bash
# Download and install Composer
curl -sS https://getcomposer.org/installer | sudo php -- \
  --install-dir=/usr/local/bin --filename=composer

# Verify
composer --version
```

### 8.2 Install Node.js (if needed)
```bash
# Install NodeSource repository (LTS version)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs

# Verify
node --version
npm --version
```

### 8.3 Install Redis (if needed)
```bash
# Install Redis server
sudo apt install -y redis-server

# Configure Redis
sudo sed -i 's/supervised no/supervised systemd/' /etc/redis/redis.conf

# Restart Redis
sudo systemctl restart redis
sudo systemctl enable redis

# Test Redis
redis-cli ping  # Should return PONG
```

---

## ✅ Phase 9: Verification

### 9.1 Service Status Check
```bash
# Check all services
sudo systemctl status nginx
sudo systemctl status php8.2-fpm
sudo systemctl status mariadb
sudo systemctl status redis  # if installed

# Check listening ports
sudo ss -tlnp | grep -E ':(80|443|3306|6379)'
```

### 9.2 Test Web Access
```bash
# Test from server (if curl available)
curl -I http://localhost
curl -I https://archive.adgully.com

# Check PHP processing
curl http://localhost/info.php | grep "PHP Version"
```

### 9.3 Check Logs
```bash
# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/www/archive.adgully.com/logs/error.log

# PHP logs
sudo tail -f /var/log/php/error.log
sudo tail -f /var/log/php/fpm-error.log

# MariaDB logs
sudo tail -f /var/log/mysql/error.log
```

### 9.4 Security Verification
```bash
# Check firewall
sudo ufw status verbose

# Check fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Check open ports
sudo ss -tlnp
```

---

## 📝 Phase 10: Documentation

### 10.1 Save Server Information
```bash
# Create info file
cat > ~/server-info.txt << EOF
Server Setup Completed: $(date)
-----------------------------------
OS: $(lsb_release -d | cut -f2)
Kernel: $(uname -r)
Nginx: $(nginx -v 2>&1)
PHP: $(php -v | head -n1)
MariaDB: $(mysql -V)
Public IP: $(curl -s ifconfig.me)
Hostname: $(hostname -f)
-----------------------------------
Web Root: /var/www/archive.adgully.com/public_html
Database: archive_db
DB User: archive_user
-----------------------------------
EOF

cat ~/server-info.txt
```

### 10.2 Remove Test Files
```bash
# IMPORTANT: Remove phpinfo after testing
sudo rm /var/www/archive.adgully.com/public_html/info.php
```

---

## 🎉 Installation Complete!

Your server is now ready for application deployment. Next steps:

1. ✅ Complete [Post-Migration Checklist](POST_MIGRATION_CHECKLIST.md)
2. 📋 Deploy your application code
3. 🔄 Import your database
4. 🧪 Run application tests
5. 🚀 Update DNS to point to new server

---

**Installation Guide Version**: 1.0  
**Last Updated**: January 11, 2026
