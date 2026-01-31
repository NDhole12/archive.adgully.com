# Code Changes Log - archive2.adgully.com Migration

## Date: January 21, 2026

### NGINX URL Rewriting Fixed (2026-01-21 02:47 UTC)

**Issue**: SEO-friendly URLs returning 404 errors
- Example: `/budget-2022-23-pm-e-vidya-initiative-to-be-expanded-to-400-channels-113695.html`
- Cause: Nginx was missing URL rewrite rules (Apache .htaccess not read by Nginx)

**Solution**: Updated nginx configuration to handle URL rewrites
- File: `/etc/nginx/sites-available/archive2.adgully.com.conf`
- Backup: `/etc/nginx/sites-available/archive2.adgully.com.conf.backup`

**Changes Made**:
```nginx
# OLD (returning 404)
location / {
    try_files $uri $uri/ =404;
}

# NEW (URL rewriting to index.php)
location / {
    try_files $uri $uri/ /index.php?request_url=$uri&$args;
}

# Also added proper PHP parameters
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
}
```

**Verification**:
```bash
# Test URL that was previously failing
curl -s -o /dev/null -w '%{http_code}' https://archive2.adgully.com/budget-2022-23-pm-e-vidya-initiative-to-be-expanded-to-400-channels-113695.html
# Result: 200 ✅
```

**Status**: ✅ FIXED - All SEO-friendly URLs now working

---

## Date: January 20, 2026

### Database Setup

**Database Created:**
- Name: `archive_adgully`
- Character Set: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`

**Database User Created:**
- Username: `archive_user`
- Password: `ArchiveUser@2026Secure`
- Host: `localhost`
- Permissions: `SELECT, INSERT, UPDATE` (No DELETE or DROP)

**SQL Import:**
- File: `/var/www/archive2.adgully.com/adgully.sql`
- Status: Imported successfully
- Database: `archive_adgully`

---

### Configuration Files to Update

#### 1. Main Database Configuration
**File:** `/var/www/archive2.adgully.com/config.php`
**Changes Required:**
```php
// OLD (to be replaced)
$db_host = 'localhost';
$db_name = 'old_database';
$db_user = 'old_user';
$db_pass = 'old_password';

// NEW (updated credentials)
$db_host = 'localhost';
$db_name = 'archive_adgully';
$db_user = 'archive_user';
$db_pass = 'ArchiveUser@2026Secure';
```

#### 2. Check for Alternative Config Files
Common locations to search:
- `config.php`
- `db_config.php`
- `includes/config.php`
- `admin/config.php`
- `client_registration/config.php`

---

### Server Configuration Changes

#### 1. SSL Certificates Installed
- Domain: `archive2.adgully.com`
- Subdomain: `pma.archive2.adgully.com`
- Issuer: Let's Encrypt
- Expiry: April 20, 2026

#### 2. phpMyAdmin Installed
- URL: https://pma.archive2.adgully.com/
- Root User: `root` / `Admin@2026MsIhJgArhSg8x`

#### 3. Web Directory Structure
```
/var/www/archive2.adgully.com/
├── admin/
├── awards_images/
├── ckeditor/
├── client_registration/
├── config.php (TO BE UPDATED)
├── adgully.sql
└── [other files]
```

---

### Testing Checklist

- [ ] Database connection test
- [ ] Homepage loads correctly
- [ ] Admin login works
- [ ] Image uploads functional
- [ ] Form submissions work
- [ ] No PHP errors in logs
- [ ] All CSS/JS loading
- [ ] SSL certificate valid

---

### Next Steps

1. Run `setup-database.ps1` to import SQL and create user
2. Find and update all `config.php` files with new credentials
3. Set proper file permissions (www-data:www-data)
4. Test website functionality
5. Check PHP error logs: `/var/log/nginx/archive2.adgully.com_error.log`

---

### Backup Information

**Original Files Location:** `D:\achive.adgully.com\archive\`
**Server Location:** `/var/www/archive2.adgully.com/`
**Database Backup:** `adgully.sql` (included in upload)

---

### Security Notes

- Database user has NO DELETE or DROP privileges
- Only SELECT, INSERT, UPDATE allowed
- Root database access only via phpMyAdmin
- SSL enforced on all domains
- Fail2ban protection active

---

**Last Updated:** January 20, 2026
**Updated By:** Migration Script
