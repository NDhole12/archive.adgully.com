$pass = 'z(P5ts@wdsESLUjMPVXs'
$server = "31.97.233.171"

Write-Host "Installing PHP 8.2..." -ForegroundColor Cyan

$cmd = @"
apt update -y && apt install -y software-properties-common && add-apt-repository -y ppa:ondrej/php && apt update -y && DEBIAN_FRONTEND=noninteractive apt install -y php8.2-fpm php8.2-mysql php8.2-mysqli php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-opcache && systemctl enable php8.2-fpm && systemctl start php8.2-fpm && systemctl restart nginx && php -v && systemctl status php8.2-fpm --no-pager && curl -I http://localhost
"@

# Use plink if available
if (Test-Path "C:\Program Files\PuTTY\plink.exe") {
    & "C:\Program Files\PuTTY\plink.exe" -ssh root@$server -pw $pass -batch $cmd
} else {
    Write-Host "Executing via SSH (enter password when prompted): $pass" -ForegroundColor Yellow
    Write-Host ""
    ssh -o PubkeyAuthentication=no root@$server $cmd
}

Write-Host ""
Write-Host "Testing site..." -ForegroundColor Cyan
Start-Sleep -Seconds 3
try {
    $r = Invoke-WebRequest -Uri "https://archive2.adgully.com/" -TimeoutSec 15
    Write-Host "SUCCESS! Site is UP! Status: $($r.StatusCode)" -ForegroundColor Green
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code) { Write-Host "HTTP $code" } else { Write-Host $_.Exception.Message }
}
