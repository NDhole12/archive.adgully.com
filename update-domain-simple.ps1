# Simple Domain Update Script
# Uploads a bash script to the server and executes it

$server = "31.97.233.171"
$pass = "z(P5ts@wdsESLUjMPVXs"

# Create bash script locally
@"
#!/bin/bash
cp /var/www/archive2.adgully.com/config.php /var/www/archive2.adgully.com/config.php.backup-domain
sed -i 's/www\.adgully\.com/archive2.adgully.com/g' /var/www/archive2.adgully.com/config.php
sed -i 's/test\.adgully\.com/archive2.adgully.com/g' /var/www/archive2.adgully.com/config.php
echo "Domain update complete"
"@ | Out-File -FilePath "$env:TEMP\update-domain.sh" -Encoding ASCII -NoNewline

# Upload script to server
& "$env:TEMP\pscp.exe" -batch -pw $pass "$env:TEMP\update-domain.sh" "root@${server}:/tmp/update-domain.sh"

# Execute script on server
& "$env:TEMP\plink.exe" -batch -pw $pass "root@$server" "chmod +x /tmp/update-domain.sh && /tmp/update-domain.sh"

Write-Host "Domain configuration updated successfully!" -ForegroundColor Green
