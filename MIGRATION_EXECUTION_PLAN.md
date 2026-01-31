# Complete Migration Execution Plan
## Archive.adgully.com - CentOS 7.9 → Ubuntu 22.04 Migration

> **Status**: Ready for Execution  
> **Last Updated**: January 11, 2026  
> **Estimated Total Time**: 10-14 days

---

## 📊 Project Status Overview

### ✅ Completed (100%)
- [x] Complete documentation (6 comprehensive guides)
- [x] Configuration templates (Nginx, PHP, MariaDB, Security)
- [x] Automation scripts (installation, backup, validation)
- [x] Requirements verification completed
- [x] All 17 PHP extensions mapped
- [x] Deprecated functions documented with replacements
- [x] Security hardening guide complete

### 🎯 Ready for Your Execution
Everything is documented and ready. You now need to execute the actual migration.

---

## 🚦 Phase 1: Pre-Migration (Days 1-3)

### Day 1: Audit & Document Current Server

**Connect to existing server:**
```bash
ssh root@172.31.21.197
# Password: byCdgzMr5AHx
```

**Collect complete server information:**
```bash
# Create audit directory
mkdir -p /root/migration-audit
cd /root/migration-audit

# System information
echo "=== SYSTEM INFO ===" > server-audit.txt
uname -a >> server-audit.txt
cat /etc/*release >> server-audit.txt
hostname -f >> server-audit.txt
df -h >> server-audit.txt
free -m >> server-audit.txt

# Web server
echo -e "\n=== APACHE INFO ===" >> server-audit.txt
httpd -v >> server-audit.txt 2>&1
apachectl -M >> server-audit.txt 2>&1
cat /etc/httpd/conf/httpd.conf > httpd-conf-backup.txt

# PHP detailed
echo -e "\n=== PHP INFO ===" >> server-audit.txt
php -v >> server-audit.txt
php -i > php-info.txt
php -m >> server-audit.txt
cat /etc/php.ini > php-ini-backup.txt
ls -la /etc/php.d/ >> server-audit.txt

# Database
echo -e "\n=== DATABASE INFO ===" >> server-audit.txt
mysql -V >> server-audit.txt
mysql -u root -p -e "SHOW VARIABLES LIKE '%version%';" >> server-audit.txt
mysql -u root -p -e "SHOW DATABASES;" >> server-audit.txt
mysql -u root -p -e "SELECT User, Host FROM mysql.user;" >> server-audit.txt

# Application
echo -e "\n=== APPLICATION INFO ===" >> server-audit.txt
ls -lah /var/www/ >> server-audit.txt
du -sh /var/www/* >> server-audit.txt
find /var/www -name "*.php" | head -20 >> server-audit.txt

# Download this file to your local machine for analysis
```

**Download audit file to your Windows machine:**
```powershell
# In PowerShell on your Windows machine
scp root@172.31.21.197:/root/migration-audit/server-audit.txt D:\archive.adgully.com\backups\
scp root@172.31.21.197:/root/migration-audit/php-info.txt D:\archive.adgully.com\backups\
scp root@172.31.21.197:/root/migration-audit/php-ini-backup.txt D:\archive.adgully.com\backups\
```

**Action Items:**
- [ ] Complete server audit
- [ ] Document all database names and users
- [ ] Identify application root directory
- [ ] List all custom Apache configurations

---

### Day 2: Create Comprehensive Backups

**On existing server (172.31.21.197):**

**1. Database Backup:**
```bash
# Create backup directory
mkdir -p /root/backups/database
cd /root/backups/database

# Get database credentials
# Check your application config file for DB name, user, password
cat /var/www/html/config.php  # Adjust path as needed

# Backup ALL databases
BACKUP_DATE=$(date +%Y%m%d-%H%M%S)
mysqldump --all-databases --single-transaction --quick --lock-tables=false \
  -u root -p > all-databases-${BACKUP_DATE}.sql

# Or backup specific database
# mysqldump -u DB_USER -p DATABASE_NAME > archive-db-${BACKUP_DATE}.sql

# Compress backup
gzip all-databases-${BACKUP_DATE}.sql

# Verify backup
ls -lh all-databases-${BACKUP_DATE}.sql.gz
```

**2. Application Files Backup:**
```bash
# Backup web files
cd /root/backups
BACKUP_DATE=$(date +%Y%m%d-%H%M%S)

# Find your document root
grep DocumentRoot /etc/httpd/conf/httpd.conf

# Backup application (adjust path as needed)
tar -czf web-files-${BACKUP_DATE}.tar.gz \
  --exclude='*.log' \
  --exclude='cache/*' \
  --exclude='tmp/*' \
  /var/www/html/

# Verify backup
ls -lh web-files-${BACKUP_DATE}.tar.gz
tar -tzf web-files-${BACKUP_DATE}.tar.gz | head -20
```

**3. Download Backups to Your Windows Machine:**
```powershell
# In PowerShell on Windows
# Create backups directory if not exists
New-Item -ItemType Directory -Force -Path "D:\archive.adgully.com\backups"

# Download database backup
scp root@172.31.21.197:/root/backups/database/all-databases-*.sql.gz D:\archive.adgully.com\backups\

# Download web files backup
scp root@172.31.21.197:/root/backups/web-files-*.tar.gz D:\archive.adgully.com\backups\
```

**4. Verify Downloaded Backups:**
```powershell
# Check file sizes
Get-ChildItem D:\archive.adgully.com\backups\ | Select-Object Name, Length, LastWriteTime
```

**Action Items:**
- [ ] Database backup created and downloaded
- [ ] Application files backup created and downloaded
- [ ] Backup sizes verified (not 0 bytes)
- [ ] Test database restore on local machine (if possible)

---

### Day 3: Scan Code for PHP Compatibility Issues

**Extract application files for scanning:**
```powershell
# In PowerShell on Windows
cd D:\archive.adgully.com\backups

# Extract web files (you'll need 7-Zip or similar)
# Install 7-Zip if not available: winget install 7zip.7zip

# Extract .tar.gz
7z x web-files-*.tar.gz
7z x web-files-*.tar
```

**Run deprecation scanner:**
```bash
# If you have Git Bash or WSL on Windows
cd /d/archive.adgully.com
bash scripts/validation/find-deprecated.sh backups/var/www/html/ > deprecated-report.txt

# Review the report
cat deprecated-report.txt
```

**Manual search if bash not available:**
```powershell
# In PowerShell - Search for deprecated functions
$phpFiles = Get-ChildItem -Path "D:\archive.adgully.com\backups\var\www\html" -Filter "*.php" -Recurse
$deprecated = @('mysql_connect', 'mysql_query', 'mysql_fetch', 'mcrypt_encrypt', 'mcrypt_decrypt', 'ereg', 'eregi', 'split', 'each(')

$results = @()
foreach ($file in $phpFiles) {
    $content = Get-Content $file.FullName -Raw
    foreach ($func in $deprecated) {
        if ($content -match $func) {
            $results += [PSCustomObject]@{
                File = $file.FullName
                Function = $func
            }
        }
    }
}

$results | Format-Table -AutoSize
$results | Export-Csv deprecated-functions.csv -NoTypeInformation
```

**Action Items:**
- [ ] Deprecation scan completed
- [ ] List of all mysql_* functions documented
- [ ] List of all mcrypt_* functions documented
- [ ] List of all ereg* functions documented
- [ ] Estimate effort to fix each issue
- [ ] Create PHP compatibility fix plan

---

## 🏗️ Phase 2: New Server Setup (Days 4-5)

### Day 4: Provision Ubuntu 22.04 Server

**1. Get a new Ubuntu 22.04 LTS server:**
- Cloud provider (DigitalOcean, AWS, Vultr, etc.)
- OR dedicated/VPS provider
- Minimum specs: 2 CPU cores, 4GB RAM, 50GB SSD

**2. Initial server access:**
```bash
# SSH to new server (replace with your actual IP)
ssh root@YOUR_NEW_SERVER_IP

# Update system
apt update && apt upgrade -y

# Set hostname
hostnamectl set-hostname archive.adgully.com
echo "127.0.0.1 archive.adgully.com" >> /etc/hosts
```

**3. Run automated installation script:**

**Upload script to new server:**
```bash
# On new Ubuntu server
wget https://raw.githubusercontent.com/YOUR_REPO/archive.adgully.com/main/scripts/install/full-install.sh
# OR manually copy from your project

# If copying manually:
# On Windows: scp D:\archive.adgully.com\scripts\install\full-install.sh root@YOUR_NEW_SERVER_IP:/root/

# Make executable and run
chmod +x full-install.sh
./full-install.sh
```

**OR follow manual installation (if automation fails):**

See **[INSTALLATION_GUIDE.md](docs/INSTALLATION_GUIDE.md)** for step-by-step commands.

**Key installation steps (summary):**
```bash
# 1. Install Nginx
apt install -y nginx

# 2. Install PHP 8.2 with all required extensions
apt install -y php8.2-fpm php8.2-cli php8.2-mysql php8.2-mysqli php8.2-curl \
  php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-opcache \
  php8.2-redis php8.2-mongodb php8.2-tidy

# 3. Install MariaDB 10.11
apt install -y mariadb-server mariadb-client
mysql_secure_installation

# 4. Install SSL tools
apt install -y certbot python3-certbot-nginx

# 5. Install security tools
apt install -y ufw fail2ban

# 6. Configure firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
```

**Action Items:**
- [ ] Ubuntu 22.04 server provisioned
- [ ] All packages installed successfully
- [ ] Services running (nginx, php8.2-fpm, mariadb)
- [ ] Firewall enabled and configured
- [ ] SSH access working

---

### Day 5: Configure New Server

**1. Apply Nginx configuration:**
```bash
# Copy configuration from project
# On Windows: scp D:\archive.adgully.com\configs\nginx\archive.adgully.com.conf root@YOUR_NEW_SERVER_IP:/tmp/

# On new server:
cp /tmp/archive.adgully.com.conf /etc/nginx/sites-available/archive.adgully.com

# Edit configuration with your details
nano /etc/nginx/sites-available/archive.adgully.com
# Replace:
# - server_name with your actual domain
# - root path if different
# - SSL certificate paths (after Let's Encrypt setup)

# Enable site
ln -s /etc/nginx/sites-available/archive.adgully.com /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Test configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

**2. Apply PHP configuration:**
```bash
# Copy PHP configs
# On Windows: 
# scp D:\archive.adgully.com\configs\php\php-custom.ini root@YOUR_NEW_SERVER_IP:/tmp/
# scp D:\archive.adgully.com\configs\php\archive-pool.conf root@YOUR_NEW_SERVER_IP:/tmp/

# On new server:
cp /tmp/php-custom.ini /etc/php/8.2/fpm/conf.d/99-custom.ini
cp /tmp/archive-pool.conf /etc/php/8.2/fpm/pool.d/archive.conf

# Edit pool config
nano /etc/php/8.2/fpm/pool.d/archive.conf
# Set: user = www-data, group = www-data

# Disable default pool if using custom
mv /etc/php/8.2/fpm/pool.d/www.conf /etc/php/8.2/fpm/pool.d/www.conf.disabled

# Test and restart PHP-FPM
php-fpm8.2 -t
systemctl restart php8.2-fpm
```

**3. Apply MariaDB configuration:**
```bash
# Copy MariaDB config
# scp D:\archive.adgully.com\configs\mariadb\mariadb-custom.cnf root@YOUR_NEW_SERVER_IP:/tmp/

cp /tmp/mariadb-custom.cnf /etc/mysql/mariadb.conf.d/99-custom.cnf

# Restart MariaDB
systemctl restart mariadb

# Create database user
mysql -u root -p

# In MySQL:
CREATE DATABASE archive_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'archive_user'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON archive_db.* TO 'archive_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**4. Setup SSL certificate:**
```bash
# Using Let's Encrypt
certbot --nginx -d archive.adgully.com -d www.archive.adgully.com

# Test auto-renewal
certbot renew --dry-run
```

**5. Configure Fail2ban:**
```bash
# Copy Fail2ban config
# scp D:\archive.adgully.com\configs\security\fail2ban-jail.local root@YOUR_NEW_SERVER_IP:/tmp/

cp /tmp/fail2ban-jail.local /etc/fail2ban/jail.local

# Restart Fail2ban
systemctl restart fail2ban

# Check status
fail2ban-client status
```

**Action Items:**
- [ ] Nginx configured and running
- [ ] PHP-FPM configured and running
- [ ] MariaDB configured with database created
- [ ] SSL certificate installed
- [ ] Fail2ban configured and active
- [ ] All services start on boot

---

## 🔄 Phase 3: Application Migration (Days 6-8)

### Day 6: Deploy Application Files

**1. Upload application files to new server:**
```bash
# On new server, create application directory
mkdir -p /var/www/archive.adgully.com
chown -R www-data:www-data /var/www/archive.adgully.com
chmod -R 755 /var/www/archive.adgully.com
```

**Upload files from Windows:**
```powershell
# Extract your backup first if not done
cd D:\archive.adgully.com\backups

# Upload via SCP (adjust paths as needed)
scp -r var/www/html/* root@YOUR_NEW_SERVER_IP:/var/www/archive.adgully.com/
```

**2. Set correct permissions:**
```bash
# On new server
cd /var/www/archive.adgully.com

# Set ownership
chown -R www-data:www-data .

# Set permissions
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

# Make writable directories for cache/uploads/logs
chmod -R 775 uploads/ cache/ logs/  # Adjust paths as needed
```

**3. Update application configuration:**
```bash
# Find and edit your config file
nano /var/www/archive.adgully.com/config.php  # Adjust filename

# Update database connection:
# - Host: localhost
# - Database: archive_db
# - User: archive_user
# - Password: [your password from Day 5]

# Update any file paths if changed
# Update any URLs if different
```

**Action Items:**
- [ ] Application files uploaded
- [ ] Permissions set correctly
- [ ] Configuration file updated
- [ ] Database credentials updated

---

### Day 7: Import Database

**1. Upload database backup to new server:**
```powershell
# From Windows
scp D:\archive.adgully.com\backups\all-databases-*.sql.gz root@YOUR_NEW_SERVER_IP:/root/
```

**2. Import database:**
```bash
# On new server
cd /root

# Extract SQL file
gunzip all-databases-*.sql.gz

# Import to MariaDB
mysql -u root -p < all-databases-*.sql

# Verify import
mysql -u root -p -e "SHOW DATABASES;"
mysql -u root -p -e "USE archive_db; SHOW TABLES;"
mysql -u root -p -e "USE archive_db; SELECT COUNT(*) FROM your_main_table;"
```

**3. Update database user privileges:**
```bash
mysql -u root -p

# Grant privileges to application user
GRANT ALL PRIVILEGES ON archive_db.* TO 'archive_user'@'localhost';
FLUSH PRIVILEGES;

# Test connection
mysql -u archive_user -p archive_db -e "SHOW TABLES;"
```

**Action Items:**
- [ ] Database imported successfully
- [ ] All tables present
- [ ] Record counts match old server
- [ ] Application user can access database

---

### Day 8: Fix PHP Compatibility Issues

**Based on your deprecation scan from Day 3, fix issues:**

**Common fixes needed:**

**1. Replace mysql_* functions:**
```php
// OLD CODE (PHP 5.6):
$conn = mysql_connect('localhost', 'user', 'pass');
mysql_select_db('database', $conn);
$result = mysql_query("SELECT * FROM table");
while ($row = mysql_fetch_assoc($result)) {
    // ...
}
mysql_close($conn);

// NEW CODE (PHP 8.2) - Using MySQLi:
$conn = mysqli_connect('localhost', 'user', 'pass', 'database');
if (!$conn) {
    die('Connection failed: ' . mysqli_connect_error());
}
$result = mysqli_query($conn, "SELECT * FROM table");
while ($row = mysqli_fetch_assoc($result)) {
    // ...
}
mysqli_close($conn);

// OR better - Use PDO:
try {
    $pdo = new PDO('mysql:host=localhost;dbname=database', 'user', 'pass');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $stmt = $pdo->query("SELECT * FROM table");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // ...
    }
} catch (PDOException $e) {
    die('Connection failed: ' . $e->getMessage());
}
```

**2. Replace mcrypt_* functions:**
```php
// OLD CODE:
$encrypted = mcrypt_encrypt(MCRYPT_RIJNDAEL_128, $key, $data, MCRYPT_MODE_CBC, $iv);

// NEW CODE - Using OpenSSL:
$encrypted = openssl_encrypt($data, 'AES-128-CBC', $key, OPENSSL_RAW_DATA, $iv);
```

**3. Replace ereg* functions:**
```php
// OLD CODE:
if (ereg("^[a-zA-Z0-9]+$", $username)) {
    // ...
}

// NEW CODE - Using preg_match:
if (preg_match("/^[a-zA-Z0-9]+$/", $username)) {
    // ...
}
```

**Upload fixed files:**
```powershell
# After fixing locally, upload changed files
scp path/to/fixed/file.php root@YOUR_NEW_SERVER_IP:/var/www/archive.adgully.com/path/to/
```

**See [PHP_COMPATIBILITY.md](docs/PHP_COMPATIBILITY.md) for complete guide.**

**Action Items:**
- [ ] All mysql_* functions replaced
- [ ] All mcrypt_* functions replaced
- [ ] All ereg* functions replaced
- [ ] Other deprecated functions fixed
- [ ] Code changes tested locally if possible

---

## 🧪 Phase 4: Testing (Days 9-10)

### Day 9: Staging Testing

**1. Setup staging access (hosts file method):**

**On your Windows machine:**
```powershell
# Edit hosts file as Administrator
notepad C:\Windows\System32\drivers\etc\hosts

# Add this line:
YOUR_NEW_SERVER_IP archive.adgully.com www.archive.adgully.com

# Save and close
```

**2. Test website functionality:**
```bash
# Run automated tests
bash scripts/validation/test-website.sh archive.adgully.com

# Manual testing checklist:
# - Homepage loads
# - Navigation works
# - Login/logout works
# - Search functionality
# - Forms submission
# - File uploads
# - Database operations (create, read, update, delete)
# - Admin panel access
# - All critical features
```

**3. Check for errors:**
```bash
# On new server, monitor logs in real-time
tail -f /var/log/nginx/error.log
tail -f /var/log/php8.2-fpm.log
tail -f /var/www/archive.adgully.com/logs/application.log  # If exists
```

**4. Performance testing:**
```bash
# Run health check
bash scripts/validation/health-check.sh

# Test response time
curl -w "@curl-format.txt" -o /dev/null -s https://archive.adgully.com/

# Create curl-format.txt:
echo "time_namelookup: %{time_namelookup}\ntime_connect: %{time_connect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}\n" > curl-format.txt
```

**Action Items:**
- [ ] All core features working
- [ ] No critical errors in logs
- [ ] Performance acceptable
- [ ] SSL certificate valid
- [ ] Mobile responsive working
- [ ] All forms functional

---

### Day 10: Final Validation

**Follow [POST_MIGRATION_CHECKLIST.md](docs/POST_MIGRATION_CHECKLIST.md):**

**1. Technical validation:**
- [ ] All services running and enabled at boot
- [ ] PHP 8.2 working correctly
- [ ] Database connections working
- [ ] File permissions correct
- [ ] SSL certificate installed and auto-renewing
- [ ] Firewall active and configured
- [ ] Fail2ban monitoring logs
- [ ] Backup scripts working

**2. Security validation:**
```bash
# Security scan
curl -I https://archive.adgully.com | grep -i "security\|x-"

# Check SSL rating
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=archive.adgully.com

# Verify firewall
ufw status verbose

# Check fail2ban
fail2ban-client status sshd
fail2ban-client status nginx-http-auth
```

**3. Performance baseline:**
```bash
# Monitor server resources
htop  # Or: top

# Check MySQL queries
mysql -u root -p -e "SHOW PROCESSLIST;"

# Review slow query log
tail /var/log/mysql/slow-query.log
```

**Action Items:**
- [ ] All POST_MIGRATION_CHECKLIST items completed
- [ ] Security scan passed
- [ ] Performance benchmarks documented
- [ ] Monitoring configured
- [ ] Team trained on new server

---

## 🚀 Phase 5: Go Live (Days 11-12)

### Day 11: Pre-Launch Preparation

**1. Reduce DNS TTL (48 hours before cutover):**
```bash
# In your DNS provider control panel:
# - Set TTL for archive.adgully.com A record to 300 seconds (5 minutes)
# - Wait 48 hours for old TTL to expire
```

**2. Final backup of OLD server:**
```bash
# On old server (172.31.21.197)
# Create final backup before cutover
mysqldump --all-databases -u root -p | gzip > /root/final-backup-$(date +%Y%m%d).sql.gz
tar -czf /root/final-files-$(date +%Y%m%d).tar.gz /var/www/html/

# Download to safe location
```

**3. Enable maintenance mode on OLD server:**
```bash
# Create maintenance page
cat > /var/www/html/maintenance.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Site Maintenance</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Site Under Maintenance</h1>
    <p>We're upgrading our servers. Back online shortly!</p>
</body>
</html>
EOF

# Redirect all traffic to maintenance page (Apache)
cat > /var/www/html/.htaccess <<'EOF'
RewriteEngine On
RewriteCond %{REQUEST_URI} !^/maintenance.html$
RewriteRule ^(.*)$ /maintenance.html [R=503,L]
ErrorDocument 503 /maintenance.html
Header Set Cache-Control "max-age=0, no-store"
EOF
```

**4. Schedule cutover time:**
- Choose low-traffic period (e.g., 2 AM - 4 AM)
- Notify users if appropriate
- Have rollback plan ready

**Action Items:**
- [ ] DNS TTL reduced 48 hours ago
- [ ] Final backups created
- [ ] Maintenance mode ready
- [ ] Cutover time scheduled
- [ ] Team briefed on process

---

### Day 12: DNS Cutover & Launch

**CUTOVER PROCEDURE:**

**1. Enable maintenance mode on old server** (done above)

**2. Final database sync (if data changed during testing):**
```bash
# Create incremental backup on old server
mysqldump archive_db -u root -p > final-sync-$(date +%Y%m%d-%H%M).sql

# Transfer to new server
scp final-sync-*.sql root@YOUR_NEW_SERVER_IP:/root/

# Import on new server
mysql -u root -p archive_db < final-sync-*.sql
```

**3. Update DNS:**
```bash
# In DNS control panel:
# Update A record for archive.adgully.com
# Old IP: 172.31.21.197
# New IP: YOUR_NEW_SERVER_IP

# Also update www.archive.adgully.com if applicable
```

**4. Monitor DNS propagation:**
```powershell
# On Windows, check DNS
nslookup archive.adgully.com

# Or online tool:
# https://www.whatsmydns.net/#A/archive.adgully.com
```

**5. Remove hosts file entry:**
```powershell
# Edit C:\Windows\System32\drivers\etc\hosts
# Remove or comment out the line you added for testing
```

**6. Monitor new server closely:**
```bash
# Watch logs in real-time
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
tail -f /var/log/php8.2-fpm.log

# Monitor server resources
htop

# Check error rates
tail -100 /var/log/nginx/error.log | wc -l
```

**7. Test from multiple locations:**
- Test from your location
- Test from different ISPs
- Test from mobile networks
- Use online testing tools

**8. Verify all functionality:**
- [ ] Homepage loads correctly
- [ ] All pages accessible
- [ ] Login/authentication works
- [ ] Database operations work
- [ ] Forms submit correctly
- [ ] File uploads work
- [ ] Search functionality works
- [ ] Admin panel accessible

**Action Items:**
- [ ] DNS updated to new server
- [ ] DNS propagated (check multiple DNS servers)
- [ ] Website accessible from new server
- [ ] All functionality verified working
- [ ] No critical errors in logs
- [ ] Performance acceptable

---

## 📊 Phase 6: Post-Launch Monitoring (Days 13-14+)

### Day 13: Active Monitoring

**1. Continuous log monitoring:**
```bash
# Check for errors every hour
grep -i "error\|critical\|fatal" /var/log/nginx/error.log | tail -50
grep -i "error\|warning" /var/log/php8.2-fpm.log | tail -50

# Monitor access patterns
tail -100 /var/log/nginx/access.log | awk '{print $9}' | sort | uniq -c | sort -rn
```

**2. Performance monitoring:**
```bash
# Run health check multiple times
bash scripts/validation/health-check.sh

# Check MySQL performance
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"
mysql -u root -p -e "SHOW STATUS LIKE 'Questions';"
mysql -u root -p -e "SHOW PROCESSLIST;"
```

**3. User feedback:**
- Monitor support tickets
- Check for error reports
- Review user complaints
- Test reported issues

**Action Items:**
- [ ] Monitor logs every 2-4 hours
- [ ] Check server resources regularly
- [ ] Review error reports
- [ ] Address any issues immediately

---

### Day 14+: Optimization & Stabilization

**1. Performance tuning:**
```bash
# Enable OPcache statistics
# Add to php-custom.ini:
echo "opcache.enable_cli=1" >> /etc/php/8.2/fpm/conf.d/99-custom.ini
systemctl restart php8.2-fpm

# Check OPcache status
php -r "print_r(opcache_get_status());"

# Tune PHP-FPM based on usage
# Monitor: tail -f /var/log/php8.2-fpm.log
# Adjust pool settings if needed
```

**2. Setup automated monitoring:**
```bash
# Create monitoring cron job
crontab -e

# Add:
# Health check every 15 minutes
*/15 * * * * /root/scripts/validation/health-check.sh >> /var/log/health-check.log 2>&1

# Backup database daily at 2 AM
0 2 * * * /root/scripts/migration/backup-database.sh >> /var/log/backup.log 2>&1

# Backup files weekly on Sunday at 3 AM
0 3 * * 0 /root/scripts/migration/backup-files.sh >> /var/log/backup.log 2>&1
```

**3. Documentation updates:**
- Document any configuration changes made
- Note any issues encountered and solutions
- Update runbooks for common tasks
- Create disaster recovery procedure

**4. Old server decommissioning (30 days after migration):**
```bash
# After 30 days of stable operation:

# 1. Create final archive of old server
# 2. Download all backups
# 3. Verify new server backups working
# 4. Cancel old server hosting
# 5. Update documentation
```

**Action Items:**
- [ ] No critical errors for 24 hours
- [ ] Performance optimized
- [ ] Automated monitoring configured
- [ ] Automated backups configured
- [ ] Team documentation updated
- [ ] Old server decommission scheduled

---

## 🆘 Emergency Rollback Procedure

**If critical issues occur:**

**1. Immediate rollback:**
```bash
# In DNS control panel:
# Change A record back to old IP: 172.31.21.197
# TTL is now 300 seconds, so propagation is fast

# On old server - disable maintenance mode:
rm /var/www/html/.htaccess
```

**2. Investigate issues on new server:**
```bash
# Check logs for errors
tail -200 /var/log/nginx/error.log
tail -200 /var/log/php8.2-fpm.log

# Check service status
systemctl status nginx
systemctl status php8.2-fpm
systemctl status mariadb
```

**3. Fix and retry:**
- Identify root cause
- Fix the issue
- Test thoroughly
- Schedule new cutover

**Rollback decision criteria:**
- Critical functionality broken
- Data loss detected
- Security breach
- Performance severely degraded (>5 seconds response time)
- High error rate (>5% of requests)

---

## ✅ Success Criteria

Migration is considered successful when:

- [ ] ✅ Website fully functional for 72 hours
- [ ] ✅ Zero critical errors in logs
- [ ] ✅ Performance equal or better than old server
- [ ] ✅ All user-reported issues resolved
- [ ] ✅ Automated backups working and tested
- [ ] ✅ Security scans passing
- [ ] ✅ SSL certificate valid and auto-renewing
- [ ] ✅ Monitoring and alerts configured
- [ ] ✅ Team trained on new infrastructure
- [ ] ✅ Documentation complete and accurate

---

## 📞 Troubleshooting Quick Reference

| Problem | Solution | Reference |
|---------|----------|-----------|
| 502 Bad Gateway | Check PHP-FPM status, socket permissions | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#502-bad-gateway) |
| Database connection failed | Verify credentials, check MariaDB status | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#database-errors) |
| Permission denied | Fix file ownership: `chown -R www-data:www-data /var/www/` | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#permission-errors) |
| Slow performance | Check OPcache, tune PHP-FPM, optimize MySQL | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#performance-issues) |
| SSL certificate error | Re-run certbot, check firewall allows 80/443 | [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#ssl-issues) |

**For detailed troubleshooting, see: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)**

---

## 📚 Documentation Reference

| Document | Purpose | When to Use |
|----------|---------|-------------|
| [RULEBOOK.md](docs/RULEBOOK.md) | Migration principles and rules | Throughout entire migration |
| [PRE_MIGRATION_CHECKLIST.md](docs/PRE_MIGRATION_CHECKLIST.md) | Pre-migration audit | Before starting (Days 1-3) |
| [INSTALLATION_GUIDE.md](docs/INSTALLATION_GUIDE.md) | Step-by-step server setup | During server setup (Days 4-5) |
| [PHP_COMPATIBILITY.md](docs/PHP_COMPATIBILITY.md) | PHP 5.6 → 8.2 changes | When fixing code (Day 8) |
| [POST_MIGRATION_CHECKLIST.md](docs/POST_MIGRATION_CHECKLIST.md) | Post-migration validation | After deployment (Day 10) |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common problems & solutions | When issues occur |

---

## 🎯 Your Next Immediate Actions

**RIGHT NOW:**

1. **Read [PRE_MIGRATION_CHECKLIST.md](docs/PRE_MIGRATION_CHECKLIST.md)** (30 minutes)
2. **Connect to old server** and run audit commands from Day 1 above
3. **Create backups** following Day 2 procedures
4. **Scan code** for deprecated functions using Day 3 methods
5. **Provision new Ubuntu 22.04 server** for Day 4

**Then proceed through each day in sequence.**

---

## 📝 Progress Tracking

Copy this to a separate file to track your progress:

```
MIGRATION PROGRESS TRACKER
=========================

Phase 1: Pre-Migration
[ ] Day 1: Server audit complete
[ ] Day 2: Backups created and verified
[ ] Day 3: Code deprecation scan complete

Phase 2: New Server Setup
[ ] Day 4: Ubuntu 22.04 server provisioned
[ ] Day 5: Server configured (Nginx, PHP, MariaDB)

Phase 3: Application Migration
[ ] Day 6: Application files deployed
[ ] Day 7: Database imported
[ ] Day 8: PHP compatibility issues fixed

Phase 4: Testing
[ ] Day 9: Staging testing complete
[ ] Day 10: Final validation complete

Phase 5: Go Live
[ ] Day 11: Pre-launch preparation
[ ] Day 12: DNS cutover successful

Phase 6: Post-Launch
[ ] Day 13: Active monitoring - no issues
[ ] Day 14+: Stabilized and optimized

Status: [NOT STARTED | IN PROGRESS | COMPLETED]
Current Phase: [Phase number]
Current Day: [Day number]
Blocker: [Any current blockers]
Next Action: [What to do next]
```

---

**Good luck with your migration! Everything is documented and ready for execution.** 🚀

**Remember**: Take backups at every step, test thoroughly, and never rush the process. Better to take extra time than to have downtime.

**Questions?** Refer to the documentation or review [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

---

*Last Updated: January 11, 2026*
*Project: archive.adgully.com Migration*
*Status: Ready for Execution*
