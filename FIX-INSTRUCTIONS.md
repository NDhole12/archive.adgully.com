# SITE FIX - STEP BY STEP GUIDE
# Site: archive2.adgully.com is returning 500 error

## METHOD 1: Quick Command (Copy & Paste)
Open a NEW PowerShell window and run this single command:

```powershell
ssh -o PubkeyAuthentication=no root@31.97.233.171 "systemctl restart php8.2-fpm nginx mariadb && sleep 3 && systemctl is-active php8.2-fpm nginx mariadb && chown -R www-data:www-data /var/www/archive2.adgully.com && curl -I http://localhost | head -5 && tail -20 /var/log/nginx/error.log"
```

When prompted for password, paste this: `z(P5ts@wdsESLUjMPVXs`

---

## METHOD 2: Interactive SSH Session
1. Open PowerShell or CMD
2. Run: `ssh root@31.97.233.171`
3. Password: `z(P5ts@wdsESLUjMPVXs`
4. Once logged in, run these commands:

```bash
# Restart all services
systemctl restart php8.2-fpm nginx mariadb

# Wait for services to start
sleep 3

# Check service status
systemctl is-active php8.2-fpm nginx mariadb

# Fix file permissions
chown -R www-data:www-data /var/www/archive2.adgully.com

# Test local site
curl -I http://localhost

# Check error logs
tail -30 /var/log/nginx/error.log
tail -30 /var/log/php8.2-fpm.log
```

---

## METHOD 3: Use PuTTY
1. Download PuTTY from: https://www.putty.org/
2. Open PuTTY
3. Host Name: `31.97.233.171`
4. Port: `22`
5. Click "Open"
6. Login as: `root`
7. Password: `z(P5ts@wdsESLUjMPVXs`
8. Run the commands from METHOD 2

---

## What the Fix Does:
1. ✅ Restarts PHP-FPM (fixes PHP processing)
2. ✅ Restarts Nginx (fixes web server)
3. ✅ Restarts MariaDB (fixes database)
4. ✅ Fixes file permissions
5. ✅ Tests site locally
6. ✅ Shows error logs

---

## After Running the Fix:
The site should be accessible at: https://archive2.adgully.com/

If still having issues, share the output from the error logs and I'll provide next steps.
