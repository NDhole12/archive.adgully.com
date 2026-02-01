@echo off
echo Uploading fixed config.php to server...
d:\archive.adgully.com\tools\pscp.exe -pw "z(P5ts@wdsESLUjMPVXs" d:\achive.adgully.com\archive.adgully.com\httpdocs\config.php root@31.97.233.171:/var/www/archive2.adgully.com/config.php

echo.
echo Verifying the change...
d:\archive.adgully.com\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 "grep 'config_image_host' /var/www/archive2.adgully.com/config.php | head -2"

echo.
echo DONE! Opening test page...
timeout /t 2 >nul
start https://archive2.adgully.com/

pause
