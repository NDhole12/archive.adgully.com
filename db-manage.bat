@echo off
REM Database management script with output to file

setlocal enabledelayedexpansion

set "logFile=C:\temp\db_operations.log"
set "plink=d:\archive.adgully.com\tools\plink.exe"
set "password=z(P5ts@wdsESLUjMPVXs"
set "server=31.97.233.171"
set "dbuser=root"
set "dbpass=Admin@2026MsIhJgArhSg8x"
set "database=archive_adgully"

REM Create temp directory
if not exist "C:\temp" mkdir "C:\temp"

(
  echo ========================================
  echo Database Management - satish_posts Table
  echo ========================================
  echo.
  
  echo [Step 1] Listing all tables in %database%...
  "%plink%" -pw "%password%" root@%server% "mysql -u %dbuser% -p%dbpass% -e 'SHOW TABLES FROM %database%;'"
  echo.
  
  echo [Step 2] Checking if satish_posts table exists...
  "%plink%" -pw "%password%" root@%server% "mysql -u %dbuser% -p%dbpass% -e \"SELECT IF(COUNT(*)=1, 'satish_posts EXISTS', 'satish_posts DOES NOT EXIST') as status FROM information_schema.TABLES WHERE TABLE_SCHEMA='%database%' AND TABLE_NAME='satish_posts';\""
  echo.
  
  echo [Step 3] Checking table count...
  "%plink%" -pw "%password%" root@%server% "mysql -u %dbuser% -p%dbpass% -e \"SELECT COUNT(*) as total_tables FROM information_schema.TABLES WHERE TABLE_SCHEMA='%database%';\""
  echo.
  
  echo [Step 4] Creating satish_posts table if it doesn't exist...
  "%plink%" -pw "%password%" root@%server% "mysql -u %dbuser% -p%dbpass% %database% << EOFQL"
  echo CREATE TABLE IF NOT EXISTS `satish_posts` (
  echo   `ID` int(11) NOT NULL AUTO_INCREMENT,
  echo   `post_title` varchar(500) DEFAULT NULL,
  echo   `post_content` longtext,
  echo   `tags` varchar(500) DEFAULT NULL,
  echo   `terms` varchar(500) DEFAULT NULL,
  echo   `keywords` varchar(500) DEFAULT NULL,
  echo   `image` varchar(500) DEFAULT NULL,
  echo   PRIMARY KEY (`ID`)
  echo ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  echo EOFQL
  echo.
  
  echo [Step 5] Verifying table structure...
  "%plink%" -pw "%password%" root@%server% "mysql -u %dbuser% -p%dbpass% -e \"DESCRIBE %database%.satish_posts;\""
  echo.
  
  echo [Step 6] Final table count...
  "%plink%" -pw "%password%" root@%server% "mysql -u %dbuser% -p%dbpass% -e \"SELECT COUNT(*) as total_tables FROM information_schema.TABLES WHERE TABLE_SCHEMA='%database%';\""
  echo.
  echo ========================================
  echo Operations completed
  echo ========================================
) > "%logFile%" 2>&1

echo Execution completed. Output saved to: %logFile%
echo.
echo Reading log file contents:
type "%logFile%"
