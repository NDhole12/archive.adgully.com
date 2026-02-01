# Archive Migration - Quick Reference

## ✅ What Was Done

### 1. Fixed URL Routing Issues
- **File:** `control_rewrite.php`
- **Problem:** Leading `/` in URLs caused array offset errors
- **Fix:** Added `ltrim($parts['path'], '/')` to remove leading slash before parsing
- **Impact:** All URLs now work (news articles, categories, etc.)

### 2. Fixed News Article URL Matching
- **File:** `config_rewrites.php`
- **Problem:** Rule 65 matched before Rule 75, breaking article ID extraction
- **Fix:** Reordered rules - moved rule 75 before rule 65
- **Impact:** Article URLs like `/havas-...-158207.html` now work

### 3. Updated Menu Links
- **Files:** `menu-items.php`, `mobile-menu-items.php`
- **Problem:** Hardcoded `https://www.adgully.com/` links
- **Fix:** Replaced with relative paths `/`
- **Impact:** 38+ menu links now work on archive2.adgully.com

### 4. Configured Database
- **File:** `config.php`
- **Changes:** 
  - Domain: `archive2.adgully.com`
  - Database: `archive_adgully`
  - User: `archive_user`
  - Image host: `www.adgully.com` (S3 bucket)

---

## 🚀 Creating archive3.adgully.com (or any new archive site)

### Only 1 File Needs Changes!

**File:** `/var/www/archive3.adgully.com/config.php`

**Line 6:**
```php
if( $_SERVER['HTTP_HOST'] == "archive3.adgully.com" )  // Change domain
```

**Lines 27-31:**
```php
$config_db_user = "archive3_user";              // Change user
$config_db_pass = "YourNewPassword";            // Change password
$config_db_db = "archive_adgully3";             // Change database name
$config_db_host = "localhost";                  // Keep same
```

**Line 121:**
```php
$config_image_host = "www.adgully.com";  // DO NOT CHANGE (shared S3 bucket)
```

### That's It! 🎉

All other files work automatically because:
- Menu files use relative paths (no domain hardcoding)
- URL routing is fixed in `control_rewrite.php`
- Nginx configuration works with any domain
- Images served from shared S3 bucket

---

## 📋 Files Modified (archive2.adgully.com)

| File | What Changed | Why |
|------|-------------|-----|
| `config.php` | Domain & DB credentials | Site-specific config |
| `control_rewrite.php` | URL parsing logic | Fix routing bug |
| `config_rewrites.php` | Rule order | Fix article URLs |
| `menu-items.php` | 18 URLs → relative paths | Menu navigation |
| `mobile-menu-items.php` | 20+ URLs → relative paths | Mobile menu |

---

## 🗑️ Cleanup Done

### Removed from Local:
- `debug_category.php`
- `test_rewrite.php`
- `test_params.php`
- `index_debug.php`
- `index_debug2.php`

### Removed from Server:
- `debug_158207.php`
- `debug_log.php`
- `debug_rewrite.php`
- `simple_test.php`
- `test_debug.php`
- `test_params.php`
- All `/tmp/*.log` files

---

## ✅ Current Status

**Archive2.adgully.com:**
- ✅ 113,111 articles accessible
- ✅ All URL types working
- ✅ Menu links corrected
- ✅ Images loading from S3
- ✅ Database: archive_adgully
- ✅ SSL: Valid until April 2026

**Ready for clone to archive3, archive4, etc.**

---

## 📞 Quick Support

**Issue: URLs not working**
→ Check `control_rewrite.php` has ltrim() fix (line 112)

**Issue: Category pages wrong layout**
→ Check `config_rewrites.php` rule order (75 before 65)

**Issue: Menu redirects to www.adgully.com**
→ Check menu files use `/` not full URLs

**Issue: New site setup**
→ Only edit `config.php` (4 lines)

---

**Documentation:** See `MIGRATION_COMPLETE_DOCUMENTATION.md` for full details
