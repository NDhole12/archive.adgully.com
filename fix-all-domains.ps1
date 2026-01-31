# Complete Domain Fix Script
# Fixes config.php AND database domain references

$server = "31.97.233.171"
$pass = "z(P5ts@wdsESLUjMPVXs"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  COMPLETE DOMAIN FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create fix script
$fixScript = @"
#!/bin/bash
set -e

echo "=== STEP 1: Backup config.php ==="
cp /var/www/archive2.adgully.com/config.php /var/www/archive2.adgully.com/config.php.backup-domain-$(date +%Y%m%d)

echo "=== STEP 2: Update config.php domains ==="
sed -i 's/www\.adgully\.com/archive2.adgully.com/g' /var/www/archive2.adgully.com/config.php
sed -i 's/test\.adgully\.com/archive2.adgully.com/g' /var/www/archive2.adgully.com/config.php
sed -i 's|http://archive2\.adgully\.com|https://archive2.adgully.com|g' /var/www/archive2.adgully.com/config.php
echo "Config updated"

echo "=== STEP 3: Check database for domain references ==="
mysql -uarchive_user -pArchiveUser@2026Secure archive_adgully -e "SELECT COUNT(*) as 'www.adgully.com references' FROM cms_article WHERE article_description LIKE '%www.adgully.com%' OR article_link LIKE '%www.adgully.com%';"
mysql -uarchive_user -pArchiveUser@2026Secure archive_adgully -e "SELECT COUNT(*) as 'test.adgully.com references' FROM cms_article WHERE article_description LIKE '%test.adgully.com%' OR article_link LIKE '%test.adgully.com%';"

echo "=== STEP 4: Update database domains (if needed) ==="
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully <<SQL
UPDATE cms_article SET article_description = REPLACE(article_description, 'www.adgully.com', 'archive2.adgully.com') WHERE article_description LIKE '%www.adgully.com%';
UPDATE cms_article SET article_description = REPLACE(article_description, 'test.adgully.com', 'archive2.adgully.com') WHERE article_description LIKE '%test.adgully.com%';
UPDATE cms_article SET article_link = REPLACE(article_link, 'www.adgully.com', 'archive2.adgully.com') WHERE article_link LIKE '%www.adgully.com%';
UPDATE cms_article SET article_link = REPLACE(article_link, 'test.adgully.com', 'archive2.adgully.com') WHERE article_link LIKE '%test.adgully.com%';
UPDATE cms_article SET article_image_thumb = REPLACE(article_image_thumb, 'www.adgully.com', 'archive2.adgully.com') WHERE article_image_thumb LIKE '%www.adgully.com%';
UPDATE cms_article SET article_image_thumb = REPLACE(article_image_thumb, 'test.adgully.com', 'archive2.adgully.com') WHERE article_image_thumb LIKE '%test.adgully.com%';
SQL
echo "Database updated"

echo "=== STEP 5: Verify changes ==="
echo "Config.php image_host:"
grep 'image_host' /var/www/archive2.adgully.com/config.php | head -3

echo ""
echo "Database check:"
mysql -uarchive_user -pArchiveUser@2026Secure archive_adgully -e "SELECT COUNT(*) as 'Remaining www/test references' FROM cms_article WHERE article_description LIKE '%www.adgully.com%' OR article_description LIKE '%test.adgully.com%' OR article_link LIKE '%www.adgully.com%' OR article_link LIKE '%test.adgully.com%';"

echo ""
echo "=== ALL FIXES COMPLETE ==="
"@

$fixScript | Out-File -FilePath "$env:TEMP\fix-all-domains.sh" -Encoding ASCII -NoNewline

Write-Host "Uploading fix script..." -ForegroundColor Yellow
& "$env:TEMP\pscp.exe" -batch -pw $pass "$env:TEMP\fix-all-domains.sh" "root@${server}:/tmp/"

Write-Host "Executing fixes on server..." -ForegroundColor Yellow
Write-Host ""
& "$env:TEMP\plink.exe" -batch -pw $pass "root@$server" "chmod +x /tmp/fix-all-domains.sh && /tmp/fix-all-domains.sh"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  FIX COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Updated:" -ForegroundColor Cyan
Write-Host "  - config.php domain references" -ForegroundColor White
Write-Host "  - Database article content" -ForegroundColor White
Write-Host "  - All www/test domains -> archive2" -ForegroundColor White
Write-Host ""
Write-Host "Test the site now:" -ForegroundColor Yellow
Write-Host "  https://archive2.adgully.com/" -ForegroundColor White
Write-Host ""
