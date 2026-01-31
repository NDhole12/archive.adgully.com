@echo off
echo Checking website files location...
echo.
echo z(P5ts@wdsESLUjMPVXs | ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no root@31.97.233.171 "echo '=== Checking Nginx config ===' && grep -E 'root|server_name' /etc/nginx/sites-enabled/* 2>/dev/null && echo '' && echo '=== Checking web directories ===' && ls -la /var/www/ 2>/dev/null && echo '' && echo '=== Checking for index files ===' && find /var/www -name 'index.php' -o -name 'index.html' 2>/dev/null && echo '' && echo '=== PHP-FPM Status ===' && systemctl is-active php8.2-fpm && echo '' && echo '=== Testing PHP ===' && php -r 'echo phpinfo();' | head -5"
