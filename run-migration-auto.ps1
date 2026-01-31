# Accept host keys and run migration
$oldServer = "archive.adgully.com"
$oldPass = "MsIhJgArhSg8x"
$newServer = "31.97.233.171"
$newPass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "Accepting host key for OLD server..." -ForegroundColor Yellow

# Use plink with -hostkey parameter to auto-accept
$keyFingerprint = "84aiBjdODCw3Ppg0JpgCOgQCwLadws3H3bYVwi QvtZg"

# Connect once to cache the key (non-interactive)
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "$env:TEMP\plink.exe"
$psi.Arguments = "-pw `"$oldPass`" root@$oldServer exit"
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $psi
$process.Start() | Out-Null

Start-Sleep -Milliseconds 1000
$process.StandardInput.WriteLine("y")
$process.StandardInput.Close()
$process.WaitForExit(5000) | Out-Null

Write-Host "Host key cached. Starting migration..." -ForegroundColor Green
Write-Host ""

# Now run the actual commands
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1: CHECK OLD SERVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

& "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServer" "mysql -uroot -p'$oldPass' -e 'SHOW DATABASES LIKE `"%adgully%`";'"

Write-Host ""
Write-Host "Article count on OLD server:"
& "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServer" "mysql -uroot -p'$oldPass' adgully -e 'SELECT COUNT(*) as Total_Articles FROM cms_article;' 2>/dev/null || mysql -uroot -p'$oldPass' archive_adgully -e 'SELECT COUNT(*) as Total_Articles FROM cms_article;' 2>/dev/null"

Write-Host ""
Write-Host "Press ENTER to continue with backup..." -ForegroundColor Yellow
Read-Host

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 2: BACKUP OLD DATABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$backupFile = "adgully_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"

& "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServer" "mysqldump -uroot -p'$oldPass' adgully > /tmp/$backupFile 2>/dev/null || mysqldump -uroot -p'$oldPass' archive_adgully > /tmp/$backupFile 2>/dev/null && ls -lh /tmp/$backupFile"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 3: DOWNLOAD TO LOCAL PC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$localBackupPath = "D:\archive.adgully.com\backups"
if (-not (Test-Path $localBackupPath)) {
    New-Item -ItemType Directory -Path $localBackupPath | Out-Null
}

& "$env:TEMP\pscp.exe" -batch -pw $oldPass "root@${oldServer}:/tmp/$backupFile" "$localBackupPath\"

if (Test-Path "$localBackupPath\$backupFile") {
    $fileSize = (Get-Item "$localBackupPath\$backupFile").Length / 1MB
    Write-Host "Downloaded: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
    
    # Clean up OLD server
    & "$env:TEMP\plink.exe" -batch -pw $oldPass "root@$oldServer" "rm /tmp/$backupFile"
    Write-Host "Cleaned up OLD server /tmp" -ForegroundColor Green
} else {
    Write-Host "ERROR: Download failed!" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 4: UPLOAD TO NEW SERVER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

& "$env:TEMP\pscp.exe" -batch -pw $newPass "$localBackupPath\$backupFile" "root@${newServer}:/tmp/"

& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" "ls -lh /tmp/$backupFile"

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "STEP 5: RESTORE ON NEW SERVER" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "This will REPLACE the NEW server database!" -ForegroundColor Red
Write-Host "Press ENTER to continue..." -ForegroundColor Yellow
Read-Host

& "$env:TEMP\plink.exe" -batch -pw $newPass "root@$newServer" @"
echo "Creating safety backup..."
mysqldump -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully > /tmp/archive_adgully_backup_before_restore.sql
echo "Dropping database..."
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "DROP DATABASE IF EXISTS archive_adgully;"
echo "Creating database..."
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "CREATE DATABASE archive_adgully CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo "Restoring..."
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully < /tmp/$backupFile
echo "Granting permissions..."
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "GRANT SELECT, INSERT, UPDATE ON archive_adgully.* TO 'archive_user'@'localhost';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "FLUSH PRIVILEGES;"
echo "Updating domains..."
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_description = REPLACE(article_description, 'www.adgully.com', 'archive2.adgully.com') WHERE article_description LIKE '%www.adgully.com%';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_description = REPLACE(article_description, 'test.adgully.com', 'archive2.adgully.com') WHERE article_description LIKE '%test.adgully.com%';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_link = REPLACE(article_link, 'www.adgully.com', 'archive2.adgully.com') WHERE article_link LIKE '%www.adgully.com%';"
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_link = REPLACE(article_link, 'test.adgully.com', 'archive2.adgully.com') WHERE article_link LIKE '%test.adgully.com%';"
echo "Cleaning up..."
rm /tmp/$backupFile
echo "COMPLETE!"
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "MIGRATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backup saved: $localBackupPath\$backupFile" -ForegroundColor Cyan
Write-Host "Test: https://archive2.adgully.com/" -ForegroundColor Yellow
