@echo off
echo Checking image URLs in database...
.\tools\plink.exe -batch -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 "mysql -u archive_user -p'ArchiveUser@2026Secure' archive_adgully -e \"SELECT post_content FROM satish_posts WHERE ID=113687 LIMIT 1\" > /tmp/post_content.txt && cat /tmp/post_content.txt | grep -o 'http[^\"]*\.jpg' | head -5"
pause
