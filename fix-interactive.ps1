# Final Auto-Fix - Will prompt for password once
$serverIP = "31.97.233.171"
$username = "root"
$plainPassword = 'z(P5ts@wdsESLUjMPVXs'

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  ARCHIVE2.ADGULLY.COM - AUTO FIX" -ForegroundColor Cyan  
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server: $serverIP" -ForegroundColor White
Write-Host "Username: $username" -ForegroundColor White
Write-Host "Password: $plainPassword" -ForegroundColor Yellow
Write-Host ""
Write-Host "Copy the password above, then:" -ForegroundColor Yellow
Write-Host "1. Press Enter to continue" -ForegroundColor Yellow
Write-Host "2. Paste the password when prompted" -ForegroundColor Yellow
Write-Host "3. Press Enter" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to connect"

Write-Host ""
Write-Host "Connecting..." -ForegroundColor Cyan
Write-Host ""

# Run the fix command
ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no root@31.97.233.171 @"
echo '=== Starting Fix ==='
echo ''
echo '[1/5] Restarting services...'
systemctl restart php8.2-fpm
systemctl restart nginx  
systemctl restart mariadb
sleep 3

echo ''
echo '[2/5] Checking service status...'
systemctl is-active php8.2-fpm && echo '  ✓ PHP-FPM running' || echo '  ✗ PHP-FPM down'
systemctl is-active nginx && echo '  ✓ Nginx running' || echo '  ✗ Nginx down'
systemctl is-active mariadb && echo '  ✓ MariaDB running' || echo '  ✗ MariaDB down'

echo ''
echo '[3/5] Fixing permissions...'
chown -R www-data:www-data /var/www/archive2.adgully.com 2>/dev/null && echo '  ✓ Done' || echo '  ✗ Directory not found'

echo ''
echo '[4/5] Testing local site...'
curl -I http://localhost 2>&1 | head -3

echo ''
echo '[5/5] Recent errors...'
tail -10 /var/log/nginx/error.log

echo ''
echo '=== Fix Complete ==='
"@

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  Testing External Access" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "https://archive2.adgully.com/" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✓ SUCCESS! Site is UP!" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode) {
        Write-Host "✗ Site returned HTTP $statusCode" -ForegroundColor Red
    } else {
        Write-Host "✗ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
