# Automated 500 Error Fix Script
# Connects to server and fixes the issue automatically

$serverIP = "31.97.233.171"
$username = "root"
$password = 'z(P5ts@wdsESLUjMPVXs'

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  AUTO-FIX: archive2.adgully.com" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Create the fix script
$fixCommands = @'
#!/bin/bash
echo "=== Emergency Fix Starting ==="
echo ""
echo "[1/5] Restarting PHP-FPM..."
systemctl restart php8.2-fpm
sleep 1
systemctl is-active php8.2-fpm && echo "  ✓ PHP-FPM: Running" || echo "  ✗ PHP-FPM: FAILED"

echo ""
echo "[2/5] Restarting Nginx..."
systemctl restart nginx
sleep 1
systemctl is-active nginx && echo "  ✓ Nginx: Running" || echo "  ✗ Nginx: FAILED"

echo ""
echo "[3/5] Restarting MariaDB..."
systemctl restart mariadb
sleep 2
systemctl is-active mariadb && echo "  ✓ MariaDB: Running" || echo "  ✗ MariaDB: FAILED"

echo ""
echo "[4/5] Fixing permissions..."
if [ -d /var/www/archive2.adgully.com ]; then
    chown -R www-data:www-data /var/www/archive2.adgully.com
    find /var/www/archive2.adgully.com -type d -exec chmod 755 {} \;
    find /var/www/archive2.adgully.com -type f -exec chmod 644 {} \;
    echo "  ✓ Permissions fixed"
else
    echo "  ✗ Directory not found: /var/www/archive2.adgully.com"
fi

echo ""
echo "[5/5] Testing site..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
echo "  Local HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "  ✓ Site is responding!"
else
    echo "  ✗ Site still has issues"
    echo ""
    echo "Recent errors:"
    tail -10 /var/log/nginx/error.log
fi

echo ""
echo "=== Fix Complete ==="
'@

# Save the script
$localScript = "fix-temp.sh"
$fixCommands | Out-File -FilePath $localScript -Encoding UTF8 -NoNewline

Write-Host "Step 1: Uploading fix script..." -ForegroundColor Yellow

# Try using plink if available
$plink = Get-Command plink -ErrorAction SilentlyContinue
if ($plink) {
    Write-Host "Using plink for connection..." -ForegroundColor Green
    
    # Upload script
    & pscp -pw $password $localScript ${username}@${serverIP}:/root/fix.sh
    
    # Execute script
    Write-Host ""
    Write-Host "Step 2: Executing fix on server..." -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Green
    & plink -ssh -pw $password ${username}@${serverIP} "bash /root/fix.sh"
    Write-Host "=========================================" -ForegroundColor Green
    
} else {
    Write-Host "Plink not found. Using SSH with script pipe..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Step 2: Connecting and fixing..." -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Green
    
    # Use SSH with heredoc
    $sshCommand = @"
systemctl restart php8.2-fpm nginx mariadb
sleep 3
echo ""
echo "Service Status:"
systemctl is-active php8.2-fpm && echo "✓ PHP-FPM" || echo "✗ PHP-FPM"
systemctl is-active nginx && echo "✓ Nginx" || echo "✗ Nginx"
systemctl is-active mariadb && echo "✓ MariaDB" || echo "✗ MariaDB"
echo ""
echo "Fixing permissions..."
chown -R www-data:www-data /var/www/archive2.adgully.com 2>/dev/null
echo ""
echo "Testing site..."
curl -I http://localhost 2>&1 | head -5
echo ""
echo "Recent errors:"
tail -10 /var/log/nginx/error.log
"@
    
    $sshCommand | ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no ${username}@${serverIP}
    
    Write-Host "=========================================" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 3: Testing external access..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "https://archive2.adgully.com/" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✓ Site is UP! Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode) {
        Write-Host "✗ Site returned: HTTP $statusCode" -ForegroundColor Red
    } else {
        Write-Host "✗ Site not accessible: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Fix Attempt Complete" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Cleanup
Remove-Item $localScript -ErrorAction SilentlyContinue
Write-Host ""
