#!/usr/bin/env pwsh
$logFile = "C:\temp\database_output.txt"
$null = New-Item -ItemType Directory -Path "C:\temp" -Force -ErrorAction SilentlyContinue
Remove-Item $logFile -Force -ErrorAction SilentlyContinue

$plink = "d:\archive.adgully.com\tools\plink.exe"
$password = "z(P5ts@wdsESLUjMPVXs"
$server = "31.97.233.171"

# Execute and log step by step
"=== Step 1: Show all tables in archive_adgully ===" | Add-Content $logFile
& $plink -pw $password root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e 'SHOW TABLES FROM archive_adgully;' 2>&1" | Add-Content $logFile

"" | Add-Content $logFile
"=== Step 2: Check if satish_posts exists ===" | Add-Content $logFile
& $plink -pw $password root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='archive_adgully' AND TABLE_NAME='satish_posts';\" 2>&1" | Add-Content $logFile

"" | Add-Content $logFile
"=== Step 3: Create satish_posts table ===" | Add-Content $logFile
$createCmd = @"
mysql -u root -pAdmin@2026MsIhJgArhSg8x archive_adgully << 'EOFTABLE'
CREATE TABLE IF NOT EXISTS \`satish_posts\` (
  \`ID\` int(11) NOT NULL AUTO_INCREMENT,
  \`post_title\` varchar(500) DEFAULT NULL,
  \`post_content\` longtext,
  \`tags\` varchar(500) DEFAULT NULL,
  \`terms\` varchar(500) DEFAULT NULL,
  \`keywords\` varchar(500) DEFAULT NULL,
  \`image\` varchar(500) DEFAULT NULL,
  PRIMARY KEY (\`ID\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
EOFTABLE
"@
& $plink -pw $password root@$server $createCmd 2>&1 | Add-Content $logFile

"" | Add-Content $logFile
"=== Step 4: Describe satish_posts table ===" | Add-Content $logFile
& $plink -pw $password root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"DESCRIBE archive_adgully.satish_posts;\" 2>&1" | Add-Content $logFile

"" | Add-Content $logFile
"=== Step 5: Final table count ===" | Add-Content $logFile
& $plink -pw $password root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) as total_tables FROM information_schema.TABLES WHERE TABLE_SCHEMA='archive_adgully';\" 2>&1" | Add-Content $logFile

"Complete! Output saved to: $logFile" | Add-Content $logFile
