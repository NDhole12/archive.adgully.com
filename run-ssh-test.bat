@echo off
REM SSH Test Script
setlocal enabledelayedexpansion

set "plink=d:\archive.adgully.com\tools\plink.exe"
set "password=z(P5ts@wdsESLUjMPVXs"
set "server=31.97.233.171"

REM Test connection and list tables
echo Testing SSH connection and database tables...
echo.
echo === Step 1: Show all tables in archive_adgully ===
"%plink%" -pw "%password%" root@%server% "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e 'SHOW TABLES FROM archive_adgully;'"

echo.
echo === Step 2: Check if satish_posts table exists ===
"%plink%" -pw "%password%" root@%server% "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT IF(COUNT(*)=1, 'satish_posts EXISTS', 'satish_posts DOES NOT EXIST') as status FROM information_schema.tables WHERE table_schema='archive_adgully' AND table_name='satish_posts';\""

echo.
echo === Step 3: Count total tables ===
"%plink%" -pw "%password%" root@%server%" "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema='archive_adgully';\""

pause
