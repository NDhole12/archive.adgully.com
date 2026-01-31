# Post-Migration Checklist

Complete this checklist **AFTER** server installation and application deployment.

---

## 📦 Application Deployment

### Deploy Application Files
- [ ] **Upload Application Code**
  ```bash
  # From local machine, upload to server
  rsync -avz --progress /path/to/local/backup/ \
    deploy@SERVER_IP:/var/www/archive.adgully.com/public_html/
  
  # OR extract from backup on server
  cd /var/www/archive.adgully.com/
  sudo tar -xzf /path/to/archive_app_YYYYMMDD.tar.gz -C public_html/
  ```
  - [ ] Files uploaded successfully
  - [ ] Directory structure intact
  - [ ] File count verified

- [ ] **Set Proper Permissions**
  ```bash
  # Set ownership
  sudo chown -R www-data:www-data /var/www/archive.adgully.com/public_html
  
  # Set permissions
  sudo find /var/www/archive.adgully.com/public_html -type f -exec chmod 644 {} \;
  sudo find /var/www/archive.adgully.com/public_html -type d -exec chmod 755 {} \;
  
  # Writable directories (adjust as needed)
  sudo chmod -R 775 /var/www/archive.adgully.com/public_html/uploads
  sudo chmod -R 775 /var/www/archive.adgully.com/public_html/cache
  sudo chmod -R 775 /var/www/archive.adgully.com/public_html/logs
  ```
  - [ ] Ownership set to www-data
  - [ ] Permissions configured
  - [ ] Writable directories identified

- [ ] **Configure Application**
  ```bash
  # Update configuration file (config.php, .env, etc.)
  sudo vim /var/www/archive.adgully.com/public_html/config/config.php
  ```
  - [ ] Database credentials updated
  - [ ] Site URL updated
  - [ ] Debug mode disabled for production
  - [ ] Error reporting configured
  - [ ] Timezone set correctly
  - [ ] API keys and secrets updated

---

## 🗄️ Database Migration

### Import Database
- [ ] **Prepare Database**
  ```bash
  # Login to MySQL
  mysql -u root -p
  ```
  ```sql
  -- Verify database exists
  SHOW DATABASES LIKE 'archive_db';
  
  -- Verify user access
  SHOW GRANTS FOR 'archive_user'@'localhost';
  
  EXIT;
  ```
  - [ ] Database exists
  - [ ] User has proper privileges

- [ ] **Import Database Dump**
  ```bash
  # Decompress backup if needed
  gunzip backups/all_databases_YYYYMMDD.sql.gz
  
  # Import database
  mysql -u archive_user -p archive_db < backups/all_databases_YYYYMMDD.sql
  
  # Or if importing all databases as root
  mysql -u root -p < backups/all_databases_YYYYMMDD.sql
  ```
  - [ ] Import completed without errors
  - [ ] Import time: _______ minutes
  - [ ] Database size verified

- [ ] **Verify Database Import**
  ```bash
  mysql -u archive_user -p archive_db
  ```
  ```sql
  -- Check tables
  SHOW TABLES;
  
  -- Count rows in main tables
  SELECT COUNT(*) FROM users;
  SELECT COUNT(*) FROM articles;  -- adjust table names
  
  -- Check character encoding
  SHOW TABLE STATUS;
  
  EXIT;
  ```
  - [ ] All tables present
  - [ ] Row counts match source
  - [ ] Character encoding correct (utf8mb4)

- [ ] **Update Database References**
  ```sql
  -- If site URL is stored in database, update it
  UPDATE options SET option_value = 'https://archive.adgully.com' 
  WHERE option_name = 'site_url';
  
  -- Update any hardcoded paths
  UPDATE posts SET post_content = REPLACE(post_content, 
    'archive2.adgully.com', 'archive.adgully.com');
  ```
  - [ ] URLs updated
  - [ ] Paths corrected
  - [ ] References validated

---

## 🔧 PHP Compatibility Fixes

### Fix Deprecated Code
- [ ] **Replace mysql_* Functions**
  ```bash
  # Search for mysql_* usage
  grep -r "mysql_connect\|mysql_query\|mysql_fetch" \
    /var/www/archive.adgully.com/public_html/
  ```
  - [ ] All mysql_* calls identified
  - [ ] Replaced with mysqli_* or PDO
  - [ ] Code tested after changes

- [ ] **Replace mcrypt Functions**
  ```bash
  # Search for mcrypt usage
  grep -r "mcrypt_" /var/www/archive.adgully.com/public_html/
  ```
  - [ ] All mcrypt_* calls identified
  - [ ] Replaced with openssl or sodium
  - [ ] Encryption/decryption verified

- [ ] **Replace ereg Functions**
  ```bash
  # Search for ereg usage
  grep -r "ereg\|eregi\|split" /var/www/archive.adgully.com/public_html/
  ```
  - [ ] All ereg* calls identified
  - [ ] Replaced with preg_* equivalents
  - [ ] Regular expressions tested

- [ ] **Fix Other Compatibility Issues**
  - [ ] Check for deprecated each() function
  - [ ] Verify array access on non-arrays
  - [ ] Fix strict type comparisons
  - [ ] Update deprecated string functions

---

## ✅ Functional Testing

### Core Functionality Tests
- [ ] **Homepage and Navigation**
  ```bash
  # Test homepage
  curl -I https://archive.adgully.com/
  ```
  - [ ] Homepage loads (HTTP 200)
  - [ ] Navigation menu works
  - [ ] Internal links functional
  - [ ] Images load correctly

- [ ] **User Authentication**
  - [ ] Login page accessible
  - [ ] Login with test user successful
  - [ ] Session persistence works
  - [ ] Logout works correctly
  - [ ] Password reset functional

- [ ] **Database Operations**
  - [ ] Read operations work (listings, detail pages)
  - [ ] Create operations work (if applicable)
  - [ ] Update operations work
  - [ ] Delete operations work
  - [ ] Search functionality works

- [ ] **File Operations**
  - [ ] File upload works
  - [ ] File download works
  - [ ] File deletion works (if applicable)
  - [ ] File permissions correct

- [ ] **Forms and Submissions**
  - [ ] Contact form works
  - [ ] Comment submission works (if applicable)
  - [ ] Form validation works
  - [ ] CSRF protection functional

- [ ] **API Endpoints** (if applicable)
  - [ ] API responds correctly
  - [ ] Authentication works
  - [ ] Response format correct
  - [ ] Error handling proper

---

## 🔍 Error Checking

### Review Error Logs
- [ ] **Check Nginx Error Logs**
  ```bash
  sudo tail -100 /var/log/nginx/error.log
  sudo tail -100 /var/www/archive.adgully.com/logs/error.log
  ```
  - [ ] No critical errors
  - [ ] 404s are expected (if any)
  - [ ] No permission errors

- [ ] **Check PHP Error Logs**
  ```bash
  sudo tail -100 /var/log/php/error.log
  sudo tail -100 /var/log/php/fpm-error.log
  ```
  - [ ] No fatal errors
  - [ ] No deprecated function warnings
  - [ ] No database connection errors

- [ ] **Check MariaDB Error Logs**
  ```bash
  sudo tail -100 /var/log/mysql/error.log
  ```
  - [ ] No connection errors
  - [ ] No query errors
  - [ ] No permission issues

- [ ] **Check Application Logs**
  ```bash
  sudo tail -100 /var/www/archive.adgully.com/public_html/logs/app.log
  ```
  - [ ] No critical application errors
  - [ ] Expected log entries present

---

## 🚀 Performance Testing

### Baseline Performance
- [ ] **Test Page Load Times**
  ```bash
  # Test homepage
  curl -w "@curl-format.txt" -o /dev/null -s https://archive.adgully.com/
  
  # Create curl-format.txt if needed:
  cat > curl-format.txt << 'EOF'
  time_namelookup:  %{time_namelookup}s\n
  time_connect:  %{time_connect}s\n
  time_appconnect:  %{time_appconnect}s\n
  time_pretransfer:  %{time_pretransfer}s\n
  time_redirect:  %{time_redirect}s\n
  time_starttransfer:  %{time_starttransfer}s\n
  ----------\n
  time_total:  %{time_total}s\n
  EOF
  ```
  - [ ] Homepage: _______ seconds
  - [ ] Article page: _______ seconds
  - [ ] Search results: _______ seconds
  - [ ] Performance acceptable

- [ ] **Test Database Performance**
  ```bash
  # Check slow queries
  sudo mysql -u root -p -e "SELECT * FROM mysql.slow_log LIMIT 10;"
  ```
  - [ ] No slow queries above threshold
  - [ ] Query times acceptable

- [ ] **Check Resource Usage**
  ```bash
  # Monitor resources during test load
  htop
  
  # Check disk I/O
  iostat -x 1 10
  
  # Check memory
  free -h
  ```
  - [ ] CPU usage: _______%
  - [ ] Memory usage: _______%
  - [ ] Disk I/O acceptable
  - [ ] No resource bottlenecks

---

## 🔐 Security Validation

### Security Checks
- [ ] **SSL/TLS Configuration**
  ```bash
  # Test SSL
  openssl s_client -connect archive.adgully.com:443 -servername archive.adgully.com
  
  # Check SSL grade (online tool)
  # Visit: https://www.ssllabs.com/ssltest/
  ```
  - [ ] SSL certificate valid
  - [ ] Certificate auto-renewal working
  - [ ] HTTPS redirect working
  - [ ] SSL Labs grade A or better

- [ ] **Security Headers**
  ```bash
  curl -I https://archive.adgully.com/ | grep -i "x-frame\|x-content\|strict-transport"
  ```
  - [ ] X-Frame-Options present
  - [ ] X-Content-Type-Options present
  - [ ] X-XSS-Protection present
  - [ ] Strict-Transport-Security present (if configured)

- [ ] **Firewall Status**
  ```bash
  sudo ufw status verbose
  ```
  - [ ] Firewall enabled
  - [ ] Only necessary ports open (22, 80, 443)
  - [ ] Rules documented

- [ ] **Fail2ban Status**
  ```bash
  sudo fail2ban-client status
  sudo fail2ban-client status nginx-http-auth
  ```
  - [ ] Fail2ban active
  - [ ] All jails enabled
  - [ ] Ban list empty (or expected)

- [ ] **File Permissions Audit**
  ```bash
  # Check for overly permissive files
  find /var/www/archive.adgully.com/public_html -type f -perm 0777
  find /var/www/archive.adgully.com/public_html -type d -perm 0777
  ```
  - [ ] No 777 permissions found
  - [ ] Config files not world-readable
  - [ ] .env file properly secured (640)

- [ ] **Database Security**
  ```bash
  mysql -u root -p
  ```
  ```sql
  -- Check for default accounts
  SELECT User, Host FROM mysql.user;
  
  -- Verify no wildcards in user hosts
  SELECT User, Host FROM mysql.user WHERE Host = '%';
  
  EXIT;
  ```
  - [ ] No anonymous users
  - [ ] No test databases
  - [ ] No wildcard hosts
  - [ ] Strong passwords used

---

## 📊 Monitoring Setup

### Configure Monitoring
- [ ] **Setup Log Rotation**
  ```bash
  # Check logrotate configuration
  sudo cat /etc/logrotate.d/nginx
  sudo cat /etc/logrotate.d/php8.2-fpm
  ```
  - [ ] Nginx logs rotating
  - [ ] PHP logs rotating
  - [ ] Application logs rotating
  - [ ] Retention period: _______ days

- [ ] **Configure Alerting** (if applicable)
  - [ ] Uptime monitoring configured
  - [ ] Disk space alerts set
  - [ ] Error rate alerts set
  - [ ] SSL expiry alerts set

- [ ] **Backup Schedule**
  ```bash
  # View cron jobs
  sudo crontab -l
  ```
  - [ ] Daily database backups scheduled
  - [ ] Weekly file backups scheduled
  - [ ] Backup retention policy set
  - [ ] Backup off-site storage configured

---

## 🔄 DNS Cutover (When Ready)

### Pre-Cutover Checklist
- [ ] **Final Verification**
  - [ ] All tests passing
  - [ ] Performance acceptable
  - [ ] Security validated
  - [ ] Backups current
  - [ ] Team notified

- [ ] **Reduce DNS TTL**
  ```bash
  # 24-48 hours before cutover
  # In your DNS provider, reduce TTL to 300 seconds (5 minutes)
  ```
  - [ ] TTL reduced to 300
  - [ ] Waited for old TTL to expire

### DNS Update
- [ ] **Update DNS Records**
  ```
  # Update A record for archive.adgully.com
  # Old IP: ____________
  # New IP: ____________
  ```
  - [ ] A record updated for archive.adgully.com
  - [ ] A record updated for www.archive.adgully.com (if applicable)
  - [ ] CNAME records updated (if any)
  - [ ] Time of change: _____________

- [ ] **Monitor Propagation**
  ```bash
  # Check DNS propagation
  dig archive.adgully.com +short
  dig @8.8.8.8 archive.adgully.com +short
  dig @1.1.1.1 archive.adgully.com +short
  
  # Check from multiple locations (use online tools)
  # https://www.whatsmydns.net/
  ```
  - [ ] New IP resolving from server
  - [ ] New IP resolving from Google DNS
  - [ ] New IP resolving from Cloudflare DNS
  - [ ] Propagation complete: _____________

### Post-Cutover
- [ ] **Verify New Server Receiving Traffic**
  ```bash
  # Monitor access logs
  sudo tail -f /var/www/archive.adgully.com/logs/access.log
  
  # Check connections
  sudo ss -tn state established '( dport = :443 or sport = :443 )'
  ```
  - [ ] Traffic coming to new server
  - [ ] No errors in logs
  - [ ] User reports positive

- [ ] **Monitor Old Server**
  - [ ] Old server traffic decreasing
  - [ ] Old server access logs reviewed
  - [ ] No new traffic after _______ hours

---

## 🧹 Cleanup

### Finalize Migration
- [ ] **Remove Test Files**
  ```bash
  # Remove any test/debug files
  sudo rm /var/www/archive.adgully.com/public_html/info.php
  sudo rm /var/www/archive.adgully.com/public_html/test.php
  sudo rm /var/www/archive.adgully.com/public_html/debug.log
  ```
  - [ ] Test files removed
  - [ ] Debug code removed
  - [ ] Temporary files cleaned

- [ ] **Update Documentation**
  - [ ] README.md updated with new server info
  - [ ] Configuration documented
  - [ ] Known issues documented
  - [ ] Runbook updated

- [ ] **Restore Normal DNS TTL**
  ```bash
  # Increase TTL back to normal (e.g., 3600 or 86400)
  ```
  - [ ] TTL restored to: _______ seconds

---

## 🎯 Post-Migration Monitoring (First 7 Days)

### Daily Checks
- [ ] **Day 1**
  - [ ] Error logs reviewed: ✅ / ❌
  - [ ] Performance metrics normal: ✅ / ❌
  - [ ] User feedback: _____________

- [ ] **Day 2**
  - [ ] Error logs reviewed: ✅ / ❌
  - [ ] Performance metrics normal: ✅ / ❌
  - [ ] User feedback: _____________

- [ ] **Day 3**
  - [ ] Error logs reviewed: ✅ / ❌
  - [ ] Performance metrics normal: ✅ / ❌
  - [ ] User feedback: _____________

- [ ] **Day 7**
  - [ ] Error logs reviewed: ✅ / ❌
  - [ ] Performance metrics normal: ✅ / ❌
  - [ ] User feedback: _____________
  - [ ] Migration considered successful: ✅ / ❌

---

## 🗑️ Decommission Old Server

### Old Server Shutdown (After 7-14 Days)
- [ ] **Final Old Server Backup**
  - [ ] Full backup created
  - [ ] Backup verified
  - [ ] Backup stored securely

- [ ] **Disable Old Server**
  - [ ] Stop web services
  - [ ] Stop database
  - [ ] Document shutdown time: _____________

- [ ] **Keep Old Server Online** (For 30 days minimum)
  - [ ] Server kept in powered-off but available state
  - [ ] Backups retained
  - [ ] Access maintained if rollback needed

- [ ] **Final Decommissioning** (After 30 days)
  - [ ] Server data wiped
  - [ ] Server terminated/returned
  - [ ] DNS records removed
  - [ ] Documentation archived

---

## ✅ Migration Sign-Off

### Final Validation
- [ ] **Technical Validation**
  - [ ] All functionality working
  - [ ] Performance meets targets
  - [ ] Security validated
  - [ ] No critical errors
  - [ ] Monitoring in place

- [ ] **Business Validation**
  - [ ] Stakeholder approval received
  - [ ] User acceptance testing passed
  - [ ] No major issues reported
  - [ ] Documentation complete

### Sign-Off
- [ ] **Technical Lead**: ____________ (Name & Date)
- [ ] **Project Manager**: ____________ (Name & Date)
- [ ] **Stakeholder**: ____________ (Name & Date)

---

## 🎉 Migration Complete!

**Migration Status**: ✅ SUCCESSFUL / ❌ ISSUES FOUND  
**Completion Date**: _____________  
**Total Downtime**: _______ minutes  
**Issues Encountered**: _____________  
**Lessons Learned**: _____________

---

**Checklist Version**: 1.0  
**Last Updated**: January 11, 2026
