@echo off
echo =========================================
echo   AUTOMATED SERVER FIX
echo =========================================
echo.
echo Server: 31.97.233.171
echo Password will be sent automatically...
echo.
echo | set /p="z(P5ts@wdsESLUjMPVXs" | ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no root@31.97.233.171 "systemctl restart php8.2-fpm nginx mariadb && sleep 3 && systemctl is-active php8.2-fpm nginx mariadb && chown -R www-data:www-data /var/www/archive2.adgully.com && curl -I http://localhost | head -5 && echo && tail -20 /var/log/nginx/error.log"
echo.
echo =========================================
echo   Testing External Access
echo =========================================
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://archive2.adgully.com/' -TimeoutSec 10; Write-Host 'SUCCESS! Status: ' $r.StatusCode -ForegroundColor Green } catch { Write-Host 'Error: HTTP' $_.Exception.Response.StatusCode.value__ -ForegroundColor Red }"
echo.
pause
