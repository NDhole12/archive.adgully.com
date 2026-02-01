#!/usr/bin/env pwsh

$logFile = "C:\temp\ssh_test.log"
$null = mkdir "C:\temp" -Force -ErrorAction SilentlyContinue

# Clear log
"" | Set-Content $logFile

$plink = "d:\archive.adgully.com\tools\plink.exe"
$password = "z(P5ts@wdsESLUjMPVXs"
$server = "31.97.233.171"

# Test 1: Connection test
"[$(Get-Date)] Starting SSH connection test..." | Tee-Object -FilePath $logFile -Append

$output1 = & $plink -pw $password root@$server "echo 'SSH Connection OK' && mysql -u root -pAdmin@2026MsIhJgArhSg8x -e 'SHOW TABLES FROM archive_adgully;'" 2>&1
"[Step 1] Tables in archive_adgully:" | Tee-Object -FilePath $logFile -Append
$output1 | Tee-Object -FilePath $logFile -Append

# Test 2: Check if satish_posts exists
"" | Tee-Object -FilePath $logFile -Append
"[Step 2] Checking if satish_posts table exists..." | Tee-Object -FilePath $logFile -Append

$output2 = & $plink -pw $password root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema='archive_adgully' AND table_name='satish_posts';\"" 2>&1
$output2 | Tee-Object -FilePath $logFile -Append

# Final message
"[$(Get-Date)] Test completed. Results saved to: $logFile" | Tee-Object -FilePath $logFile -Append
