# Database Comparison and Restore Script
# Compares OLD server database with NEW server and optionally restores

$newServer = "31.97.233.171"
$newPass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  DATABASE COMPARISON & RESTORE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Prompt for old server details
Write-Host "OLD SERVER DETAILS:" -ForegroundColor Yellow
$oldServer = Read-Host "Enter OLD server IP address"
$oldPass = Read-Host "Enter OLD server SSH password" -AsSecureString
$oldPassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($oldPass))
$oldDbPass = Read-Host "Enter OLD server MySQL root password" -AsSecureString
$oldDbPassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($oldDbPass))
$oldDbName = Read-Host "Enter OLD database name (e.g., adgully, archive_adgully)"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1: CHECK OLD SERVER DATABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$checkScript = @"
#!/bin/bash
echo "=== OLD Server Database Info ==="
mysql -uroot -p'$oldDbPassPlain' -e "SHOW DATABASES LIKE '%adgully%';"
echo ""
echo "=== Table count in $oldDbName ==="
mysql -uroot -p'$oldDbPassPlain' $oldDbName -e "SELECT COUNT(*) as 'Total Tables' FROM information_schema.tables WHERE table_schema='$oldDbName';"
echo ""
echo "=== Article count ==="
mysql -uroot -p'$oldDbPassPlain' $oldDbName -e "SELECT COUNT(*) as 'Total Articles' FROM cms_article;" 2>/dev/null || echo "cms_article table not found"
echo ""
echo "=== Sample article titles ==="
mysql -uroot -p'$oldDbPassPlain' $oldDbName -e "SELECT article_id, article_title FROM cms_article ORDER BY article_id DESC LIMIT 5;" 2>/dev/null || echo "No articles found"
"@

$checkScript | Out-File -FilePath "$env:TEMP\check-old-db.sh" -Encoding ASCII -NoNewline
& "$env:TEMP\pscp.exe" -batch -pw $oldPassPlain "$env:TEMP\check-old-db.sh" "${oldServer}:/tmp/" 2>&1 | Out-Null
& "$env:TEMP\plink.exe" -batch -pw $oldPassPlain "root@$oldServer" "chmod +x /tmp/check-old-db.sh && /tmp/check-old-db.sh"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 2: CHECK NEW SERVER DATABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" @"
echo "=== NEW Server Database Info ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "SHOW DATABASES LIKE '%adgully%';"
echo ""
echo "=== Table count in archive_adgully ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "SELECT COUNT(*) as 'Total Tables' FROM information_schema.tables WHERE table_schema='archive_adgully';"
echo ""
echo "=== Article count ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "SELECT COUNT(*) as 'Total Articles' FROM cms_article;"
echo ""
echo "=== Sample article titles ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "SELECT article_id, article_title FROM cms_article ORDER BY article_id DESC LIMIT 5;"
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "COMPARISON COMPLETE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Do you want to:" -ForegroundColor Cyan
Write-Host "1. Backup OLD database and restore to NEW server (REPLACES current data)" -ForegroundColor White
Write-Host "2. Exit without changes" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Enter choice (1 or 2)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "WARNING: THIS WILL REPLACE ALL DATA" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "Type 'YES' to confirm database restore"
    
    if ($confirm -eq "YES") {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "STEP 3: BACKUP OLD DATABASE" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        
        $backupFile = "adgully_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
        
        Write-Host "Creating backup on OLD server..." -ForegroundColor Yellow
        & "$env:TEMP\plink.exe" -batch -pw $oldPassPlain "root@$oldServer" "mysqldump -uroot -p'$oldDbPassPlain' $oldDbName > /tmp/$backupFile && echo 'Backup created: /tmp/$backupFile' && ls -lh /tmp/$backupFile"
        
        Write-Host ""
        Write-Host "Downloading backup from OLD server..." -ForegroundColor Yellow
        & "$env:TEMP\pscp.exe" -batch -pw $oldPassPlain "root@${oldServer}:/tmp/$backupFile" "$env:TEMP\"
        
        if (Test-Path "$env:TEMP\$backupFile") {
            $fileSize = (Get-Item "$env:TEMP\$backupFile").Length / 1MB
            Write-Host "Downloaded: $backupFile ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
            
            Write-Host ""
            Write-Host "Uploading to NEW server..." -ForegroundColor Yellow
            & "$env:TEMP\pscp.exe" -batch -pw $newPass "$env:TEMP\$backupFile" "root@${newServer}:/tmp/"
            
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "STEP 4: RESTORE TO NEW SERVER" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            
            & "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" @"
echo "=== Backing up current NEW database ==="
mysqldump -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully > /tmp/archive_adgully_backup_before_restore.sql
echo "Current database backed up"

echo "=== Dropping current database ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "DROP DATABASE IF EXISTS archive_adgully;"

echo "=== Creating fresh database ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "CREATE DATABASE archive_adgully CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "=== Restoring from OLD server backup ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully < /tmp/$backupFile

echo "=== Verifying restore ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "SELECT COUNT(*) as 'Total Articles' FROM cms_article;"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "SELECT article_id, article_title FROM cms_article ORDER BY article_id DESC LIMIT 5;"

echo "=== Updating domain references in restored data ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully <<SQL
UPDATE cms_article SET article_description = REPLACE(article_description, 'www.adgully.com', 'archive2.adgully.com');
UPDATE cms_article SET article_description = REPLACE(article_description, 'test.adgully.com', 'archive2.adgully.com');
UPDATE cms_article SET article_link = REPLACE(article_link, 'www.adgully.com', 'archive2.adgully.com');
UPDATE cms_article SET article_link = REPLACE(article_link, 'test.adgully.com', 'archive2.adgully.com');
UPDATE cms_article SET article_image_thumb = REPLACE(article_image_thumb, 'www.adgully.com', 'archive2.adgully.com');
UPDATE cms_article SET article_image_thumb = REPLACE(article_image_thumb, 'test.adgully.com', 'archive2.adgully.com');
SQL

echo ""
echo "=== RESTORE COMPLETE ==="
"@
            
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "DATABASE RESTORED SUCCESSFULLY!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Backup saved at: $env:TEMP\$backupFile" -ForegroundColor Cyan
            Write-Host "Old database on NEW server backed up at: /tmp/archive_adgully_backup_before_restore.sql" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Test the site now: https://archive2.adgully.com/" -ForegroundColor Yellow
        } else {
            Write-Host "ERROR: Backup download failed!" -ForegroundColor Red
        }
    } else {
        Write-Host "Restore cancelled." -ForegroundColor Yellow
    }
} else {
    Write-Host "No changes made." -ForegroundColor Yellow
}

Write-Host ""
