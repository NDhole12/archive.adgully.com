#!/usr/bin/env pwsh

<#
.SYNOPSIS
Remote Database Setup - satish_posts Table
Executes all required database operations via SSH

.NOTES
Uses plink.exe for Windows SSH connectivity
#>

param(
    [string]$OutputFile = "C:\temp\database_setup_results.txt"
)

# Ensure temp directory exists
$null = New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($OutputFile)) -Force -ErrorAction SilentlyContinue

# Configuration
$plinkPath = "d:\archive.adgully.com\tools\plink.exe"
$sshPassword = "z(P5ts@wdsESLUjMPVXs"
$server = "31.97.233.171"
$dbUser = "root"
$dbPassword = "Admin@2026MsIhJgArhSg8x"
$database = "archive_adgully"

# Verify plink exists
if (-not (Test-Path $plinkPath)) {
    Write-Error "plink.exe not found at $plinkPath"
    exit 1
}

# Log function
function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Message" | Tee-Object -FilePath $OutputFile -Append
}

Log "=========================================="
Log "Database Setup - satish_posts Table"
Log "=========================================="
Log ""

Log "[1] Connecting to $server and listing tables..."
Log "Database: $database"
Log ""

# Step 1: List all tables
Log "=== Current Tables ==="
$result1 = & $plinkPath -pw $sshPassword root@$server "mysql -u $dbUser -p$dbPassword -e 'SHOW TABLES FROM $database;'" 2>&1
$result1 | Tee-Object -FilePath $OutputFile -Append
Log ""

# Step 2: Check if satish_posts exists
Log "=== Checking satish_posts Table ==="
$result2 = & $plinkPath -pw $sshPassword root@$server "mysql -u $dbUser -p$dbPassword -e \"SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$database' AND TABLE_NAME='satish_posts';\" 2>&1" 
$result2 | Tee-Object -FilePath $OutputFile -Append
Log ""

# Step 3: Create table if it doesn't exist
Log "=== Creating satish_posts Table ==="
$sqlCreate = @"
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
"@

$result3 = & $plinkPath -pw $sshPassword root@$server "mysql -u $dbUser -p$dbPassword $database << 'EOFCREATE'
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
EOFCREATE
" 2>&1
$result3 | Tee-Object -FilePath $OutputFile -Append
Log ""

# Step 4: Verify table structure
Log "=== Table Structure ===" 
$result4 = & $plinkPath -pw $sshPassword root@$server "mysql -u $dbUser -p$dbPassword -e \"DESCRIBE $database.satish_posts;\" 2>&1"
$result4 | Tee-Object -FilePath $OutputFile -Append
Log ""

# Step 5: Count tables
Log "=== Final Table Count ===" 
$result5 = & $plinkPath -pw $sshPassword root@$server "mysql -u $dbUser -p$dbPassword -e \"SELECT COUNT(*) as total_tables FROM information_schema.TABLES WHERE TABLE_SCHEMA='$database';\" 2>&1"
$result5 | Tee-Object -FilePath $OutputFile -Append
Log ""

Log "=========================================="
Log "✓ Database setup operations completed"
Log "=========================================="
Log ""
Log "Results saved to: $OutputFile"

# Display results
Write-Host "Script execution completed. Opening results file..."
if (Test-Path $OutputFile) {
    Write-Host ""
    Write-Host "=== RESULTS ===" -ForegroundColor Cyan
    Get-Content $OutputFile | Write-Host
} else {
    Write-Host "No output file created." -ForegroundColor Yellow
}
