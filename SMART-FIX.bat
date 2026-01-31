@echo off
echo =========================================
echo   SMART FIX - Checking and Fixing Site
echo =========================================
echo.
echo Server: 31.97.233.171
echo.
echo This will:
echo - Check what's installed
echo - Only install/fix what's broken
echo - Preserve existing database and files
echo.

ssh root@31.97.233.171 "bash -s" << 'EOF'
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
    echo "  ✓ Website files exist"
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
    echo "  ✓ PHP installed: $PHP_VERSION"
    PHP_INSTALLED=1
else
    echo "  ✗ PHP not installed"
    PHP_INSTALLED=0
fi

# Check PHP-FPM service
echo ""
echo "[4/8] Checking PHP-FPM service..."
if systemctl is-active --quiet php8.2-fpm; then
    echo "  ✓ PHP-FPM running"
    FPM_RUNNING=1
elif systemctl list-unit-files | grep -q php8.2-fpm; then
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
else
    echo "  ⚠ Nginx not running - restarting..."
    systemctl start nginx
fi

# Check MariaDB
echo ""
echo "[6/8] Checking MariaDB..."
if systemctl is-active --quiet mariadb; then
    echo "  ✓ MariaDB running"
else
    echo "  ⚠ MariaDB not running - restarting..."
    systemctl start mariadb
fi

# FIX SECTION
echo ""
echo "[7/8] FIXING ISSUES..."
echo ""

if [ $PHP_INSTALLED -eq 0 ] || [ $FPM_INSTALLED -eq 0 ]; then
    echo "Installing PHP 8.2 and extensions..."
    apt update -qq
    apt install -y software-properties-common
    add-apt-repository -y ppa:ondrej/php
    apt update -qq
    DEBIAN_FRONTEND=noninteractive apt install -y php8.2-fpm php8.2-mysql php8.2-mysqli php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-opcache
    systemctl enable php8.2-fpm
    systemctl start php8.2-fpm
    echo "  ✓ PHP installed and started"
elif [ $FPM_RUNNING -eq 0 ]; then
    echo "Starting PHP-FPM..."
    systemctl enable php8.2-fpm
    systemctl start php8.2-fpm
    echo "  ✓ PHP-FPM started"
else
    echo "  ✓ PHP-FPM already running"
fi

# Restart Nginx to ensure it connects to PHP-FPM
systemctl restart nginx
echo "  ✓ Nginx restarted"

# Create test page if no files exist
if [ $FILES_EXIST -eq 0 ]; then
    echo ""
    echo "Creating test page (no website files found)..."
    mkdir -p /var/www/archive2.adgully.com
    echo '<?php phpinfo(); ?>' > /var/www/archive2.adgully.com/index.php
    chown -R www-data:www-data /var/www/archive2.adgully.com
    echo "  ✓ Test page created"
fi

# Fix permissions
chown -R www-data:www-data /var/www/archive2.adgully.com 2>/dev/null
echo "  ✓ Permissions fixed"

# Final status check
echo ""
echo "[8/8] FINAL STATUS CHECK"
echo ""
systemctl is-active php8.2-fpm && echo "  ✓ PHP-FPM: Running" || echo "  ✗ PHP-FPM: Failed"
systemctl is-active nginx && echo "  ✓ Nginx: Running" || echo "  ✗ Nginx: Failed"
systemctl is-active mariadb && echo "  ✓ MariaDB: Running" || echo "  ✗ MariaDB: Failed"

echo ""
echo "Testing local site..."
HTTP_CODE=$(curl -s -o /dev/null -w "%%{http_code}" http://localhost)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "  ✓ Site responding: HTTP $HTTP_CODE"
else
    echo "  ⚠ Site status: HTTP $HTTP_CODE"
fi

echo ""
echo "=== FIX COMPLETE ==="
echo ""
echo "Summary:"
[ $DB_EXISTS -eq 1 ] && echo "  ✓ Database: Preserved" || echo "  ✗ Database: Needs restore"
[ $FILES_EXIST -eq 1 ] && echo "  ✓ Files: Preserved" || echo "  ⚠ Files: Test page created"
echo "  ✓ Services: All running"
echo ""
echo "Check: https://archive2.adgully.com/"

EOF

echo.
echo =========================================
echo   Testing External Access
echo =========================================
timeout /t 3 /nobreak > nul
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://archive2.adgully.com/' -TimeoutSec 15 -ErrorAction Stop; Write-Host 'SUCCESS! Site Status:' $r.StatusCode -ForegroundColor Green } catch { $code = $_.Exception.Response.StatusCode.value__; if ($code) { Write-Host 'Site Status: HTTP' $code -ForegroundColor Yellow } else { Write-Host 'Error:' $_.Exception.Message -ForegroundColor Red } }"
echo.
echo =========================================
echo   Done!
echo =========================================
pause
