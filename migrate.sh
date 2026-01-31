#!/bin/bash
set -e
echo '========================================'
echo '  MIGRATION: OLD to NEW SERVER'
echo '========================================'
echo 'Installing sshpass...'
apt-get update -qq && apt-get install -y sshpass >/dev/null 2>&1
echo 'Step 1: Checking OLD server...'
sshpass -p'MsIhJgArhSg8x' ssh -o StrictHostKeyChecking=no root@13.234.95.152 'mysql -uroot -pMsIhJgArhSg8x -e "SHOW DATABASES LIKE \"%adgully%\";"'
echo 'Step 2: Backing up OLD database...'
sshpass -p'MsIhJgArhSg8x' ssh -o StrictHostKeyChecking=no root@13.234.95.152 'mysqldump -uroot -pMsIhJgArhSg8x adgully > /tmp/old_backup.sql && ls -lh /tmp/old_backup.sql'
echo 'Step 3: Downloading to NEW server...'
sshpass -p'MsIhJgArhSg8x' scp -o StrictHostKeyChecking=no root@13.234.95.152:/tmp/old_backup.sql /tmp/
echo 'Step 4: Cleaning OLD server...'
sshpass -p'MsIhJgArhSg8x' ssh -o StrictHostKeyChecking=no root@13.234.95.152 'rm /tmp/old_backup.sql'
echo 'Step 5: Backing up NEW database...'
mysqldump -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully > /tmp/new_backup_before.sql 2>/dev/null || echo 'No existing data'
echo 'Step 6: Restoring database...'
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e 'DROP DATABASE IF EXISTS archive_adgully; CREATE DATABASE archive_adgully CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully < /tmp/old_backup.sql
echo 'Step 7: Granting permissions...'
mysql -uroot -pAdmin@2026MsIhJgArhSg8x -e "GRANT SELECT, INSERT, UPDATE ON archive_adgully.* TO 'archive_user'@'localhost'; FLUSH PRIVILEGES;"
echo 'Step 8: Updating domains...'
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e "UPDATE cms_article SET article_description=REPLACE(article_description,'www.adgully.com','archive2.adgully.com'), article_description=REPLACE(article_description,'test.adgully.com','archive2.adgully.com'), article_link=REPLACE(article_link,'www.adgully.com','archive2.adgully.com'), article_link=REPLACE(article_link,'test.adgully.com','archive2.adgully.com'), article_image_thumb=REPLACE(article_image_thumb,'www.adgully.com','archive2.adgully.com'), article_image_thumb=REPLACE(article_image_thumb,'test.adgully.com','archive2.adgully.com');"
echo 'Step 9: Updating config.php...'
cd /var/www/archive2.adgully.com
sed -i 's|www.adgully.com|archive2.adgully.com|g; s|test.adgully.com|archive2.adgully.com|g; s|http://archive2|https://archive2|g' application/config/config.php
echo 'Step 10: Verifying...'
mysql -uroot -pAdmin@2026MsIhJgArhSg8x archive_adgully -e 'SELECT COUNT(*) as Articles FROM cms_article;'
echo '========================================'
echo '✓ MIGRATION COMPLETE!'
echo '========================================'
