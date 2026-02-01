@echo off
echo Uploading full adgully.sql (937MB) to server...
d:\archive.adgully.com\tools\pscp.exe -pw "z(P5ts@wdsESLUjMPVXs" d:\achive.adgully.com\archive.adgully.com\httpdocs\adgully.sql root@31.97.233.171:/tmp/adgully_full.sql

echo.
echo Upload complete! Importing into database...
d:\archive.adgully.com\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 "mysql -u archive_user -p'ArchiveUser@2026Secure' archive_adgully < /tmp/adgully_full.sql && echo 'Database import complete!'"

pause
