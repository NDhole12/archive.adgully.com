@echo off
echo Uploading Nginx configuration...
.\tools\pscp.exe -batch -pw "z(P5ts@wdsESLUjMPVXs" .\configs\nginx\archive2.adgully.com.conf root@31.97.233.171:/etc/nginx/sites-available/archive2.adgully.com.conf

echo Testing and reloading Nginx...
.\tools\plink.exe -batch -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 "nginx -t && systemctl reload nginx && echo 'SUCCESS: Nginx reloaded'"

pause
