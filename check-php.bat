@echo off
echo Checking PHP installation on server...
echo.
echo z(P5ts@wdsESLUjMPVXs | ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no root@31.97.233.171 "echo '=== PHP Version ===' && php -v 2>&1; echo '=== PHP Services ===' && systemctl list-units --type=service | grep php; echo '=== PHP Directories ===' && ls -la /etc/php/ 2>&1; echo '=== Nginx Status ===' && systemctl status nginx --no-pager | head -10"
