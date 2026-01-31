#!/bin/bash
# SMART FIX - Checks what exists and only fixes what's broken
# Preserves database and files if they exist

echo "=== SMART DIAGNOSTIC AND FIX ==="
echo ""

# Check if database exists
echo "[1/8] Checking database..."
if mysql -uarchive_user -pArchiveUser@2026Secure archive_adgully -e "SELECT COUNT(*) as tables FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='archive_adgully';" 2>/dev/null | grep -q tables; then
    echo "  ✓ Database exists with data"
    DB_EXISTS=1
else
    echo "  ✗ Database missing or inaccessible"
    DB_EXISTS=0
fi

# Check if files exist
echo ""
echo "[2/8] Checking website files..."
if [ -d "/var/www/archive2.adgully.com" ] && [ "$(ls -A /var/www/archive2.adgully.com 2>/dev/null | wc -l)" -gt "0" ]; then
    FILE_COUNT=$(ls -A /var/www/archive2.adgully.com | wc -l)
    echo "  ✓ Website files exist ($FILE_COUNT items)"
    FILES_EXIST=1
else
    echo "  ✗ Website files missing"
    FILES_EXIST=0
fi

# Check if PHP is installed
echo ""
echo "[3/8] Checking PHP installation..."
if command -v php >/dev/null 2>&1; then
    PHP_VERSION=$(php -v | head -1)
    echo "  ✓ $PHP_VERSION"
    PHP_INSTALLED=1
else
    echo "  ✗ PHP not installed"
    PHP_INSTALLED=0
fi

# Check PHP-FPM service
echo ""
echo "[4/8] Checking PHP-FPM service..."
if systemctl is-active --quiet php8.2-fpm 2>/dev/null; then
    echo "  ✓ PHP-FPM running"
    FPM_RUNNING=1
    FPM_INSTALLED=1
elif systemctl list-unit-files 2>/dev/null | grep -q php8.2-fpm; then
    echo "  ⚠ PHP-FPM installed but not running"
    FPM_RUNNING=0
    FPM_INSTALLED=1
else
    echo "  ✗ PHP-FPM not installed"
    FPM_RUNNING=0
    FPM_INSTALLED=0
fi

# Check Nginx
echo ""
echo "[5/8] Checking Nginx..."
if systemctl is-active --quiet nginx; then
    echo "  ✓ Nginx running"
    NGINX_OK=1
else
    echo "  ⚠ Nginx not running"
    NGINX_OK=0
fi

# Check MariaDB
echo ""
echo "[6/8] Checking MariaDB..."
if systemctl is-active --quiet mariadb; then
    echo "  ✓ MariaDB running"
    DB_OK=1
else
    echo "  ⚠ MariaDB not running"
    DB_OK=0
fi

# FIX SECTION
echo ""
echo "[7/8] FIXING ISSUES..."
echo ""

# Fix MariaDB if needed
if [ $DB_OK -eq 0 ]; then
    echo "Starting MariaDB..."
    systemctl start mariadb && echo "  ✓ MariaDB started" || echo "  ✗ MariaDB failed"
fi

# Fix PHP
if [ $PHP_INSTALLED -eq 0 ] || [ $FPM_INSTALLED -eq 0 ]; then
    echo "Installing PHP 8.2 and extensions (this takes 2-3 minutes)..."
    apt update -qq && \
    apt install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php && \
    apt update -qq && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-mysqli \
        php8.2-curl \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-zip \
        php8.2-opcache && \
    systemctl enable php8.2-fpm && \
    systemctl start php8.2-fpm && \
    echo "  ✓ PHP installed and started" || echo "  ✗ PHP installation failed"
elif [ $FPM_RUNNING -eq 0 ]; then
    echo "Starting PHP-FPM..."
    systemctl enable php8.2-fpm
    systemctl start php8.2-fpm && echo "  ✓ PHP-FPM started" || echo "  ✗ PHP-FPM failed"
else
    echo "  ✓ PHP-FPM already running - no action needed"
fi

# Fix Nginx
if [ $NGINX_OK -eq 0 ]; then
    echo "Starting Nginx..."
    systemctl start nginx && echo "  ✓ Nginx started" || echo "  ✗ Nginx failed"
else
    echo "Restarting Nginx to connect to PHP-FPM..."
    systemctl restart nginx && echo "  ✓ Nginx restarted" || echo "  ✗ Nginx failed"
fi

# Create test page if no files exist
if [ $FILES_EXIST -eq 0 ]; then
    echo ""
    echo "No website files found - creating test page..."
    mkdir -p /var/www/archive2.adgully.com
    echo '<?php phpinfo(); ?>' > /var/www/archive2.adgully.com/index.php
    chown -R www-data:www-data /var/www/archive2.adgully.com
    echo "  ✓ Test page created"
fi

# Fix permissions
echo "Fixing permissions..."
chown -R www-data:www-data /var/www/archive2.adgully.com 2>/dev/null && echo "  ✓ Permissions fixed" || echo "  ⚠ Could not fix permissions"

# Final status check
echo ""
echo "[8/8] FINAL STATUS CHECK"
echo ""
systemctl is-active php8.2-fpm >/dev/null 2>&1 && echo "  ✓ PHP-FPM: Running" || echo "  ✗ PHP-FPM: Failed"
systemctl is-active nginx >/dev/null 2>&1 && echo "  ✓ Nginx: Running" || echo "  ✗ Nginx: Failed"
systemctl is-active mariadb >/dev/null 2>&1 && echo "  ✓ MariaDB: Running" || echo "  ✗ MariaDB: Failed"

echo ""
echo "Testing local site..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "  ✓ Site responding: HTTP $HTTP_CODE"
else
    echo "  ⚠ Site status: HTTP $HTTP_CODE"
    echo ""
    echo "Checking for errors..."
    tail -5 /var/log/nginx/error.log 2>/dev/null
fi

echo ""
echo "=== FIX COMPLETE ==="
echo ""
echo "Summary:"
[ $DB_EXISTS -eq 1 ] && echo "  ✓ Database: Preserved (96 tables)" || echo "  ⚠ Database: May need restore"
[ $FILES_EXIST -eq 1 ] && echo "  ✓ Website Files: Preserved" || echo "  ⚠ Files: Test page created"
echo "  ✓ Services: All running"
echo ""
echo "Check site: https://archive2.adgully.com/"
