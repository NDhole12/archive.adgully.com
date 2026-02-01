#!/usr/bin/env pwsh

<#
.DESCRIPTION
Complete database management script for satish_posts table
Performs: Check table, Create if needed, Verify creation
#>

$ErrorActionPreference = 'Stop'

# Configuration
$plink = "d:\archive.adgully.com\tools\plink.exe"
$password = "z(P5ts@wdsESLUjMPVXs"
$server = "31.97.233.171"
$dbUser = "root"
$dbPass = "Admin@2026MsIhJgArhSg8x"
$database = "archive_adgully"

# Helper function to execute MySQL queries via SSH
function Invoke-RemoteMySQL {
    param(
        [string]$Query,
        [string]$Database = ""
    )
    
    $fullCmd = if ($Database) {
        "mysql -u $dbUser -p$dbPass $Database -e `"$Query`" 2>&1"
    } else {
        "mysql -u $dbUser -p$dbPass -e `"$Query`" 2>&1"
    }
    
    $result = & $plink -pw $password root@$server $fullCmd
    return $result
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Database Management - satish_posts Table" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Step 1: List all existing tables
Write-Host "[Step 1] Checking existing tables in $database..." -ForegroundColor Cyan
$tables = Invoke-RemoteMySQL -Query "SHOW TABLES FROM $database;" -Database $database
Write-Host "Existing tables:"
Write-Host ($tables -join "`n")
Write-Host ""

# Step 2: Check if satish_posts exists
Write-Host "[Step 2] Checking if satish_posts table exists..." -ForegroundColor Cyan
$checkTable = Invoke-RemoteMySQL -Query "SELECT COUNT(*) as count FROM information_schema.TABLES WHERE TABLE_SCHEMA='$database' AND TABLE_NAME='satish_posts';" -Database $database
Write-Host "Check result: $checkTable"

$tableExists = $checkTable | Select-String -Pattern '\s1' | Measure-Object | Select-Object -ExpandProperty Count

if ($tableExists -gt 0) {
    Write-Host "✓ satish_posts table already EXISTS" -ForegroundColor Green
} else {
    Write-Host "✗ satish_posts table DOES NOT EXIST - Creating it now..." -ForegroundColor Yellow
    Write-Host ""
    
    # Step 3: Create the table
    Write-Host "[Step 3] Creating satish_posts table..." -ForegroundColor Cyan
    
    $createSQL = @"
CREATE TABLE `satish_posts` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `post_title` varchar(500) DEFAULT NULL,
  `post_content` longtext,
  `tags` varchar(500) DEFAULT NULL,
  `terms` varchar(500) DEFAULT NULL,
  `keywords` varchar(500) DEFAULT NULL,
  `image` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
"@
    
    $createResult = Invoke-RemoteMySQL -Query $createSQL -Database $database
    Write-Host "Create result: $createResult"
    Write-Host ""
}

# Step 4: Verify table structure
Write-Host "[Step 4] Verifying table structure..." -ForegroundColor Cyan
$describe = Invoke-RemoteMySQL -Query "DESCRIBE satish_posts;" -Database $database
Write-Host $describe
Write-Host ""

# Step 5: Final count of tables
Write-Host "[Step 5] Final table count in $database..." -ForegroundColor Cyan
$finalCount = Invoke-RemoteMySQL -Query "SELECT COUNT(*) as total_tables FROM information_schema.TABLES WHERE TABLE_SCHEMA='$database';" -Database $database
Write-Host "Total tables: $finalCount"
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Database operations completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
