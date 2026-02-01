@echo off
REM Automated Database Setup - No user input required

cd /d "d:\archive.adgully.com"

echo ========================================
echo Database Setup Automation
echo ========================================
echo.

REM Step 1: List tables
echo [1] Listing tables...
"tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e 'SHOW TABLES FROM archive_adgully;' 2>&1"
echo.

REM Step 2: Check table existence
echo [2] Checking satish_posts table...
"tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='archive_adgully' AND TABLE_NAME='satish_posts';\" 2>&1"
echo.

REM Step 3: Create table
echo [3] Creating satish_posts table...
"tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 "mysql -u root -pAdmin@2026MsIhJgArhSg8x archive_adgully -e \"CREATE TABLE IF NOT EXISTS satish_posts (ID int(11) NOT NULL AUTO_INCREMENT, post_title varchar(500) DEFAULT NULL, post_content longtext, tags varchar(500) DEFAULT NULL, terms varchar(500) DEFAULT NULL, keywords varchar(500) DEFAULT NULL, image varchar(500) DEFAULT NULL, PRIMARY KEY (ID)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;\" 2>&1"
echo.

REM Step 4: Verify structure
echo [4] Verifying table structure...
"tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"DESCRIBE archive_adgully.satish_posts;\" 2>&1"
echo.

REM Step 5: Final count
echo [5] Final table count...
"tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) as total_tables FROM information_schema.TABLES WHERE TABLE_SCHEMA='archive_adgully';\" 2>&1"
echo.

echo ========================================
echo Setup Complete
echo ========================================
