@echo off
echo =========================================
echo   INSTALLING PHP 8.2 ON SERVER
echo =========================================
echo.
echo This will install PHP 8.2-FPM and fix the site
echo Server: 31.97.233.171
echo.
echo Installation steps:
echo 1. Update system
echo 2. Add PHP repository
echo 3. Install PHP 8.2-FPM
echo 4. Install PHP extensions
echo 5. Start services
echo.
pause
echo.
echo Starting installation...
echo.

echo z(P5ts@wdsESLUjMPVXs | ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no root@31.97.233.171 "echo '=== Step 1: System Update ===' && apt update -qq && echo '=== Step 2: Install Prerequisites ===' && DEBIAN_FRONTEND=noninteractive apt install -y -qq software-properties-common && echo '=== Step 3: Add PHP Repository ===' && add-apt-repository -y ppa:ondrej/php && apt update -qq && echo '=== Step 4: Install PHP 8.2-FPM ===' && DEBIAN_FRONTEND=noninteractive apt install -y php8.2-fpm && echo '=== Step 5: Install PHP Extensions ===' && DEBIAN_FRONTEND=noninteractive apt install -y php8.2-mysql php8.2-mysqli php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-opcache && echo '=== Step 6: Enable & Start Services ===' && systemctl enable php8.2-fpm && systemctl start php8.2-fpm && systemctl restart nginx && echo '=== Step 7: Verify Installation ===' && php -v && systemctl is-active php8.2-fpm nginx && echo '=== Step 8: Test Site ===' && curl -I http://localhost | head -3 && echo '=== Installation Complete ==='"

echo.
echo =========================================
echo   Testing External Access
echo =========================================
echo.

timeout /t 5 /nobreak

powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://archive2.adgully.com/' -TimeoutSec 15; Write-Host 'SUCCESS! Site is UP!' -ForegroundColor Green; Write-Host 'Status Code:' $r.StatusCode -ForegroundColor Green } catch { $code = $_.Exception.Response.StatusCode.value__; if ($code) { Write-Host 'Status: HTTP' $code } else { Write-Host 'Error:' $_.Exception.Message } }"

echo.
echo =========================================
echo   Installation Complete!
echo =========================================
pause
