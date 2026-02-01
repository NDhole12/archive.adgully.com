# URL Rerouting Logic Documentation
## Archive.adgully.com - Complete URL Routing System

**Purpose:** Detailed documentation of how URL routing and rewriting works in the archive.adgully.com system

**Last Updated:** February 2, 2026

---

## 📚 TABLE OF CONTENTS

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [File Structure](#file-structure)
4. [URL Parsing Flow](#url-parsing-flow)
5. [Rewrite Rules](#rewrite-rules)
6. [Critical Fixes](#critical-fixes)
7. [Testing & Debugging](#testing--debugging)
8. [Domain Independence](#domain-independence)
9. [Troubleshooting](#troubleshooting)

---

## 📖 OVERVIEW

The archive.adgully.com site uses a **custom PHP-based URL routing system** instead of Apache's .htaccess or Nginx's built-in rewrite rules. This gives more flexibility but requires understanding how the system works.

### Key Characteristics

- **Entry Point:** All requests go through `index.php`
- **Routing Engine:** `control_rewrite.php` handles URL parsing
- **Rule Definition:** `config_rewrites.php` defines URL patterns
- **Domain Independent:** Routing logic works with any domain
- **Parameter Extraction:** URLs parsed into `$page`, `$param1`, `$param2`, etc.

### Why Custom Routing?

1. **Legacy System:** Migrated from old CMS with specific URL structure
2. **Complex Rules:** Need granular control over URL matching
3. **SEO Preservation:** Maintain old URLs for search engine rankings
4. **Multi-site Support:** Same codebase can serve multiple domains

---

## 🏗️ SYSTEM ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER REQUEST                              │
│   https://archive.adgully.com/havas-media-group-158207.html     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                         NGINX                                    │
│   - Receives request                                             │
│   - Serves static files (CSS, JS, images) directly              │
│   - Passes dynamic requests to PHP-FPM                           │
│   - Sets $_SERVER['REQUEST_URI'] = "/havas-media-group-158207.html"│
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       PHP-FPM (5.6)                              │
│   - Executes index.php                                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        index.php                                 │
│   - Entry point for all requests                                │
│   - Includes control_rewrite.php                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    control_rewrite.php                           │
│   1. Parse $_SERVER['REQUEST_URI']                              │
│   2. Load config_rewrites.php (rules)                            │
│   3. Match URI against rules                                     │
│   4. Extract parameters ($1, $2, etc.)                           │
│   5. Map to internal path                                        │
│   6. Set $page, $param1, $param2, etc.                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Page File (e.g., news/news.php)            │
│   - Receives $page, $param1, $param2, etc.                      │
│   - Queries database using parameters                            │
│   - Renders HTML output                                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      OUTPUT TO BROWSER                           │
│   - HTML page with article content                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 FILE STRUCTURE

### Core Routing Files

| File | Location | Purpose | Changes for Domain Migration |
|------|----------|---------|------------------------------|
| `index.php` | `/var/www/[DOMAIN]/` | Entry point, includes control_rewrite.php | None |
| `control_rewrite.php` | `/var/www/[DOMAIN]/` | URL parsing and routing engine | None |
| `config_rewrites.php` | `/var/www/[DOMAIN]/` | URL pattern definitions | None |
| `config.php` | `/var/www/[DOMAIN]/` | Database config (domain-specific) | **YES - Update HTTP_HOST check** |

### Page Files (Destination of Routes)

| File | Purpose | Accessed When |
|------|---------|---------------|
| `news/news.php` | Display single news article | URL matches pattern: `/(.*?)-([0-9]+).html` |
| `category/category.php` | Display category listing | URL starts with `/category/` |
| `videos/videos.php` | Display video gallery | URL starts with `/videos/` |
| `gallery/gallery.php` | Display photo gallery | URL starts with `/gallery/` |
| `search/search.php` | Display search results | URL starts with `/search/` |

---

## 🔄 URL PARSING FLOW

### Step-by-Step Breakdown

Let's trace how this URL is processed:

**Input URL:** `https://archive.adgully.com/havas-media-group-bags-mandate-158207.html`

#### Step 1: Nginx Processing
```nginx
# Nginx config: /etc/nginx/sites-available/archive.adgully.com.conf

location / {
    try_files $uri $uri/ /index.php?request_url=$uri&$args;
}

# Nginx checks:
# 1. Does /havas-media-group-bags-mandate-158207.html exist as file? NO
# 2. Does /havas-media-group-bags-mandate-158207.html/ exist as directory? NO
# 3. Pass to /index.php with request_url=/havas-media-group-bags-mandate-158207.html
```

**Result:** PHP receives `$_GET['request_url'] = "/havas-media-group-bags-mandate-158207.html"`

---

#### Step 2: index.php
```php
<?php
// index.php is minimal, just includes the routing engine
include('control_rewrite.php');
?>
```

**Result:** control_rewrite.php takes over

---

#### Step 3: control_rewrite.php - Initial Parsing

**File:** `control_rewrite.php` (Lines 1-20)

```php
<?php
// Get the requested URL from Nginx
$request_uri = $_REQUEST['request_url'];
// Result: $request_uri = "/havas-media-group-bags-mandate-158207.html"

// Parse the URL into components
$parts = parse_url( $_SERVER['REQUEST_URI'] );
// Result: 
// $parts['path'] = "/havas-media-group-bags-mandate-158207.html"
// $parts['query'] = null (no query string in this example)

// Clean up the path - REMOVE LEADING SLASH (CRITICAL FIX!)
$path_clean = ltrim($parts['path'], '/');
// Result: $path_clean = "havas-media-group-bags-mandate-158207.html"

// Split path into segments
$paths = explode( "/" , $path_clean );
// Result: $paths[0] = "havas-media-group-bags-mandate-158207.html"
?>
```

**Why ltrim() is critical:**
```php
// WITHOUT ltrim (BROKEN):
$parts['path'] = "/havas-media-group-bags-mandate-158207.html"
$paths = explode("/", $parts['path'])
// Result: $paths[0] = "" (empty!), $paths[1] = "havas-media-group-bags-mandate-158207.html"

// WITH ltrim (FIXED):
$path_clean = "havas-media-group-bags-mandate-158207.html"
$paths = explode("/", $path_clean)
// Result: $paths[0] = "havas-media-group-bags-mandate-158207.html"
```

---

#### Step 4: Load Rewrite Rules

**File:** `config_rewrites.php`

```php
<?php
$rewriterules = array(
    "45" => array( 
        "url" => "/videos/(.*?)", 
        "map" => "/videos/videos/$1",
        "rule" => "rewrite"
    ),
    "50" => array( 
        "url" => "/(.*?)/(.*?)/(.*?)\.html", 
        "map" => "/news/$1-$2/old/$3",
        "rule" => "rewrite"
    ),
    "75" => array( 
        "url" => "/(.*?)-([0-9]+).html",
        "map" => "/news/news/$2",
        "rule" => "rewrite"
    ),
    "65" => array( 
        "url" => "/(.*?)/(.*?)\.html", 
        "map" => "/news/$1/old/$2",
        "rule" => "rewrite"
    ),
);
?>
```

**Rule Matching Order:**
1. Try rule 45 (videos)
2. Try rule 50 (three-part URLs)
3. Try rule 75 (article with ID) - **MATCHES!**
4. Try rule 65 (two-part URLs) - never reached

---

#### Step 5: Match Against Rules

**File:** `control_rewrite.php` (Lines 30-70)

```php
<?php
foreach( $rewriterules as $rvprio => $dos ){
    $rvurl  = $dos['url'];    // Pattern to match
    $rvmap  = $dos['map'];    // Destination to map to
    $rvrule = $dos['rule'];   // Action (rewrite, r301, etc.)
    
    // Prepare pattern for regex matching
    $rvurl = substr( $rvurl, 1, strlen( $rvurl ) ); // Remove leading /
    $rvurl = str_replace("/", "\/", $rvurl );       // Escape slashes
    
    // Test if pattern matches the request URI
    $matched = preg_match( "/^" . $rvurl . "$/" , $request_uri , $matches  );
    
    if( $matched ){
        // Extract captured groups
        $rvmap = str_replace( "\$1", $matches[1], $rvmap );
        $rvmap = str_replace( "\$2", $matches[2], $rvmap );
        // ... etc for $3 through $9
        
        // Update request URI to the mapped value
        $request_uri = $rvmap;
        break; // Stop matching
    }
}
?>
```

**For our example:**

```php
// Testing rule 75: /(.*?)-([0-9]+).html
// Input: "havas-media-group-bags-mandate-158207.html"
// Pattern: (.*?)-([0-9]+).html

preg_match("/^(.*?)-([0-9]+)\.html$/", "havas-media-group-bags-mandate-158207.html", $matches);

// Result: MATCH!
// $matches[0] = "havas-media-group-bags-mandate-158207.html" (full match)
// $matches[1] = "havas-media-group-bags-mandate" (first capture group)
// $matches[2] = "158207" (second capture group)

// Apply mapping: "/news/news/$2"
$rvmap = "/news/news/158207"

// Update request URI
$request_uri = "/news/news/158207"
```

---

#### Step 6: Extract Page and Parameters

**File:** `control_rewrite.php` (Lines 110-127)

```php
<?php
// Parse the mapped URI
$parts = parse_url( $request_uri );
// Result: $parts['path'] = "/news/news/158207"

// Clean and split
$path_clean = ltrim($parts['path'], '/');
// Result: $path_clean = "news/news/158207"

$paths = explode( "/" , $path_clean );
// Result: 
// $paths[0] = "news"
// $paths[1] = "news"
// $paths[2] = "158207"

// Extract page and parameters
$page = isset($paths[0]) ? $paths[0] : '';
// Result: $page = "news"

$param1 = isset($paths[1]) ? trim($paths[1]) : '';
// Result: $param1 = "news"

$param2 = isset($paths[2]) ? trim($paths[2]) : '';
// Result: $param2 = "158207"

$param3 = isset($paths[3]) ? trim($paths[3]) : '';
// Result: $param3 = ""

// ... $param4 through $param9 (all empty)
?>
```

---

#### Step 7: Include Page File

**File:** `index.php` (after control_rewrite.php returns)

```php
<?php
// Now $page = "news", $param1 = "news", $param2 = "158207"

// index.php includes the appropriate page file
if( $page == "news" ){
    include("news/news.php");
}
?>
```

---

#### Step 8: Page File Processes Request

**File:** `news/news.php`

```php
<?php
// Receives: $param1 = "news", $param2 = "158207"

// Query database for post with ID 158207
$sql = "SELECT * FROM satish_posts WHERE post_id = " . intval($param2);
$result = mysqli_query($conn, $sql);
$article = mysqli_fetch_assoc($result);

// Display article
echo "<h1>" . $article['post_title'] . "</h1>";
echo "<div>" . $article['post_content'] . "</div>";
?>
```

**Result:** Article with ID 158207 displayed to user

---

## 🎯 REWRITE RULES

### Rule Structure

Each rule in `config_rewrites.php` has this structure:

```php
"PRIORITY" => array(
    "url"  => "/PATTERN",      // URL pattern to match (regex)
    "map"  => "/DESTINATION",  // Where to map the URL
    "rule" => "ACTION",        // What action to take (rewrite, r301, end)
    "case" => "y/n",           // Case-sensitive? (y=case-insensitive)
    "que"  => "y/n",           // Preserve query string?
    "page" => "PAGE_TYPE",     // Page type (for reference)
    "s"    => SCORE            // Score (unused, legacy)
)
```

---

### Active Rules

#### Rule 1: Case Study Redirect
```php
"1" => array( 
    "url" => "/case-studies-wat-consult(.*?)", 
    "map" => "/case-studies/", 
    "rule" => "r301"
)
```

**Purpose:** Redirect old case study URLs to new location  
**Action:** 301 Permanent Redirect  
**Example:** `/case-studies-wat-consult-old` → `/case-studies/`

---

#### Rule 9: Gallery Category
```php
"9" => array( 
    "url" => "/gallery/([a-zA-Z]+)", 
    "map" => "/gallery/?show=$1", 
    "rule" => "rewrite"
)
```

**Purpose:** Gallery category pages  
**Action:** Internal rewrite  
**Example:** `/gallery/events` → `/gallery/?show=events`

---

#### Rule 10: Gallery Photo
```php
"10" => array( 
    "url" => "/gallery/(.*?)\-([0-9]+)\.html", 
    "map" => "/gallery/$2", 
    "rule" => "rewrite"
)
```

**Purpose:** Individual gallery photos  
**Action:** Internal rewrite  
**Example:** `/gallery/award-show-2024-12345.html` → `/gallery/12345`

---

#### Rule 45: Videos
```php
"45" => array( 
    "url" => "/videos/(.*?)", 
    "map" => "/videos/videos/$1", 
    "rule" => "rewrite"
)
```

**Purpose:** Video pages  
**Action:** Internal rewrite  
**Example:** `/videos/interview-ceo` → `/videos/videos/interview-ceo`

---

#### Rule 50: Three-Part Article URLs
```php
"50" => array( 
    "url" => "/(.*?)/(.*?)/(.*?)\.html", 
    "map" => "/news/$1-$2/old/$3", 
    "rule" => "rewrite"
)
```

**Purpose:** Old URL format with three parts  
**Action:** Internal rewrite  
**Example:** `/category/marketing/article-name.html` → `/news/category-marketing/old/article-name`

---

#### Rule 75: Article with ID (MOST IMPORTANT)
```php
"75" => array( 
    "url" => "/(.*?)-([0-9]+).html", 
    "map" => "/news/news/$2", 
    "rule" => "rewrite"
)
```

**Purpose:** Current article URL format  
**Action:** Internal rewrite  
**Example:** `/havas-media-group-158207.html` → `/news/news/158207`

**Why this is most important:**
- Handles 95% of article URLs
- Extracts article ID for database lookup
- MUST come before rule 65 (more specific pattern)

---

#### Rule 65: Two-Part HTML URLs
```php
"65" => array( 
    "url" => "/(.*?)/(.*?)\.html", 
    "map" => "/news/$1/old/$2", 
    "rule" => "rewrite"
)
```

**Purpose:** Legacy two-part URLs  
**Action:** Internal rewrite  
**Example:** `/category/article-name.html` → `/news/category/old/article-name`

**Why this comes after rule 75:**
- More general pattern
- Would match `/article-123.html` incorrectly as `/article/123`
- Rule 75 needs first chance to match

---

### Rule Priority Matters!

**WRONG ORDER (BROKEN):**
```php
$rewriterules = array(
    "65" => array( "url" => "/(.*?)/(.*?)\.html", ... ),  // TOO GENERAL
    "75" => array( "url" => "/(.*?)-([0-9]+).html", ... ), // NEVER REACHED
);

// Testing URL: /havas-media-group-158207.html
// Rule 65 matches: /(.*?)/(.*?)\.html
// Captures: $1="havas-media-group", $2="158207"
// Maps to: /news/havas-media-group/old/158207
// WRONG! ID not extracted correctly
```

**CORRECT ORDER (FIXED):**
```php
$rewriterules = array(
    "75" => array( "url" => "/(.*?)-([0-9]+).html", ... ), // SPECIFIC FIRST
    "65" => array( "url" => "/(.*?)/(.*?)\.html", ... ),  // GENERAL SECOND
);

// Testing URL: /havas-media-group-158207.html
// Rule 75 matches first: /(.*?)-([0-9]+).html
// Captures: $1="havas-media-group-", $2="158207"
// Maps to: /news/news/158207
// CORRECT! ID extracted properly
```

---

## 🔧 CRITICAL FIXES

### Fix 1: Leading Slash Removal

**File:** `control_rewrite.php`  
**Lines:** 112-113

**Problem:**
```php
// BEFORE (BROKEN)
$parts = parse_url( $_SERVER['REQUEST_URI'] );
$paths = explode( "/" , $parts['path'] );

// For URL: /havas-media-group-158207.html
// $parts['path'] = "/havas-media-group-158207.html"
// $paths = ["", "havas-media-group-158207.html"]
//           ^^^ EMPTY STRING!
// $page = $paths[0] = "" (WRONG!)
```

**Solution:**
```php
// AFTER (FIXED)
$parts = parse_url( $_SERVER['REQUEST_URI'] );
$path_clean = ltrim($parts['path'], '/');  // REMOVE LEADING SLASH
$paths = explode( "/" , $path_clean );

// For URL: /havas-media-group-158207.html
// $parts['path'] = "/havas-media-group-158207.html"
// $path_clean = "havas-media-group-158207.html"
// $paths = ["havas-media-group-158207.html"]
// $page = $paths[0] = "havas-media-group-158207.html" (CORRECT!)
```

**Impact:**
- Without fix: $page is empty, nothing matches
- With fix: $page has value, matches rewrite rules
- **Critical for all URLs to work**

---

### Fix 2: isset() Checks

**File:** `control_rewrite.php`  
**Lines:** 98, 100-102, 115-127

**Problem:**
```php
// BEFORE (BROKEN)
$qstr = explode( "&",$parts['query'] );
// PHP Notice: Undefined index: query
```

**Solution:**
```php
// AFTER (FIXED)
$qstr = isset($parts['query']) ? explode( "&",$parts['query'] ) : array();
```

**All isset() checks added:**
```php
// Line 98: Query string
$qstr = isset($parts['query']) ? explode( "&",$parts['query'] ) : array();

// Lines 100-102: GET/REQUEST parameters
if(isset($pps[0])) $_GET[ $pps[ 0 ] ] = isset($pps[1]) ? $pps[ 1 ] : '';
if(isset($pps[0])) $_REQUEST[ $pps[ 0 ] ] = isset($pps[1]) ? $pps[ 1 ] : '';

// Lines 115-127: All page parameters
$page = isset($paths[0]) ? $paths[0] : '';
$param1 = isset($paths[1]) ? trim($paths[1]) : '';
$param2 = isset($paths[2]) ? trim($paths[2]) : '';
// ... through $param9
```

**Impact:**
- Prevents PHP notices/warnings
- Handles URLs without query strings
- Handles URLs with fewer path segments

---

### Fix 3: Rule Reordering

**File:** `config_rewrites.php`

**Problem:**
```php
// BEFORE (BROKEN)
$rewriterules = array(
    "65" => array( "url" => "/(.*?)/(.*?)\.html", ... ),
    "75" => array( "url" => "/(.*?)-([0-9]+).html", ... ),
);
```

**Solution:**
```php
// AFTER (FIXED)
$rewriterules = array(
    "75" => array( "url" => "/(.*?)-([0-9]+).html", ... ),
    "65" => array( "url" => "/(.*?)/(.*?)\.html", ... ),
);
```

**Why this matters:**
| URL | Rule 65 First (WRONG) | Rule 75 First (CORRECT) |
|-----|----------------------|------------------------|
| `/article-123.html` | Matches 65: `/article/123` | Matches 75: `/news/news/123` |
| `/cat/article.html` | Matches 65: `/news/cat/old/article` | Doesn't match 75, matches 65: `/news/cat/old/article` |

---

## 🧪 TESTING & DEBUGGING

### Enable Debug Mode

**File:** `control_rewrite.php` (add after line 110)

```php
// ENABLE DEBUG (TEMPORARY!)
error_log("=== URL PARSING DEBUG ===");
error_log("REQUEST_URI: " . $_SERVER['REQUEST_URI']);
error_log("path: " . $parts['path']);
error_log("path_clean: " . $path_clean);
error_log("page: " . $page);
error_log("param1: " . $param1);
error_log("param2: " . $param2);
error_log("===========================");
```

**View debug output:**
```bash
# On server
tail -f /var/log/nginx/archive.adgully.com_error.log

# Will show:
# === URL PARSING DEBUG ===
# REQUEST_URI: /havas-media-group-158207.html
# path: /havas-media-group-158207.html
# path_clean: havas-media-group-158207.html
# page: news
# param1: news
# param2: 158207
# ===========================
```

---

### Test Individual Rules

**Create test file:** `/var/www/archive.adgully.com/test-routing.php`

```php
<?php
// Test URL matching
$test_urls = array(
    "/havas-media-group-158207.html",
    "/category/marketing",
    "/videos/ceo-interview",
    "/gallery/events-2024.html",
);

include('config_rewrites.php');

foreach($test_urls as $test_url){
    echo "<h3>Testing: $test_url</h3>";
    
    foreach($rewriterules as $rule_id => $rule){
        $pattern = $rule['url'];
        $pattern = substr($pattern, 1, strlen($pattern));
        $pattern = str_replace("/", "\/", $pattern);
        
        if(preg_match("/^" . $pattern . "$/", $test_url, $matches)){
            echo "MATCHED Rule $rule_id<br>";
            echo "Pattern: {$rule['url']}<br>";
            echo "Map to: {$rule['map']}<br>";
            echo "Captures: ";
            print_r($matches);
            echo "<br><br>";
            break;
        }
    }
}
?>
```

**Access:** `https://archive.adgully.com/test-routing.php`

**Expected output:**
```
Testing: /havas-media-group-158207.html
MATCHED Rule 75
Pattern: /(.*?)-([0-9]+).html
Map to: /news/news/$2
Captures: Array([0]=>/havas-media-group-158207.html [1]=>havas-media-group- [2]=>158207)

Testing: /category/marketing
No match (handled by index.php directly)

Testing: /videos/ceo-interview
MATCHED Rule 45
Pattern: /videos/(.*?)
Map to: /videos/videos/$1
Captures: Array([0]=>/videos/ceo-interview [1]=>ceo-interview)
```

---

## 🌐 DOMAIN INDEPENDENCE

### Why Routing is Domain-Independent

The routing system uses **relative URLs** and **server variables**, not hardcoded domains:

```php
// ✅ DOMAIN-INDEPENDENT (used in control_rewrite.php)
$request_uri = $_SERVER['REQUEST_URI'];
$parts = parse_url( $_SERVER['REQUEST_URI'] );

// ❌ DOMAIN-DEPENDENT (NOT used in routing)
if( strpos($request_uri, "archive2.adgully.com") !== false ){
    // This would break on domain change
}
```

### Files That ARE Domain-Dependent

**Only these files need updates for domain migration:**

1. **config.php** - Database connection based on domain
```php
if( $_SERVER['HTTP_HOST'] == "archive.adgully.com" ){
    $config_db_db = "archive_adgully"; // Production DB
} else {
    $config_db_db = "adgully_test";   // Test DB
}
```

2. **menu-items.php** - Hardcoded menu URLs
```php
<a href="https://archive.adgully.com/category/marketing">Marketing</a>
```

3. **mobile-menu-items.php** - Hardcoded mobile menu URLs
```php
<a href="https://archive.adgully.com/category/television">Television</a>
```

### Files That Are Domain-Independent

**These files work with ANY domain - DO NOT change:**

- control_rewrite.php
- config_rewrites.php
- index.php
- news/news.php
- category/category.php
- videos/videos.php
- All block_*.php files (use relative paths)

---

## 🔍 TROUBLESHOOTING

### Issue 1: All URLs Show 404

**Symptoms:**
- Homepage loads
- All other URLs show 404

**Diagnosis:**
```bash
# Check nginx configuration
nginx -t

# Check if PHP-FPM is running
systemctl status php5.6-fpm

# Check error logs
tail -f /var/log/nginx/archive.adgully.com_error.log
```

**Common causes:**
1. Nginx not passing to PHP-FPM
2. index.php not being executed
3. control_rewrite.php has syntax error

**Fix:**
```bash
# Restart services
systemctl restart php5.6-fpm
systemctl restart nginx

# Test PHP
echo "<?php phpinfo(); ?>" > /var/www/archive.adgully.com/test.php
# Visit: https://archive.adgully.com/test.php
# Should show PHP info
```

---

### Issue 2: News Articles Show 404

**Symptoms:**
- Homepage loads
- Category pages load
- News article URLs show 404

**Diagnosis:**
```php
// Add debug to control_rewrite.php after line 112
error_log("DEBUG page: " . $page);
error_log("DEBUG param1: " . $param1);
error_log("DEBUG param2: " . $param2);

// Check error log
tail -f /var/log/nginx/archive.adgully.com_error.log
```

**Common causes:**
1. Leading slash not removed (missing ltrim fix)
2. Rule order wrong (rule 65 before rule 75)
3. news/news.php file missing or has errors

**Fix:**
```bash
# Verify ltrim fix exists
grep -n "ltrim" /var/www/archive.adgully.com/control_rewrite.php
# Should show line 112: $path_clean = ltrim($parts['path'], '/');

# Verify rule order
grep -n '"75"' /var/www/archive.adgully.com/config_rewrites.php
grep -n '"65"' /var/www/archive.adgully.com/config_rewrites.php
# Rule 75 line number should be LESS than rule 65 line number

# Test news.php directly
# Visit: https://archive.adgully.com/news/news.php?param2=158207
# Should show article
```

---

### Issue 3: Wrong Article Displays

**Symptoms:**
- Article URL loads
- But shows different article or 404

**Diagnosis:**
```php
// In news/news.php, add debug at top:
error_log("NEWS DEBUG param1: " . $param1);
error_log("NEWS DEBUG param2: " . $param2);

// Check what ID is being queried
```

**Common causes:**
1. Rule matching wrong pattern
2. Parameter extraction incorrect
3. Database query using wrong parameter

**Fix:**
```php
// Verify param2 has the article ID
// In news/news.php:
$article_id = intval($param2); // Should be 158207
error_log("Querying article ID: " . $article_id);
```

---

### Issue 4: Rewrite Rules Not Applied

**Symptoms:**
- URLs not being rewritten
- Raw URLs visible in address bar

**Diagnosis:**
```php
// In control_rewrite.php, add debug in foreach loop:
error_log("Testing rule " . $rvprio . ": " . $rvurl);
error_log("Against: " . $request_uri);
error_log("Matched: " . ($matched ? "YES" : "NO"));
```

**Common causes:**
1. config_rewrites.php not loaded
2. Regex pattern incorrect
3. Breaking out of loop too early

**Fix:**
```php
// Verify config_rewrites.php loaded
include('config_rewrites.php');
error_log("Loaded " . count($rewriterules) . " rules");

// Should show: Loaded 6 rules
```

---

### Issue 5: Infinite Redirect Loop

**Symptoms:**
- Browser shows "Too many redirects"
- Page never loads

**Diagnosis:**
```bash
# Check for redirect rules
grep "r301" /var/www/archive.adgully.com/config_rewrites.php

# Check error log for redirect chain
tail -f /var/log/nginx/archive.adgully.com_error.log
```

**Common causes:**
1. Rule redirects to itself
2. Rule redirects to another rule that redirects back
3. Nginx and PHP both redirecting

**Fix:**
```php
// In config_rewrites.php, review r301 rules:
"1" => array( 
    "url" => "/case-studies-wat-consult(.*?)", 
    "map" => "/case-studies/",  // Make sure this doesn't match rule 1 again
    "rule" => "r301"
),
```

---

## 📚 APPENDIX

### URL Examples

| URL Type | Example | Rule | Map To | Page | Param1 | Param2 |
|----------|---------|------|--------|------|--------|--------|
| News article | `/havas-media-group-158207.html` | 75 | `/news/news/158207` | news | news | 158207 |
| Category | `/category/marketing` | none | `/category/marketing` | category | marketing | |
| Videos | `/videos/ceo-interview` | 45 | `/videos/videos/ceo-interview` | videos | videos | ceo-interview |
| Gallery | `/gallery/events-2024-12345.html` | 10 | `/gallery/12345` | gallery | 12345 | |
| Search | `/search/?q=havas` | none | `/search/?q=havas` | search | | |

---

### Regex Patterns Explained

| Pattern | Meaning | Example Match | Captures |
|---------|---------|---------------|----------|
| `(.*?)` | Capture any characters (non-greedy) | `havas-media-group` | $1 |
| `([0-9]+)` | Capture one or more digits | `158207` | $2 |
| `\.html` | Match literal ".html" | `.html` | - |
| `/videos/(.*)` | Match /videos/ followed by anything | `/videos/ceo-interview` | $1=ceo-interview |
| `^pattern$` | Match entire string (start to end) | - | - |

---

### Server Variables

| Variable | Example Value | Used For |
|----------|---------------|----------|
| `$_SERVER['REQUEST_URI']` | `/havas-media-group-158207.html` | Full request path |
| `$_SERVER['HTTP_HOST']` | `archive.adgully.com` | Domain check (config.php) |
| `$_GET['request_url']` | `/havas-media-group-158207.html` | Request from Nginx |
| `$_REQUEST['request_url']` | `/havas-media-group-158207.html` | Same as $_GET |

---

## 🎓 KEY TAKEAWAYS

1. **Custom routing system** - Not .htaccess or Nginx rewrite
2. **Domain-independent routing** - Works with any domain
3. **Two critical fixes** - ltrim() and rule order
4. **Debug-friendly** - Add error_log() calls to trace
5. **Rule order matters** - Specific before general
6. **Three files to change for domain migration** - config.php, menu-items.php, mobile-menu-items.php
7. **Do not change routing files for domain migration** - control_rewrite.php and config_rewrites.php are domain-independent

---

**Document Version:** 1.0  
**Last Updated:** February 2, 2026  
**For Questions:** Refer to COMPLETE_DOMAIN_MIGRATION_GUIDE.md
