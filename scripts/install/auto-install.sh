#!/bin/bash
set -e  # Exit on any error

echo "============================================================"
echo "  UBUNTU LEMP STACK INSTALLATION"
echo "  Archive.adgully.com Migration"
echo "============================================================"
echo ""
echo "Starting installation at: $(date)"
echo ""

# Detect OS and version
OS_ID="$(. /etc/os-release; echo $ID)"
OS_VERSION="$(. /etc/os-release; echo $VERSION_ID)"
echo "Detected OS: $OS_ID $OS_VERSION"
echo ""

# phpMyAdmin subdomain and admin email (used for TLS)
PMA_HOST="pma.archive.adgully.com"
ADMIN_EMAIL="saurabh@adgully.com"
echo "phpMyAdmin will be available at: $PMA_HOST (if DNS points to this server)"
echo "Admin email for TLS: $ADMIN_EMAIL"
echo ""

# Function to print section headers
print_section() {
    echo ""
    echo "============================================================"
    echo "  $1"
    echo "============================================================"
    echo ""
}

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo "✓ $1 successful"
    else
        echo "✗ $1 failed"
        exit 1
    fi
}

# Update system
print_section "PHASE 1: SYSTEM UPDATE"
apt update
check_success "System update"
DEBIAN_FRONTEND=noninteractive apt upgrade -y
check_success "System upgrade"
apt autoremove -y
apt autoclean

# Set hostname
print_section "PHASE 2: HOSTNAME CONFIGURATION"
hostnamectl set-hostname archive.adgully.com
echo "127.0.0.1 archive.adgully.com" >> /etc/hosts
check_success "Hostname configuration"
echo "Hostname set to: $(hostname)"

# Install basic tools
print_section "PHASE 3: ESSENTIAL TOOLS"
apt install -y curl wget git unzip software-properties-common gnupg2 ca-certificates apt-transport-https
check_success "Essential tools installation"

# Install Nginx
print_section "PHASE 4: NGINX INSTALLATION"
apt install -y nginx
check_success "Nginx installation"
systemctl enable nginx
systemctl start nginx
nginx -v
systemctl status nginx --no-pager | grep Active

# Install PHP
print_section "PHASE 5: PHP INSTALLATION"
install_php_core() {
    set +e
    apt install -y php8.2-fpm php8.2-cli php8.2-common
    rc=$?
    if [ $rc -ne 0 ]; then
        echo "php8.2 packages not available or failed; installing generic php-fpm package"
        apt install -y php-fpm php-cli php-common
        rc=$?
    fi
    set -e
    return $rc
}

install_php_core
check_success "PHP core installation"

echo "Installing PHP extensions..."
apt install -y \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-opcache \
    php-intl \
    php-bcmath \
    php-soap \
    php-readline
check_success "PHP extensions installation"

# Install additional PHP extensions
echo "Installing Redis and MongoDB extensions..."
apt install -y php8.2-redis 2>/dev/null || echo "Redis extension optional"
apt install -y php8.2-mongodb 2>/dev/null || echo "MongoDB extension optional"

# Install Tidy extension
apt install -y php8.2-tidy 2>/dev/null || echo "Tidy extension optional"

# Determine PHP-FPM service name (try common variants, then probe)
if systemctl list-units --full -all | grep -q 'php8.3-fpm.service'; then
    PHP_FPM_SERVICE=php8.3-fpm
elif systemctl list-units --full -all | grep -q 'php8.2-fpm.service'; then
    PHP_FPM_SERVICE=php8.2-fpm
elif systemctl list-units --full -all | grep -q 'php-fpm.service'; then
    PHP_FPM_SERVICE=php-fpm
else
    # Try to detect from /etc/init.d or systemctl listing
    if [ -f /etc/init.d/php8.3-fpm ]; then
        PHP_FPM_SERVICE=php8.3-fpm
    elif [ -f /etc/init.d/php8.2-fpm ]; then
        PHP_FPM_SERVICE=php8.2-fpm
    else
        PHP_FPM_SERVICE=$(systemctl list-units --type=service --all | awk '/php.*fpm/ {print $1; exit}' | sed 's/.service$//')
        if [ -z "$PHP_FPM_SERVICE" ]; then
            PHP_FPM_SERVICE=php-fpm
        fi
    fi
fi

# Enable/start the detected PHP-FPM service (non-fatal if unit name varies)
systemctl enable ${PHP_FPM_SERVICE} 2>/dev/null || true
systemctl start ${PHP_FPM_SERVICE} 2>/dev/null || true
php -v
echo ""
echo "Installed PHP extensions:"
php -m | grep -E 'mysqli|pdo_mysql|curl|gd|mbstring|json|openssl|zip|xml|opcache'

# Install MariaDB
print_section "PHASE 6: MARIADB INSTALLATION"
apt install -y mariadb-server mariadb-client
check_success "MariaDB installation"
systemctl enable mariadb
systemctl start mariadb
mysql --version
systemctl status mariadb --no-pager | grep Active

# Install SSL tools
print_section "PHASE 7: SSL CERTIFICATE TOOLS"
apt install -y certbot python3-certbot-nginx
check_success "Certbot installation"
certbot --version

# Install phpMyAdmin (optional but requested)
print_section "PHASE 7b: PHPMYADMIN INSTALLATION"
echo "Configuring non-interactive phpMyAdmin install"
# Avoid interactive debconf prompts: do not configure dbconfig (we'll use existing MariaDB)
echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections || true
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections || true

DEBIAN_FRONTEND=noninteractive apt update
if DEBIAN_FRONTEND=noninteractive apt install -y phpmyadmin --no-install-recommends; then
    echo "✓ phpMyAdmin package installed"
else
    echo "phpMyAdmin package not available or failed; installing manually from upstream"
    # Manual install: download latest and extract
    PMA_DIR="/usr/share/phpmyadmin"
    mkdir -p $PMA_DIR
    TMP=/tmp/phpmyadmin.tar.gz
    wget -qO $TMP https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
    tar xzf $TMP -C /usr/share --strip-components=1 phpMyAdmin-*/
    rm -f $TMP
    echo "✓ phpMyAdmin installed to $PMA_DIR"
fi

# Ensure required PHP extensions for phpMyAdmin
apt install -y php-mbstring php-zip php-gd php-json php-xml || true

# Configure Nginx alias for phpMyAdmin
if [ -d "/usr/share/phpmyadmin" ]; then
    # find php-fpm socket
    PHP_FPM_SOCK_PATH=$(find /run/php -type s -name '*.sock' | head -n1 || true)
    if [ -n "$PHP_FPM_SOCK_PATH" ]; then
        PHP_FPM_SOCK="unix:$PHP_FPM_SOCK_PATH"
    else
        PHP_FPM_SOCK="unix:/run/php/php-fpm.sock"
    fi

    cat > /etc/nginx/snippets/phpmyadmin.conf <<NGINX_PMA
    location /phpmyadmin {
        root /usr/share/;
        index index.php index.html index.htm;
    }

    location ~ ^/phpmyadmin/(.+\.php)$ {
        root /usr/share/;
        fastcgi_pass $PHP_FPM_SOCK;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
        root /usr/share/;
    }
NGINX_PMA

    # Try to include snippet in default server block if present
    if [ -f /etc/nginx/sites-available/default ]; then
        if ! grep -q "phpmyadmin.conf" /etc/nginx/sites-available/default; then
            sed -i '/server_name _;/a \    include /etc/nginx/snippets/phpmyadmin.conf;' /etc/nginx/sites-available/default || true
        fi
    fi

    # Reload nginx to apply phpMyAdmin config
    nginx -t && systemctl reload nginx || true
    echo "✓ phpMyAdmin Nginx configuration applied (access at /phpmyadmin)"
fi

# Create a dedicated Nginx site for phpMyAdmin on a subdomain and attempt TLS
if [ -d "/usr/share/phpmyadmin" ]; then
    print_section "PHASE 7c: PHPMYADMIN SUBDOMAIN + TLS"

    PMA_SITE_CONF="/etc/nginx/sites-available/$PMA_HOST"
    cat > "$PMA_SITE_CONF" <<NGINX_PMA_SITE
server {
    listen 80;
    server_name $PMA_HOST;

    root /usr/share/phpmyadmin;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass $PHP_FPM_SOCK;
    }

    location ~* \.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt)$ {
        expires max;
        log_not_found off;
    }
}
NGINX_PMA_SITE

    ln -sf "$PMA_SITE_CONF" "/etc/nginx/sites-enabled/$PMA_HOST"
    nginx -t && systemctl reload nginx || true

    # Try to fetch a certificate using Certbot (requires DNS -> this server)
    if command -v certbot >/dev/null 2>&1; then
        echo "Attempting to obtain TLS certificate for $PMA_HOST via certbot..."
        if certbot --nginx -d "$PMA_HOST" --non-interactive --agree-tos -m "$ADMIN_EMAIL"; then
            echo "✓ TLS certificate obtained and nginx configured for $PMA_HOST"
        else
            echo "⚠ Certbot failed to obtain a certificate. Ensure DNS for $PMA_HOST points to this server and port 80 is reachable.";
        fi
    else
        echo "⚠ Certbot not installed; skipping TLS setup for $PMA_HOST"
    fi
fi

# Install UFW Firewall
print_section "PHASE 8: FIREWALL SETUP"
apt install -y ufw
check_success "UFW installation"

# Configure firewall
echo "Configuring firewall rules..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable
check_success "Firewall configuration"
echo ""
ufw status verbose

# Install Fail2ban
print_section "PHASE 9: FAIL2BAN INSTALLATION"
apt install -y fail2ban
check_success "Fail2ban installation"
systemctl enable fail2ban
systemctl start fail2ban
systemctl status fail2ban --no-pager | grep Active

# Install additional utilities
print_section "PHASE 10: ADDITIONAL UTILITIES"
apt install -y htop ncdu net-tools
check_success "Additional utilities installation"

# Verify all services
print_section "PHASE 11: SERVICE VERIFICATION"
echo "Checking service status..."
echo ""
echo "Nginx: $(systemctl is-active nginx)"
echo "PHP-FPM: $(systemctl is-active $PHP_FPM_SERVICE)"
echo "MariaDB: $(systemctl is-active mariadb)"
echo "Fail2ban: $(systemctl is-active fail2ban)"
echo "Firewall: $(ufw status | grep -q 'Status: active' && echo 'active' || echo 'inactive')"

# System information
print_section "PHASE 12: SYSTEM INFORMATION"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "CPU Cores: $(nproc)"
echo "Total RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "Available Disk: $(df -h / | tail -1 | awk '{print $4}')"
echo "IP Address: $(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1 | head -1)"

# Create directory structure
print_section "PHASE 13: DIRECTORY STRUCTURE"
mkdir -p /var/www/archive.adgully.com
mkdir -p /root/backups/database
mkdir -p /root/backups/files
mkdir -p /root/scripts
mkdir -p /root/configs
chown -R www-data:www-data /var/www/archive.adgully.com
check_success "Directory structure creation"

# Installation complete
print_section "INSTALLATION COMPLETE"
echo "Installation finished at: $(date)"
echo ""
echo "============================================================"
echo "  NEXT STEPS:"
echo "============================================================"
echo ""
echo "1. Upload configuration files to /root/configs/"
echo "2. Configure services (Day 5 in MIGRATION_EXECUTION_PLAN.md)"
echo "3. Secure MariaDB: mysql_secure_installation"
echo "4. Create database and user"
echo "5. Deploy application files (Day 6)"
echo "6. Import database (Day 7)"
echo ""
echo "============================================================"
echo ""
echo "INSTALLATION LOG SAVED TO: /root/installation.log"
echo ""
