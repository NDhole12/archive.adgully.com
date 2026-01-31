#!/bin/bash
# Emergency 500 Error Fix - Run on server
# Usage: ssh root@31.97.233.171 'bash -s' < emergency-fix.sh

set -e

echo "========================================="
echo "Emergency 500 Error Fix"
echo "Server: archive2.adgully.com"
echo "========================================="
echo ""

# Step 1: Restart all services
echo "[1/6] Restarting services..."
systemctl restart php8.2-fpm
echo "  ✓ PHP-FPM restarted"
systemctl restart nginx
echo "  ✓ Nginx restarted"
systemctl restart mariadb
echo "  ✓ MariaDB restarted"
sleep 2

# Step 2: Check service status
echo ""
echo "[2/6] Verifying services..."
systemctl is-active --quiet php8.2-fpm && echo "  ✓ PHP-FPM: Running" || echo "  ✗ PHP-FPM: FAILED"
systemctl is-active --quiet nginx && echo "  ✓ Nginx: Running" || echo "  ✗ Nginx: FAILED"
systemctl is-active --quiet mariadb && echo "  ✓ MariaDB: Running" || echo "  ✗ MariaDB: FAILED"

# Step 3: Fix permissions
echo ""
echo "[3/6] Fixing file permissions..."
if [ -d "/var/www/archive2.adgully.com" ]; then
    chown -R www-data:www-data /var/www/archive2.adgully.com
    find /var/www/archive2.adgully.com -type d -exec chmod 755 {} \;
    find /var/www/archive2.adgully.com -type f -exec chmod 644 {} \;
    echo "  ✓ Permissions fixed"
else
    echo "  ✗ Web root not found!"
fi

# Step 4: Test database
echo ""
echo "[4/6] Testing database connection..."
mysql -uarchive_user -pArchiveUser@2026Secure archive_adgully -e "SELECT 'OK' as status;" 2>&1 | grep -q "OK" && echo "  ✓ Database: Connected" || echo "  ✗ Database: Connection failed"

# Step 5: Test local site
echo ""
echo "[5/6] Testing local HTTP..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "  ✓ Local site: HTTP $HTTP_CODE (OK)"
else
    echo "  ✗ Local site: HTTP $HTTP_CODE (ERROR)"
fi

# Step 6: Show recent errors
echo ""
echo "[6/6] Recent errors (if any)..."
echo "--- Nginx errors (last 5 lines) ---"
tail -5 /var/log/nginx/error.log 2>/dev/null || echo "No errors"
echo ""
echo "--- PHP-FPM errors (last 5 lines) ---"
tail -5 /var/log/php8.2-fpm.log 2>/dev/null || tail -5 /var/log/php/fpm-error.log 2>/dev/null || echo "No errors"

# Final test
echo ""
echo "========================================="
echo "Testing external access..."
echo "========================================="
curl -I https://archive2.adgully.com 2>&1 | head -1
echo ""
echo "Fix complete! Check status above."
