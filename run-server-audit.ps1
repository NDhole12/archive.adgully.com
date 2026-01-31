# PowerShell Script to Audit Remote Server
# This script connects to your existing server and gathers configuration information
# Usage: .\run-server-audit.ps1

# Server connection details
$ServerIP = "172.31.21.197"
$Username = "root"
$ReportFile = "server-audit-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

Write-Host "========================================"
Write-Host "Server Audit Script"
Write-Host "========================================"
Write-Host "Server: $Username@$ServerIP"
Write-Host "Report will be saved to: $ReportFile"
Write-Host ""
Write-Host "Note: You'll be prompted for the SSH password"
Write-Host ""

# Check if ssh is available
try {
    $sshTest = Get-Command ssh -ErrorAction Stop
    Write-Host "[OK] SSH client found" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] SSH client not found. Please install OpenSSH client." -ForegroundColor Red
    Write-Host "Install via: Settings > Apps > Optional Features > OpenSSH Client"
    exit 1
}

Write-Host ""
Write-Host "Connecting to server and running audit..." -ForegroundColor Yellow
Write-Host ""

# The audit commands to run on the remote server
$AuditScript = @'
#!/bin/bash
echo "========================================"
echo "SERVER CONFIGURATION AUDIT"
echo "========================================"
echo "Generated: $(date)"
echo "Server: $(hostname) ($(hostname -I | awk '{print $1}'))"
echo ""

echo "=== SYSTEM INFORMATION ==="
echo "OS Release:"
cat /etc/*release 2>/dev/null | grep -E "PRETTY_NAME|VERSION_ID|NAME|VERSION"
echo ""
echo "Kernel:"
uname -r
echo ""
echo "Architecture:"
uname -m
echo ""
echo "Hostname:"
hostname -f
echo ""

echo "=== WEB SERVER DETECTION ==="
echo "Checking for Apache..."
if command -v httpd &> /dev/null; then
    echo "Apache found: $(which httpd)"
    httpd -v
elif command -v apache2 &> /dev/null; then
    echo "Apache found: $(which apache2)"
    apache2 -v
else
    echo "Apache not found in PATH"
fi
echo ""
echo "Apache Status:"
systemctl is-active httpd 2>/dev/null || systemctl is-active apache2 2>/dev/null || echo "Status unknown"
echo ""
echo "Apache Modules (first 30):"
httpd -M 2>/dev/null | head -30 || apache2ctl -M 2>/dev/null | head -30 || echo "Could not list modules"
echo ""

echo "=== PHP CONFIGURATION ==="
echo "PHP Version:"
php -v 2>/dev/null || echo "PHP not found"
echo ""
echo "PHP Binary:"
which php 2>/dev/null || echo "Not in PATH"
echo ""
echo "PHP Configuration Files:"
php --ini 2>/dev/null || echo "Could not get config info"
echo ""
echo "=== PHP EXTENSIONS (All Loaded) ==="
php -m 2>/dev/null | sort || echo "Could not list extensions"
echo ""
echo "=== KEY PHP SETTINGS ==="
php -r "echo 'memory_limit: ' . ini_get('memory_limit') . \"\n\";" 2>/dev/null
php -r "echo 'max_execution_time: ' . ini_get('max_execution_time') . \"\n\";" 2>/dev/null
php -r "echo 'upload_max_filesize: ' . ini_get('upload_max_filesize') . \"\n\";" 2>/dev/null
php -r "echo 'post_max_size: ' . ini_get('post_max_size') . \"\n\";" 2>/dev/null
php -r "echo 'display_errors: ' . ini_get('display_errors') . \"\n\";" 2>/dev/null
php -r "echo 'error_reporting: ' . ini_get('error_reporting') . \"\n\";" 2>/dev/null
echo ""

echo "=== DATABASE ==="
echo "MySQL/MariaDB Version:"
mysql -V 2>/dev/null || echo "MySQL/MariaDB not found"
echo ""
echo "Database Service Status:"
systemctl is-active mariadb 2>/dev/null || systemctl is-active mysqld 2>/dev/null || systemctl is-active mysql 2>/dev/null || echo "Status unknown"
echo ""

echo "=== WEB ROOT DETECTION ==="
echo "Checking common web root locations..."
for dir in /var/www/html /var/www /usr/share/nginx/html /home/*/public_html; do
    if [ -d "$dir" ]; then
        echo "Found: $dir"
        echo "  Size: $(du -sh $dir 2>/dev/null | cut -f1)"
        echo "  Files: $(find $dir -type f 2>/dev/null | wc -l)"
        echo "  Top-level contents:"
        ls -lh $dir 2>/dev/null | head -15
        echo ""
    fi
done
echo ""

echo "=== APACHE DOCUMENT ROOTS ==="
grep -r "DocumentRoot" /etc/httpd/ /etc/apache2/ 2>/dev/null | head -10 || echo "Could not find Apache config"
echo ""

echo "=== RESOURCE USAGE ==="
echo "CPU:"
grep "model name" /proc/cpuinfo | head -1
echo "CPU Cores: $(grep -c processor /proc/cpuinfo)"
echo ""
echo "Memory:"
free -h
echo ""
echo "Disk Usage:"
df -h
echo ""
echo "System Load:"
uptime
echo ""

echo "=== NETWORK CONFIGURATION ==="
echo "IP Addresses:"
ip addr show 2>/dev/null | grep "inet " || ifconfig 2>/dev/null | grep "inet "
echo ""
echo "Open Ports:"
ss -tlnp 2>/dev/null | grep -E ":(80|443|3306|22|8080) " || netstat -tlnp 2>/dev/null | grep -E ":(80|443|3306|22|8080) " || echo "Could not list ports"
echo ""

echo "=== SECURITY ==="
echo "Firewall Status:"
if command -v firewall-cmd &> /dev/null; then
    echo "Firewalld detected"
    systemctl is-active firewalld
    firewall-cmd --list-all 2>/dev/null | head -20
elif command -v ufw &> /dev/null; then
    echo "UFW detected"
    ufw status
else
    echo "No recognized firewall found"
fi
echo ""
echo "SELinux:"
getenforce 2>/dev/null || echo "SELinux not available"
echo ""

echo "=== INSTALLED PHP PACKAGES ==="
echo "Looking for PHP packages..."
if command -v rpm &> /dev/null; then
    echo "RPM-based system detected"
    rpm -qa | grep -i php | sort
elif command -v dpkg &> /dev/null; then
    echo "DEB-based system detected"
    dpkg -l | grep php | awk '{print $2}' | sort
else
    echo "Could not determine package manager"
fi
echo ""

echo "=== PHP-FPM DETECTION ==="
if command -v php-fpm &> /dev/null; then
    echo "PHP-FPM found: $(which php-fpm)"
    php-fpm -v 2>/dev/null
    echo "Status:"
    systemctl is-active php-fpm 2>/dev/null || echo "Status unknown"
else
    echo "PHP-FPM not found in PATH"
fi
echo ""

echo "=== SSL CERTIFICATES ==="
echo "Checking for SSL certificates..."
if [ -d "/etc/letsencrypt/live" ]; then
    echo "Let's Encrypt certificates found:"
    ls -la /etc/letsencrypt/live/ 2>/dev/null
fi
if [ -d "/etc/ssl/certs" ]; then
    echo "SSL certs directory exists: /etc/ssl/certs"
fi
echo ""

echo "=== CRON JOBS ==="
echo "Root crontab:"
crontab -l 2>/dev/null || echo "No crontab for root"
echo ""

echo "=== RECENT LOG ERRORS (Last 10) ==="
echo "Apache/httpd errors:"
tail -10 /var/log/httpd/error_log 2>/dev/null || tail -10 /var/log/apache2/error.log 2>/dev/null || echo "Log not found"
echo ""
echo "PHP errors:"
tail -10 /var/log/php_errors.log 2>/dev/null || tail -10 /var/log/php-fpm/error.log 2>/dev/null || echo "Log not found"
echo ""

echo "=== IMPORTANT FILE LOCATIONS ==="
echo "PHP config: $(php --ini 2>/dev/null | grep "Loaded Configuration File" | cut -d: -f2 | xargs)"
echo "Apache config: $(find /etc -name "httpd.conf" -o -name "apache2.conf" 2>/dev/null | head -1)"
echo ""

echo "========================================"
echo "AUDIT COMPLETE"
echo "========================================"
echo ""
echo "Summary:"
echo "- OS: $(cat /etc/*release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
echo "- PHP: $(php -v 2>/dev/null | head -1 || echo 'Not found')"
echo "- Web Server: $(httpd -v 2>/dev/null | head -1 || apache2 -v 2>/dev/null | head -1 || echo 'Not found')"
echo "- Database: $(mysql -V 2>/dev/null || echo 'Not found')"
echo "========================================"
'@

# Execute the audit script on the remote server
try {
    Write-Host "Running audit script on remote server..." -ForegroundColor Cyan
    Write-Host "(You'll need to enter the password: byCdgzMr5AHx)" -ForegroundColor Yellow
    Write-Host ""
    
    $AuditScript | ssh "$Username@$ServerIP" 'bash -s' | Out-File -FilePath $ReportFile -Encoding UTF8
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================"
        Write-Host "SUCCESS!" -ForegroundColor Green
        Write-Host "========================================"
        Write-Host "Audit completed successfully!"
        Write-Host "Report saved to: $ReportFile"
        Write-Host ""
        Write-Host "Opening report file..."
        
        # Display report
        Write-Host ""
        Write-Host "=== REPORT PREVIEW (First 50 lines) ===" -ForegroundColor Cyan
        Get-Content $ReportFile -Head 50
        Write-Host ""
        Write-Host "... (see full report in $ReportFile)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Opening full report in notepad..."
        Start-Process notepad $ReportFile
        
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Review the report file: $ReportFile"
        Write-Host "2. Share relevant sections with your team"
        Write-Host "3. Compare with PRE_MIGRATION_CHECKLIST.md"
        Write-Host "4. Look for any deprecated PHP functions in your code"
    } else {
        Write-Host ""
        Write-Host "ERROR: Audit failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Please check your connection and try again."
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to connect or execute audit" -ForegroundColor Red
    Write-Host "Error details: $_"
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify the server IP is correct: $ServerIP"
    Write-Host "2. Check if you can ping the server: ping $ServerIP"
    Write-Host "3. Try manual SSH: ssh $Username@$ServerIP"
    Write-Host "4. Ensure OpenSSH client is installed"
}

Write-Host ""
Write-Host "Script finished." -ForegroundColor Cyan
