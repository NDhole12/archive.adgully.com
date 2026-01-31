# Server Diagnostic Script
# Run this to diagnose the 500 error

$serverIP = "31.97.233.171"
$password = 'z(P5ts@wdsESLUjMPVXs'

Write-Host "=== Server Diagnostic for archive2.adgully.com ===" -ForegroundColor Cyan
Write-Host ""

# Create commands to run
$commands = @(
    "systemctl status php8.2-fpm --no-pager -l",
    "systemctl status nginx --no-pager -l",
    "systemctl status mariadb --no-pager -l",
    "tail -30 /var/log/nginx/error.log",
    "tail -30 /var/log/php8.2-fpm.log 2>/dev/null || tail -30 /var/log/php/fpm-error.log 2>/dev/null || echo 'PHP log not found'",
    "ls -la /var/www/archive2.adgully.com/public_html/index.php 2>/dev/null || echo 'Index file not found'",
    "mysql -uarchive_user -pArchiveUser@2026Secure archive_adgully -e 'SELECT 1;' 2>&1"
)

Write-Host "To diagnose the issue, please SSH into the server and run:" -ForegroundColor Yellow
Write-Host "ssh root@$serverIP" -ForegroundColor Green
Write-Host ""
Write-Host "Then run these commands one by one:" -ForegroundColor Yellow
Write-Host ""

foreach ($cmd in $commands) {
    Write-Host "# $cmd" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== Quick Fix Commands ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "# If PHP-FPM is down:" -ForegroundColor Yellow
Write-Host "systemctl restart php8.2-fpm" -ForegroundColor Green
Write-Host ""
Write-Host "# If Nginx is down:" -ForegroundColor Yellow
Write-Host "systemctl restart nginx" -ForegroundColor Green
Write-Host ""
Write-Host "# Fix file permissions:" -ForegroundColor Yellow
Write-Host "chown -R www-data:www-data /var/www/archive2.adgully.com" -ForegroundColor Green
Write-Host ""
Write-Host "# Test site after fixes:" -ForegroundColor Yellow
Write-Host "curl -I http://localhost" -ForegroundColor Green
