$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "adgully_$timestamp.sql"

Write-Host "Step 1: Backup OLD database..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw "byCdgzMr5AHx" "root@172.31.21.197" "mysqldump -uroot -pMsIhJgArhSg8x adgully > /tmp/$backupFile && ls -lh /tmp/$backupFile"

Write-Host "Step 2: Download to PC..." -ForegroundColor Yellow
& "$env:TEMP\pscp.exe" -batch -pw "byCdgzMr5AHx" "root@172.31.21.197:/tmp/$backupFile" "D:\archive.adgully.com\backups\"

Write-Host "Step 3: Upload to NEW server..." -ForegroundColor Yellow
& "$env:TEMP\pscp.exe" -batch -pw "z(P5ts@wdsESLUjMPVXs" "D:\archive.adgully.com\backups\$backupFile" "root@31.97.233.171:/tmp/"

Write-Host "Step 4: Restore database..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw "z(P5ts@wdsESLUjMPVXs" "root@31.97.233.171" "mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e 'DROP DATABASE IF EXISTS archive_adgully; CREATE DATABASE archive_adgully;' && mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully < /tmp/$backupFile && mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e 'SELECT COUNT(*) FROM cms_article;'"

Write-Host "Step 5: Update domains..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw "z(P5ts@wdsESLUjMPVXs" "root@31.97.233.171" "mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e 'UPDATE cms_article SET article_description=REPLACE(article_description,''www.adgully.com'',''archive2.adgully.com''), article_link=REPLACE(article_link,''www.adgully.com'',''archive2.adgully.com'');'"

Write-Host "DONE! Test: https://archive2.adgully.com/" -ForegroundColor Green
