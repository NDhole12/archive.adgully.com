# Automated SSL Setup Script
# Automatically installs SSL certificates without password prompts

$serverIP = "31.97.233.171"
$serverUser = "root"
$serverPass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  AUTOMATED SSL CERTIFICATE SETUP" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Target: $serverIP" -ForegroundColor White
Write-Host "Domains: archive2.adgully.com, pma.archive2.adgully.com" -ForegroundColor White
Write-Host ""

# Try to find plink (PuTTY)
$plinkPath = $null
$possiblePaths = @(
    "C:\Program Files\PuTTY\plink.exe",
    "C:\Program Files (x86)\PuTTY\plink.exe",
    "$env:ProgramFiles\PuTTY\plink.exe",
    "$env:LOCALAPPDATA\Programs\PuTTY\plink.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $plinkPath = $path
        break
    }
}

# Check if plink is in PATH
if (-not $plinkPath) {
    $plink = Get-Command plink -ErrorAction SilentlyContinue
    if ($plink) {
        $plinkPath = $plink.Source
    }
}

# If plink not found, download it
if (-not $plinkPath) {
    Write-Host "PuTTY plink not found. Downloading..." -ForegroundColor Yellow
    $plinkPath = "$env:TEMP\plink.exe"
    try {
        Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe" -OutFile $plinkPath -UseBasicParsing
        Write-Host "Downloaded plink.exe to: $plinkPath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download plink.exe" -ForegroundColor Red
        Write-Host "Please install PuTTY manually from: https://www.putty.org/" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "Using: $plinkPath" -ForegroundColor Green
Write-Host ""
Write-Host "Installing SSL certificates..." -ForegroundColor Yellow
Write-Host "This may take 30-60 seconds..." -ForegroundColor Gray
Write-Host ""

# Commands to run on server
$commands = @(
    "certbot --nginx -d archive2.adgully.com -d pma.archive2.adgully.com --non-interactive --agree-tos --email admin@adgully.com --redirect",
    "nginx -t",
    "systemctl reload nginx",
    "certbot certificates",
    "echo 'SSL_INSTALLATION_COMPLETE'"
)

$fullCommand = $commands -join " && "

# Run with plink
$output = & $plinkPath -batch -pw $serverPass "$serverUser@$serverIP" $fullCommand 2>&1

Write-Host $output
Write-Host ""

if ($output -match "SSL_INSTALLATION_COMPLETE" -or $output -match "Certificate Name: archive2.adgully.com") {
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "  SUCCESS - SSL CERTIFICATES INSTALLED!" -ForegroundColor Green  
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your sites are now secure:" -ForegroundColor Cyan
    Write-Host "  https://archive2.adgully.com" -ForegroundColor White
    Write-Host "  https://pma.archive2.adgully.com" -ForegroundColor White
    Write-Host ""
    Write-Host "IT IS DONE!" -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
} else {
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "  FAILED - Check error messages above" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual fix:" -ForegroundColor Yellow
    Write-Host "  ssh root@$serverIP" -ForegroundColor White
    Write-Host "  certbot --nginx -d archive2.adgully.com -d pma.archive2.adgully.com" -ForegroundColor White
}
