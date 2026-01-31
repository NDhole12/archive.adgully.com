# Pre-Migration Checklist

Complete this checklist **BEFORE** starting any migration work. Each item must be verified and signed off.

---

## 🔍 Discovery Phase

### Current Server Audit
- [ ] **Server Access Confirmed**
  - [ ] SSH access to current server working
  - [ ] Root or sudo access available
  - [ ] Server credentials documented securely
  - [ ] Server IP address and hostname recorded

- [ ] **System Information Collected**
  ```bash
  # Run these commands and save output
  uname -a                          # OS version
  cat /etc/*release                 # Distribution details
  hostnamectl                       # System info
  df -h                            # Disk usage
  free -m                          # Memory usage
  ```
  - [ ] Output saved to: `backups/server-info.txt`

- [ ] **Web Server Configuration Documented**
  ```bash
  httpd -v                         # Apache version
  httpd -V                         # Apache compile settings
  httpd -M                         # Apache modules
  apache2ctl -S                    # Virtual hosts
  ```
  - [ ] Apache version: ____________
  - [ ] Configuration backed up: `/etc/httpd/` or `/etc/apache2/`
  - [ ] Virtual hosts documented

- [ ] **PHP Configuration Documented**
  ```bash
  php -v                           # PHP version
  php -m                           # Installed modules
  php -i > backups/phpinfo.txt     # Full PHP info
  php --ini                        # Config file locations
  ```
  - [ ] PHP version confirmed: ____________
  - [ ] All enabled extensions listed
  - [ ] php.ini backed up
  - [ ] All .ini files from /etc/php.d/ backed up

- [ ] **Database Information Collected**
  ```bash
  mysql -V                         # MySQL/MariaDB version
  mysql -e "SHOW DATABASES;"       # List all databases
  mysql -e "SHOW VARIABLES LIKE 'character_set%';"
  mysql -e "SHOW VARIABLES LIKE 'collation%';"
  ```
  - [ ] Database version: ____________
  - [ ] Database list documented
  - [ ] Character encoding confirmed
  - [ ] Database size calculated

---

## 📦 Backup Phase

### Application Backup
- [ ] **Full Application Backup**
  ```bash
  # Create timestamped backup
  tar -czf archive_app_$(date +%Y%m%d).tar.gz /var/www/html/
  ```
  - [ ] Backup created: `archive_app_YYYYMMDD.tar.gz`
  - [ ] Backup size: ____________
  - [ ] Backup stored off-server (S3, NAS, etc.)
  - [ ] Backup integrity verified: `tar -tzf backup.tar.gz > /dev/null`

- [ ] **Configuration Files Backed Up**
  - [ ] Apache configs: `/etc/httpd/` or `/etc/apache2/`
  - [ ] PHP configs: `/etc/php.ini` and `/etc/php.d/`
  - [ ] Custom application configs
  - [ ] SSL certificates: `/etc/letsencrypt/` or `/etc/ssl/`
  - [ ] Cron jobs: `crontab -l > backups/crontab.txt`
  - [ ] Environment files: `.env`, `.htaccess`

### Database Backup
- [ ] **Full Database Dump**
  ```bash
  # Create database backup
  mysqldump --all-databases --single-transaction --routines --triggers \
    --events --add-drop-database --quick --lock-tables=false \
    > backups/all_databases_$(date +%Y%m%d).sql
  
  # Compress it
  gzip backups/all_databases_*.sql
  ```
  - [ ] Backup created and compressed
  - [ ] Backup size: ____________
  - [ ] Backup stored off-server
  - [ ] Backup tested (restore to test environment)

- [ ] **Verify Database Backup**
  ```bash
  # Test restore on a test database
  mysql test_db < backups/all_databases_YYYYMMDD.sql
  ```
  - [ ] Restore test successful
  - [ ] All tables present
  - [ ] Data integrity verified

### Additional Backups
- [ ] **User Files and Uploads**
  - [ ] Uploads directory backed up
  - [ ] User-generated content backed up
  - [ ] Total size: ____________

- [ ] **Logs (for reference)**
  - [ ] Apache access logs: `/var/log/httpd/` or `/var/log/apache2/`
  - [ ] Apache error logs
  - [ ] PHP error logs
  - [ ] Recent 7 days minimum

- [ ] **DNS Records Documented**
  ```bash
  # For each domain
  dig archive2.adgully.com
  dig archive.adgully.com
  ```
  - [ ] Current A records documented
  - [ ] Current CNAME records documented
  - [ ] TTL values noted
  - [ ] DNS provider access confirmed

---

## 🔬 Code Analysis Phase

### PHP Compatibility Check
- [ ] **Scan for Deprecated Functions**
  ```bash
  # Search for mysql_* functions (deprecated)
  grep -r "mysql_connect\|mysql_query\|mysql_fetch" /var/www/html/
  
  # Search for ereg functions (removed in PHP 7)
  grep -r "ereg\|eregi\|ereg_replace" /var/www/html/
  
  # Search for mcrypt (removed in PHP 7.2)
  grep -r "mcrypt_" /var/www/html/
  ```
  - [ ] Results documented in: `backups/deprecated_functions.txt`
  - [ ] Count of `mysql_*` calls: ____________
  - [ ] Count of `ereg*` calls: ____________
  - [ ] Count of `mcrypt_*` calls: ____________

- [ ] **Identify Third-Party Dependencies**
  ```bash
  # Look for composer.json
  find /var/www/html -name "composer.json"
  
  # Look for package.json
  find /var/www/html -name "package.json"
  ```
  - [ ] Composer dependencies listed
  - [ ] All packages PHP 8.2 compatible (check packagist.org)
  - [ ] Outdated packages identified
  - [ ] Update strategy documented

- [ ] **Static Code Analysis** (if possible)
  ```bash
  # Install and run PHPCompatibility (if not in production)
  # Or run locally on a copy
  phpcs --standard=PHPCompatibility --runtime-set testVersion 8.2 /path/to/code
  ```
  - [ ] Analysis completed
  - [ ] Critical issues documented
  - [ ] Warnings documented
  - [ ] Fix plan created

### Application Dependencies
- [ ] **Required PHP Extensions Identified**
  - [ ] List from current server: ____________
  - [ ] Cross-referenced with code usage
  - [ ] Modern equivalents identified:
    - [ ] `mysql` → `mysqli` or `PDO`
    - [ ] `mcrypt` → `openssl` or `sodium`
    - [ ] `ereg` → `preg_*` (PCRE)

- [ ] **External Services Documented**
  - [ ] SMTP server/email service
  - [ ] API integrations (payment, social, etc.)
  - [ ] CDN or asset hosting
  - [ ] Caching services (Redis, Memcached)
  - [ ] Any other external dependencies

---

## 🧪 Testing Environment Setup

### Staging Server
- [ ] **Staging Environment Created**
  - [ ] Same OS as target (Ubuntu 22.04)
  - [ ] Same PHP version as target (8.2)
  - [ ] Same database version as target
  - [ ] Isolated from production
  - [ ] Accessible for testing

- [ ] **Application Deployed to Staging**
  - [ ] Full backup restored to staging
  - [ ] Database imported successfully
  - [ ] Configuration updated for staging
  - [ ] Application starts without errors

- [ ] **Staging Tests Passed**
  - [ ] Homepage loads correctly
  - [ ] User authentication works
  - [ ] Database operations successful
  - [ ] File uploads work
  - [ ] Search functionality works
  - [ ] Forms submit correctly
  - [ ] All critical features tested

---

## 📊 Performance Baseline

### Current Performance Metrics
- [ ] **Collect Baseline Metrics**
  ```bash
  # Page load time
  curl -w "@curl-format.txt" -o /dev/null -s https://archive2.adgully.com/
  
  # Server response time
  time curl -s https://archive2.adgully.com/ > /dev/null
  ```
  - [ ] Average page load time: _______ seconds
  - [ ] Average TTFB: _______ ms
  - [ ] Peak traffic time identified: _______
  - [ ] Average concurrent users: _______
  - [ ] Database query performance documented

- [ ] **Resource Usage Baseline**
  ```bash
  top -b -n 1 > backups/top_output.txt
  free -m > backups/memory.txt
  df -h > backups/disk_usage.txt
  ```
  - [ ] Average CPU usage: _______%
  - [ ] Average memory usage: _______%
  - [ ] Average disk I/O: _______

---

## 🔐 Security Audit

### Current Security Status
- [ ] **Review Current Security**
  - [ ] SSL certificate status: _______
  - [ ] Firewall rules documented
  - [ ] Open ports identified: `netstat -tuln`
  - [ ] User accounts reviewed: `cat /etc/passwd`
  - [ ] Sudo access reviewed: `cat /etc/sudoers`

- [ ] **Identify Security Issues**
  - [ ] Outdated software versions noted
  - [ ] Weak configurations identified
  - [ ] Security patches needed listed

---

## 📋 Infrastructure Planning

### New Server Requirements
- [ ] **Hardware/VPS Specifications**
  - [ ] CPU cores: ____________
  - [ ] RAM: ____________
  - [ ] Disk space: ____________
  - [ ] Bandwidth: ____________
  - [ ] Provider: ____________

- [ ] **Network Configuration**
  - [ ] Static IP address assigned: ____________
  - [ ] Reverse DNS configured
  - [ ] Firewall rules planned
  - [ ] VPN access (if needed)

- [ ] **DNS Migration Plan**
  - [ ] Current TTL: _______ (reduce to 300 before migration)
  - [ ] A record change planned
  - [ ] Propagation time estimated: _______
  - [ ] Rollback DNS plan documented

### Timeline and Resources
- [ ] **Migration Schedule**
  - [ ] Start date: ____________
  - [ ] Estimated duration: ____________
  - [ ] Maintenance window: ____________
  - [ ] Rollback deadline: ____________

- [ ] **Team and Responsibilities**
  - [ ] Project lead: ____________
  - [ ] System administrator: ____________
  - [ ] Developer: ____________
  - [ ] QA/Testing: ____________
  - [ ] Stakeholders notified

---

## ✅ Final Pre-Migration Verification

### Checkpoint Review
- [ ] **All Sections Above Completed**: Yes / No
- [ ] **All Backups Verified and Tested**: Yes / No
- [ ] **Staging Environment Working**: Yes / No
- [ ] **Code Compatibility Issues Identified**: Yes / No
- [ ] **Migration Plan Documented**: Yes / No
- [ ] **Rollback Plan Ready**: Yes / No
- [ ] **Team Ready and Briefed**: Yes / No

### Sign-Off
- [ ] **Technical Lead Approval**: ____________ (Name & Date)
- [ ] **Project Manager Approval**: ____________ (Name & Date)
- [ ] **Stakeholder Approval**: ____________ (Name & Date)

---

## 🚀 Ready to Proceed

**If all items above are checked**, you are ready to proceed to the [Installation Guide](INSTALLATION_GUIDE.md).

**If any items are NOT checked**, do NOT proceed. Complete all checklist items first.

---

**Checklist Version**: 1.0  
**Completed By**: ____________  
**Completion Date**: ____________
