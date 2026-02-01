# Domain & Database Configuration Change Guide

This document lists all database connections and domain name references that need to be changed when migrating from `archive2.adgully.com` to `archive.adgully.com`.

---

## PART 1: DATABASE CONNECTIONS

### Current Production Database Credentials

| Setting | Value |
|---------|-------|
| Server IP | 31.97.233.171 |
| Database Name | archive_adgully |
| Database Host | localhost |
| Application User | archive_user |
| Application Password | ArchiveUser@2026Secure |
| Root User | root |
| Root Password | Admin@2026MsIhJgArhSg8x |
| phpMyAdmin User | phpmyadmin |
| Tables | 96 tables |

---

### Files with Database Configuration (Need to Change)

#### 1. Website Configuration Files (On Server)

**Location:** `/var/www/archive2.adgully.com/` (production server)

| File Path | Variables to Change |
|-----------|---------------------|
| `/var/www/archive2.adgully.com/config.php` | `$config_db_user`, `$config_db_pass`, `$config_db_db`, `$config_db_host` |
| `/var/www/archive2.adgully.com/client_registration/config.php` | Same as above |
| `/var/www/archive2.adgully.com/manager/config.php` | Same as above |
| `/var/www/archive2.adgully.com/cmo2023/php/config.php` | Same as above |

**Current Values (OLD - from original server):**
```php
$config_db_user = "adgully";
$config_db_pass = "adgully";
$config_db_db = "adgully";
$config_db_host = "172.31.35.34";
```

**New Values (CURRENT - production server):**
```php
$config_db_user = "archive_user";
$config_db_pass = "ArchiveUser@2026Secure";
$config_db_db = "archive_adgully";
$config_db_host = "localhost";
```

---

#### 2. Local Scripts (Windows Machine)

| File | Line Numbers | What to Change |
|------|--------------|----------------|
| `d:\archive.adgully.com\setup-database.ps1` | Lines 8-12 | `$dbName`, `$dbUser`, `$dbPass`, `$rootPass` |
| `d:\archive.adgully.com\update-config-files.ps1` | Lines 20-55 | sed commands with DB credentials |
| `d:\archive.adgully.com\run-database-setup.ps1` | Lines 20-25 | `$dbUser`, `$dbPassword`, `$database` |
| `d:\archive.adgully.com\db-manage.bat` | Lines 6-12 | `dbuser`, `dbpass`, `database` |
| `d:\archive.adgully.com\check-db-images.bat` | Line 3 | MySQL connection string |
| `d:\archive.adgully.com\upload-and-import-sql.bat` | Lines 3, 7 | DB credentials in command |
| `d:\archive.adgully.com\manage-satish-posts.ps1` | Lines 14-17 | `$dbUser`, `$dbPass`, `$database` |
| `d:\archive.adgully.com\execute-db-tasks.ps1` | Various | DB connection parameters |
| `d:\archive.adgully.com\quick-setup.ps1` | Various | DB credentials |

---

#### 3. Shell Scripts (For Server)

| File | Line Numbers | What to Change |
|------|--------------|----------------|
| `d:\archive.adgully.com\scripts\install\full-install.sh` | Lines 21-22 | `DB_NAME`, `DB_USER` |
| `d:\archive.adgully.com\scripts\migration\backup-database.sh` | Lines 6-7 | `DB_USER`, `DB_NAME` |
| `d:\archive.adgully.com\scripts\fix_config.php` | Lines 8-9 | Database name replacement |
| `d:\archive.adgully.com\scripts\fix_config.sh` | Line 2 | Config file path |

---

#### 4. Documentation Files (Update References)

| File | What to Update |
|------|----------------|
| `d:\archive.adgully.com\MIGRATION_STATUS_REPORT.md` | DB credentials documentation |
| `d:\archive.adgully.com\SERVER_DETAILS.md` | DB credentials section |
| `d:\archive.adgully.com\README.md` | DB info section |
| `d:\archive.adgully.com\.github\copilot-instructions.md` | DB credentials |
| `d:\archive.adgully.com\DATABASE_SETUP_REPORT.md` | All DB references |

---

## PART 2: DOMAIN NAME CHANGES

### When Changing from archive2.adgully.com to archive.adgully.com

---

### 1. Nginx Configuration Files

| File | Lines | Current Value | Change To |
|------|-------|---------------|-----------|
| `configs\nginx\archive2.adgully.com.conf` | 4 | `server_name archive2.adgully.com;` | `server_name archive.adgully.com www.archive.adgully.com;` |
| `configs\nginx\archive2.adgully.com.conf` | 11 | `access_log /var/log/nginx/archive2.adgully.com.access.log;` | `access_log /var/log/nginx/archive.adgully.com.access.log;` |
| `configs\nginx\archive2.adgully.com.conf` | 12 | `error_log /var/log/nginx/archive2.adgully.com.error.log;` | `error_log /var/log/nginx/archive.adgully.com.error.log;` |
| `configs\nginx\archive2.adgully.com.conf` | 16 | `ssl_certificate /etc/letsencrypt/live/archive2.adgully.com/fullchain.pem;` | `ssl_certificate /etc/letsencrypt/live/archive.adgully.com/fullchain.pem;` |
| `configs\nginx\archive2.adgully.com.conf` | 17 | `ssl_certificate_key /etc/letsencrypt/live/archive2.adgully.com/privkey.pem;` | `ssl_certificate_key /etc/letsencrypt/live/archive.adgully.com/privkey.pem;` |
| `configs\nginx\archive2.adgully.com.conf` | 34 | `root /var/www/archive2.adgully.com;` | `root /var/www/archive.adgully.com;` |

---

### 2. phpMyAdmin Nginx Config

| File | Lines | Current Value | Change To |
|------|-------|---------------|-----------|
| `configs\nginx\pma.archive2.adgully.com.conf` | 4 | `server_name pma.archive2.adgully.com;` | `server_name pma.archive.adgully.com;` |
| `configs\nginx\pma.archive2.adgully.com.conf` | 11-12 | Log paths with `archive2` | Change to `archive` |
| `configs\nginx\pma.archive2.adgully.com.conf` | 15-17 | SSL cert paths with `archive2` | Change to `archive` |
| `configs\nginx\pma.archive2.adgully.com.conf` | 34-35 | Root and alias paths | Change to `archive` |

---

### 3. PHP-FPM Pool Configuration

| File | Line | Current Value | Change To |
|------|------|---------------|-----------|
| `configs\php\archive-pool.conf` | 46 | `open_basedir = /var/www/archive.adgully.com:...` | Already correct (archive.adgully.com) |

---

### 4. PowerShell/Batch Scripts

| File | Lines | What to Change |
|------|-------|----------------|
| `update-config-files.ps1` | 21-77 | All `/var/www/archive2.adgully.com/` paths |
| `upload-config-now.bat` | 3, 7, 12 | Destination paths |
| `deploy-nginx.bat` | 3 | Nginx config name |
| `update-nginx-config.ps1` | 4, 5, 11 | Config paths |
| `check-images.bat` | 2-4 | Directory paths |
| `test_url.bat` | 2 | Test URL |
| `setup-database.ps1` | 15, 24 | Domain references |
| `run-database-setup.ps1` | 20 | Domain reference |
| `migrate-database-complete.ps1` | 21, 178-184, 218, 222-223 | Domain SQL updates |
| `quick-setup.ps1` | 6 | Log path reference |

---

### 5. PHP Scripts

| File | Line | What to Change |
|------|------|----------------|
| `scripts\fix_config.php` | 4 | `/var/www/archive2.adgully.com/config.php` |
| `scripts\fix_nginx.php` | 4 | `/etc/nginx/sites-enabled/archive2.adgully.com.conf` |
| `scripts\fix_config.sh` | 2 | `/var/www/archive2.adgully.com/config.php` |

---

### 6. Documentation Files

| File | Lines | What to Update |
|------|-------|----------------|
| `.github\copilot-instructions.md` | 4 | Live URL reference |
| `README.md` | 10, 22, 23, 43, 44, 114 | URLs and config names |
| `MIGRATION_STATUS_REPORT.md` | Multiple | All archive2 references |
| `SERVER_DETAILS.md` | 11, 49, 183, 204, 220, 289-290, 303 | Domain references |
| `IMAGE_FIX_DOCUMENTATION.md` | 4, 6, 10, 20, 25, 33, 43 | Domain references |

---

### 7. Server-Side Changes Required

#### File System Changes
```bash
# Rename web directory
mv /var/www/archive2.adgully.com /var/www/archive.adgully.com

# Rename nginx config
mv /etc/nginx/sites-available/archive2.adgully.com.conf /etc/nginx/sites-available/archive.adgully.com.conf

# Update symlink
ln -sf /etc/nginx/sites-available/archive.adgully.com.conf /etc/nginx/sites-enabled/

# Rename log files (optional)
mv /var/log/nginx/archive2.adgully.com.access.log /var/log/nginx/archive.adgully.com.access.log
mv /var/log/nginx/archive2.adgully.com.error.log /var/log/nginx/archive.adgully.com.error.log
```

#### SSL Certificate (Get New Certificate)
```bash
certbot certonly --nginx -d archive.adgully.com -d www.archive.adgully.com
```

#### DNS Changes Required
Update DNS A records:
- `archive.adgully.com` → `31.97.233.171`
- `www.archive.adgully.com` → `31.97.233.171`
- `pma.archive.adgully.com` → `31.97.233.171`

---

## PART 3: QUICK REFERENCE CHECKLIST

### Database Changes Checklist
- [ ] Update `/var/www/[domain]/config.php`
- [ ] Update `/var/www/[domain]/client_registration/config.php`
- [ ] Update `/var/www/[domain]/manager/config.php`
- [ ] Update `/var/www/[domain]/cmo2023/php/config.php`
- [ ] Test database connection

### Domain Change Checklist
- [ ] Update DNS records
- [ ] Rename web directory on server
- [ ] Update nginx configuration
- [ ] Obtain new SSL certificate
- [ ] Update nginx log paths
- [ ] Update PHP-FPM pool config
- [ ] Update all local scripts
- [ ] Update documentation
- [ ] Test website functionality
- [ ] Test phpMyAdmin access

---

## PART 4: IMAGE HOST CONFIGURATION

**Note:** Images are loaded from S3 bucket via `www.adgully.com`. This should NOT be changed.

| File | Configuration |
|------|---------------|
| `configs\nginx\archive2.adgully.com.conf` (Lines 40-51) | Proxy to `www.adgully.com` for `/img/` requests |
| Website config.php | `$config_image_host = "www.adgully.com";` |

---

## PART 5: SSH/SERVER ACCESS

| Setting | Value |
|---------|-------|
| Server IP | 31.97.233.171 |
| SSH User | root |
| SSH Password | z(P5ts@wdsESLUjMPVXs |
| SSH Port | 22 |

---

---

## PART 6: ACTUAL WEBSITE CODE (httpdocs folder)

**Source Location:** `D:\achive.adgully.com\archive.adgully.com\httpdocs`

### Main Config Files with Database Connections

#### 1. Root config.php (MAIN DATABASE CONFIG)
**File:** `D:\achive.adgully.com\archive.adgully.com\httpdocs\config.php`
**Lines:** 10-18

```php
if( $_SERVER['HTTP_HOST'] == "archive2.adgully.com" ){
    $config_db_user = "archive_user";
    $config_db_pass = "ArchiveUser@2026Secure";
    $config_db_db   = "archive_adgully";
    $config_db_host = "localhost";
    $config_image_host = "www.adgully.com";
    $config_s3_bucket_name = "adgully";
}
```

**To change domain from archive2 to archive:**
- Line 10: Change `"archive2.adgully.com"` to `"archive.adgully.com"`

---

#### 2. client_registration/config.php
**File:** `D:\achive.adgully.com\archive.adgully.com\httpdocs\client_registration\config.php`
**Lines:** 4, 15

- Line 4: Includes `../config.php` (inherits main DB settings)
- Line 15: Has additional mobexx database connection for `www.adgully.com`

**No changes needed** - inherits from root config.php

---

#### 3. manager/config.php
**File:** `D:\achive.adgully.com\archive.adgully.com\httpdocs\manager\config.php`
**Lines:** 5, 13

- Line 5: Includes `../config.php` (inherits main DB settings)
- Line 13: Uses inherited `$config_db_*` variables

**No changes needed** - inherits from root config.php

---

#### 4. cmo2023/php/config.php (NEEDS UPDATE)
**File:** `D:\achive.adgully.com\archive.adgully.com\httpdocs\cmo2023\php\config.php`
**Lines:** 8-15

```php
if( $_SERVER['HTTP_HOST'] == "www.adgully.com" ){
    $config_db_user     = "adgully";
    $config_db_pass     = "adgully";
    $config_db_db       = "adgully";
    $config_db_host     = "localhost";
    $config_image_host  = "www.adgully.com";
}
```

**To update for archive domain:**
- Line 8: Add condition for `"archive.adgully.com"` with new credentials

---

### Domain References in Website Code

| File | Line | Current Value | Change To |
|------|------|---------------|-----------|
| `config.php` | 10 | `archive2.adgully.com` | `archive.adgully.com` |
| `config_2.php` | 4 | `archive.adgully.com` | Already correct |
| `common_security.php` | 11 | `archive.adgully.com` | Already correct |
| `common_security.php` | 13 | `archive.adgully.com` | Already correct |
| `common_security_dos_blocker.php` | 132, 189 | `archive.adgully.com` | Already correct |

---

### All Config Files in httpdocs (Complete List)

| File Path | Purpose | DB Connection |
|-----------|---------|---------------|
| `/config.php` | **MAIN** - Primary database config | **YES - UPDATE** |
| `/config_2.php` | Alternative config (archive.adgully.com) | YES |
| `/client_registration/config.php` | Client registration module | Inherits from root |
| `/manager/config.php` | Manager module | Inherits from root |
| `/manager2/config.php` | Manager 2 module | Check separately |
| `/cmo2023/php/config.php` | CMO 2023 event | **YES - UPDATE** |
| `/cmo2023-kolkata/php/config.php` | CMO Kolkata event | Check separately |
| `/cmo2022/config.php` | CMO 2022 event | Check separately |
| `/event-calender/includes/config.php` | Event calendar | Check separately |
| `/admin/config_*.php` | Admin configs (no DB) | No |
| `/mail_config.php` | Email settings | No |
| `/webinar/configs.php` | Webinar module | Check separately |
| `/TalkWalker/configs.php` | TalkWalker integration | Check separately |

---

### S3 Bucket Configuration (In Website Code)

**File:** `config.php` (Lines 36-37)
```php
$s3_access_key = "AKIA5Y4PVZAPF3************";  // See SERVER_DETAILS.md for actual key
$s3_access_secret = "Need3DEtfCe0****************";  // See SERVER_DETAILS.md for actual secret
```

**Note:** S3 credentials should remain the same regardless of domain change.

---

## QUICK CHANGE SUMMARY

### Files to Change When Switching archive2 → archive

| Priority | File | Line | Change |
|----------|------|------|--------|
| **HIGH** | `httpdocs/config.php` | 10 | `archive2.adgully.com` → `archive.adgully.com` |
| **HIGH** | `configs/nginx/archive2.adgully.com.conf` | Multiple | Rename file & update all references |
| **HIGH** | `configs/nginx/pma.archive2.adgully.com.conf` | Multiple | Rename file & update all references |
| MEDIUM | `cmo2023/php/config.php` | 8 | Add archive.adgully.com condition |
| MEDIUM | Server directory | - | Rename `/var/www/archive2.adgully.com` |
| MEDIUM | SSL Certificates | - | Get new certs for archive.adgully.com |
| LOW | All PowerShell scripts | Various | Update domain references |
| LOW | Documentation files | Various | Update URLs |

---

*Document created: 2026-02-01*
*For archive.adgully.com migration project*
