# Archive2.adgully.com - Complete Migration Documentation

## Migration Status: ✅ COMPLETE
**Site Live at:** https://archive2.adgully.com/  
**Migration Date:** February 2, 2026  
**Database:** archive_adgully (113,111 posts, 610,788 action logs)

---

## Summary of Changes

### 1. **Database Setup** ✅
- **Database Name:** archive_adgully
- **User:** archive_user
- **Password:** ArchiveUser@2026Secure
- **Host:** localhost
- **Records:** 
  - 113,111 posts in `satish_posts`
  - 610,788 action logs in `actions_log`
  - 71 categories in `satish_category`
  - 96 tables total

### 2. **Core Configuration Files Modified**

#### A. `config.php` ✅
**Location:** `/var/www/archive2.adgully.com/config.php`

**Changes Made:**
```php
// Line 6: Domain check
if( $_SERVER['HTTP_HOST'] == "archive2.adgully.com" )

// Line 27-31: Database credentials
$config_db_user = "archive_user";
$config_db_pass = "ArchiveUser@2026Secure";
$config_db_db = "archive_adgully";
$config_db_host = "localhost";

// Line 121: Image host (S3 bucket)
$config_image_host = "www.adgully.com";
```

**Purpose:** Configure site for archive2 domain with correct database and image S3 bucket.

---

#### B. `control_rewrite.php` ✅ **CRITICAL FIX**
**Location:** `/var/www/archive2.adgully.com/control_rewrite.php`

**Problem:** URL parsing was off by one - leading `/` caused empty $page variable.

**Changes Made:**
```php
// Line 98: Added isset check for query parameter
$qstr = isset($parts['query']) ? explode( "&",$parts['query'] ) : array();

// Line 100-102: Added isset checks
if(isset($pps[0])) $_GET[ $pps[ 0 ] ] = isset($pps[1]) ? $pps[ 1 ] : '';
if(isset($pps[0])) $_REQUEST[ $pps[ 0 ] ] = isset($pps[1]) ? $pps[ 1 ] : '';

// Line 112-113: CRITICAL FIX - Remove leading slash before exploding
$path_clean = ltrim($parts['path'], '/');
$paths = explode( "/" , $path_clean );

// Line 115-127: Added isset checks for all path parameters
$page=isset($paths[0]) ? $paths[0] : '';
$param1=isset($paths[1]) ? trim($paths[1]) : '';
$param2=isset($paths[2]) ? trim($paths[2]) : '';
$param3=isset($paths[3]) ? trim($paths[3]) : '';
// ... etc for $param4 through $param9
```

**Impact:** 
- ✅ News article URLs working: `/havas-...-158207.html`
- ✅ Category pages working: `/category/marketing/talking-insights`
- ✅ All URL patterns now route correctly

---

#### C. `config_rewrites.php` ✅ **CRITICAL FIX**
**Location:** `/var/www/archive2.adgully.com/config_rewrites.php`

**Problem:** Rule 65 `/(.*?)/(.*?)\.html` was matching before rule 75 `/(.*?)-([0-9]+).html`

**Changes Made:**
```php
// Reordered rules - moved rule 75 BEFORE rule 65
"45" => array( "url" => "/videos/(.*?)", ... ),
"50" => array( "url" => "/(.*?)/(.*?)/(.*?)\.html", ... ),
"75" => array( "url" => "/(.*?)-([0-9]+).html", "map"=>"/news/news/$2", ... ), // MOVED UP
"65" => array( "url" => "/(.*?)/(.*?)\.html", ... ), // MOVED DOWN
```

**Impact:** News article IDs now extracted correctly from URLs.

---

#### D. `menu-items.php` ✅
**Location:** `/var/www/archive2.adgully.com/menu-items.php`

**Changes Made:** Replaced ALL 18 occurrences of `https://www.adgully.com/` with `/`

**Affected Links:**
- Talking Insights
- PR Conversation
- COVID-19 search
- Event Calendar
- Trending Now (2018-2022)
- Powerful Influencer (2019-2022)
- CMO events (2021-2023)
- International category
- SCREENXX Reviews

**Impact:** All menu links now stay within archive2.adgully.com domain.

---

#### E. `mobile-menu-items.php` ✅
**Location:** `/var/www/archive2.adgully.com/mobile-menu-items.php`

**Changes Made:** Replaced ALL 20+ occurrences of `https://www.adgully.com/` with `/`

**Impact:** Mobile menu links work correctly on archive2 domain.

---

### 3. **Nginx Configuration** ✅
**File:** `/etc/nginx/sites-available/archive2.adgully.com.conf`

**Key Settings:**
```nginx
server_name archive2.adgully.com;
root /var/www/archive2.adgully.com;

location / {
    try_files $uri $uri/ /index.php?request_url=$uri&$args;
}

location ~ \.php$ {
    fastcgi_pass unix:/run/php/php5.6-fpm.sock;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
}
```

**SSL:** Let's Encrypt certificates valid until April 2026

---

### 4. **MySQL Remote Access** ✅
**Configuration:** `/etc/mysql/mariadb.conf.d/50-server.cnf`

**Changes:**
```ini
bind-address = 0.0.0.0  # Allow remote connections
```

**Firewall:**
```bash
ufw allow 3306/tcp
```

**User Access:**
```sql
GRANT ALL PRIVILEGES ON archive_adgully.* TO 'archive_user'@'13.126.78.52' 
IDENTIFIED BY 'ArchiveUser@2026Secure';
```

**MySQL Workbench Connection:**
- Host: 31.97.233.171
- Port: 3306
- User: archive_user
- Password: ArchiveUser@2026Secure
- Database: archive_adgully

---

## Files Modified Summary

| File Path | Purpose | Status |
|-----------|---------|--------|
| `/var/www/archive2.adgully.com/config.php` | Domain & DB config | ✅ Updated |
| `/var/www/archive2.adgully.com/control_rewrite.php` | URL routing fix | ✅ Fixed |
| `/var/www/archive2.adgully.com/config_rewrites.php` | Rule ordering fix | ✅ Fixed |
| `/var/www/archive2.adgully.com/menu-items.php` | Desktop menu links | ✅ Updated |
| `/var/www/archive2.adgully.com/mobile-menu-items.php` | Mobile menu links | ✅ Updated |
| `/etc/nginx/sites-available/archive2.adgully.com.conf` | Web server config | ✅ Working |
| `/etc/mysql/mariadb.conf.d/50-server.cnf` | MySQL remote access | ✅ Enabled |

---

## Testing Results ✅

### URL Testing
- ✅ Homepage: https://archive2.adgully.com/
- ✅ News article: https://archive2.adgully.com/havas-has-made-a-good-start-says-yannick-bollor-as-q1-revenue-rises-5-2-158207.html
- ✅ Category page: https://archive2.adgully.com/category/marketing/talking-insights
- ✅ Image loading: S3 bucket at www.adgully.com working

### Database Verification
- ✅ 113,111 posts accessible
- ✅ Categories loading correctly
- ✅ Images from S3 displaying
- ✅ Remote MySQL access working

---

## Step-by-Step Guide: Creating archive3.adgully.com

### Prerequisites
- Server: Ubuntu 22.04 with Nginx + PHP 5.6 + MariaDB
- Domain: archive3.adgully.com pointed to server IP
- Source code: Copy from archive2.adgully.com

### Step 1: Database Setup

```bash
# Create database
mysql -u root -p
CREATE DATABASE archive_adgully3;
CREATE USER 'archive3_user'@'localhost' IDENTIFIED BY 'NewPassword2026';
GRANT ALL PRIVILEGES ON archive_adgully3.* TO 'archive3_user'@'localhost';
FLUSH PRIVILEGES;

# Import data
mysql -u archive3_user -p archive_adgully3 < /path/to/adgully_fixed.sql
mysql -u archive3_user -p archive_adgully3 < /path/to/action_log_fixed.sql
```

### Step 2: Copy Website Files

```bash
# Copy from archive2
cp -r /var/www/archive2.adgully.com /var/www/archive3.adgully.com
cd /var/www/archive3.adgully.com
chown -R www-data:www-data .
```

### Step 3: Update config.php

**File:** `/var/www/archive3.adgully.com/config.php`

```php
// Line 6: Change domain
if( $_SERVER['HTTP_HOST'] == "archive3.adgully.com" )

// Lines 27-31: Update database credentials
$config_db_user = "archive3_user";
$config_db_pass = "NewPassword2026";
$config_db_db = "archive_adgully3";
$config_db_host = "localhost";

// Line 121: S3 bucket remains same
$config_image_host = "www.adgully.com";  // No change needed
```

### Step 4: Nginx Configuration

**File:** `/etc/nginx/sites-available/archive3.adgully.com.conf`

```nginx
server {
    listen 80;
    server_name archive3.adgully.com;
    root /var/www/archive3.adgully.com;
    index index.php index.html;

    # SSL configuration (after Let's Encrypt setup)
    listen 443 ssl http2;
    ssl_certificate /etc/letsencrypt/live/archive3.adgully.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/archive3.adgully.com/privkey.pem;

    location / {
        try_files $uri $uri/ /index.php?request_url=$uri&$args;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php5.6-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

**Enable site:**
```bash
ln -s /etc/nginx/sites-available/archive3.adgully.com.conf /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### Step 5: SSL Certificate

```bash
# Install Let's Encrypt
certbot --nginx -d archive3.adgully.com
```

### Step 6: Verify All Files

**✅ Files that DO NOT need changes:**
- `control_rewrite.php` ✅ (already fixed)
- `config_rewrites.php` ✅ (already fixed)
- `menu-items.php` ✅ (uses relative paths)
- `mobile-menu-items.php` ✅ (uses relative paths)
- All other `.php` files ✅

**🔧 Files that MUST be changed:**
1. `config.php` - Domain and database credentials only

### Step 7: Testing Checklist

```bash
# Test homepage
curl -I https://archive3.adgully.com/

# Test news article URL
curl -I https://archive3.adgully.com/havas-has-made-a-good-start-says-yannick-bollor-as-q1-revenue-rises-5-2-158207.html

# Test category page
curl -I https://archive3.adgully.com/category/marketing/talking-insights

# Check database connection
mysql -u archive3_user -p archive_adgully3 -e "SELECT COUNT(*) FROM satish_posts;"

# Check menu links
curl -s https://archive3.adgully.com/ | grep -c '/category/marketing/talking-insights'
```

---

## Quick Reference: One File to Change

### For any archiveN.adgully.com:

**ONLY MODIFY:** `/var/www/archiveN.adgully.com/config.php`

**Lines to change:**
1. **Line 6:** `if( $_SERVER['HTTP_HOST'] == "archiveN.adgully.com" )`
2. **Line 27:** `$config_db_user = "archiveN_user";`
3. **Line 28:** `$config_db_pass = "YourNewPassword";`
4. **Line 29:** `$config_db_db = "archive_adgullyN";`

**Everything else works automatically due to:**
- Relative paths in menu files (no domain hardcoding)
- Fixed URL routing in control_rewrite.php
- Nginx passes request_url correctly
- S3 images use shared www.adgully.com bucket

---

## Backup Files

**Server Backups:**
- `/var/www/archive2.adgully.com/index.php.backup` - Original index.php
- SQL dumps stored in `/root/backups/`

**Local Backups:**
- `d:\archive.adgully.com\backups\` - Database dumps
- `d:\achive.adgully.com\archive.adgully.com\httpdocs\` - Source code

---

## Troubleshooting

### Issue: URLs return 404
**Solution:** Check control_rewrite.php has the ltrim() fix on line 112-113

### Issue: Category pages show wrong layout
**Solution:** Verify config_rewrites.php has rule 75 BEFORE rule 65

### Issue: Menu links redirect to www.adgully.com
**Solution:** Check menu-items.php and mobile-menu-items.php use `/` not `https://www.adgully.com/`

### Issue: Images not loading
**Solution:** Verify config.php line 121 has `$config_image_host = "www.adgully.com";`

### Issue: Database connection errors
**Solution:** Check config.php database credentials match MySQL user

---

## Server Credentials

**SSH Access:**
- Host: 31.97.233.171
- User: root
- Password: z(P5ts@wdsESLUjMPVXs

**MySQL Root:**
- User: root
- Password: Admin@2026MsIhJgArhSg8x

**Archive2 Database:**
- User: archive_user
- Password: ArchiveUser@2026Secure
- Database: archive_adgully

---

## Important Notes

1. **PHP 5.6** - Site uses legacy PHP 5.6 for compatibility
2. **S3 Images** - All images served from www.adgully.com S3 bucket (shared across all archive sites)
3. **Relative Paths** - Menu files use relative paths, work on any domain
4. **URL Routing** - control_rewrite.php fix is critical for all URL types
5. **Rule Order** - config_rewrites.php rule ordering affects URL matching

---

## Migration Complete! 🎉

Archive2.adgully.com is now fully operational with:
- ✅ 113,111 articles accessible
- ✅ All URL types working (news, category, etc.)
- ✅ Menu navigation corrected
- ✅ Images loading from S3
- ✅ Database remote access enabled
- ✅ SSL certificate valid

**Ready for archive3, archive4, etc. - Just update config.php!**
