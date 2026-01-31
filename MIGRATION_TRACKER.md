# Migration Progress Tracker
## Archive.adgully.com - Server Migration Status

> **Use this file to track your migration progress**  
> **Instructions**: Replace [ ] with [x] as you complete each task

---

## 📊 Project Information

| Field | Value |
|-------|-------|
| **Project Start Date** | January 11, 2026 |
| **Target Go-Live Date** | January 25, 2026 (Est.) |
| **Old Server IP** | 172.31.21.197 |
| **New Server IP** | 31.97.233.171 ✅ |
| **Current Phase** | Phase 2: Server Setup (Day 4) |
| **Migration Status** | 🟡 In Progress |

---

## 🎯 Phase 1: Pre-Migration (Days 1-3)

### Day 1: Server Audit ⏱️ Est. 2-4 hours

**System Information:**
- [ ] Connected to old server (172.31.21.197)
- [ ] Collected OS information (CentOS 7.9 confirmed)
- [ ] Documented system resources (CPU, RAM, Disk)
- [ ] Identified hostname: _______________

**Web Server:**
- [ ] Documented Apache version: _______________
- [ ] Listed all Apache modules in use
- [ ] Backed up Apache configuration files
- [ ] Identified DocumentRoot: _______________

**PHP Configuration:**
- [ ] Confirmed PHP version: 5.6.40
- [ ] Listed all installed PHP extensions (17 required)
- [ ] Backed up php.ini configuration
- [ ] Documented custom PHP settings

**Database:**
- [ ] Documented MariaDB/MySQL version: _______________
- [ ] Listed all databases: _______________
- [ ] Listed all database users
- [ ] Documented database sizes

**Application:**
- [ ] Located application root directory: _______________
- [ ] Counted total PHP files: _______________
- [ ] Identified critical application paths
- [ ] Documented application size: _______________

**Audit Report:**
- [ ] Saved audit report to: `D:\archive.adgully.com\backups\`
- [ ] Reviewed audit findings
- [ ] No unexpected configurations found

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

### Day 2: Backup Creation ⏱️ Est. 2-4 hours

**Database Backup:**
- [ ] Created database backup directory on old server
- [ ] Backed up all databases (mysqldump)
- [ ] Compressed database backup (.sql.gz)
- [ ] Verified backup file size: _______________
- [ ] Downloaded to Windows machine
- [ ] Backup location: `D:\archive.adgully.com\backups\all-databases-[date].sql.gz`
- [ ] Tested database backup integrity

**Application Files Backup:**
- [ ] Created files backup directory on old server
- [ ] Backed up web files (tar.gz)
- [ ] Excluded cache/logs/tmp directories
- [ ] Verified backup file size: _______________
- [ ] Downloaded to Windows machine
- [ ] Backup location: `D:\archive.adgully.com\backups\web-files-[date].tar.gz`
- [ ] Verified backup contains all files

**Backup Verification:**
- [ ] Database backup not corrupted (0 bytes)
- [ ] Files backup not corrupted (0 bytes)
- [ ] Can extract files backup successfully
- [ ] Total backup size: _______________
- [ ] Backup copies stored in 2+ locations
- [ ] Tested restore process (optional but recommended)

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

### Day 3: Code Compatibility Scan ⏱️ Est. 2-4 hours

**Extract Application:**
- [ ] Extracted web-files backup on Windows machine
- [ ] Application extracted to: _______________
- [ ] All files accessible for scanning

**Deprecation Scanning:**
- [ ] Ran find-deprecated.sh script (or manual PowerShell search)
- [ ] Saved scan results to: `deprecated-report.txt`
- [ ] Reviewed scan results

**Deprecated Functions Found:**

**mysql_\* functions:**
- [ ] Count found: _______________
- [ ] Files affected: _______________
- [ ] Estimated fix time: _______________

**mcrypt_\* functions:**
- [ ] Count found: _______________
- [ ] Files affected: _______________
- [ ] Estimated fix time: _______________

**ereg\* functions:**
- [ ] Count found: _______________
- [ ] Files affected: _______________
- [ ] Estimated fix time: _______________

**Other deprecated (each(), split(), create_function()):**
- [ ] Count found: _______________
- [ ] Files affected: _______________
- [ ] Estimated fix time: _______________

**Fix Plan:**
- [ ] Created list of all files requiring changes
- [ ] Prioritized critical functions first
- [ ] Estimated total fix time: _______________
- [ ] Created backup of original code
- [ ] Ready to start fixing compatibility issues

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

## 🏗️ Phase 2: New Server Setup (Days 4-5)

### Day 4: Server Provisioning ⏱️ Est. 2-4 hours

**Server Acquisition:**
- [x] Ubuntu 22.04 LTS server provisioned ✅
- [x] Server provider: (Your hosting provider)
- [x] Server specs: (To be verified)
- [x] Server IP address: 31.97.233.171 ✅
- [x] Root password set: z(P5ts@wdsESLUjMPVXs ✅

**Initial Access:**
- [ ] SSH access working
- [ ] Root login successful
- [ ] System updated (apt update && apt upgrade)
- [ ] Hostname set to: archive.adgully.com

**Package Installation:**

Choose installation method:
- [ ] **Option A**: Automated (full-install.sh script)
- [ ] **Option B**: Manual (following INSTALLATION_GUIDE.md)

**Nginx:**
- [ ] Nginx installed
- [ ] Version: _______________
- [ ] Service enabled and running
- [ ] Default page accessible

**PHP 8.2:**
- [ ] PHP 8.2-FPM installed
- [ ] All 17 required extensions installed:
  - [ ] php8.2-mysql (mysqli, pdo_mysql, mysqlnd)
  - [ ] php8.2-curl
  - [ ] php8.2-gd
  - [ ] php8.2-mbstring
  - [ ] php8.2-xml
  - [ ] php8.2-zip
  - [ ] php8.2-opcache
  - [ ] php8.2-redis
  - [ ] php8.2-mongodb
  - [ ] php8.2-tidy
  - [ ] php8.2-intl
  - [ ] json (built-in)
  - [ ] openssl (built-in)
- [ ] Service enabled and running

**MariaDB 10.11:**
- [ ] MariaDB 10.11+ installed
- [ ] Version: _______________
- [ ] mysql_secure_installation completed
- [ ] Root password set: _______________
- [ ] Service enabled and running

**Security Tools:**
- [ ] UFW firewall installed
- [ ] Certbot (Let's Encrypt) installed
- [ ] Fail2ban installed
- [ ] All tools functioning

**Firewall Configuration:**
- [ ] UFW enabled
- [ ] Port 22 (SSH) allowed
- [ ] Port 80 (HTTP) allowed
- [ ] Port 443 (HTTPS) allowed
- [ ] All other ports blocked
- [ ] Firewall status verified

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

### Day 5: Server Configuration ⏱️ Est. 3-5 hours

**Nginx Configuration:**
- [ ] Copied archive.adgully.com.conf to server
- [ ] Placed in /etc/nginx/sites-available/
- [ ] Edited with correct domain name
- [ ] Edited with correct root path
- [ ] Created symbolic link to sites-enabled/
- [ ] Removed default site configuration
- [ ] Tested configuration (nginx -t)
- [ ] Reloaded Nginx successfully

**PHP Configuration:**
- [ ] Copied php-custom.ini to server
- [ ] Placed in /etc/php/8.2/fpm/conf.d/
- [ ] Copied archive-pool.conf to server
- [ ] Placed in /etc/php/8.2/fpm/pool.d/
- [ ] Edited pool user/group (www-data)
- [ ] Disabled default www pool (optional)
- [ ] Tested PHP-FPM configuration
- [ ] Restarted PHP-FPM successfully

**MariaDB Configuration:**
- [ ] Copied mariadb-custom.cnf to server
- [ ] Placed in /etc/mysql/mariadb.conf.d/
- [ ] Reviewed and adjusted settings
- [ ] Restarted MariaDB successfully
- [ ] Created application database
  - Database name: _______________
  - Character set: utf8mb4
  - Collation: utf8mb4_unicode_ci
- [ ] Created application user: _______________
- [ ] Set user password: _______________
- [ ] Granted privileges to database
- [ ] Tested database connection

**SSL Certificate:**
- [ ] Ran certbot --nginx command
- [ ] Certificate issued for: archive.adgully.com
- [ ] Certificate issued for: www.archive.adgully.com
- [ ] Auto-renewal tested (certbot renew --dry-run)
- [ ] Certificate expiry date: _______________
- [ ] HTTPS working correctly

**Fail2ban Configuration:**
- [ ] Copied fail2ban-jail.local to server
- [ ] Placed in /etc/fail2ban/
- [ ] Reviewed and adjusted ban times
- [ ] Restarted Fail2ban successfully
- [ ] Verified jails active (fail2ban-client status)

**Service Verification:**
- [ ] All services running: `systemctl status nginx php8.2-fpm mariadb`
- [ ] All services enabled at boot
- [ ] No errors in service logs
- [ ] Server ready for application deployment

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

## 🔄 Phase 3: Application Migration (Days 6-8)

### Day 6: Application Deployment ⏱️ Est. 2-4 hours

**Directory Setup:**
- [ ] Created /var/www/archive.adgully.com/
- [ ] Set ownership to www-data:www-data
- [ ] Set base permissions to 755

**File Upload:**
- [ ] Uploaded all application files to new server
- [ ] Upload method used: _______________
- [ ] All files uploaded successfully
- [ ] File count matches original: _______________

**Permissions:**
- [ ] Set correct ownership (www-data:www-data)
- [ ] Set directory permissions (755)
- [ ] Set file permissions (644)
- [ ] Set writable permissions for:
  - [ ] uploads/ directory (775)
  - [ ] cache/ directory (775)
  - [ ] logs/ directory (775)
  - [ ] Other: _______________

**Configuration Update:**
- [ ] Located application config file: _______________
- [ ] Updated database host: localhost
- [ ] Updated database name: _______________
- [ ] Updated database user: _______________
- [ ] Updated database password: _______________
- [ ] Updated file paths (if changed)
- [ ] Updated base URL (if changed)
- [ ] Saved configuration changes

**Preliminary Test:**
- [ ] Accessed site via IP address: http://NEW_SERVER_IP/
- [ ] Homepage loads (or shows expected error)
- [ ] No critical PHP errors
- [ ] Ready for database import

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

### Day 7: Database Migration ⏱️ Est. 1-3 hours

**Upload Database Backup:**
- [ ] Uploaded database backup to new server
- [ ] Location: /root/all-databases-[date].sql.gz
- [ ] File integrity verified

**Extract Backup:**
- [ ] Extracted .sql.gz file
- [ ] SQL file size: _______________
- [ ] File readable and not corrupted

**Import Database:**
- [ ] Started database import
- [ ] Import completed without errors
- [ ] Import time taken: _______________

**Database Verification:**
- [ ] Verified all databases imported
- [ ] Database list matches old server
- [ ] Checked table count: _______________
- [ ] Spot-checked record counts
- [ ] Sample query: `SELECT COUNT(*) FROM main_table` = _______________
- [ ] No missing data detected

**User Privileges:**
- [ ] Granted privileges to application user
- [ ] Flushed privileges
- [ ] Tested connection as application user
- [ ] Application can connect successfully

**Application Test:**
- [ ] Accessed homepage (should now work)
- [ ] No database connection errors
- [ ] Database queries working
- [ ] Data displaying correctly

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

### Day 8: PHP Compatibility Fixes ⏱️ Est. 4-8 hours (varies)

**Based on Day 3 deprecation scan, fix all issues:**

**mysql_* Function Replacement:**
- [ ] Total functions to replace: _______________
- [ ] Conversion method chosen: ☐ MySQLi / ☐ PDO
- [ ] All mysql_connect() replaced
- [ ] All mysql_select_db() replaced
- [ ] All mysql_query() replaced
- [ ] All mysql_fetch_assoc() replaced
- [ ] All mysql_fetch_array() replaced
- [ ] All mysql_num_rows() replaced
- [ ] All mysql_close() replaced
- [ ] All other mysql_* functions replaced
- [ ] Code tested locally (if possible)
- [ ] Updated files uploaded to server

**mcrypt_* Function Replacement:**
- [ ] Total functions to replace: _______________
- [ ] All mcrypt_encrypt() replaced with openssl_encrypt()
- [ ] All mcrypt_decrypt() replaced with openssl_decrypt()
- [ ] Encryption/decryption still works correctly
- [ ] Tested with existing encrypted data
- [ ] Updated files uploaded to server

**ereg* Function Replacement:**
- [ ] Total functions to replace: _______________
- [ ] All ereg() replaced with preg_match()
- [ ] All eregi() replaced with preg_match() with /i flag
- [ ] All split() replaced with explode() or preg_split()
- [ ] All ereg_replace() replaced with preg_replace()
- [ ] Regex patterns adjusted for PCRE syntax
- [ ] Pattern matching still works correctly
- [ ] Updated files uploaded to server

**Other Deprecated Functions:**
- [ ] All each() replaced with foreach()
- [ ] All create_function() replaced with anonymous functions
- [ ] All other PHP 8.2 incompatibilities fixed
- [ ] Updated files uploaded to server

**Testing After Fixes:**
- [ ] Homepage loads without errors
- [ ] All pages accessible
- [ ] Login/authentication working
- [ ] Forms submitting correctly
- [ ] Search functionality working
- [ ] Database CRUD operations working
- [ ] File uploads working
- [ ] All critical features tested
- [ ] No PHP errors in logs
- [ ] Application fully functional

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

## 🧪 Phase 4: Testing (Days 9-10)

### Day 9: Staging Testing ⏱️ Est. 4-6 hours

**Staging Access Setup:**
- [ ] Edited Windows hosts file
- [ ] Added: NEW_SERVER_IP archive.adgully.com
- [ ] Flushed DNS cache (ipconfig /flushdns)
- [ ] Site accessible via domain name

**Automated Testing:**
- [ ] Ran test-website.sh script
- [ ] HTTP response: 200 OK
- [ ] HTTPS working correctly
- [ ] SSL certificate valid
- [ ] Security headers present
- [ ] Response time acceptable: _______________ ms

**Manual Functionality Testing:**

**Core Features:**
- [ ] Homepage loads correctly
- [ ] Navigation menu working
- [ ] Internal links working
- [ ] Search functionality working
- [ ] Contact forms working

**User Features:**
- [ ] User registration working
- [ ] User login working
- [ ] User profile working
- [ ] Password reset working
- [ ] User dashboard working

**Content Features:**
- [ ] Content displays correctly
- [ ] Images loading
- [ ] Categories working
- [ ] Archives working
- [ ] Pagination working

**Admin Features:**
- [ ] Admin login working
- [ ] Admin dashboard accessible
- [ ] Content management working
- [ ] User management working
- [ ] Settings management working

**Form Submissions:**
- [ ] Contact form submits
- [ ] Email notifications sent
- [ ] File uploads working
- [ ] Data validation working
- [ ] CAPTCHA working (if applicable)

**Database Operations:**
- [ ] CREATE operations working
- [ ] READ operations working
- [ ] UPDATE operations working
- [ ] DELETE operations working

**Log Monitoring:**
- [ ] Monitored error.log (no critical errors)
- [ ] Monitored php-fpm.log (no warnings)
- [ ] Monitored application logs (no issues)
- [ ] All error logs acceptable

**Browser Testing:**
- [ ] Chrome/Edge tested
- [ ] Firefox tested
- [ ] Safari tested (if available)
- [ ] Mobile browser tested

**Device Testing:**
- [ ] Desktop layout working
- [ ] Tablet layout working
- [ ] Mobile layout working

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

### Day 10: Final Validation ⏱️ Est. 3-5 hours

**Follow POST_MIGRATION_CHECKLIST.md:**

**Technical Validation:**
- [ ] All services running
- [ ] All services enabled at boot
- [ ] PHP 8.2 working correctly
- [ ] Database connections stable
- [ ] File permissions correct
- [ ] Log rotation configured

**Security Validation:**
- [ ] Firewall active and configured
- [ ] Fail2ban monitoring logs
- [ ] SSL certificate valid
- [ ] Security headers present
- [ ] No root SSH login
- [ ] Strong passwords set
- [ ] Tested security scan: https://securityheaders.com
- [ ] SSL Labs grade: _______________

**Performance Validation:**
- [ ] Ran health-check.sh script
- [ ] Homepage response time: _______________ ms
- [ ] Server load acceptable: _______________
- [ ] Memory usage acceptable: _______________
- [ ] Disk space available: _______________
- [ ] Database query performance good

**Backup Validation:**
- [ ] Automated database backup scheduled
- [ ] Automated files backup scheduled
- [ ] Backup scripts tested
- [ ] Backup restoration tested
- [ ] Backup retention policy set

**Monitoring Setup:**
- [ ] Health check cron job added
- [ ] Error log monitoring setup
- [ ] Disk space monitoring setup
- [ ] SSL expiry monitoring setup

**Documentation:**
- [ ] All configuration changes documented
- [ ] Server credentials stored securely
- [ ] Emergency contacts listed
- [ ] Rollback procedure documented

**Team Readiness:**
- [ ] Team briefed on new server
- [ ] Access credentials shared securely
- [ ] Migration timeline communicated
- [ ] Support plan in place

**Go/No-Go Decision:**
- [ ] All critical tests passed
- [ ] No blocking issues identified
- [ ] Team ready for cutover
- [ ] **Decision:** ☐ GO / ☐ NO-GO

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

## 🚀 Phase 5: Go Live (Days 11-12)

### Day 11: Pre-Launch Preparation ⏱️ Est. 2-3 hours

**DNS Preparation (48 hours before cutover):**
- [ ] Logged into DNS provider control panel
- [ ] Found archive.adgully.com A record
- [ ] Current TTL value: _______________
- [ ] Reduced TTL to 300 seconds (5 minutes)
- [ ] TTL reduction time: _______________
- [ ] Must wait 48 hours before cutover

**Final Backup (Old Server):**
- [ ] Created final database backup
- [ ] Created final files backup
- [ ] Downloaded to secure location
- [ ] Verified backup integrity
- [ ] Backup size: _______________

**Maintenance Mode Preparation:**
- [ ] Created maintenance.html page
- [ ] Created .htaccess for Apache redirect
- [ ] Tested maintenance mode (briefly)
- [ ] Disabled maintenance mode
- [ ] Ready to enable when needed

**Cutover Planning:**
- [ ] Cutover time scheduled: _______________
- [ ] Time zone: _______________
- [ ] Team notified of cutover time
- [ ] User notification sent (if applicable)
- [ ] Rollback plan reviewed
- [ ] Emergency contacts confirmed

**Pre-Cutover Checklist:**
- [ ] New server fully tested and ready
- [ ] No outstanding issues
- [ ] Team available during cutover
- [ ] Monitoring tools ready
- [ ] Communication channels open

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

### Day 12: DNS Cutover & Go Live ⏱️ Est. 4-6 hours

**Pre-Cutover (T-60 minutes):**
- [ ] Final check of new server (all services running)
- [ ] Final check of staging tests (all passing)
- [ ] Team on standby
- [ ] Monitoring tools ready

**Cutover (T-30 minutes):**
- [ ] Enabled maintenance mode on old server
- [ ] Verified maintenance page showing
- [ ] Created final incremental database backup (if needed)
- [ ] Uploaded to new server (if needed)
- [ ] Imported to new database (if needed)

**DNS Update (T-0 minutes):**
- [ ] Logged into DNS control panel
- [ ] Updated A record for archive.adgully.com
  - Old IP: 172.31.21.197
  - New IP: _______________
- [ ] Updated A record for www.archive.adgully.com (if applicable)
- [ ] Saved DNS changes
- [ ] DNS update time: _______________

**DNS Propagation Monitoring:**
- [ ] T+5 min: Checked DNS propagation (nslookup)
- [ ] T+10 min: Site accessible via new IP
- [ ] T+15 min: Multiple locations tested
- [ ] T+30 min: Majority of DNS servers updated
- [ ] T+60 min: Full propagation confirmed

**Remove Staging Configuration:**
- [ ] Removed hosts file entry on Windows
- [ ] Flushed DNS cache (ipconfig /flushdns)
- [ ] Site resolves to new server naturally

**Go-Live Verification:**
- [ ] Homepage loads correctly
- [ ] All pages accessible
- [ ] Login/authentication working
- [ ] Forms submitting
- [ ] Database operations working
- [ ] No critical errors in logs
- [ ] HTTPS working correctly
- [ ] SSL certificate valid

**Immediate Monitoring (First Hour):**
- [ ] Monitored Nginx access.log (tail -f)
- [ ] Monitored Nginx error.log (no critical errors)
- [ ] Monitored PHP-FPM log (no errors)
- [ ] Monitored server resources (htop)
- [ ] Response time acceptable: _______________ ms
- [ ] No user complaints received

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

## 📊 Phase 6: Post-Launch (Days 13-14+)

### Day 13: Active Monitoring ⏱️ Continuous

**Hourly Checks (First 24 hours):**

**Hour 1-2:**
- [ ] No critical errors
- [ ] Response time: _______________ ms
- [ ] Server load: _______________

**Hour 3-4:**
- [ ] No critical errors
- [ ] Response time: _______________ ms
- [ ] Server load: _______________

**Hour 5-6:**
- [ ] No critical errors
- [ ] Response time: _______________ ms
- [ ] Server load: _______________

**Hour 7-8:**
- [ ] No critical errors
- [ ] Response time: _______________ ms
- [ ] Server load: _______________

**Hour 12:**
- [ ] No critical errors
- [ ] Response time: _______________ ms
- [ ] Server load: _______________

**Hour 24:**
- [ ] No critical errors
- [ ] Response time: _______________ ms
- [ ] Server load: _______________

**Log Analysis:**
- [ ] Reviewed last 100 errors (none critical)
- [ ] Reviewed access patterns (normal)
- [ ] Reviewed PHP errors (none blocking)
- [ ] Reviewed slow queries (none concerning)

**Performance Analysis:**
- [ ] Average response time: _______________ ms
- [ ] Peak response time: _______________ ms
- [ ] CPU usage average: _______________%
- [ ] Memory usage average: _______________%
- [ ] Disk I/O acceptable

**User Feedback:**
- [ ] No critical user complaints
- [ ] Minor issues (if any): _______________
- [ ] All issues addressed
- [ ] User satisfaction acceptable

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

### Day 14+: Optimization & Stabilization ⏱️ Ongoing

**Performance Optimization:**
- [ ] Enabled OPcache statistics
- [ ] Reviewed OPcache hit rate: _______________%
- [ ] Tuned PHP-FPM pool settings (if needed)
- [ ] Optimized MySQL tables
- [ ] Reviewed and optimized slow queries
- [ ] Performance acceptable and stable

**Monitoring Automation:**
- [ ] Added health check cron job (every 15 minutes)
- [ ] Added database backup cron job (daily 2 AM)
- [ ] Added files backup cron job (weekly Sunday 3 AM)
- [ ] Tested all cron jobs manually
- [ ] Verified cron job logs

**Documentation Updates:**
- [ ] Documented all configuration changes
- [ ] Documented any issues encountered
- [ ] Documented solutions applied
- [ ] Updated runbooks for common tasks
- [ ] Created disaster recovery procedure

**Team Training:**
- [ ] Team trained on new server structure
- [ ] Team knows how to access logs
- [ ] Team knows how to restart services
- [ ] Team knows emergency procedures
- [ ] Team comfortable with new setup

**Old Server Decommissioning Plan:**
- [ ] New server stable for 7 days
- [ ] All backups from old server archived
- [ ] All configurations from old server documented
- [ ] Verified new server backups working
- [ ] Scheduled old server cancellation (30 days post-migration)
- [ ] Old server decommission date: _______________

**Status:** ⬜ Not Started / 🟡 In Progress / ✅ Completed  
**Issues/Notes:** _______________________________________

---

## ✅ Migration Success Criteria

**Mark each criterion as completed:**

- [ ] ✅ Website fully functional for 72 hours
- [ ] ✅ Zero critical errors in logs
- [ ] ✅ Performance equal or better than old server
  - Old server response time: _______________ ms
  - New server response time: _______________ ms
  - Improvement: _______________%
- [ ] ✅ All user-reported issues resolved
- [ ] ✅ Automated backups working and tested
- [ ] ✅ Security scans passing
  - SSL Labs grade: _______________
  - Security headers: _______________
- [ ] ✅ SSL certificate valid and auto-renewing
  - Expiry date: _______________
- [ ] ✅ Monitoring and alerts configured
- [ ] ✅ Team trained on new infrastructure
- [ ] ✅ Documentation complete and accurate

**Migration Status:** ⬜ Not Complete / ✅ **SUCCESSFUL**

**Migration Completion Date:** _______________

---

## 📈 Metrics Comparison

| Metric | Old Server | New Server | Change |
|--------|-----------|------------|--------|
| OS | CentOS 7.9 | Ubuntu 22.04 | ✅ Modernized |
| PHP Version | 5.6.40 | 8.2.x | ✅ Major upgrade |
| Web Server | Apache | Nginx | ✅ Improved |
| Database | MariaDB/MySQL | MariaDB 10.11 | ✅ Latest LTS |
| Response Time | ___ ms | ___ ms | ___% |
| CPU Usage | ___% | ___% | ___% |
| Memory Usage | ___% | ___% | ___% |
| Uptime | ___% | ___% | ___% |
| Security Grade | ___ | ___ | ___ |

---

## 🆘 Issues Log

**Record any issues encountered during migration:**

### Issue #1
- **Date:** _______________
- **Phase:** _______________
- **Severity:** ☐ Critical / ☐ High / ☐ Medium / ☐ Low
- **Description:** _______________
- **Solution:** _______________
- **Time to resolve:** _______________
- **Status:** ⬜ Open / ✅ Resolved

### Issue #2
- **Date:** _______________
- **Phase:** _______________
- **Severity:** ☐ Critical / ☐ High / ☐ Medium / ☐ Low
- **Description:** _______________
- **Solution:** _______________
- **Time to resolve:** _______________
- **Status:** ⬜ Open / ✅ Resolved

### Issue #3
- **Date:** _______________
- **Phase:** _______________
- **Severity:** ☐ Critical / ☐ High / ☐ Medium / ☐ Low
- **Description:** _______________
- **Solution:** _______________
- **Time to resolve:** _______________
- **Status:** ⬜ Open / ✅ Resolved

*(Add more issues as needed)*

---

## 📞 Key Contacts

| Role | Name | Contact | Availability |
|------|------|---------|--------------|
| Project Lead | _______________ | _______________ | _______________ |
| System Admin | _______________ | _______________ | _______________ |
| Developer | _______________ | _______________ | _______________ |
| DBA | _______________ | _______________ | _______________ |
| DNS Admin | _______________ | _______________ | _______________ |
| Hosting Support | _______________ | _______________ | _______________ |

---

## 🎯 Lessons Learned

**After migration completion, document what went well and what could be improved:**

**What Went Well:**
1. _______________
2. _______________
3. _______________

**What Could Be Improved:**
1. _______________
2. _______________
3. _______________

**Recommendations for Future Migrations:**
1. _______________
2. _______________
3. _______________

---

## 📊 Final Sign-Off

**Migration Approved By:**

| Name | Role | Signature | Date |
|------|------|-----------|------|
| _______________ | _______________ | _______________ | _______________ |
| _______________ | _______________ | _______________ | _______________ |
| _______________ | _______________ | _______________ | _______________ |

**Migration Status:** ✅ **COMPLETED SUCCESSFULLY**

---

*Use this tracker throughout your migration journey!* 🚀

*Last Updated: January 11, 2026*
