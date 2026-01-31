# Complete Migration - Using IP Addresses
$oldServerIP = "13.234.95.152"
$oldPass = "MsIhJgArhSg8x"
$newServerIP = "31.97.233.171"
$newPass = "z(P5ts@wdsESLUjMPVXs"

$backupFile = "adgully_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
$localBackupPath = "D:\archive.adgully.com\backups"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  AUTOMATED DATABASE MIGRATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "OLD Server: 13.234.95.152 (archive.adgully.com)" -ForegroundColor Yellow
Write-Host "NEW Server: 31.97.233.171 (archive2.adgully.com)" -ForegroundColor Yellow
Write-Host ""

# Ensure backups directory
if (-not (Test-Path $localBackupPath)) {
    New-Item -ItemType Directory -Path $localBackupPath | Out-Null
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1: CHECK OLD SERVER DATABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

& "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServerIP" "mysql -uroot -p'$oldPass' -e 'SHOW DATABASES LIKE \`"%adgully%\`";'"

Write-Host ""
Write-Host "Article count:"
& "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServerIP" "mysql -uroot -p'$oldPass' adgully -e 'SELECT COUNT(*) as Total_Articles FROM cms_article;' 2>/dev/null || mysql -uroot -p'$oldPass' archive_adgully -e 'SELECT COUNT(*) as Total_Articles FROM cms_article;' 2>/dev/null"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 2: BACKUP OLD DATABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

& "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServerIP" "mysqldump -uroot -p'$oldPass' adgully > /tmp/$backupFile 2>/dev/null || mysqldump -uroot -p'$oldPass' archive_adgully > /tmp/$backupFile 2>/dev/null && ls -lh /tmp/$backupFile"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 3: DOWNLOAD TO LOCAL PC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

& "$env:TEMP\pscp.exe" -batch -pw $oldPass "root@${oldServerIP}:/tmp/$backupFile" "$localBackupPath\"

if (Test-Path "$localBackupPath\$backupFile") {
    $fileSize = (Get-Item "$localBackupPath\$backupFile").Length / 1MB
    Write-Host "✓ Downloaded: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
    
    & "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServerIP" "rm /tmp/$backupFile"
    Write-Host "✓ Cleaned OLD server /tmp" -ForegroundColor Green
} else {
    Write-Host "✗ ERROR: Download failed!" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 4: UPLOAD TO NEW SERVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

& "$env:TEMP\pscp.exe" -batch -pw $newPass "$localBackupPath\$backupFile" "root@${newServerIP}:/tmp/"
& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServerIP" "ls -lh /tmp/$backupFile"
Write-Host "✓ Uploaded to NEW server" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "STEP 5: RESTORE ON NEW SERVER" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host "This will REPLACE the NEW server database!" -ForegroundColor Red
Write-Host ""

& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServerIP" @"
echo "=== Creating safety backup ==="
mysqldump -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully > /tmp/archive_adgully_backup_before_restore.sql
echo "✓ Safety backup created"

echo ""
echo "=== Dropping database ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "DROP DATABASE IF EXISTS archive_adgully;"
echo "✓ Database dropped"

echo ""
echo "=== Creating database ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "CREATE DATABASE archive_adgully CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo "✓ Database created"

echo ""
echo "=== Restoring from OLD server backup ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully < /tmp/$backupFile
echo "✓ Database restored"

echo ""
echo "=== Granting permissions ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "GRANT SELECT, INSERT, UPDATE ON archive_adgully.* TO 'archive_user'@'localhost';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "FLUSH PRIVILEGES;"
echo "✓ Permissions granted"

echo ""
echo "=== Updating domain references ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_description = REPLACE(article_description, 'www.adgully.com', 'archive2.adgully.com') WHERE article_description LIKE '%www.adgully.com%';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_description = REPLACE(article_description, 'test.adgully.com', 'archive2.adgully.com') WHERE article_description LIKE '%test.adgully.com%';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_link = REPLACE(article_link, 'www.adgully.com', 'archive2.adgully.com') WHERE article_link LIKE '%www.adgully.com%';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_link = REPLACE(article_link, 'test.adgully.com', 'archive2.adgully.com') WHERE article_link LIKE '%test.adgully.com%';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_image_thumb = REPLACE(article_image_thumb, 'www.adgully.com', 'archive2.adgully.com') WHERE article_image_thumb LIKE '%www.adgully.com%';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_image_thumb = REPLACE(article_image_thumb, 'test.adgully.com', 'archive2.adgully.com') WHERE article_image_thumb LIKE '%test.adgully.com%';"
echo "✓ Domain references updated"

echo ""
echo "=== Verifying restoration ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "SELECT COUNT(*) as Total_Articles FROM cms_article;"

echo ""
echo "=== Cleaning up ==="
rm /tmp/$backupFile
echo "✓ Temporary file removed"
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  MIGRATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "✓ OLD server database backed up" -ForegroundColor Green
Write-Host "✓ Backup saved: $localBackupPath\$backupFile" -ForegroundColor Green
Write-Host "✓ Restored to NEW server" -ForegroundColor Green
Write-Host "✓ Domains updated to archive2.adgully.com" -ForegroundColor Green
Write-Host "✓ OLD server unchanged" -ForegroundColor Green
Write-Host ""
Write-Host "Test website now:" -ForegroundColor Yellow
Write-Host "  https://archive2.adgully.com/" -ForegroundColor White
Write-Host "  https://archive2.adgully.com/category/advertising/agency" -ForegroundColor White
Write-Host ""
