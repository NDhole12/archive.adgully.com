# Setup SSL Certificates for archive2.adgully.com
# Run this script to obtain Let's Encrypt SSL certificates

$serverIP = "31.97.233.171"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  SSL CERTIFICATE SETUP - Archive2.adgully.com" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Target: $serverIP" -ForegroundColor White
Write-Host "Domains: archive2.adgully.com, pma.archive2.adgully.com" -ForegroundColor White
Write-Host ""

Write-Host "This will:" -ForegroundColor Yellow
Write-Host "  - Obtain Let's Encrypt SSL certificates" -ForegroundColor Cyan
Write-Host "  - Configure Nginx for HTTPS" -ForegroundColor Cyan
Write-Host "  - Enable automatic SSL renewal" -ForegroundColor Cyan
Write-Host ""

Write-Host "Connecting to server and installing SSL certificates..." -ForegroundColor Yellow
Write-Host ""

# Run certbot commands
$sshCommand = "certbot --nginx -d archive2.adgully.com -d pma.archive2.adgully.com --non-interactive --agree-tos --email admin@adgully.com --redirect && nginx -t && systemctl reload nginx && certbot certificates"

ssh root@$serverIP $sshCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "  SUCCESS - SSL CERTIFICATES INSTALLED!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your sites are now secure (HTTPS):" -ForegroundColor Cyan
    Write-Host "  - https://archive2.adgully.com" -ForegroundColor White
    Write-Host "  - https://pma.archive2.adgully.com" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "  FAILED - SSL INSTALLATION ERROR" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check manually:" -ForegroundColor Yellow
    Write-Host "  ssh root@$serverIP" -ForegroundColor White
    Write-Host "  certbot certificates" -ForegroundColor White
}

