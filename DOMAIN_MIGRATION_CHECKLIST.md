# Domain Migration Quick Checklist
## Use this checklist for every domain migration

**Current Domain:** archive2.adgully.com  
**Target Domain:** archive.adgully.com  
**Server IP:** 31.97.233.171  
**Migration Date:** _____________

---

## ✅ PRE-MIGRATION CHECKLIST

### DNS Setup
- [ ] Add A record: [NEW_DOMAIN] → 31.97.233.171
- [ ] Add A record: www.[NEW_DOMAIN] → 31.97.233.171
- [ ] Wait for DNS propagation (test with `nslookup`)
- [ ] Verify DNS resolves correctly

### Server Preparation
- [ ] SSH into server: `.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171`
- [ ] Create directory: `mkdir -p /var/www/[NEW_DOMAIN]`
- [ ] Set ownership: `chown -R www-data:www-data /var/www/[NEW_DOMAIN]`
- [ ] Set permissions: `chmod -R 755 /var/www/[NEW_DOMAIN]`

### SSL Certificate
- [ ] Generate certificate: `certbot certonly --nginx -d [NEW_DOMAIN] -d www.[NEW_DOMAIN]`
- [ ] Verify certificate: `ls -la /etc/letsencrypt/live/[NEW_DOMAIN]/`
- [ ] Check expiration date

---

## 🔧 CONFIGURATION FILES CHECKLIST

### 1. Nginx Configuration
**File:** `d:\archive.adgully.com\configs\nginx\[NEW_DOMAIN].conf`

- [ ] Line 4: `server_name [NEW_DOMAIN] www.[NEW_DOMAIN];`
- [ ] Line 11: `server_name [NEW_DOMAIN] www.[NEW_DOMAIN];`
- [ ] Line 12: `root /var/www/[NEW_DOMAIN];`
- [ ] Line 16: `ssl_certificate /etc/letsencrypt/live/[NEW_DOMAIN]/fullchain.pem;`
- [ ] Line 17: `ssl_certificate_key /etc/letsencrypt/live/[NEW_DOMAIN]/privkey.pem;`
- [ ] Line 34: `access_log /var/log/nginx/[NEW_DOMAIN]_access.log;`
- [ ] Line 35: `error_log /var/log/nginx/[NEW_DOMAIN]_error.log;`
- [ ] Upload to server: `.\tools\pscp.exe -pw "..." configs/nginx/[NEW_DOMAIN].conf root@31.97.233.171:/etc/nginx/sites-available/`
- [ ] Create symlink: `ln -sf /etc/nginx/sites-available/[NEW_DOMAIN].conf /etc/nginx/sites-enabled/`
- [ ] Test config: `nginx -t`

### 2. PHP-FPM Pool Configuration
**File:** `d:\archive.adgully.com\configs\php\archive-pool.conf`

- [ ] Line 1: Update comment with new domain
- [ ] Line 46: `php_admin_value[open_basedir] = /var/www/[NEW_DOMAIN]:/tmp:/var/lib/php/sessions`
- [ ] Upload to server: `.\tools\pscp.exe -pw "..." configs/php/archive-pool.conf root@31.97.233.171:/etc/php/5.6/fpm/pool.d/`

### 3. Main Config File
**File:** `d:\achive.adgully.com\archive.adgully.com\httpdocs\config.php`

- [ ] Line 10: Change `if( $_SERVER['HTTP_HOST'] == "[NEW_DOMAIN]" || $_SERVER['HTTP_HOST'] == "www.[NEW_DOMAIN]" ){`
- [ ] Verify database credentials are correct (archive_user, ArchiveUser@2026Secure, archive_adgully)
- [ ] Upload to server: `.\tools\pscp.exe -pw "..." httpdocs/config.php root@31.97.233.171:/var/www/[NEW_DOMAIN]/`

### 4. Menu Files
**File:** `d:\achive.adgully.com\archive.adgully.com\httpdocs\menu-items.php`

- [ ] Find-replace: [OLD_DOMAIN] → [NEW_DOMAIN] (all href URLs)
- [ ] Verify all 15 category links updated
- [ ] Upload to server

**File:** `d:\achive.adgully.com\archive.adgully.com\httpdocs\mobile-menu-items.php`

- [ ] Find-replace: [OLD_DOMAIN] → [NEW_DOMAIN] (all href URLs)
- [ ] Verify all 15 category links updated
- [ ] Upload to server

### 5. Sub-Application Config Files
- [ ] `client_registration/config.php` - Update DB credentials
- [ ] `manager/config.php` - Update DB credentials
- [ ] `cmo2023/php/config.php` - Update DB credentials

### 6. Control Files (NO CHANGES NEEDED - Verify Only)
- [ ] Verify `control_rewrite.php` has line 112-113 fix: `$path_clean = ltrim($parts['path'], '/');`
- [ ] Verify `config_rewrites.php` has correct rule order (75 before 65)

---

## 📤 FILE UPLOAD CHECKLIST

### Upload All Application Files
- [ ] Upload entire httpdocs: `.\tools\pscp.exe -r -pw "..." httpdocs/* root@31.97.233.171:/var/www/[NEW_DOMAIN]/`

### OR Upload Individual Files
- [ ] config.php
- [ ] menu-items.php
- [ ] mobile-menu-items.php
- [ ] control_rewrite.php
- [ ] config_rewrites.php
- [ ] client_registration/config.php
- [ ] manager/config.php
- [ ] cmo2023/php/config.php

### Set Permissions
- [ ] `chown -R www-data:www-data /var/www/[NEW_DOMAIN]`
- [ ] `find /var/www/[NEW_DOMAIN] -type d -exec chmod 755 {} \;`
- [ ] `find /var/www/[NEW_DOMAIN] -type f -exec chmod 644 {} \;`
- [ ] `chmod -R 775 /var/www/[NEW_DOMAIN]/images`
- [ ] `chmod -R 775 /var/www/[NEW_DOMAIN]/uploads`

---

## 🔄 SERVICE RESTART CHECKLIST

- [ ] Restart PHP-FPM: `systemctl restart php5.6-fpm`
- [ ] Check PHP-FPM status: `systemctl status php5.6-fpm` (should be active)
- [ ] Restart Nginx: `systemctl restart nginx`
- [ ] Check Nginx status: `systemctl status nginx` (should be active)
- [ ] Check error logs: `tail -f /var/log/nginx/[NEW_DOMAIN]_error.log`

---

## 🧪 TESTING CHECKLIST

### URL Testing
- [ ] **Homepage:** https://[NEW_DOMAIN]/ (loads with news articles)
- [ ] **WWW Homepage:** https://www.[NEW_DOMAIN]/ (loads with news articles)
- [ ] **News Article:** https://[NEW_DOMAIN]/havas-media-group-158207.html (loads article)
- [ ] **Category Marketing:** https://[NEW_DOMAIN]/category/marketing (shows marketing articles)
- [ ] **Category Television:** https://[NEW_DOMAIN]/category/television
- [ ] **Category Digital:** https://[NEW_DOMAIN]/category/digital
- [ ] **Videos:** https://[NEW_DOMAIN]/videos/ (shows video gallery)
- [ ] **Search:** https://[NEW_DOMAIN]/search/?q=test

### SSL Testing
- [ ] Browser shows green padlock
- [ ] Certificate valid for [NEW_DOMAIN] and www.[NEW_DOMAIN]
- [ ] Certificate issued by Let's Encrypt
- [ ] Certificate expiration date noted: __________
- [ ] No mixed content warnings

### Database Testing
- [ ] Run query: `mysql -u archive_user -p'ArchiveUser@2026Secure' -e "USE archive_adgully; SELECT COUNT(*) FROM satish_posts;"`
- [ ] Result shows ~113,111 posts
- [ ] Test article loads correct data from database
- [ ] Verify using production database (not test database)

### PHP Testing
- [ ] Create phpinfo.php: `echo '<?php phpinfo(); ?>' > /var/www/[NEW_DOMAIN]/phpinfo.php`
- [ ] Access: https://[NEW_DOMAIN]/phpinfo.php
- [ ] Verify PHP 5.6.40
- [ ] Verify Server API: FPM/FastCGI
- [ ] Delete phpinfo.php: `rm /var/www/[NEW_DOMAIN]/phpinfo.php`

### Menu Testing
- [ ] Click "Home" - goes to [NEW_DOMAIN] (not old domain)
- [ ] Click "Marketing" - goes to [NEW_DOMAIN]/category/marketing
- [ ] Click "Television" - goes to [NEW_DOMAIN]/category/television
- [ ] Click "Digital" - goes to [NEW_DOMAIN]/category/digital
- [ ] Check all 15 category links
- [ ] Test mobile menu (responsive view)

### Error Log Check
- [ ] Nginx error log empty (or no critical errors)
- [ ] PHP-FPM error log empty (or no critical errors)
- [ ] No 404 errors for CSS/JS files
- [ ] No database connection errors
- [ ] No permission denied errors

---

## 📄 DOCUMENTATION CHECKLIST

### Update Documentation Files
- [ ] README.md - Update domain references
- [ ] SERVER_DETAILS.md - Update domain and SSL expiry date
- [ ] MIGRATION_STATUS_REPORT.md - Update live site URL and migration date
- [ ] MIGRATION_COMPLETE_DOCUMENTATION.md - Update domain and date
- [ ] QUICK_REFERENCE.md - Update domain examples
- [ ] .github/copilot-instructions.md - Update domain in project status
- [ ] DOMAIN_DATABASE_CHANGE_GUIDE.md - Update current domain section
- [ ] COMPLETE_DOMAIN_MIGRATION_GUIDE.md - Update examples if needed

### Update Local Scripts (Optional)
- [ ] update-nginx-config.ps1 - Update domain variable
- [ ] upload-config-now.bat - Update domain reference
- [ ] deploy-nginx.bat - Update domain reference
- [ ] quick-setup.ps1 - Update domain variable

---

## 🗑️ CLEANUP CHECKLIST (After Verification)

### Remove Old Configuration (ONLY AFTER NEW SITE WORKS)
- [ ] Backup old site: `tar -czf /root/[OLD_DOMAIN]-backup.tar.gz /var/www/[OLD_DOMAIN]`
- [ ] Disable old nginx config: `rm /etc/nginx/sites-enabled/[OLD_DOMAIN].conf`
- [ ] Reload nginx: `systemctl reload nginx`
- [ ] Optional: Remove old directory: `rm -rf /var/www/[OLD_DOMAIN]`

### Verify Old Domain
- [ ] Test old domain still accessible (if keeping it)
- [ ] OR verify old domain redirects to new domain (if redirecting)
- [ ] OR verify old domain shows "Site moved" page (if deprecating)

---

## ✅ COMPLETION CHECKLIST

- [ ] All files uploaded successfully
- [ ] All services restarted
- [ ] All tests passed
- [ ] Documentation updated
- [ ] SSL certificate valid
- [ ] No errors in logs
- [ ] Client/stakeholders notified
- [ ] Backup created
- [ ] Migration date recorded

---

## 📞 TROUBLESHOOTING QUICK REFERENCE

| Issue | Quick Fix |
|-------|-----------|
| Site shows test data | Check config.php HTTP_HOST check |
| News articles 404 | Verify control_rewrite.php ltrim fix |
| SSL error | Regenerate cert: `certbot renew --force-renewal` |
| CSS not loading | Fix permissions: `chmod 644` files, `chmod 755` dirs |
| Database error | Test connection, verify credentials |
| Menu wrong links | Run sed replace on menu-items.php |

---

## 📝 NOTES SECTION

**Migration Notes:**
- Date started: _________________
- Date completed: _________________
- Issues encountered: _________________
- Resolution: _________________
- Time taken: _________________
- Downtime (if any): _________________

**DNS Propagation:**
- Started: _________________
- Completed: _________________

**Certificate Details:**
- Issue date: _________________
- Expiry date: _________________
- Auto-renewal: ☐ Enabled ☐ Disabled

**Performance:**
- Old domain response time: _________________
- New domain response time: _________________
- Any performance issues: _________________

---

**Checklist Version:** 1.0  
**Last Updated:** February 2, 2026  
**Based on:** COMPLETE_DOMAIN_MIGRATION_GUIDE.md
