@echo off
echo =========================================
echo   AUTO-INSTALLING PHP 8.2
echo =========================================
echo.
echo Server: 31.97.233.171
echo Starting installation automatically...
echo.

echo z(P5ts@wdsESLUjMPVXs | ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no root@31.97.233.171 "echo '=== Installing PHP 8.2 ===' && apt update -y && apt install -y software-properties-common && add-apt-repository -y ppa:ondrej/php && apt update -y && DEBIAN_FRONTEND=noninteractive apt install -y php8.2-fpm php8.2-mysql php8.2-mysqli php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-opcache && systemctl enable php8.2-fpm && systemctl start php8.2-fpm && systemctl restart nginx && echo '=== Installation Complete ===' && php -v && systemctl is-active php8.2-fpm nginx && curl -I http://localhost | head -3"

echo.
echo =========================================
echo   Testing Site...
echo =========================================
timeout /t 3 /nobreak > nul
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://archive2.adgully.com/' -TimeoutSec 15; Write-Host 'SUCCESS! Site is UP!' -ForegroundColor Green; Write-Host 'Status:' $r.StatusCode } catch { $code = $_.Exception.Response.StatusCode.value__; if ($code) { Write-Host 'HTTP' $code } else { Write-Host $_.Exception.Message } }"
echo.
echo Done!
