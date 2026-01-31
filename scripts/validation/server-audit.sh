#!/bin/bash
# Server Configuration Audit Script
# Usage: ssh root@172.31.21.197 'bash -s' < server-audit.sh > server-report.txt

echo "========================================"
echo "SERVER CONFIGURATION AUDIT"
echo "========================================"
echo "Generated: $(date)"
echo ""

echo "=== SYSTEM INFORMATION ==="
echo "OS Release:"
cat /etc/*release 2>/dev/null | grep -E 'PRETTY_NAME|VERSION_ID'
echo ""
echo "Kernel:"
uname -r
echo ""
echo "Hostname:"
hostname
echo ""

echo "=== WEB SERVER ==="
echo "Apache Version:"
httpd -v 2>/dev/null || apache2 -v 2>/dev/null || echo "Not found"
echo ""
echo "Apache Status:"
systemctl is-active httpd 2>/dev/null || systemctl is-active apache2 2>/dev/null || echo "Unknown"
echo ""
echo "Apache Modules:"
httpd -M 2>/dev/null | head -20 || echo "Could not list modules"
echo ""
echo "Virtual Hosts:"
httpd -S 2>/dev/null | head -20 || apache2ctl -S 2>/dev/null | head -20 || echo "Could not list vhosts"
echo ""

echo "=== PHP CONFIGURATION ==="
echo "PHP Version:"
php -v 2>/dev/null || echo "PHP not found in PATH"
echo ""
echo "PHP Binary Location:"
which php
echo ""
echo "PHP Configuration Files:"
php --ini 2>/dev/null
echo ""
echo "PHP Extensions (Loaded):"
php -m 2>/dev/null | sort
echo ""
echo "Key PHP Settings:"
php -i 2>/dev/null | grep -E 'memory_limit|max_execution_time|upload_max_filesize|post_max_size|display_errors|error_reporting'
echo ""

echo "=== DATABASE ==="
echo "MySQL/MariaDB Version:"
mysql -V 2>/dev/null || echo "MySQL/MariaDB not found"
echo ""
echo "Database Status:"
systemctl is-active mariadb 2>/dev/null || systemctl is-active mysql 2>/dev/null || echo "Unknown"
echo ""
echo "Database Character Set:"
mysql -e "SHOW VARIABLES LIKE 'character_set%';" 2>/dev/null || echo "Could not connect"
echo ""

echo "=== WEB ROOT ==="
echo "Apache DocumentRoot (from config):"
grep -r "DocumentRoot" /etc/httpd/ /etc/apache2/ 2>/dev/null | head -5
echo ""
echo "Web Root Contents:"
ls -lah /var/www/html/ 2>/dev/null | head -20 || echo "/var/www/html not found"
echo ""
echo "Web Root Size:"
du -sh /var/www/html/ 2>/dev/null || echo "Could not calculate"
echo ""

echo "=== RESOURCE USAGE ==="
echo "CPU Info:"
grep "model name" /proc/cpuinfo | head -1
grep "cpu cores" /proc/cpuinfo | head -1
echo ""
echo "Memory:"
free -h
echo ""
echo "Disk Usage:"
df -h
echo ""
echo "Load Average:"
uptime
echo ""

echo "=== NETWORK ==="
echo "IP Addresses:"
ip addr show | grep -E 'inet ' | head -5
echo ""
echo "Listening Ports:"
ss -tlnp | grep -E ':(80|443|3306|22) '
echo ""

echo "=== SECURITY ==="
echo "Firewall Status:"
systemctl is-active firewalld 2>/dev/null || systemctl is-active ufw 2>/dev/null || echo "No firewall detected"
echo ""
echo "Firewall Rules:"
firewall-cmd --list-all 2>/dev/null || ufw status 2>/dev/null || echo "Could not get rules"
echo ""
echo "SELinux Status:"
getenforce 2>/dev/null || echo "SELinux not available"
echo ""

echo "=== INSTALLED PACKAGES (PHP Related) ==="
rpm -qa | grep php | sort 2>/dev/null || dpkg -l | grep php | sort 2>/dev/null || echo "Could not list packages"
echo ""

echo "=== CRON JOBS ==="
echo "Root Crontab:"
crontab -l 2>/dev/null || echo "No crontab for root"
echo ""

echo "=== RECENT ERRORS (Last 20 lines) ==="
echo "Apache Error Log:"
tail -20 /var/log/httpd/error_log 2>/dev/null || tail -20 /var/log/apache2/error.log 2>/dev/null || echo "Log not found"
echo ""

echo "========================================"
echo "AUDIT COMPLETE"
echo "========================================"
