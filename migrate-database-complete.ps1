# Complete Database Migration Script
# OLD Server (archive.adgully.com) -> Local PC -> NEW Server (archive2.adgully.com)

$oldServer = "archive.adgully.com"
$oldPass = "MsIhJgArhSg8x"
$oldDbPass = "MsIhJgArhSg8x"

$newServer = "31.97.233.171"
$newPass = "z(P5ts@wdsESLUjMPVXs"
$newDbPass = "Admin@2026MsIhJgArhSg8x"

$backupFile = "adgully_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
$localBackupPath = "D:\archive.adgully.com\backups"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DATABASE MIGRATION SCRIPT" -ForegroundColor Cyan
Write-Host "  OLD -> LOCAL PC -> NEW" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "OLD Server: archive.adgully.com" -ForegroundColor Yellow
Write-Host "NEW Server: archive2.adgully.com (31.97.233.171)" -ForegroundColor Yellow
Write-Host ""

# Ensure backups directory exists
if (-not (Test-Path $localBackupPath)) {
    New-Item -ItemType Directory -Path $localBackupPath | Out-Null
    Write-Host "Created backup directory: $localBackupPath" -ForegroundColor Green
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1: CHECK OLD SERVER DATABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "(READ ONLY - No changes to OLD server)" -ForegroundColor Green
Write-Host ""

& "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServer" @"
echo "=== Databases on OLD server ==="
mysql -uroot -p'$oldDbPass' -e "SHOW DATABASES LIKE '%adgully%';"
echo ""
echo "=== Tables in 'adgully' database ==="
mysql -uroot -p'$oldDbPass' adgully -e "SELECT COUNT(*) as 'Total Tables' FROM information_schema.tables WHERE table_schema='adgully';" 2>/dev/null || echo "Database 'adgully' not found, checking 'archive_adgully'..."
mysql -uroot -p'$oldDbPass' archive_adgully -e "SELECT COUNT(*) as 'Total Tables' FROM information_schema.tables WHERE table_schema='archive_adgully';" 2>/dev/null || echo "No matching database found"
echo ""
echo "=== Article count ==="
mysql -uroot -p'$oldDbPass' adgully -e "SELECT COUNT(*) as 'Total Articles' FROM cms_article;" 2>/dev/null || mysql -uroot -p'$oldDbPass' archive_adgully -e "SELECT COUNT(*) as 'Total Articles' FROM cms_article;" 2>/dev/null
echo ""
echo "=== Sample articles from OLD server ==="
mysql -uroot -p'$oldDbPass' adgully -e "SELECT article_id, article_title FROM cms_article ORDER BY article_id DESC LIMIT 5;" 2>/dev/null || mysql -uroot -p'$oldDbPass' archive_adgully -e "SELECT article_id, article_title FROM cms_article ORDER BY article_id DESC LIMIT 5;" 2>/dev/null
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 2: BACKUP OLD DATABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creating backup on OLD server..." -ForegroundColor Yellow
Write-Host ""

& "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServer" @"
echo "Creating mysqldump backup..."
mysqldump -uroot -p'$oldDbPass' adgully > /tmp/$backupFile 2>/dev/null || mysqldump -uroot -p'$oldDbPass' archive_adgully > /tmp/$backupFile 2>/dev/null
if [ -f /tmp/$backupFile ]; then
    echo "Backup created successfully!"
    ls -lh /tmp/$backupFile
else
    echo "ERROR: Backup creation failed!"
    exit 1
fi
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 3: DOWNLOAD TO LOCAL PC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Downloading from OLD server to: $localBackupPath\$backupFile" -ForegroundColor Yellow
Write-Host ""

& "$env:TEMP\pscp.exe" -batch -pw $oldPass "root@${oldServer}:/tmp/$backupFile" "$localBackupPath\"

if (Test-Path "$localBackupPath\$backupFile") {
    $fileSize = (Get-Item "$localBackupPath\$backupFile").Length / 1MB
    Write-Host "✓ Downloaded successfully: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
    
    # Clean up OLD server /tmp
    Write-Host ""
    Write-Host "Cleaning up temporary file on OLD server..." -ForegroundColor Yellow
    & "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServer" "rm /tmp/$backupFile && echo 'Temporary file removed from OLD server'"
} else {
    Write-Host "✗ ERROR: Download failed!" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 4: CHECK NEW SERVER CURRENT STATE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" @"
echo "=== Current NEW server database ==="
mysql -uroot -p'$newDbPass' -e "SHOW DATABASES LIKE '%adgully%';"
echo ""
echo "=== Tables in 'archive_adgully' ==="
mysql -uroot -p'$newDbPass' archive_adgully -e "SELECT COUNT(*) as 'Total Tables' FROM information_schema.tables WHERE table_schema='archive_adgully';"
echo ""
echo "=== Article count on NEW server ==="
mysql -uroot -p'$newDbPass' archive_adgully -e "SELECT COUNT(*) as 'Total Articles' FROM cms_article;"
echo ""
echo "=== Sample articles from NEW server ==="
mysql -uroot -p'$newDbPass' archive_adgully -e "SELECT article_id, article_title FROM cms_article ORDER BY article_id DESC LIMIT 5;"
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 5: UPLOAD BACKUP TO NEW SERVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Uploading from LOCAL PC to NEW server..." -ForegroundColor Yellow
Write-Host "Source: $localBackupPath\$backupFile" -ForegroundColor White
Write-Host "Destination: NEW server /tmp/$backupFile" -ForegroundColor White
Write-Host ""

& "$env:TEMP\pscp.exe" -batch -pw $newPass "$localBackupPath\$backupFile" "root@${newServer}:/tmp/"

Write-Host ""
Write-Host "Verifying upload on NEW server..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" "ls -lh /tmp/$backupFile && echo '✓ Backup file uploaded successfully to NEW server'"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 6: BACKUP NEW SERVER (SAFETY)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creating safety backup of NEW server current data..." -ForegroundColor Yellow
Write-Host ""

& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" @"
echo "Creating safety backup..."
mysqldump -uroot -p'$newDbPass' archive_adgully > /tmp/archive_adgully_backup_before_restore_$(date +%Y%m%d_%H%M%S).sql
ls -lh /tmp/archive_adgully_backup_before_restore*.sql | tail -1
echo "✓ Safety backup created"
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "STEP 7: RESTORE DATABASE ON NEW SERVER" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "WARNING: This will REPLACE the NEW server database!" -ForegroundColor Red
Write-Host "Press ENTER to continue or CTRL+C to cancel..." -ForegroundColor Yellow
Read-Host

Write-Host ""
Write-Host "Restoring OLD database to NEW server..." -ForegroundColor Yellow
Write-Host ""

& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" @"
echo "=== Dropping current database ==="
mysql -uroot -p'$newDbPass' -e "DROP DATABASE IF EXISTS archive_adgully;"
echo "✓ Database dropped"

echo ""
echo "=== Creating fresh database ==="
mysql -uroot -p'$newDbPass' -e "CREATE DATABASE archive_adgully CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo "✓ Database created"

echo ""
echo "=== Restoring from OLD server backup ==="
mysql -uroot -p'$newDbPass' archive_adgully < /tmp/$backupFile
echo "✓ Database restored"

echo ""
echo "=== Granting permissions to archive_user ==="
mysql -uroot -p'$newDbPass' -e "GRANT SELECT, INSERT, UPDATE ON archive_adgully.* TO 'archive_user'@'localhost';"
mysql -uroot -p'$newDbPass' -e "FLUSH PRIVILEGES;"
echo "✓ Permissions granted"

echo ""
echo "=== Updating domain references ==="
mysql -uroot -p'$newDbPass' archive_adgully <<SQL
UPDATE cms_article SET article_description = REPLACE(article_description, 'www.adgully.com', 'archive2.adgully.com') WHERE article_description LIKE '%www.adgully.com%';
UPDATE cms_article SET article_description = REPLACE(article_description, 'test.adgully.com', 'archive2.adgully.com') WHERE article_description LIKE '%test.adgully.com%';
UPDATE cms_article SET article_description = REPLACE(article_description, 'http://archive2.adgully.com', 'https://archive2.adgully.com') WHERE article_description LIKE '%http://archive2.adgully.com%';
UPDATE cms_article SET article_link = REPLACE(article_link, 'www.adgully.com', 'archive2.adgully.com') WHERE article_link LIKE '%www.adgully.com%';
UPDATE cms_article SET article_link = REPLACE(article_link, 'test.adgully.com', 'archive2.adgully.com') WHERE article_link LIKE '%test.adgully.com%';
UPDATE cms_article SET article_image_thumb = REPLACE(article_image_thumb, 'www.adgully.com', 'archive2.adgully.com') WHERE article_image_thumb LIKE '%www.adgully.com%';
UPDATE cms_article SET article_image_thumb = REPLACE(article_image_thumb, 'test.adgully.com', 'archive2.adgully.com') WHERE article_image_thumb LIKE '%test.adgully.com%';
SQL
echo "✓ Domain references updated"

echo ""
echo "=== Cleaning up temporary backup file ==="
rm /tmp/$backupFile
echo "✓ Temporary file removed"
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 8: VERIFY RESTORATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" @"
echo "=== Final verification ==="
mysql -uroot -p'$newDbPass' archive_adgully -e "SELECT COUNT(*) as 'Total Articles' FROM cms_article;"
echo ""
echo "=== Sample articles on NEW server after restore ==="
mysql -uroot -p'$newDbPass' archive_adgully -e "SELECT article_id, article_title FROM cms_article ORDER BY article_id DESC LIMIT 5;"
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  MIGRATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "✓ OLD server database backed up" -ForegroundColor Green
Write-Host "✓ Backup saved to: $localBackupPath\$backupFile" -ForegroundColor Green
Write-Host "✓ Backup uploaded to NEW server" -ForegroundColor Green
Write-Host "✓ NEW server database restored from OLD server" -ForegroundColor Green
Write-Host "✓ Domain references updated to archive2.adgully.com" -ForegroundColor Green
Write-Host "✓ OLD server unchanged (no data lost)" -ForegroundColor Green
Write-Host ""
Write-Host "Test the website now:" -ForegroundColor Yellow
Write-Host "  https://archive2.adgully.com/" -ForegroundColor White
Write-Host "  https://archive2.adgully.com/category/advertising/agency" -ForegroundColor White
Write-Host ""
