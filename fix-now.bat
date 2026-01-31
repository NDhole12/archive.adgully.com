@echo off
REM Quick fix using password authentication
echo === Connecting to server and fixing ===
echo.

REM Use SSH with password (will prompt)
echo Server: 31.97.233.171
echo Username: root
echo Password: z(P5ts@wdsESLUjMPVXs
echo.
echo Commands to run:
echo - Restart PHP-FPM, Nginx, MariaDB
echo - Fix permissions
echo - Test site
echo.
pause

ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no root@31.97.233.171 "systemctl restart php8.2-fpm nginx mariadb && sleep 3 && systemctl is-active php8.2-fpm nginx mariadb && chown -R www-data:www-data /var/www/archive2.adgully.com && curl -I http://localhost | head -5 && echo && echo '=== Checking errors ===' && tail -10 /var/log/nginx/error.log"

echo.
echo === Testing external access ===
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://archive2.adgully.com/' -TimeoutSec 10; Write-Host 'SUCCESS! Status:' $r.StatusCode -ForegroundColor Green } catch { Write-Host 'Error:' $_.Exception.Message -ForegroundColor Red }"

pause
