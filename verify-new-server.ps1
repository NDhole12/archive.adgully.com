# Quick New Server Verification Script
# Connects to NEW Ubuntu server and verifies basic setup

$newServerIP = "31.97.233.171"
$newServerPass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEW SERVER VERIFICATION" -ForegroundColor Cyan
Write-Host "Server: $newServerIP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if SSH client is available
$sshVersion = Get-Command ssh -ErrorAction SilentlyContinue
if (-not $sshVersion) {
    Write-Host "ERROR: SSH client not found!" -ForegroundColor Red
    Write-Host "Please install OpenSSH client:" -ForegroundColor Yellow
    Write-Host "Settings > Apps > Optional Features > Add OpenSSH Client" -ForegroundColor Yellow
    exit 1
}

Write-Host "SSH client found: $($sshVersion.Version)" -ForegroundColor Green
Write-Host ""

Write-Host "Attempting to connect to NEW server..." -ForegroundColor Yellow
Write-Host "IP: $newServerIP" -ForegroundColor White
Write-Host ""

Write-Host "IMPORTANT NOTES:" -ForegroundColor Cyan
Write-Host "1. You will be prompted for SSH fingerprint confirmation" -ForegroundColor White
Write-Host "   Type 'yes' and press Enter" -ForegroundColor White
Write-Host ""
Write-Host "2. You will be prompted for password" -ForegroundColor White
Write-Host "   Enter: $newServerPass" -ForegroundColor White
Write-Host ""
Write-Host "3. This script will run basic verification commands" -ForegroundColor White
Write-Host ""

# Create verification commands
$verifyCommands = @"
echo '=== NEW SERVER VERIFICATION REPORT ==='
echo ''
echo '=== HOSTNAME ==='
hostname
echo ''
echo '=== OPERATING SYSTEM ==='
cat /etc/os-release | grep -E 'PRETTY_NAME|VERSION_ID'
echo ''
echo '=== KERNEL ==='
uname -r
echo ''
echo '=== IP ADDRESS ==='
ip addr show | grep 'inet ' | grep -v '127.0.0.1'
echo ''
echo '=== CPU CORES ==='
nproc
echo ''
echo '=== MEMORY ==='
free -h | grep -E 'Mem|Swap'
echo ''
echo '=== DISK SPACE ==='
df -h | grep -E 'Filesystem|/$'
echo ''
echo '=== UPTIME ==='
uptime
echo ''
echo '=== PACKAGES NEED UPDATE ==='
apt list --upgradable 2>/dev/null | wc -l
echo ''
echo '=== CURRENTLY INSTALLED WEB/DB SOFTWARE ==='
echo 'Nginx:' \$(which nginx 2>/dev/null || echo 'Not installed')
echo 'PHP:' \$(which php 2>/dev/null || echo 'Not installed')
echo 'MySQL/MariaDB:' \$(which mysql 2>/dev/null || echo 'Not installed')
echo ''
echo '=== FIREWALL STATUS ==='
ufw status 2>/dev/null || echo 'UFW not installed or not active'
echo ''
echo '=== VERIFICATION COMPLETE ==='
echo ''
echo 'Next Steps:'
echo '1. Run: apt update && apt upgrade -y'
echo '2. Set hostname: hostnamectl set-hostname archive.adgully.com'
echo '3. Upload and run: full-install.sh'
echo '4. Follow MIGRATION_EXECUTION_PLAN.md Day 4'
"@

# Save report
$reportPath = "D:\archive.adgully.com\backups\new-server-verification-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

Write-Host "Connecting and running verification..." -ForegroundColor Yellow
Write-Host "Report will be saved to: $reportPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "===== SSH CONNECTION STARTING =====" -ForegroundColor Green
Write-Host ""

# Execute SSH command
$sshCommand = "ssh root@$newServerIP `"$verifyCommands`""
$output = Invoke-Expression $sshCommand 2>&1

# Save output
$output | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host ""
Write-Host "===== VERIFICATION COMPLETE =====" -ForegroundColor Green
Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Cyan
Write-Host $reportPath -ForegroundColor White
Write-Host ""

# Display output
Write-Host "===== REPORT CONTENT =====" -ForegroundColor Cyan
Write-Host $output
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT ACTIONS:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Connect to server:" -ForegroundColor White
Write-Host "   ssh root@$newServerIP" -ForegroundColor Green
Write-Host ""
Write-Host "2. Update system:" -ForegroundColor White
Write-Host "   apt update && apt upgrade -y" -ForegroundColor Green
Write-Host ""
Write-Host "3. Set hostname:" -ForegroundColor White
Write-Host "   hostnamectl set-hostname archive.adgully.com" -ForegroundColor Green
Write-Host ""
Write-Host "4. Upload installation script:" -ForegroundColor White
Write-Host "   scp D:\archive.adgully.com\scripts\install\full-install.sh root@$newServerIP:/root/" -ForegroundColor Green
Write-Host ""
Write-Host "5. Run installation:" -ForegroundColor White
Write-Host "   chmod +x /root/full-install.sh && /root/full-install.sh" -ForegroundColor Green
Write-Host ""
Write-Host "6. Follow MIGRATION_EXECUTION_PLAN.md Day 4-5" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
