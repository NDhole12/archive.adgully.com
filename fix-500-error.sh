#!/bin/bash
# Quick Server Health Check & Fix Script
# Run this on the server: bash fix-500-error.sh

echo "=== archive2.adgully.com - 500 Error Diagnostic & Fix ==="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check services
echo -e "${YELLOW}1. Checking service status...${NC}"
echo ""

echo "PHP-FPM Status:"
systemctl is-active php8.2-fpm
if [ $? -ne 0 ]; then
    echo -e "${RED}PHP-FPM is DOWN! Attempting restart...${NC}"
    systemctl restart php8.2-fpm
    sleep 2
    systemctl status php8.2-fpm --no-pager -l
fi

echo ""
echo "Nginx Status:"
systemctl is-active nginx
if [ $? -ne 0 ]; then
    echo -e "${RED}Nginx is DOWN! Attempting restart...${NC}"
    systemctl restart nginx
    sleep 2
fi

echo ""
echo "MariaDB Status:"
systemctl is-active mariadb
if [ $? -ne 0 ]; then
    echo -e "${RED}MariaDB is DOWN! Attempting restart...${NC}"
    systemctl restart mariadb
    sleep 3
fi

# Check logs for errors
echo ""
echo -e "${YELLOW}2. Checking error logs...${NC}"
echo ""

echo "=== Nginx Error Log (last 20 lines) ==="
tail -20 /var/log/nginx/error.log

echo ""
echo "=== PHP-FPM Error Log (last 20 lines) ==="
if [ -f /var/log/php8.2-fpm.log ]; then
    tail -20 /var/log/php8.2-fpm.log
elif [ -f /var/log/php/fpm-error.log ]; then
    tail -20 /var/log/php/fpm-error.log
else
    echo "PHP-FPM log not found"
fi

# Check database connection
echo ""
echo -e "${YELLOW}3. Testing database connection...${NC}"
mysql -uarchive_user -pArchiveUser@2026Secure archive_adgully -e "SELECT 'Database OK' as status;" 2>&1

# Check web root
echo ""
echo -e "${YELLOW}4. Checking web root...${NC}"
if [ -f /var/www/archive2.adgully.com/public_html/index.php ]; then
    echo -e "${GREEN}index.php exists${NC}"
    ls -la /var/www/archive2.adgully.com/public_html/index.php
    
    # Check for syntax errors
    echo ""
    echo "Checking PHP syntax:"
    php -l /var/www/archive2.adgully.com/public_html/index.php
else
    echo -e "${RED}index.php NOT FOUND!${NC}"
    echo "Contents of /var/www/archive2.adgully.com/:"
    ls -la /var/www/archive2.adgully.com/ 2>/dev/null || echo "Directory does not exist!"
fi

# Fix permissions
echo ""
echo -e "${YELLOW}5. Fixing file permissions...${NC}"
if [ -d /var/www/archive2.adgully.com ]; then
    chown -R www-data:www-data /var/www/archive2.adgully.com
    find /var/www/archive2.adgully.com -type f -exec chmod 644 {} \;
    find /var/www/archive2.adgully.com -type d -exec chmod 755 {} \;
    echo -e "${GREEN}Permissions fixed${NC}"
else
    echo -e "${RED}Web root directory not found!${NC}"
fi

# Test local connection
echo ""
echo -e "${YELLOW}6. Testing local HTTP connection...${NC}"
curl -I http://localhost 2>&1 | head -10

echo ""
echo -e "${YELLOW}7. Testing HTTPS connection...${NC}"
curl -I https://archive2.adgully.com 2>&1 | head -10

echo ""
echo -e "${GREEN}=== Diagnostic Complete ===${NC}"
echo ""
echo "If the site is still down, check the errors above and:"
echo "1. Look for specific PHP errors in the logs"
echo "2. Check if the database credentials are correct"
echo "3. Verify the web root path in Nginx config"
echo "4. Check if there are .htaccess rules that need conversion"
