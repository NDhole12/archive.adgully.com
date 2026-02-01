# Complete Domain Migration Guide
## Archive.adgully.com - Domain Change Documentation

**Purpose:** Ultra-detailed guide for migrating from one domain to another (e.g., archive2.adgully.com → archive.adgully.com)

**Last Updated:** February 2, 2026

---

## 📋 MIGRATION CHECKLIST

Use this checklist every time you migrate to a new domain:

- [ ] 1. Update DNS records (A/CNAME)
- [ ] 2. Generate SSL certificate
- [ ] 3. Update Nginx configuration
- [ ] 4. Update PHP-FPM pool
- [ ] 5. Update core PHP files
- [ ] 6. Update menu files
- [ ] 7. Update database connection (if needed)
- [ ] 8. Update local scripts
- [ ] 9. Update documentation files
- [ ] 10. Test all URLs (homepage, news, category, videos)
- [ ] 11. Verify SSL certificate
- [ ] 12. Check error logs

---

## 🎯 CRITICAL FILES TO CHANGE

### PRIORITY 1: Server Configuration Files (Must Change)

#### 1. Nginx Server Block
**File Location:** `/etc/nginx/sites-available/[DOMAIN].conf`

**What to change:**
- Server name
- Root directory path
- SSL certificate paths
- Access log path
- Error log path

**Example Change:**
```nginx
# OLD (archive2.adgully.com)
server {
    listen 443 ssl http2;
    server_name archive2.adgully.com;
    root /var/www/archive2.adgully.com;
    
    ssl_certificate /etc/letsencrypt/live/archive2.adgully.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/archive2.adgully.com/privkey.pem;
    
    access_log /var/log/nginx/archive2.adgully.com_access.log;
    error_log /var/log/nginx/archive2.adgully.com_error.log;
}

# NEW (archive.adgully.com)
server {
    listen 443 ssl http2;
    server_name archive.adgully.com www.archive.adgully.com;
    root /var/www/archive.adgully.com;
    
    ssl_certificate /etc/letsencrypt/live/archive.adgully.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/archive.adgully.com/privkey.pem;
    
    access_log /var/log/nginx/archive.adgully.com_access.log;
    error_log /var/log/nginx/archive.adgully.com_error.log;
}
```

**Local File:** `d:\archive.adgully.com\configs\nginx\[DOMAIN].conf`

**Line-by-line changes:**
- Line 4: `server_name archive2.adgully.com;` → `server_name archive.adgully.com www.archive.adgully.com;`
- Line 11: `server_name archive2.adgully.com;` → `server_name archive.adgully.com www.archive.adgully.com;`
- Line 12: `root /var/www/archive2.adgully.com;` → `root /var/www/archive.adgully.com;`
- Line 16: SSL cert path → `/etc/letsencrypt/live/archive.adgully.com/fullchain.pem`
- Line 17: SSL key path → `/etc/letsencrypt/live/archive.adgully.com/privkey.pem`
- Line 34: Access log → `/var/log/nginx/archive.adgully.com_access.log`
- Line 35: Error log → `/var/log/nginx/archive.adgully.com_error.log`

---

#### 2. PHP-FPM Pool Configuration
**File Location:** `/etc/php/5.6/fpm/pool.d/archive-pool.conf`

**What to change:**
- Pool name (optional but recommended)
- open_basedir directive

**Example Change:**
```ini
; OLD
[archive2_pool]
php_admin_value[open_basedir] = /var/www/archive2.adgully.com:/tmp:/var/lib/php/sessions

; NEW
[archive_pool]
php_admin_value[open_basedir] = /var/www/archive.adgully.com:/tmp:/var/lib/php/sessions
```

**Local File:** `d:\archive.adgully.com\configs\php\archive-pool.conf`

**Line-by-line changes:**
- Line 1: Comment line (update domain name in comment)
- Line 46: `php_admin_value[open_basedir] = /var/www/archive2.adgully.com:/tmp:/var/lib/php/sessions` 
  → `php_admin_value[open_basedir] = /var/www/archive.adgully.com:/tmp:/var/lib/php/sessions`

---

### PRIORITY 2: Core PHP Application Files (Must Change)

#### 3. Main Configuration File
**File Location (Server):** `/var/www/[DOMAIN]/config.php`

**File Location (Local):** `d:\achive.adgully.com\archive.adgully.com\httpdocs\config.php`

**What to change:**
- Line 10: HTTP_HOST check

**Example Change:**
```php
// OLD
if( $_SERVER['HTTP_HOST'] == "archive2.adgully.com" ){
    $config_db_user = "archive_user";
    $config_db_pass = "ArchiveUser@2026Secure";
    $config_db_db = "archive_adgully";
    $config_db_host = "localhost";
    $config_image_host = "www.adgully.com";
    $config_s3_bucket_name = "adgully";
}

// NEW
if( $_SERVER['HTTP_HOST'] == "archive.adgully.com" || $_SERVER['HTTP_HOST'] == "www.archive.adgully.com" ){
    $config_db_user = "archive_user";
    $config_db_pass = "ArchiveUser@2026Secure";
    $config_db_db = "archive_adgully";
    $config_db_host = "localhost";
    $config_image_host = "www.adgully.com";
    $config_s3_bucket_name = "adgully";
}
```

**⚠️ CRITICAL:** This file controls database connection. If wrong domain, site shows test database content!

---

#### 4. Control Rewrite File
**File Location (Server):** `/var/www/[DOMAIN]/control_rewrite.php`

**File Location (Local):** `d:\achive.adgully.com\archive.adgully.com\httpdocs\control_rewrite.php`

**What to change:** NOTHING (domain-independent)

**Important:** This file was fixed for URL routing issues. Changes made:
- Line 98: Added `isset()` check for query parameter
- Line 100-102: Added `isset()` checks for GET/REQUEST parameters
- Line 112-113: **CRITICAL FIX** - Remove leading slash before exploding path
  ```php
  $path_clean = ltrim($parts['path'], '/');
  $paths = explode( "/" , $path_clean );
  ```
- Line 115-127: Added `isset()` checks for all $param0-$param9 variables

**Why this matters:** Without the `ltrim()` fix, URLs like `/havas-...-158207.html` would parse incorrectly, causing $page to be empty.

---

#### 5. Rewrite Rules Configuration
**File Location (Server):** `/var/www/[DOMAIN]/config_rewrites.php`

**File Location (Local):** `d:\achive.adgully.com\archive.adgully.com\httpdocs\config_rewrites.php`

**What to change:** NOTHING (domain-independent)

**Important:** Rule order matters! Current correct order:
```php
$rewriterules = array(
    "45" => array( "url" => "/videos/(.*?)", "map"=>"/videos/videos/$1", ... ),
    "50" => array( "url" => "/(.*?)/(.*?)/(.*?)\.html", "map"=>"/news/$1-$2/old/$3", ... ),
    "75" => array( "url" => "/(.*?)-([0-9]+).html", "map"=>"/news/news/$2", ... ), // MUST be before rule 65
    "65" => array( "url" => "/(.*?)/(.*?)\.html", "map"=>"/news/$1/old/$2", ... ),
);
```

**Why this order matters:**
- Rule 75 matches news articles: `/havas-media-group-158207.html` → `/news/news/158207`
- Rule 65 is more general: `/(.*?)/(.*?)\.html`
- If rule 65 comes first, it matches before rule 75, extracting wrong parameters

---

#### 6. Menu Items Files
**File Locations (Server):**
- `/var/www/[DOMAIN]/menu-items.php`
- `/var/www/[DOMAIN]/mobile-menu-items.php`

**File Locations (Local):**
- `d:\achive.adgully.com\archive.adgully.com\httpdocs\menu-items.php`
- `d:\achive.adgully.com\archive.adgully.com\httpdocs\mobile-menu-items.php`

**What to change:** All href URLs

**Example Change:**
```php
// OLD
<li><a href="https://archive2.adgully.com">Home</a></li>
<li><a href="https://archive2.adgully.com/category/marketing">Marketing</a></li>

// NEW
<li><a href="https://archive.adgully.com">Home</a></li>
<li><a href="https://archive.adgully.com/category/marketing">Marketing</a></li>
```

**Automated fix (run on server):**
```bash
# For menu-items.php
sed -i 's/archive2\.adgully\.com/archive.adgully.com/g' /var/www/archive.adgully.com/menu-items.php

# For mobile-menu-items.php
sed -i 's/archive2\.adgully\.com/archive.adgully.com/g' /var/www/archive.adgully.com/mobile-menu-items.php
```

**Categories to update in both files:**
1. Home
2. Marketing
3. Television
4. Digital
5. Mainstreaming
6. Radio
7. Regional
8. Youth
9. Films
10. OOH
11. Celebrity News
12. Tech
13. PR
14. Events
15. CMO Speak

---

#### 7. Sub-application Config Files
**File Locations (Server):**
- `/var/www/[DOMAIN]/client_registration/config.php`
- `/var/www/[DOMAIN]/manager/config.php`
- `/var/www/[DOMAIN]/cmo2023/php/config.php`

**What to change:** Database credentials (same as main config.php)

**Example Change:**
```php
// Each file should have:
$config_db_user = "archive_user";
$config_db_pass = "ArchiveUser@2026Secure";
$config_db_db = "archive_adgully";
$config_db_host = "localhost";
```

---

### PRIORITY 3: Local Development Scripts (Should Change)

#### 8. PowerShell Deployment Scripts

**Files to update:**
1. `d:\archive.adgully.com\update-nginx-config.ps1`
2. `d:\archive.adgully.com\upload-config-now.bat`
3. `d:\archive.adgully.com\deploy-nginx.bat`
4. `d:\archive.adgully.com\quick-setup.ps1`

**What to change:** Domain references in upload commands

**Example Change (update-nginx-config.ps1):**
```powershell
# OLD
$domain = "archive2.adgully.com"
$nginxConfig = "configs/nginx/archive2.adgully.com.conf"
$remotePath = "/etc/nginx/sites-available/archive2.adgully.com.conf"

# NEW
$domain = "archive.adgully.com"
$nginxConfig = "configs/nginx/archive.adgully.com.conf"
$remotePath = "/etc/nginx/sites-available/archive.adgully.com.conf"
```

---

#### 9. Database Management Scripts

**Files to update:**
1. `d:\archive.adgully.com\setup-database.ps1`
2. `d:\archive.adgully.com\run-database-setup.ps1`
3. `d:\archive.adgully.com\db-manage.bat`
4. `d:\archive.adgully.com\execute-db-tasks.ps1`

**What to change:** Database credentials (if database changes)

**Current credentials (DO NOT CHANGE unless creating new database):**
```powershell
$dbName = "archive_adgully"
$dbUser = "archive_user"
$dbPass = "ArchiveUser@2026Secure"
$rootPass = "Admin@2026MsIhJgArhSg8x"
```

**⚠️ NOTE:** These scripts only need updating if you create a NEW database. If keeping same database, credentials stay the same!

---

#### 10. SSH/Upload Scripts

**Files to update:**
1. `d:\archive.adgully.com\ssh-test.ps1`
2. `d:\archive.adgully.com\run-ssh-test.bat`

**What to change:** Server IP and paths

**Current values:**
```powershell
$serverIP = "31.97.233.171"
$serverUser = "root"
$serverPass = "z(P5ts@wdsESLUjMPVXs"
$remotePath = "/var/www/archive2.adgully.com"
```

**If changing domain on SAME server:**
- Keep IP and credentials
- Update $remotePath only

**If changing to NEW server:**
- Update ALL values

---

### PRIORITY 4: Documentation Files (Should Change)

#### 11. Documentation to Update

**Files to update:**
1. `README.md` - Main project documentation
2. `SERVER_DETAILS.md` - Server access info
3. `MIGRATION_STATUS_REPORT.md` - Migration status
4. `QUICK_REFERENCE.md` - Quick reference guide
5. `.github/copilot-instructions.md` - GitHub Copilot instructions
6. `MIGRATION_COMPLETE_DOCUMENTATION.md` - Complete migration docs
7. `DOMAIN_DATABASE_CHANGE_GUIDE.md` - This guide (update examples)

**What to change:**
- All domain references in examples
- Live site URL
- SSL certificate expiration dates
- Migration completion dates

---

## 🚀 STEP-BY-STEP MIGRATION PROCEDURE

### Phase 1: Pre-Migration (DO THIS FIRST)

#### Step 1.1: DNS Configuration
```bash
# Add DNS A record for new domain
# Point archive.adgully.com → 31.97.233.171

# If using Cloudflare/DNS provider:
# 1. Log in to DNS control panel
# 2. Add A record: archive.adgully.com → 31.97.233.171
# 3. Add A record: www.archive.adgully.com → 31.97.233.171
# 4. Wait for DNS propagation (10-60 minutes)
```

**Verify DNS:**
```bash
# Windows
nslookup archive.adgully.com

# Should return: 31.97.233.171
```

---

#### Step 1.2: Create Directory on Server
```bash
# SSH into server
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171

# Create new directory
mkdir -p /var/www/archive.adgully.com
chown -R www-data:www-data /var/www/archive.adgully.com
chmod -R 755 /var/www/archive.adgully.com
```

---

#### Step 1.3: Generate SSL Certificate
```bash
# On server (SSH)
certbot certonly --nginx -d archive.adgully.com -d www.archive.adgully.com

# Verify certificate created
ls -la /etc/letsencrypt/live/archive.adgully.com/

# Should see:
# - fullchain.pem
# - privkey.pem
# - chain.pem
# - cert.pem
```

---

### Phase 2: Configuration Updates

#### Step 2.1: Update Local Nginx Config
```bash
# Edit file: d:\archive.adgully.com\configs\nginx\archive.adgully.com.conf

# Change all references:
# - server_name
# - root directory
# - SSL certificate paths
# - Log file paths

# Use find-replace:
# archive2.adgully.com → archive.adgully.com
```

**Verification checklist:**
- [ ] Line 4: `server_name archive.adgully.com www.archive.adgully.com;`
- [ ] Line 11: `server_name archive.adgully.com www.archive.adgully.com;`
- [ ] Line 12: `root /var/www/archive.adgully.com;`
- [ ] Line 16: SSL cert path correct
- [ ] Line 17: SSL key path correct
- [ ] Line 34: Access log path correct
- [ ] Line 35: Error log path correct

---

#### Step 2.2: Update Local PHP-FPM Config
```bash
# Edit file: d:\archive.adgully.com\configs\php\archive-pool.conf

# Line 46: Change open_basedir
php_admin_value[open_basedir] = /var/www/archive.adgully.com:/tmp:/var/lib/php/sessions
```

---

#### Step 2.3: Upload Nginx Configuration
```powershell
# Run from: d:\archive.adgully.com\

# Upload nginx config
.\tools\pscp.exe -pw "z(P5ts@wdsESLUjMPVXs" `
  configs/nginx/archive.adgully.com.conf `
  root@31.97.233.171:/etc/nginx/sites-available/archive.adgully.com.conf

# Create symbolic link (on server)
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 `
  "ln -sf /etc/nginx/sites-available/archive.adgully.com.conf /etc/nginx/sites-enabled/"

# Test nginx configuration
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 `
  "nginx -t"

# Should see:
# nginx: configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful
```

---

#### Step 2.4: Upload PHP-FPM Configuration
```powershell
# Upload PHP-FPM pool config
.\tools\pscp.exe -pw "z(P5ts@wdsESLUjMPVXs" `
  configs/php/archive-pool.conf `
  root@31.97.233.171:/etc/php/5.6/fpm/pool.d/archive-pool.conf
```

---

### Phase 3: Application File Updates

#### Step 3.1: Update Local PHP Files

**File 1: config.php**
```php
// Edit: d:\achive.adgully.com\archive.adgully.com\httpdocs\config.php
// Line 10: Change domain check

if( $_SERVER['HTTP_HOST'] == "archive.adgully.com" || $_SERVER['HTTP_HOST'] == "www.archive.adgully.com" ){
    $config_db_user = "archive_user";
    $config_db_pass = "ArchiveUser@2026Secure";
    $config_db_db = "archive_adgully";
    $config_db_host = "localhost";
    $config_image_host = "www.adgully.com";
    $config_s3_bucket_name = "adgully";
}
```

**File 2: menu-items.php**
```bash
# Use find-replace in VS Code:
# Find: archive2.adgully.com
# Replace: archive.adgully.com
# Files: menu-items.php
```

**File 3: mobile-menu-items.php**
```bash
# Use find-replace in VS Code:
# Find: archive2.adgully.com
# Replace: archive.adgully.com
# Files: mobile-menu-items.php
```

---

#### Step 3.2: Upload Application Files
```powershell
# Upload entire httpdocs folder
.\tools\pscp.exe -r -pw "z(P5ts@wdsESLUjMPVXs" `
  httpdocs/* `
  root@31.97.233.171:/var/www/archive.adgully.com/

# OR upload specific files:
.\tools\pscp.exe -pw "z(P5ts@wdsESLUjMPVXs" `
  httpdocs/config.php `
  root@31.97.233.171:/var/www/archive.adgully.com/config.php

.\tools\pscp.exe -pw "z(P5ts@wdsESLUjMPVXs" `
  httpdocs/menu-items.php `
  root@31.97.233.171:/var/www/archive.adgully.com/menu-items.php

.\tools\pscp.exe -pw "z(P5ts@wdsESLUjMPVXs" `
  httpdocs/mobile-menu-items.php `
  root@31.97.233.171:/var/www/archive.adgully.com/mobile-menu-items.php
```

---

#### Step 3.3: Set Permissions
```bash
# On server
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171

# Set ownership
chown -R www-data:www-data /var/www/archive.adgully.com

# Set directory permissions
find /var/www/archive.adgully.com -type d -exec chmod 755 {} \;

# Set file permissions
find /var/www/archive.adgully.com -type f -exec chmod 644 {} \;

# Make specific directories writable
chmod -R 775 /var/www/archive.adgully.com/images
chmod -R 775 /var/www/archive.adgully.com/uploads
```

---

### Phase 4: Service Restart

#### Step 4.1: Restart Services
```bash
# On server (SSH)
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171

# Restart PHP-FPM
systemctl restart php5.6-fpm

# Check PHP-FPM status
systemctl status php5.6-fpm

# Restart Nginx
systemctl restart nginx

# Check Nginx status
systemctl status nginx
```

---

### Phase 5: Testing & Verification

#### Step 5.1: Test URLs

**Homepage:**
```bash
# Test homepage
https://archive.adgully.com/

# Should load main page with news articles
```

**News Article:**
```bash
# Test news article URL
https://archive.adgully.com/havas-media-group-bags-mandate-for-samsung-galaxy-s21-series-158207.html

# Should load article with ID 158207
# Check page title, content, images
```

**Category Page:**
```bash
# Test category page
https://archive.adgully.com/category/marketing

# Should show marketing articles
```

**Videos:**
```bash
# Test videos page
https://archive.adgully.com/videos/

# Should show video gallery
```

---

#### Step 5.2: Check Error Logs
```bash
# On server
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171

# Check nginx error log
tail -f /var/log/nginx/archive.adgully.com_error.log

# Check PHP-FPM error log
tail -f /var/log/php5.6-fpm.log
```

**Common errors to watch for:**
- 404 errors (file not found)
- 500 errors (PHP errors)
- Database connection errors
- SSL certificate errors
- Permission denied errors

---

#### Step 5.3: Verify SSL Certificate
```bash
# Test SSL
https://archive.adgully.com/

# Should show green padlock in browser

# Check certificate details:
# - Valid for: archive.adgully.com, www.archive.adgully.com
# - Issued by: Let's Encrypt
# - Valid until: (3 months from issue date)
```

**Using command line:**
```bash
# Windows (PowerShell)
$url = "https://archive.adgully.com"
$request = [System.Net.WebRequest]::Create($url)
$response = $request.GetResponse()
$cert = $request.ServicePoint.Certificate
$cert | Format-List *

# Should show valid certificate info
```

---

#### Step 5.4: Database Connection Test
```bash
# On server
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171

# Test database connection
mysql -u archive_user -p'ArchiveUser@2026Secure' -e "USE archive_adgully; SELECT COUNT(*) FROM satish_posts;"

# Should return: 113111 (or current post count)
```

---

#### Step 5.5: PHP Configuration Test
```bash
# Create test file on server
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 `
  "echo '<?php phpinfo(); ?>' > /var/www/archive.adgully.com/phpinfo.php"

# Test in browser
https://archive.adgully.com/phpinfo.php

# Verify:
# - PHP Version: 5.6.40
# - Server API: FPM/FastCGI
# - Configuration File: /etc/php/5.6/fpm/php.ini

# REMOVE file after testing (security)
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 `
  "rm /var/www/archive.adgully.com/phpinfo.php"
```

---

### Phase 6: Documentation Updates

#### Step 6.1: Update Documentation Files

**Files to update:**
1. `README.md`
2. `SERVER_DETAILS.md`
3. `MIGRATION_STATUS_REPORT.md`
4. `QUICK_REFERENCE.md`
5. `.github/copilot-instructions.md`

**Use find-replace:**
```bash
# In VS Code:
# Find: archive2.adgully.com
# Replace: archive.adgully.com
# Files to include: *.md
```

---

#### Step 6.2: Update Migration Date
```markdown
# In MIGRATION_COMPLETE_DOCUMENTATION.md
**Site Live at:** https://archive.adgully.com/
**Migration Date:** February 2, 2026  # Update to actual date
```

---

### Phase 7: Cleanup (Optional)

#### Step 7.1: Remove Old Configuration
```bash
# On server (only after verifying new site works)
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171

# Disable old site
rm /etc/nginx/sites-enabled/archive2.adgully.com.conf

# Reload nginx
systemctl reload nginx

# Optional: Remove old directory (BACKUP FIRST!)
# tar -czf /root/archive2-backup.tar.gz /var/www/archive2.adgully.com
# rm -rf /var/www/archive2.adgully.com
```

---

## 🔍 TROUBLESHOOTING

### Issue 1: Site Shows Test Database Content

**Symptom:** Site loads but shows wrong content or test data

**Cause:** config.php HTTP_HOST check is wrong

**Solution:**
```php
// Check config.php line 10
if( $_SERVER['HTTP_HOST'] == "archive.adgully.com" || $_SERVER['HTTP_HOST'] == "www.archive.adgully.com" ){
    // Correct credentials here
}
```

**Verify:**
```bash
# On server
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 `
  "grep -n 'HTTP_HOST' /var/www/archive.adgully.com/config.php"
```

---

### Issue 2: News Articles Show 404

**Symptom:** Homepage works but news article URLs show 404

**Cause:** control_rewrite.php or config_rewrites.php has issues

**Solution:**
```php
// Verify control_rewrite.php line 112-113
$path_clean = ltrim($parts['path'], '/');
$paths = explode( "/" , $path_clean );

// Verify config_rewrites.php rule order
// Rule 75 MUST come before rule 65
```

**Test:**
```bash
# Enable debug in control_rewrite.php temporarily
# Add after line 110:
error_log("DEBUG: path = " . $parts['path']);
error_log("DEBUG: path_clean = " . $path_clean);
error_log("DEBUG: page = " . $page);

# Check nginx error log
tail -f /var/log/nginx/archive.adgully.com_error.log
```

---

### Issue 3: SSL Certificate Error

**Symptom:** Browser shows "Not Secure" or certificate warning

**Cause:** Certificate not generated or nginx config wrong

**Solution:**
```bash
# Regenerate certificate
certbot certonly --nginx -d archive.adgully.com -d www.archive.adgully.com --force-renewal

# Verify certificate paths in nginx config
ls -la /etc/letsencrypt/live/archive.adgully.com/

# Restart nginx
systemctl restart nginx
```

---

### Issue 4: CSS/JS Not Loading

**Symptom:** Site loads but no styling, broken layout

**Cause:** File permissions or nginx config

**Solution:**
```bash
# Fix permissions
chown -R www-data:www-data /var/www/archive.adgully.com
find /var/www/archive.adgully.com -type f -exec chmod 644 {} \;
find /var/www/archive.adgully.com -type d -exec chmod 755 {} \;

# Verify nginx config has correct root
grep "root" /etc/nginx/sites-available/archive.adgully.com.conf

# Should show:
# root /var/www/archive.adgully.com;
```

---

### Issue 5: Database Connection Failed

**Symptom:** "Error establishing database connection"

**Cause:** Wrong database credentials or database not accessible

**Solution:**
```bash
# Test database connection
mysql -u archive_user -p'ArchiveUser@2026Secure' -e "USE archive_adgully; SELECT 1;"

# If fails, check user exists:
mysql -u root -p'Admin@2026MsIhJgArhSg8x' -e "SELECT User, Host FROM mysql.user WHERE User='archive_user';"

# If user missing, create:
mysql -u root -p'Admin@2026MsIhJgArhSg8x' <<EOF
CREATE USER 'archive_user'@'localhost' IDENTIFIED BY 'ArchiveUser@2026Secure';
GRANT ALL PRIVILEGES ON archive_adgully.* TO 'archive_user'@'localhost';
FLUSH PRIVILEGES;
EOF
```

---

### Issue 6: Menu Links Still Point to Old Domain

**Symptom:** Menu links go to archive2.adgully.com instead of archive.adgully.com

**Cause:** menu-items.php not updated

**Solution:**
```bash
# On server
sed -i 's/archive2\.adgully\.com/archive.adgully.com/g' /var/www/archive.adgully.com/menu-items.php
sed -i 's/archive2\.adgully\.com/archive.adgully.com/g' /var/www/archive.adgully.com/mobile-menu-items.php

# Verify
grep -n "archive2" /var/www/archive.adgully.com/menu-items.php

# Should return no results
```

---

## 📊 QUICK REFERENCE TABLES

### File Change Summary

| File | Change Type | Priority | Can Use Find-Replace |
|------|-------------|----------|----------------------|
| Nginx config | Domain, paths | CRITICAL | Yes |
| PHP-FPM pool | Path | CRITICAL | Yes |
| config.php | Domain check | CRITICAL | No (manual) |
| menu-items.php | URLs | HIGH | Yes |
| mobile-menu-items.php | URLs | HIGH | Yes |
| control_rewrite.php | None | N/A | N/A |
| config_rewrites.php | None | N/A | N/A |

---

### Domain-Independent Files (No Changes Needed)

| File | Why No Change Needed |
|------|---------------------|
| control_rewrite.php | Uses $_SERVER variables, not hardcoded domain |
| config_rewrites.php | URL patterns are domain-independent |
| block_HEADER*.php | Uses relative URLs |
| block_FOOTER*.php | Uses relative URLs |
| news/news.php | Domain-independent routing |
| category/category.php | Domain-independent routing |

---

### Service Restart Order

| Step | Command | Why |
|------|---------|-----|
| 1 | `systemctl restart php5.6-fpm` | Apply PHP config changes |
| 2 | `systemctl restart nginx` | Apply Nginx config changes |
| 3 | `systemctl status php5.6-fpm` | Verify PHP running |
| 4 | `systemctl status nginx` | Verify Nginx running |

---

### Testing Checklist

| Test | URL | Expected Result |
|------|-----|-----------------|
| Homepage | `https://archive.adgully.com/` | Loads with news articles |
| SSL | `https://archive.adgully.com/` | Green padlock, valid cert |
| News article | `https://archive.adgully.com/[article]-[id].html` | Loads specific article |
| Category | `https://archive.adgully.com/category/[name]` | Shows category articles |
| Videos | `https://archive.adgully.com/videos/` | Shows video gallery |
| Database | MySQL connection test | Returns post count |
| PHP version | phpinfo.php (temp) | Shows PHP 5.6.40 |

---

## 🎓 REROUTING LOGIC EXPLAINED

### How URL Routing Works

The site uses a custom URL rewriting system (NOT standard .htaccess):

1. **Entry Point:** Nginx sends all requests to `index.php`
2. **index.php** includes `control_rewrite.php`
3. **control_rewrite.php** does:
   - Parse request URI
   - Match against rewrite rules in `config_rewrites.php`
   - Extract page type and parameters
   - Include appropriate page file (news.php, category.php, etc.)

### URL Parsing Flow

```
User requests: https://archive.adgully.com/havas-media-group-158207.html
                                           ↓
Nginx receives request, passes to index.php
                                           ↓
index.php includes control_rewrite.php
                                           ↓
control_rewrite.php parses URI:
  - Full URI: /havas-media-group-158207.html
  - Remove leading /: havas-media-group-158207.html
  - Match against rules in config_rewrites.php
                                           ↓
Rule 75 matches: /(.*?)-([0-9]+).html
  - $1 = havas-media-group
  - $2 = 158207
  - Map to: /news/news/158207
                                           ↓
Extract page and params:
  - $page = "news"
  - $param1 = "news"
  - $param2 = "158207"
                                           ↓
Include: news/news.php
                                           ↓
news.php queries database for post ID 158207
                                           ↓
Display article
```

### Critical Rerouting Fixes

**Fix 1: Leading Slash Removal (control_rewrite.php line 112-113)**
```php
// BEFORE (BROKEN)
$paths = explode( "/" , $parts['path'] );
// Result: $paths[0] = "" (empty), $paths[1] = "havas-media-group-158207.html"
// $page = "" (empty) - WRONG!

// AFTER (FIXED)
$path_clean = ltrim($parts['path'], '/');
$paths = explode( "/" , $path_clean );
// Result: $paths[0] = "havas-media-group-158207.html"
// $page = "havas-media-group-158207.html" - matches rule 75 correctly
```

**Fix 2: Rule Order (config_rewrites.php)**
```php
// BEFORE (BROKEN)
"65" => array( "url" => "/(.*?)/(.*?)\.html", ... ),  // Too general, matches first
"75" => array( "url" => "/(.*?)-([0-9]+).html", ... ), // Never reached

// AFTER (FIXED)
"75" => array( "url" => "/(.*?)-([0-9]+).html", ... ), // Specific first
"65" => array( "url" => "/(.*?)/(.*?)\.html", ... ),  // General second
```

**Why fix 2 matters:**
- URL: `/havas-media-group-158207.html`
- Rule 65 pattern: `/(.*?)/(.*?)\.html` - would match with $1="havas-media-group" $2="158207" - WRONG extraction
- Rule 75 pattern: `/(.*?)-([0-9]+).html` - matches with $1="havas-media-group-" $2="158207" - CORRECT

---

### Domain Independence

**Why control_rewrite.php doesn't need domain changes:**
```php
// Uses server variables, not hardcoded domains
$parts = parse_url( $_SERVER['REQUEST_URI'] );
$request_uri = $_REQUEST['request_url'];

// Works with ANY domain pointing to this server
// archive.adgully.com → same code
// archive2.adgully.com → same code
// test.adgully.com → same code
```

**Where domain DOES matter:**
```php
// config.php - determines which database to use
if( $_SERVER['HTTP_HOST'] == "archive.adgully.com" ){
    $config_db_db = "archive_adgully"; // Production database
} else {
    $config_db_db = "adgully_test";   // Test database
}
```

---

## 🔐 SECURITY NOTES

### SSL Certificate Renewal

Let's Encrypt certificates expire every 90 days. Auto-renewal is configured.

**Check auto-renewal:**
```bash
# On server
systemctl status certbot.timer

# Should show: active (waiting)
```

**Manual renewal (if needed):**
```bash
certbot renew --dry-run  # Test renewal
certbot renew            # Actual renewal
systemctl reload nginx   # Apply new cert
```

---

### Firewall Rules

**Current rules (UFW):**
```bash
# Check firewall status
ufw status

# Should allow:
# - SSH (22/tcp)
# - HTTP (80/tcp)
# - HTTPS (443/tcp)
```

**Add new domain to firewall (if needed):**
```bash
# No changes needed - firewall is port-based, not domain-based
```

---

### File Permissions

**Never set 777 permissions:**
```bash
# WRONG (security risk)
chmod -R 777 /var/www/archive.adgully.com

# CORRECT
chown -R www-data:www-data /var/www/archive.adgully.com
find /var/www/archive.adgully.com -type d -exec chmod 755 {} \;
find /var/www/archive.adgully.com -type f -exec chmod 644 {} \;
```

---

## 📝 CONCLUSION

This guide covers ALL aspects of domain migration for archive.adgully.com. Follow each step carefully, and you won't miss anything.

**Key takeaways:**
1. **Critical files:** Nginx config, PHP-FPM pool, config.php, menu files
2. **Domain-independent files:** control_rewrite.php, config_rewrites.php
3. **Testing is crucial:** Test all URL types before declaring success
4. **Documentation matters:** Update all docs after migration

**If you follow this guide:**
- ✅ Domain migration will be complete
- ✅ No broken links
- ✅ SSL will work
- ✅ Database connection correct
- ✅ All URLs will route properly

---

**Last Updated:** February 2, 2026  
**Document Version:** 1.0  
**Author:** GitHub Copilot (via Satish)
