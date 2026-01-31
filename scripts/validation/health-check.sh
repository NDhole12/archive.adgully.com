#!/bin/bash
# Server Health Check Script
# Usage: bash health-check.sh

echo "========================================"
echo "Server Health Check"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if service is running
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}✓${NC} $1 is running"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT running"
        return 1
    fi
}

# Check port is listening
check_port() {
    if ss -tlnp | grep -q ":$1 "; then
        echo -e "${GREEN}✓${NC} Port $1 is listening"
        return 0
    else
        echo -e "${RED}✗${NC} Port $1 is NOT listening"
        return 1
    fi
}

# System Information
echo "===== System Information ====="
echo "Hostname: $(hostname)"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo ""

# Resource Usage
echo "===== Resource Usage ====="
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print "  " $2 " user, " $4 " system, " $8 " idle"}'
echo ""
echo "Memory Usage:"
free -h | awk 'NR==2{printf "  Used: %s / %s (%.2f%%)\n", $3, $2, $3*100/$2}'
echo ""
echo "Disk Usage:"
df -h / | awk 'NR==2{printf "  Used: %s / %s (%s)\n", $3, $2, $5}'
echo ""

# Service Status
echo "===== Service Status ====="
check_service nginx
check_service php8.2-fpm
check_service mariadb
check_service redis-server
check_service fail2ban
echo ""

# Port Status
echo "===== Port Status ====="
check_port 80
check_port 443
check_port 3306
check_port 6379
echo ""

# Firewall Status
echo "===== Firewall Status ====="
if sudo ufw status | grep -q "Status: active"; then
    echo -e "${GREEN}✓${NC} UFW is active"
    echo "Open ports:"
    sudo ufw status | grep ALLOW | awk '{print "  " $1}'
else
    echo -e "${RED}✗${NC} UFW is not active"
fi
echo ""

# SSL Certificate
echo "===== SSL Certificate ====="
if [ -d "/etc/letsencrypt/live/archive.adgully.com" ]; then
    CERT_FILE="/etc/letsencrypt/live/archive.adgully.com/cert.pem"
    EXPIRY=$(openssl x509 -in $CERT_FILE -noout -enddate | cut -d= -f2)
    EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))
    
    if [ $DAYS_LEFT -gt 30 ]; then
        echo -e "${GREEN}✓${NC} SSL certificate valid (expires in $DAYS_LEFT days)"
    elif [ $DAYS_LEFT -gt 0 ]; then
        echo -e "${YELLOW}!${NC} SSL certificate expires soon (in $DAYS_LEFT days)"
    else
        echo -e "${RED}✗${NC} SSL certificate has expired!"
    fi
else
    echo -e "${YELLOW}!${NC} No SSL certificate found"
fi
echo ""

# PHP Status
echo "===== PHP Status ====="
PHP_VERSION=$(php -v | head -n1 | awk '{print $2}')
echo "PHP Version: $PHP_VERSION"

PHP_FPM_PROCS=$(ps aux | grep php-fpm | grep -v grep | wc -l)
echo "PHP-FPM processes: $PHP_FPM_PROCS"

if [ -S "/run/php/php8.2-fpm.sock" ]; then
    echo -e "${GREEN}✓${NC} PHP-FPM socket exists"
else
    echo -e "${RED}✗${NC} PHP-FPM socket not found"
fi
echo ""

# Database Status
echo "===== Database Status ====="
if systemctl is-active --quiet mariadb; then
    DB_VERSION=$(mysql -V | awk '{print $5}' | sed 's/,//')
    echo "MariaDB Version: $DB_VERSION"
    
    DB_CONNS=$(mysql -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | awk 'NR==2{print $2}')
    if [ ! -z "$DB_CONNS" ]; then
        echo "Active connections: $DB_CONNS"
    fi
fi
echo ""

# Recent Errors
echo "===== Recent Errors (last 10) ====="
echo "Nginx errors:"
if [ -f "/var/log/nginx/error.log" ]; then
    sudo tail -10 /var/log/nginx/error.log | grep -i error | tail -3 || echo "  No recent errors"
else
    echo "  Log file not found"
fi
echo ""

echo "PHP errors:"
if [ -f "/var/log/php/error.log" ]; then
    sudo tail -10 /var/log/php/error.log | tail -3 || echo "  No recent errors"
else
    echo "  Log file not found"
fi
echo ""

# Network Status
echo "===== Network Status ====="
echo "Active connections:"
ss -tn state established '( dport = :80 or dport = :443 )' | wc -l | awk '{print "  HTTP/HTTPS: " $1}'
echo ""

echo "========================================"
echo "Health check complete"
echo "========================================"
