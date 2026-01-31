@echo off
echo =========================================
echo   Creating Test Page on Server
echo =========================================
echo.

echo z(P5ts@wdsESLUjMPVXs | ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no root@31.97.233.171 "mkdir -p /var/www/archive2.adgully.com && echo '<?php echo \"<h1>PHP is Working!</h1>\"; echo \"<p>PHP Version: \" . phpversion() . \"</p>\"; echo \"<p>Server: \" . php_uname() . \"</p>\"; phpinfo(); ?>' > /var/www/archive2.adgully.com/index.php && chown -R www-data:www-data /var/www/archive2.adgully.com && ls -la /var/www/archive2.adgully.com/ && echo '' && echo 'Testing...' && curl -I http://localhost"

echo.
echo =========================================
echo   Testing Site
echo =========================================
timeout /t 2 /nobreak > nul
powershell -Command "try { $r = Invoke-WebRequest -Uri 'https://archive2.adgully.com/' -TimeoutSec 10; Write-Host 'SUCCESS! Site Status:' $r.StatusCode -ForegroundColor Green } catch { Write-Host 'Status:' $_.Exception.Response.StatusCode.value__ }"
echo.
echo Done!
