# Update Domain Configuration Script
# Changes domain from archive.adgully.com to archive2.adgully.com

$server = "31.97.233.171"
$pass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DOMAIN CONFIGURATION UPDATE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Updating domain references:" -ForegroundColor Yellow
Write-Host "  FROM: https://www.adgully.com/" -ForegroundColor Red
Write-Host "  FROM: http://www.adgully.com/" -ForegroundColor Red
Write-Host "  TO:   https://archive2.adgully.com/" -ForegroundColor Green
Write-Host ""

# Run updates on server
& "$env:TEMP\plink.exe" -batch -pw $pass "root@$server" @"
#!/bin/bash
set -e

echo "=== Checking current domain references ==="
grep -n 'www.adgully.com' /var/www/archive2.adgully.com/config.php || echo "No www.adgully.com found"
grep -n 'test.adgully.com' /var/www/archive2.adgully.com/config.php || echo "No test.adgully.com found"
echo ""

echo "=== Creating backup ==="
cp /var/www/archive2.adgully.com/config.php /var/www/archive2.adgully.com/config.php.backup-domain

echo "=== Updating domain references ==="
# Update www.adgully.com to archive2.adgully.com
sed -i 's/www\.adgully\.com/archive2.adgully.com/g' /var/www/archive2.adgully.com/config.php
sed -i 's/test\.adgully\.com/archive2.adgully.com/g' /var/www/archive2.adgully.com/config.php

echo ""
echo "=== Verifying changes ==="
grep -n 'archive2.adgully.com' /var/www/archive2.adgully.com/config.php | head -10

echo ""
echo "=== Domain update complete ==="
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  UPDATE COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Domain references updated in config.php" -ForegroundColor Cyan
Write-Host "Backup saved: config.php.backup-domain" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test the website:" -ForegroundColor Yellow
Write-Host "  https://archive2.adgully.com/" -ForegroundColor White
Write-Host ""
