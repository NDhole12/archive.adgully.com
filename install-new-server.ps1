# Automated Installation Script for New Ubuntu Server
# Connects to 31.97.233.171 and installs complete LEMP stack

$newServerIP = "31.97.233.171"
$newServerUser = "root"
$newServerPass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ARCHIVE.ADGULLY.COM - NEW SERVER INSTALLATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Target Server: $newServerIP" -ForegroundColor White
Write-Host "Installation: Complete LEMP Stack (Nginx + PHP 8.2 + MariaDB)" -ForegroundColor White
Write-Host ""

# Check SSH availability
$sshCheck = Get-Command ssh -ErrorAction SilentlyContinue
if (-not $sshCheck) {
    Write-Host "ERROR: SSH client not found!" -ForegroundColor Red
    Write-Host "Install OpenSSH: Settings > Apps > Optional Features > Add OpenSSH Client" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ SSH client found" -ForegroundColor Green
Write-Host ""

# Create installation script
$installScript = @"
#!/bin/bash
set -e  # Exit on any error

echo "============================================================"
echo "  UBUNTU 22.04 LEMP STACK INSTALLATION"
echo "  Archive.adgully.com Migration"
echo "============================================================"
echo ""
echo "Starting installation at: $(date)"
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

# Install PHP 8.2
print_section "PHASE 5: PHP 8.2 INSTALLATION"
apt install -y php8.2-fpm php8.2-cli php8.2-common
check_success "PHP 8.2 core installation"

echo "Installing PHP extensions..."
apt install -y \
    php8.2-mysql \
    php8.2-mysqli \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    php8.2-opcache \
    php8.2-intl \
    php8.2-bcmath \
    php8.2-soap \
    php8.2-xmlrpc \
    php8.2-readline
check_success "PHP extensions installation"

# Install additional PHP extensions
echo "Installing Redis and MongoDB extensions..."
apt install -y php8.2-redis php8.2-mongodb 2>/dev/null || echo "Redis/MongoDB extensions optional"

# Install Tidy extension
apt install -y php8.2-tidy 2>/dev/null || echo "Tidy extension optional"

systemctl enable php8.2-fpm
systemctl start php8.2-fpm
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
echo "Nginx:"
systemctl is-active nginx && echo "✓ Running" || echo "✗ Not running"
echo ""
echo "PHP-FPM:"
systemctl is-active php8.2-fpm && echo "✓ Running" || echo "✗ Not running"
echo ""
echo "MariaDB:"
systemctl is-active mariadb && echo "✓ Running" || echo "✗ Not running"
echo ""
echo "Fail2ban:"
systemctl is-active fail2ban && echo "✓ Running" || echo "✗ Not running"
echo ""
echo "Firewall:"
ufw status | grep -q "Status: active" && echo "✓ Active" || echo "✗ Inactive"

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
echo "1. Upload configuration files:"
echo "   - configs/nginx/archive.adgully.com.conf"
echo "   - configs/php/php-custom.ini"
echo "   - configs/php/archive-pool.conf"
echo "   - configs/mariadb/mariadb-custom.cnf"
echo "   - configs/security/fail2ban-jail.local"
echo ""
echo "2. Configure services (Day 5 in MIGRATION_EXECUTION_PLAN.md)"
echo ""
echo "3. Secure MariaDB:"
echo "   mysql_secure_installation"
echo ""
echo "4. Create database and user:"
echo "   mysql -u root -p"
echo ""
echo "5. Deploy application files (Day 6)"
echo ""
echo "6. Import database (Day 7)"
echo ""
echo "============================================================"
echo ""
echo "INSTALLATION LOG SAVED TO: /root/installation.log"
echo ""
"@

# Save script locally first
$scriptPath = "D:\archive.adgully.com\backups\install-server-$(Get-Date -Format 'yyyyMMdd-HHmmss').sh"
$installScript | Out-File -FilePath $scriptPath -Encoding UTF8 -NoNewline

Write-Host "Installation script created: $scriptPath" -ForegroundColor Green
Write-Host ""

Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "  STARTING REMOTE INSTALLATION" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "This will:" -ForegroundColor White
Write-Host "  1. Update Ubuntu system" -ForegroundColor Cyan
Write-Host "  2. Install Nginx web server" -ForegroundColor Cyan
Write-Host "  3. Install PHP 8.2 with all extensions" -ForegroundColor Cyan
Write-Host "  4. Install MariaDB 10.11 database" -ForegroundColor Cyan
Write-Host "  5. Install SSL tools (Certbot)" -ForegroundColor Cyan
Write-Host "  6. Configure UFW firewall" -ForegroundColor Cyan
Write-Host "  7. Install Fail2ban security" -ForegroundColor Cyan
Write-Host "  8. Create directory structure" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estimated time: 10-20 minutes" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Continue with installation? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Uploading installation script to server..." -ForegroundColor Yellow

# Upload script via SSH
$uploadCmd = @"
ssh root@$newServerIP "cat > /root/install.sh" < "$scriptPath"
"@

try {
    # Create temporary script file on server
Write-Host "Connecting to $newServerIP..." -ForegroundColor Cyan
    
    # Upload the script
    `$scpCmd = "scp ```"$scriptPath```" root@`${newServerIP}:/root/install.sh"
    Write-Host "Uploading script..." -ForegroundColor Cyan
    Invoke-Expression $scpCmd
    
    Write-Host "✓ Script uploaded successfully" -ForegroundColor Green
    Write-Host ""
    
    # Make executable and run
    Write-Host "Making script executable and starting installation..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "  INSTALLATION OUTPUT (LIVE)" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    
    `$installCmd = "ssh root@`$newServerIP 'chmod +x /root/install.sh && /root/install.sh 2>&1 | tee /root/installation.log'"
    Invoke-Expression $installCmd
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "  INSTALLATION COMPLETE!" -ForegroundColor Green
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host ""
    
    # Save output locally
    `$localLogPath = "D:\archive.adgully.com\backups\installation-`$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    `$downloadLogCmd = "scp root@`${newServerIP}:/root/installation.log ```"`$localLogPath```""
    Invoke-Expression `$downloadLogCmd 2>`$null
    
    Write-Host "Installation log saved to:" -ForegroundColor Cyan
    Write-Host $localLogPath -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "ERROR during installation:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "You can manually connect and check:" -ForegroundColor Yellow
    Write-Host "ssh root@$newServerIP" -ForegroundColor White
    Write-Host "cat /root/installation.log" -ForegroundColor White
    exit 1
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Verify Services:" -ForegroundColor Yellow
Write-Host "   ssh root@$newServerIP" -ForegroundColor White
Write-Host "   systemctl status nginx php8.2-fpm mariadb" -ForegroundColor White
Write-Host ""
Write-Host "2. Secure MariaDB:" -ForegroundColor Yellow
Write-Host "   mysql_secure_installation" -ForegroundColor White
Write-Host ""
Write-Host "3. Upload Configuration Files:" -ForegroundColor Yellow
Write-Host "   scp -r D:\archive.adgully.com\configs\* root@`${newServerIP}:/root/configs/" -ForegroundColor White
Write-Host ""
Write-Host "4. Continue with Day 5 Configuration:" -ForegroundColor Yellow
Write-Host "   Open: MIGRATION_EXECUTION_PLAN.md" -ForegroundColor White
Write-Host "   Section: Day 5 - Configure New Server" -ForegroundColor White
Write-Host ""
Write-Host "5. Track Progress:" -ForegroundColor Yellow
Write-Host "   Update: MIGRATION_TRACKER.md" -ForegroundColor White
Write-Host "   Mark Day 4 complete, start Day 5" -ForegroundColor White
Write-Host ""

Write-Host "============================================================" -ForegroundColor Green
Write-Host "  SERVER READY FOR CONFIGURATION!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
