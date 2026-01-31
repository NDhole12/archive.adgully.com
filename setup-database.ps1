# Database Setup Script for archive2.adgully.com
# Imports SQL and creates database user with proper permissions

$serverIP = "31.97.233.171"
$serverPass = "z(P5ts@wdsESLUjMPVXs"
$plinkPath = "$env:TEMP\plink.exe"

# Database configuration
$dbName = "archive_adgully"
$dbUser = "archive_user"
$dbPass = "ArchiveUser@2026Secure"
$rootPass = "Admin@2026MsIhJgArhSg8x"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  DATABASE SETUP - archive2.adgully.com" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Creating database..." -ForegroundColor Yellow
$createDb = "mysql -uroot -p$rootPass -e 'CREATE DATABASE IF NOT EXISTS $dbName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"
& $plinkPath -batch -pw $serverPass "root@$serverIP" $createDb

Write-Host "Step 2: Importing SQL file..." -ForegroundColor Yellow
$importSql = "mysql -uroot -p$rootPass $dbName < /var/www/archive2.adgully.com/adgully.sql"
& $plinkPath -batch -pw $serverPass "root@$serverIP" $importSql

Write-Host "Step 3: Creating database user..." -ForegroundColor Yellow
$createUser = @"
mysql -uroot -p$rootPass -e \"
CREATE USER IF NOT EXISTS '$dbUser'@'localhost' IDENTIFIED BY '$dbPass';
GRANT SELECT, INSERT, UPDATE ON $dbName.* TO '$dbUser'@'localhost';
FLUSH PRIVILEGES;
SELECT User, Host FROM mysql.user WHERE User='$dbUser';
\"
"@
& $plinkPath -batch -pw $serverPass "root@$serverIP" $createUser

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  DATABASE SETUP COMPLETE!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Database Configuration:" -ForegroundColor Cyan
Write-Host "  Database Name: $dbName" -ForegroundColor White
Write-Host "  Database User: $dbUser" -ForegroundColor White
Write-Host "  Database Pass: $dbPass" -ForegroundColor White
Write-Host "  Permissions:   SELECT, INSERT, UPDATE only" -ForegroundColor White
Write-Host ""
Write-Host "Next: Update config.php with these credentials" -ForegroundColor Yellow
