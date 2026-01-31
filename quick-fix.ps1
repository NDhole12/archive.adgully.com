# Quick Auto-Fix for 500 Error
$serverIP = "31.97.233.171"
$username = "root"

Write-Host "=== Auto-Fixing Server ===" -ForegroundColor Cyan
Write-Host ""

# Create inline fix commands
$commands = "systemctl restart php8.2-fpm nginx mariadb; sleep 3; systemctl is-active php8.2-fpm nginx mariadb; chown -R www-data:www-data /var/www/archive2.adgully.com 2>/dev/null; curl -I http://localhost 2>&1 | head -5"

Write-Host "Connecting to $serverIP..." -ForegroundColor Yellow
Write-Host "Running fix commands..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================="-ForegroundColor Green

# Execute via SSH
$process = Start-Process -FilePath "ssh" -ArgumentList "-o StrictHostKeyChecking=no","-o PubkeyAuthentication=no","${username}@${serverIP}",$commands -NoNewWindow -Wait -PassThru

Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Test the site
Write-Host "Testing site..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://archive2.adgully.com/" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "SUCCESS! Site is UP - Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode) {
        Write-Host "Site returned: HTTP $statusCode" -ForegroundColor Yellow
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Fix complete!" -ForegroundColor Cyan
