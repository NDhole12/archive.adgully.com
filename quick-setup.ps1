# Simple inline PowerShell script with file output

$plinkPath = "d:\archive.adgully.com\tools\plink.exe"
$sshPassword = "z(P5ts@wdsESLUjMPVXs"
$server = "31.97.233.171"
$outputFile = "D:\archive.adgully.com\setup_log.txt"

# Clear previous log
"Database Setup Log - $(Get-Date)" | Set-Content $outputFile

# Step 1: List tables
"Step 1: Listing tables..." | Add-Content $outputFile
& $plinkPath -pw $sshPassword root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e 'SHOW TABLES FROM archive_adgully;' 2>&1" | Add-Content $outputFile

# Step 2: Create table
"Step 2: Creating satish_posts table..." | Add-Content $outputFile
& $plinkPath -pw $sshPassword root@$server @"
mysql -u root -pAdmin@2026MsIhJgArhSg8x archive_adgully << 'EOF'
CREATE TABLE IF NOT EXISTS satish_posts (
  ID int(11) NOT NULL AUTO_INCREMENT,
  post_title varchar(500) DEFAULT NULL,
  post_content longtext,
  tags varchar(500) DEFAULT NULL,
  terms varchar(500) DEFAULT NULL,
  keywords varchar(500) DEFAULT NULL,
  image varchar(500) DEFAULT NULL,
  PRIMARY KEY (ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
EOF
"@ | Add-Content $outputFile

# Step 3: Verify
"Step 3: Verifying table structure..." | Add-Content $outputFile
& $plinkPath -pw $sshPassword root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"DESCRIBE archive_adgully.satish_posts;\" 2>&1" | Add-Content $outputFile

"Completed!" | Add-Content $outputFile

# Print the log
Write-Host "=== Database Setup Results ===" 
Get-Content $outputFile
