# Simple Installation Runner - Uploads and executes installation script
# For new Ubuntu server at 31.97.233.171

param(
    [switch]$AutoConfirm
)

$serverIP = "31.97.233.171"
$scriptPath = "D:\archive.adgully.com\scripts\install\auto-install.sh"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  NEW SERVER INSTALLATION - Archive.adgully.com" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Target: $serverIP" -ForegroundColor White
Write-Host "Script: $scriptPath" -ForegroundColor White
Write-Host ""

# Check if script exists
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Installation script not found!" -ForegroundColor Red
    Write-Host "Expected: $scriptPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Installation script found" -ForegroundColor Green
Write-Host ""

Write-Host "This will install:" -ForegroundColor Yellow
Write-Host "  • Nginx web server" -ForegroundColor Cyan
Write-Host "  • PHP 8.2 + all extensions" -ForegroundColor Cyan
Write-Host "  • MariaDB 10.11 database" -ForegroundColor Cyan
Write-Host "  • UFW Firewall" -ForegroundColor Cyan
Write-Host "  • Fail2ban security" -ForegroundColor Cyan
Write-Host "  • SSL tools (Certbot)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Estimated time: 10-20 minutes" -ForegroundColor Yellow
Write-Host ""

# If AutoConfirm flag provided, skip the interactive prompt
if (-not $AutoConfirm) {
    $confirm = Read-Host "Continue? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "AutoConfirm supplied - continuing without prompt" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Uploading script to server..." -ForegroundColor Yellow

# Upload script
scp $scriptPath root@${serverIP}:/root/auto-install.sh

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Failed to upload script" -ForegroundColor Red
    Write-Host "Check SSH connection and credentials" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Script uploaded" -ForegroundColor Green
Write-Host ""
Write-Host "Starting installation (this will take 10-20 minutes)..." -ForegroundColor Yellow
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

# Run installation
ssh root@$serverIP "chmod +x /root/auto-install.sh && /root/auto-install.sh 2>&1 | tee /root/installation.log"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Installation failed" -ForegroundColor Red
    Write-Host "Check manually:" -ForegroundColor Yellow
    Write-Host "  ssh root@$serverIP" -ForegroundColor White
    Write-Host "  cat /root/installation.log" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

# Download log
$logPath = "D:\archive.adgully.com\backups\installation-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
scp root@${serverIP}:/root/installation.log $logPath 2>$null
Write-Host "Log saved: $logPath" -ForegroundColor Cyan
Write-Host ""

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Verify services:" -ForegroundColor Yellow
Write-Host "   ssh root@$serverIP" -ForegroundColor White
Write-Host "   systemctl status nginx php8.2-fpm mariadb" -ForegroundColor White
Write-Host ""
Write-Host "2. Secure MariaDB:" -ForegroundColor Yellow
Write-Host "   ssh root@$serverIP" -ForegroundColor White
Write-Host "   mysql_secure_installation" -ForegroundColor White
Write-Host ""
Write-Host "3. Upload configs:" -ForegroundColor Yellow
Write-Host "   scp -r D:\archive.adgully.com\configs root@${serverIP}:/root/" -ForegroundColor White
Write-Host ""
Write-Host "4. Continue with Day 5 (MIGRATION_EXECUTION_PLAN.md)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
