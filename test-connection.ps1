#!/usr/bin/env pwsh

$plink = "d:\archive.adgully.com\tools\plink.exe"
$password = "z(P5ts@wdsESLUjMPVXs"
$server = "31.97.233.171"

# Test 1: Show tables
Write-Host "=== Test 1: Listing all tables in archive_adgully ===" -ForegroundColor Cyan
$result1 = & $plink -pw $password root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e 'SHOW TABLES FROM archive_adgully;' 2>&1"
Write-Host $result1

# Test 2: Check if satish_posts exists
Write-Host "`n=== Test 2: Checking for satish_posts table ===" -ForegroundColor Cyan
$result2 = & $plink -pw $password root@$server "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) as exists_satish_posts FROM information_schema.tables WHERE table_schema='archive_adgully' AND table_name='satish_posts';\" 2>&1"
Write-Host $result2
