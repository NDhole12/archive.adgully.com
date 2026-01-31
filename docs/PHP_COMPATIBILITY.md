# PHP 5.6 to 8.2 Compatibility Guide

This guide covers all breaking changes and migration strategies when upgrading from PHP 5.6 to PHP 8.2.

---

## 🚨 Critical Breaking Changes

### 1. Removed Extensions and Functions

#### mysql Extension (Removed in PHP 7.0)
**Problem**: All `mysql_*` functions removed  
**Impact**: 🔴 **CRITICAL** - Application will crash

**Old Code**:
```php
// ❌ Will cause fatal error
$conn = mysql_connect('localhost', 'user', 'pass');
mysql_select_db('database', $conn);
$result = mysql_query("SELECT * FROM table");
$row = mysql_fetch_assoc($result);
mysql_close($conn);
```

**Solution 1: Use MySQLi**:
```php
// ✅ MySQLi (procedural style)
$conn = mysqli_connect('localhost', 'user', 'pass', 'database');
$result = mysqli_query($conn, "SELECT * FROM table");
$row = mysqli_fetch_assoc($result);
mysqli_close($conn);
```

**Solution 2: Use PDO** (Recommended):
```php
// ✅ PDO (best practice)
try {
    $pdo = new PDO('mysql:host=localhost;dbname=database', 'user', 'pass');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo->query("SELECT * FROM table");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
} catch(PDOException $e) {
    error_log("Database error: " . $e->getMessage());
}
```

**Conversion Table**:
| PHP 5.6 (mysql) | PHP 8.2 (MySQLi) | PHP 8.2 (PDO) |
|-----------------|------------------|---------------|
| `mysql_connect()` | `mysqli_connect()` | `new PDO()` |
| `mysql_query()` | `mysqli_query()` | `$pdo->query()` |
| `mysql_fetch_assoc()` | `mysqli_fetch_assoc()` | `$stmt->fetch(PDO::FETCH_ASSOC)` |
| `mysql_num_rows()` | `mysqli_num_rows()` | `$stmt->rowCount()` |
| `mysql_insert_id()` | `mysqli_insert_id()` | `$pdo->lastInsertId()` |
| `mysql_error()` | `mysqli_error()` | `try/catch PDOException` |
| `mysql_real_escape_string()` | `mysqli_real_escape_string()` | Prepared statements |

#### mcrypt Extension (Removed in PHP 7.2)
**Problem**: All `mcrypt_*` functions removed  
**Impact**: 🔴 **CRITICAL** - Encryption/decryption will fail

**Old Code**:
```php
// ❌ Will cause fatal error
$encrypted = mcrypt_encrypt(
    MCRYPT_RIJNDAEL_128,
    $key,
    $data,
    MCRYPT_MODE_CBC,
    $iv
);
```

**Solution: Use OpenSSL**:
```php
// ✅ OpenSSL equivalent
$encrypted = openssl_encrypt(
    $data,
    'AES-128-CBC',
    $key,
    OPENSSL_RAW_DATA,
    $iv
);

// Decryption
$decrypted = openssl_decrypt(
    $encrypted,
    'AES-128-CBC',
    $key,
    OPENSSL_RAW_DATA,
    $iv
);
```

**Conversion Table**:
| mcrypt | OpenSSL Equivalent |
|--------|-------------------|
| `MCRYPT_RIJNDAEL_128` | `aes-128-cbc` |
| `MCRYPT_RIJNDAEL_256` | `aes-256-cbc` |
| `MCRYPT_BLOWFISH` | `bf-cbc` |
| `MCRYPT_DES` | `des-cbc` |

**Important**: Encrypted data with mcrypt may not be compatible with OpenSSL. You may need to decrypt old data with PHP 5.6 and re-encrypt with OpenSSL.

#### ereg Extension (Removed in PHP 7.0)
**Problem**: All `ereg*` functions removed  
**Impact**: 🟠 **HIGH** - Pattern matching will fail

**Old Code**:
```php
// ❌ Will cause fatal error
if (ereg("^[a-zA-Z0-9]+$", $string)) {
    // ...
}

$replaced = ereg_replace("[^a-zA-Z0-9]", "", $string);
```

**Solution: Use PCRE (preg_* functions)**:
```php
// ✅ PCRE equivalent
if (preg_match("/^[a-zA-Z0-9]+$/", $string)) {
    // ...
}

$replaced = preg_replace("/[^a-zA-Z0-9]/", "", $string);
```

**Conversion Table**:
| ereg | PCRE (preg) |
|------|-------------|
| `ereg($pattern, $string)` | `preg_match("/$pattern/", $string)` |
| `eregi($pattern, $string)` | `preg_match("/$pattern/i", $string)` |
| `ereg_replace($pattern, $replacement, $string)` | `preg_replace("/$pattern/", $replacement, $string)` |
| `split($pattern, $string)` | `preg_split("/$pattern/", $string)` |

**Note**: PCRE patterns need delimiters (usually `/`), and special characters must be escaped differently.

---

### 2. Deprecated Functions

#### each() Function (Deprecated 7.2, Removed 8.0)
**Old Code**:
```php
// ❌ Deprecated
while (list($key, $value) = each($array)) {
    echo "$key => $value\n";
}
```

**Solution**:
```php
// ✅ Use foreach
foreach ($array as $key => $value) {
    echo "$key => $value\n";
}
```

#### create_function() (Deprecated 7.2, Removed 8.0)
**Old Code**:
```php
// ❌ Deprecated
$func = create_function('$a,$b', 'return $a + $b;');
echo $func(1, 2);
```

**Solution**:
```php
// ✅ Use anonymous functions (closures)
$func = function($a, $b) {
    return $a + $b;
};
echo $func(1, 2);
```

#### String Search Functions
**Old Code**:
```php
// ❌ Deprecated (passing needle as number)
$pos = strpos($haystack, 97); // ASCII code for 'a'
```

**Solution**:
```php
// ✅ Pass actual character
$pos = strpos($haystack, 'a');
```

---

### 3. Type System Changes

#### Strict Types
PHP 8.x enforces stricter type checking.

**Old Code** (PHP 5.6 tolerates):
```php
function add(int $a, int $b) {
    return $a + $b;
}

echo add("5", "10"); // PHP 5.6: Works (auto-converts)
                     // PHP 8.2: Works but with deprecation warnings
```

**Solution**:
```php
// ✅ Enable strict types
declare(strict_types=1);

function add(int $a, int $b): int {
    return $a + $b;
}

echo add(5, 10); // Use actual integers
```

#### Return Type Declarations
PHP 8.x requires proper return types in some contexts.

**Old Code**:
```php
// ❌ May cause issues in PHP 8
function getValue() {
    return null; // Sometimes returns null
}
```

**Solution**:
```php
// ✅ Use nullable return type
function getValue(): ?string {
    return null; // Explicitly allows null
}
```

---

### 4. Error Handling Changes

#### Errors Promoted to Exceptions
Many errors that were warnings in PHP 5.6 are now Exceptions in PHP 8.

**Old Code**:
```php
// PHP 5.6: Returns false, triggers warning
$result = file_get_contents('nonexistent.txt');
if ($result === false) {
    // Handle error
}
```

**Solution**:
```php
// ✅ PHP 8.2: Use try/catch
try {
    $result = file_get_contents('nonexistent.txt');
} catch (\Throwable $e) {
    error_log("File error: " . $e->getMessage());
    $result = false;
}
```

#### Undefined Variables
PHP 8 throws errors for undefined variables.

**Old Code**:
```php
// PHP 5.6: Notice (can be suppressed)
echo $undefined_var;
```

**Solution**:
```php
// ✅ Check existence first
echo $defined_var ?? 'default value';

// Or
if (isset($maybe_defined)) {
    echo $maybe_defined;
}
```

---

### 5. Array and String Handling

#### Array Access on Non-Arrays
**Old Code**:
```php
// PHP 5.6: Returns null with notice
$value = $string[0]['key']; // $string is a string
```

**Solution**:
```php
// ✅ Proper type checking
if (is_array($data) && isset($data[0]['key'])) {
    $value = $data[0]['key'];
}
```

#### Negative String Offsets
**Old Code**:
```php
// PHP 5.6: Returns empty string
$char = $string[-1];
```

**Solution**:
```php
// ✅ PHP 8.2: Actually works as expected (gets last char)
// But verify behavior in your code
$char = $string[-1]; // Gets last character
```

---

### 6. Object-Oriented Changes

#### Constructor Property Promotion (PHP 8.0+)
**Old Code**:
```php
class User {
    private $name;
    private $email;
    
    public function __construct($name, $email) {
        $this->name = $name;
        $this->email = $email;
    }
}
```

**New Feature** (optional but recommended):
```php
// ✅ Constructor property promotion
class User {
    public function __construct(
        private string $name,
        private string $email
    ) {}
}
```

#### Nullsafe Operator (PHP 8.0+)
**Old Code**:
```php
$country = null;
if ($session && $session->user && $session->user->address) {
    $country = $session->user->address->country;
}
```

**New Feature**:
```php
// ✅ Nullsafe operator
$country = $session?->user?->address?->country;
```

---

## 🔍 Detection Tools

### Find Deprecated Code

#### 1. Use PHPCompatibility Sniff
```bash
# Install PHP_CodeSniffer
composer require --dev squizlabs/php_codesniffer

# Install PHPCompatibility
composer require --dev phpcompatibility/php-compatibility

# Configure
vendor/bin/phpcs --config-set installed_paths vendor/phpcompatibility/php-compatibility

# Run check
vendor/bin/phpcs --standard=PHPCompatibility \
  --runtime-set testVersion 8.2 \
  /path/to/your/code
```

#### 2. Manual Grep Searches
```bash
# Find mysql_* functions
grep -rn "mysql_" /var/www/html/ --include="*.php"

# Find mcrypt_* functions
grep -rn "mcrypt_" /var/www/html/ --include="*.php"

# Find ereg functions
grep -rn "\bereg\b\|\beregi\b\|\bereg_replace\b" /var/www/html/ --include="*.php"

# Find each() function
grep -rn "\beach(" /var/www/html/ --include="*.php"

# Find create_function
grep -rn "create_function" /var/www/html/ --include="*.php"

# Find @ error suppression (often hides problems)
grep -rn "@\$" /var/www/html/ --include="*.php"
```

---

## 📋 Migration Checklist

### Code Audit
- [ ] Search for `mysql_*` functions
- [ ] Search for `mcrypt_*` functions
- [ ] Search for `ereg*` functions
- [ ] Search for `each()` calls
- [ ] Search for `create_function()` calls
- [ ] Search for `split()` calls (use `explode()` or `preg_split()`)
- [ ] Check for undefined variable usage
- [ ] Check for array access on non-arrays
- [ ] Review all @ error suppressors

### Testing Strategy
- [ ] Set up PHP 8.2 development environment
- [ ] Enable error reporting to maximum
  ```php
  error_reporting(E_ALL);
  ini_set('display_errors', 1);
  ```
- [ ] Test all critical user flows
- [ ] Test admin/backend functionality
- [ ] Test all forms and submissions
- [ ] Test file uploads
- [ ] Test search functionality
- [ ] Test API endpoints (if any)
- [ ] Test scheduled tasks/cron jobs
- [ ] Review all error logs

### Gradual Migration Approach
1. **Set up PHP 8.2 on staging server**
2. **Run automated scans** (PHPCompatibility)
3. **Fix critical issues** (mysql, mcrypt, ereg)
4. **Deploy to staging and test**
5. **Fix warnings and notices**
6. **Deploy to staging and test again**
7. **Run load tests**
8. **Deploy to production** (with rollback plan ready)

---

## 🆘 Common Error Messages and Solutions

### "Call to undefined function mysql_connect()"
**Solution**: Replace all `mysql_*` with `mysqli_*` or PDO

### "Call to undefined function mcrypt_encrypt()"
**Solution**: Replace with `openssl_encrypt()`

### "Call to undefined function ereg()"
**Solution**: Replace with `preg_match()`

### "Undefined variable"
**Solution**: Initialize variables or use null coalescing (`??`)

### "Trying to access array offset on value of type null"
**Solution**: Check `isset()` before array access

### "Array and string offset access syntax with curly braces is no longer supported"
**Solution**: Replace `$string{0}` with `$string[0]`

### "Passing null to parameter #1 ($string) of type string is deprecated"
**Solution**: Ensure parameters are not null or make them nullable

---

## 📚 Additional Resources

- [PHP 7.0 Migration Guide](https://www.php.net/manual/en/migration70.php)
- [PHP 7.1 Migration Guide](https://www.php.net/manual/en/migration71.php)
- [PHP 7.2 Migration Guide](https://www.php.net/manual/en/migration72.php)
- [PHP 7.3 Migration Guide](https://www.php.net/manual/en/migration73.php)
- [PHP 7.4 Migration Guide](https://www.php.net/manual/en/migration74.php)
- [PHP 8.0 Migration Guide](https://www.php.net/manual/en/migration80.php)
- [PHP 8.1 Migration Guide](https://www.php.net/manual/en/migration81.php)
- [PHP 8.2 Migration Guide](https://www.php.net/manual/en/migration82.php)

---

**Version**: 1.0  
**Last Updated**: January 11, 2026
