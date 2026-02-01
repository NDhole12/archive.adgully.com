@echo off
REM ========================================
REM Database Setup - satish_posts Table
REM ========================================
REM Production Server: 31.97.233.171
REM Database: archive_adgully
REM ========================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo Database Setup - satish_posts Table
echo ========================================
echo.
echo Server: 31.97.233.171
echo Database: archive_adgully
echo Date: %date% %time%
echo.
pause

echo.
echo [STEP 1] Listing all tables in archive_adgully...
echo.
"d:\archive.adgully.com\tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 ^
  "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e 'SHOW TABLES FROM archive_adgully;'"
echo.
pause

echo.
echo [STEP 2] Checking if satish_posts table exists...
echo.
"d:\archive.adgully.com\tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 ^
  "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='archive_adgully' AND TABLE_NAME='satish_posts';\""
echo.
pause

echo.
echo [STEP 3] Creating satish_posts table (IF NOT EXISTS)...
echo.
"d:\archive.adgully.com\tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 ^
  "mysql -u root -pAdmin@2026MsIhJgArhSg8x archive_adgully << EOFCREATE"
echo CREATE TABLE IF NOT EXISTS `satish_posts` ^(
echo   `ID` int^(11^) NOT NULL AUTO_INCREMENT,
echo   `post_title` varchar^(500^) DEFAULT NULL,
echo   `post_content` longtext,
echo   `tags` varchar^(500^) DEFAULT NULL,
echo   `terms` varchar^(500^) DEFAULT NULL,
echo   `keywords` varchar^(500^) DEFAULT NULL,
echo   `image` varchar^(500^) DEFAULT NULL,
echo   PRIMARY KEY ^(`ID`^)
echo ^) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
echo EOFCREATE
echo.
pause

echo.
echo [STEP 4] Verifying table structure...
echo.
"d:\archive.adgully.com\tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 ^
  "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"DESCRIBE archive_adgully.satish_posts;\""
echo.
pause

echo.
echo [STEP 5] Final table count in archive_adgully...
echo.
"d:\archive.adgully.com\tools\plink.exe" -pw z(P5ts@wdsESLUjMPVXs root@31.97.233.171 ^
  "mysql -u root -pAdmin@2026MsIhJgArhSg8x -e \"SELECT COUNT(*) as total_tables FROM information_schema.TABLES WHERE TABLE_SCHEMA='archive_adgully';\""
echo.
pause

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
pause
