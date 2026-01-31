# Direct Migration - PC as intermediary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DATABASE MIGRATION VIA LOCAL PC" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "adgully_$timestamp.sql"
$localPath = "D:\archive.adgully.com\backups\$backupFile"

# Step 1: Backup on OLD server
Write-Host "Step 1: Creating backup on OLD server..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw "MsIhJgArhSg8x" "root@13.234.95.152" "mysqldump -uroot -pMsIhJgArhSg8x adgully > /tmp/$backupFile && ls -lh /tmp/$backupFile"

# Step 2: Download to PC
Write-Host "`nStep 2: Downloading to PC..." -ForegroundColor Yellow
& "$env:TEMP\pscp.exe" -batch -pw "MsIhJgArhSg8x" "root@13.234.95.152:/tmp/$backupFile" "$localPath"

if (Test-Path $localPath) {
    $sizeMB = [math]::Round((Get-Item $localPath).Length / 1MB, 2)
    Write-Host "✓ Downloaded: $sizeMB MB" -ForegroundColor Green
} else {
    Write-Host "✗ Download failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Clean OLD server
Write-Host "`nStep 3: Cleaning OLD server..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw "MsIhJgArhSg8x" "root@13.234.95.152" "rm /tmp/$backupFile"
Write-Host "✓ OLD server cleaned" -ForegroundColor Green

# Step 4: Upload to NEW server
Write-Host "`nStep 4: Uploading to NEW server..." -ForegroundColor Yellow
& "$env:TEMP\pscp.exe" -batch -pw "z(P5ts@wdsESLUjMPVXs" "$localPath" "root@31.97.233.171:/tmp/"
Write-Host "✓ Uploaded" -ForegroundColor Green

# Step 5: Restore on NEW server
Write-Host "`nStep 5: Restoring database on NEW server..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw "z(P5ts@wdsESLUjMPVXs" "root@31.97.233.171" "mysqldump -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully > /tmp/backup_before.sql 2>/dev/null; mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e 'DROP DATABASE IF EXISTS archive_adgully; CREATE DATABASE archive_adgully CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'; mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully < /tmp/$backupFile; mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e 'GRANT SELECT, INSERT, UPDATE ON archive_adgully.* TO ''archive_user''@''localhost''; FLUSH PRIVILEGES;'; mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e 'SELECT COUNT(*) as Total_Articles FROM cms_article;'; rm /tmp/$backupFile"

Write-Host "`nDatabase restored!" -ForegroundColor Green

# Step 6: Update domains
Write-Host "`nStep 6: Updating domain references..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw "z(P5ts@wdsESLUjMPVXs" "root@31.97.233.171" "mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e 'UPDATE cms_article SET article_description=REPLACE(article_description,''www.adgully.com'',''archive2.adgully.com'') WHERE article_description LIKE ''%www.adgully.com%'';'; mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e 'UPDATE cms_article SET article_description=REPLACE(article_description,''test.adgully.com'',''archive2.adgully.com'') WHERE article_description LIKE ''%test.adgully.com%'';'; mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e 'UPDATE cms_article SET article_link=REPLACE(article_link,''www.adgully.com'',''archive2.adgully.com'') WHERE article_link LIKE ''%www.adgully.com%'';'; mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e 'UPDATE cms_article SET article_link=REPLACE(article_link,''test.adgully.com'',''archive2.adgully.com'') WHERE article_link LIKE ''%test.adgully.com%'';'; cd /var/www/archive2.adgully.com; sed -i 's|www.adgully.com|archive2.adgully.com|g; s|test.adgully.com|archive2.adgully.com|g; s|http://archive2|https://archive2|g' application/config/config.php"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  MIGRATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nBackup saved: $localPath" -ForegroundColor White
Write-Host "Test now: https://archive2.adgully.com/" -ForegroundColor White
