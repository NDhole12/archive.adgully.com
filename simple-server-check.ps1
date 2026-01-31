# Simple Server Check Script
# This will prompt for password once and get all essential info

$ServerIP = "172.31.21.197"
$Username = "root"
$OutputFile = "server-check-simple.txt"

Write-Host "Connecting to $Username@$ServerIP..." -ForegroundColor Cyan
Write-Host "You'll be prompted for password once" -ForegroundColor Yellow
Write-Host ""

# Simple one-line command to get essential info
$Command = @"
echo '=== PHP VERSION ===' && php -v && echo '' && echo '=== PHP EXTENSIONS ===' && php -m && echo '' && echo '=== MYSQL VERSION ===' && mysql -V && echo '' && echo '=== APACHE VERSION ===' && httpd -v && echo '' && echo '=== SYSTEM INFO ===' && cat /etc/centos-release && echo '' && echo '=== PHP CONFIG ===' && php --ini
"@

$Command | ssh "$Username@$ServerIP" 'bash -s' | Tee-Object -FilePath $OutputFile

Write-Host ""
Write-Host "Report saved to: $OutputFile" -ForegroundColor Green
Write-Host "Opening report..." -ForegroundColor Cyan
notepad $OutputFile
