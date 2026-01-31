# Check Server Status and Install Certbot
# Fully automated - no password prompts

$serverIP = "31.97.233.171"
$serverUser = "root"
$serverPass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  SERVER CHECK & CERTBOT INSTALLATION" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Get plink
$plinkPath = "$env:TEMP\plink.exe"
if (-not (Test-Path $plinkPath)) {
    Write-Host "Downloading plink..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe" -OutFile $plinkPath -UseBasicParsing
}

Write-Host "Step 1: Checking server status..." -ForegroundColor Yellow
$checkCmd = "nginx -v 2>&1 && php -v && which certbot"
$status = & $plinkPath -batch -pw $serverPass "$serverUser@$serverIP" $checkCmd 2>&1
Write-Host $status
Write-Host ""

if ($status -notmatch "certbot") {
    Write-Host "Step 2: Installing Certbot..." -ForegroundColor Yellow
    $installCmd = "apt update && apt install -y certbot python3-certbot-nginx && certbot --version"
    $installOutput = & $plinkPath -batch -pw $serverPass "$serverUser@$serverIP" $installCmd 2>&1
    Write-Host $installOutput
    Write-Host ""
}

Write-Host "Step 3: Installing SSL certificates..." -ForegroundColor Yellow
$sslCmd = "certbot --nginx -d archive2.adgully.com -d pma.archive2.adgully.com --non-interactive --agree-tos --email admin@adgully.com --redirect && nginx -t && systemctl reload nginx"
$sslOutput = & $plinkPath -batch -pw $serverPass "$serverUser@$serverIP" $sslCmd 2>&1
Write-Host $sslOutput
Write-Host ""

if ($sslOutput -match "Successfully|Congratulations") {
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "  IT IS DONE!" -ForegroundColor Green -BackgroundColor Black
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "SSL certificates installed:" -ForegroundColor Cyan
    Write-Host "  https://archive2.adgully.com" -ForegroundColor White
    Write-Host "  https://pma.archive2.adgully.com" -ForegroundColor White
} else {
    Write-Host "Check output above for errors" -ForegroundColor Yellow
}
