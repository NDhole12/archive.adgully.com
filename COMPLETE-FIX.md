## 🔴 HTTP 500 ERROR - COMPLETE FIX

### Quick Fix (30 seconds):

**Open PowerShell and run:**

```powershell
ssh -o PubkeyAuthentication=no root@31.97.233.171
```

**Password:** `z(P5ts@wdsESLUjMPVXs`

**Then copy/paste this ONE command:**

```bash
apt update && apt install -y software-properties-common && add-apt-repository -y ppa:ondrej/php && apt update && DEBIAN_FRONTEND=noninteractive apt install -y php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip && mkdir -p /var/www/archive2.adgully.com && echo '<?php phpinfo(); ?>' > /var/www/archive2.adgully.com/index.php && chown -R www-data:www-data /var/www/archive2.adgully.com && systemctl enable php8.2-fpm && systemctl start php8.2-fpm && systemctl restart nginx && sleep 3 && curl -I http://localhost && echo "DONE - Check https://archive2.adgully.com/"
```

**This single command will:**
1. ✅ Install PHP 8.2-FPM (if missing)
2. ✅ Install PHP extensions
3. ✅ Create test page
4. ✅ Fix permissions
5. ✅ Start all services
6. ✅ Test site

**Takes 2-3 minutes to complete.**

---

## What's Happening:

The server `31.97.233.171` either:
- Never had PHP installed, OR
- PHP-FPM service stopped

This is preventing the site from working.

---

## After Running the Command:

Visit: **https://archive2.adgully.com/**

You should see a PHP info page instead of the 500 error.

---

## Still Having Issues?

If you see errors, share them and I'll provide next steps!
