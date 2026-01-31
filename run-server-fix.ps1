# Automated Server Fix Script
# This will connect to the server and run diagnostics

$serverIP = "31.97.233.171"
$username = "root"

Write-Host "=== Connecting to Server and Running Diagnostics ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server: $serverIP" -ForegroundColor Yellow
Write-Host ""

# Create the fix script content
$fixScript = @'
#!/bin/bash
echo "=== Quick 500 Error Fix ==="
echo "1. Restarting services..."
systemctl restart php8.2-fpm
systemctl restart nginx
systemctl restart mariadb
sleep 3
echo "2. Checking status..."
systemctl is-active php8.2-fpm && echo "✓ PHP-FPM running" || echo "✗ PHP-FPM failed"
systemctl is-active nginx && echo "✓ Nginx running" || echo "✗ Nginx failed"
systemctl is-active mariadb && echo "✓ MariaDB running" || echo "✗ MariaDB failed"
echo "3. Fixing permissions..."
chown -R www-data:www-data /var/www/archive2.adgully.com 2>/dev/null && echo "✓ Permissions fixed" || echo "✗ Directory not found"
echo "4. Testing site..."
curl -I http://localhost 2>&1 | head -5
echo "5. Checking recent errors..."
tail -10 /var/log/nginx/error.log
'@

# Save script to temp file
$tempScript = "fix-500-quick.sh"
$fixScript | Out-File -FilePath $tempScript -Encoding UTF8 -NoNewline

Write-Host "Created diagnostic script: $tempScript" -ForegroundColor Green
Write-Host ""
Write-Host "To fix the server, run these commands:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Copy the script to server:" -ForegroundColor Cyan
Write-Host "   scp $tempScript ${username}@${serverIP}:~/" -ForegroundColor White
Write-Host ""
Write-Host "2. Connect to server:" -ForegroundColor Cyan
Write-Host "   ssh ${username}@${serverIP}" -ForegroundColor White
Write-Host ""
Write-Host "3. Run the fix script:" -ForegroundColor Cyan
Write-Host "   bash ~/fix-500-quick.sh" -ForegroundColor White
Write-Host ""
Write-Host "OR run this single command to do all at once:" -ForegroundColor Yellow
Write-Host ""
Write-Host "ssh ${username}@${serverIP} 'bash -s' < $tempScript" -ForegroundColor Green
Write-Host ""
