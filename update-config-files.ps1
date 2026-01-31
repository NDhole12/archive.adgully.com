# Update Configuration Files Script
# Updates all config files with new database credentials

$server = "31.97.233.171"
$pass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CONFIG FILES UPDATE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create update script for server
$updateScript = @'
#!/bin/bash
set -e

echo "=== Updating Configuration Files ==="
echo ""

# Main config.php
echo "1. Updating /var/www/archive2.adgully.com/config.php"
sed -i "s/\$config_db_user = \"adgully\";/\$config_db_user = \"archive_user\";/g" /var/www/archive2.adgully.com/config.php
sed -i "s/\$config_db_pass = \"adgully\";/\$config_db_pass = \"ArchiveUser@2026Secure\";/g" /var/www/archive2.adgully.com/config.php
sed -i "s/\$config_db_db = \"adgully\";/\$config_db_db = \"archive_adgully\";/g" /var/www/archive2.adgully.com/config.php
sed -i "s/\$config_db_host = \"172.31.35.34\";/\$config_db_host = \"localhost\";/g" /var/www/archive2.adgully.com/config.php
sed -i "s/\$config_db_user = \"adgully_test\";/\$config_db_user = \"archive_user\";/g" /var/www/archive2.adgully.com/config.php
sed -i "s/\$config_db_pass = \"adgully_test\";/\$config_db_pass = \"ArchiveUser@2026Secure\";/g" /var/www/archive2.adgully.com/config.php
sed -i "s/\$config_db_db = \"adgully_test\";/\$config_db_db = \"archive_adgully\";/g" /var/www/archive2.adgully.com/config.php

# Client registration config
if [ -f /var/www/archive2.adgully.com/client_registration/config.php ]; then
    echo "2. Updating client_registration/config.php"
    sed -i "s/\$db_user = \"adgully\";/\$db_user = \"archive_user\";/g" /var/www/archive2.adgully.com/client_registration/config.php
    sed -i "s/\$db_pass = \"adgully\";/\$db_pass = \"ArchiveUser@2026Secure\";/g" /var/www/archive2.adgully.com/client_registration/config.php
    sed -i "s/\$db_name = \"adgully\";/\$db_name = \"archive_adgully\";/g" /var/www/archive2.adgully.com/client_registration/config.php
    sed -i "s/\$db_host = \"172.31.35.34\";/\$db_host = \"localhost\";/g" /var/www/archive2.adgully.com/client_registration/config.php
fi

# Manager config
if [ -f /var/www/archive2.adgully.com/manager/config.php ]; then
    echo "3. Updating manager/config.php"
    sed -i "s/\$db_user = \"adgully\";/\$db_user = \"archive_user\";/g" /var/www/archive2.adgully.com/manager/config.php
    sed -i "s/\$db_pass = \"adgully\";/\$db_pass = \"ArchiveUser@2026Secure\";/g" /var/www/archive2.adgully.com/manager/config.php
    sed -i "s/\$db_name = \"adgully\";/\$db_name = \"archive_adgully\";/g" /var/www/archive2.adgully.com/manager/config.php
    sed -i "s/\$db_host = \"172.31.35.34\";/\$db_host = \"localhost\";/g" /var/www/archive2.adgully.com/manager/config.php
fi

# CMO 2023 config
if [ -f /var/www/archive2.adgully.com/cmo2023/php/config.php ]; then
    echo "4. Updating cmo2023/php/config.php"
    sed -i "s/\$db_user = \"adgully\";/\$db_user = \"archive_user\";/g" /var/www/archive2.adgully.com/cmo2023/php/config.php
    sed -i "s/\$db_pass = \"adgully\";/\$db_pass = \"ArchiveUser@2026Secure\";/g" /var/www/archive2.adgully.com/cmo2023/php/config.php
    sed -i "s/\$db_name = \"adgully\";/\$db_name = \"archive_adgully\";/g" /var/www/archive2.adgully.com/cmo2023/php/config.php
    sed -i "s/\$db_host = \"172.31.35.34\";/\$db_host = \"localhost\";/g" /var/www/archive2.adgully.com/cmo2023/php/config.php
fi

echo ""
echo "=== Setting File Permissions ==="
echo ""

# Set ownership
echo "Setting ownership to www-data:www-data..."
chown -R www-data:www-data /var/www/archive2.adgully.com/

# Set directory permissions
echo "Setting directory permissions (755)..."
find /var/www/archive2.adgully.com/ -type d -exec chmod 755 {} \;

# Set file permissions
echo "Setting file permissions (644)..."
find /var/www/archive2.adgully.com/ -type f -exec chmod 644 {} \;

# Make uploads directories writable
echo "Setting upload directories (775)..."
for dir in images uploads tmp temp cache; do
    if [ -d "/var/www/archive2.adgully.com/$dir" ]; then
        chmod 775 "/var/www/archive2.adgully.com/$dir"
    fi
done

echo ""
echo "=== Configuration Update Complete ==="
echo ""

# Verify database connection
echo "Testing database connection..."
php -r "
\$conn = new mysqli('localhost', 'archive_user', 'ArchiveUser@2026Secure', 'archive_adgully');
if (\$conn->connect_error) {
    echo 'FAILED: ' . \$conn->connect_error . PHP_EOL;
    exit(1);
} else {
    echo 'SUCCESS: Connected to database' . PHP_EOL;
    echo 'Database: archive_adgully' . PHP_EOL;
    echo 'Tables: ' . \$conn->query('SHOW TABLES')->num_rows . PHP_EOL;
    \$conn->close();
}
"

echo ""
'@

# Save script to temp file
$updateScript | Out-File -FilePath "$env:TEMP\update-config.sh" -Encoding ASCII -NoNewline

Write-Host "Uploading update script..." -ForegroundColor Yellow
& "$env:TEMP\pscp.exe" -batch -pw $pass "$env:TEMP\update-config.sh" "root@$($server):/root/"

Write-Host "Making script executable and running..." -ForegroundColor Yellow
& "$env:TEMP\plink.exe" -batch -pw $pass "root@$server" "chmod +x /root/update-config.sh && /root/update-config.sh"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  UPDATE COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration files updated:" -ForegroundColor Cyan
Write-Host "  - config.php (main)" -ForegroundColor White
Write-Host "  - client_registration/config.php" -ForegroundColor White
Write-Host "  - manager/config.php" -ForegroundColor White
Write-Host "  - cmo2023/php/config.php" -ForegroundColor White
Write-Host ""
Write-Host "New credentials:" -ForegroundColor Cyan
Write-Host "  User: archive_user" -ForegroundColor White
Write-Host "  Pass: ArchiveUser@2026Secure" -ForegroundColor White
Write-Host "  DB: archive_adgully" -ForegroundColor White
Write-Host "  Host: localhost" -ForegroundColor White
Write-Host ""
Write-Host "Permissions set:" -ForegroundColor Cyan
Write-Host "  Owner: www-data:www-data" -ForegroundColor White
Write-Host "  Directories: 755" -ForegroundColor White
Write-Host "  Files: 644" -ForegroundColor White
Write-Host "  Uploads: 775" -ForegroundColor White
Write-Host ""
