# Quick Command Reference
## Archive.adgully.com Migration - Essential Commands

> **Quick access to all commands you'll need during migration**

---

## 🔐 Server Access

### Old Server (CentOS 7.9)
```bash
ssh root@172.31.21.197
# Password: byCdgzMr5AHx
```

### New Server (Ubuntu 22.04)
```bash
ssh root@YOUR_NEW_SERVER_IP
```

---

## 📊 Audit Commands (Old Server)

### System Information
```bash
# OS details
cat /etc/*release
uname -a
hostname -f

# Resources
df -h
free -m
uptime
```

### Web Server
```bash
# Apache version and modules
httpd -v
apachectl -M
systemctl status httpd

# Apache config
cat /etc/httpd/conf/httpd.conf
grep DocumentRoot /etc/httpd/conf/httpd.conf
```

### PHP Information
```bash
# PHP version and modules
php -v
php -m
php -i

# PHP config
cat /etc/php.ini
ls -la /etc/php.d/
```

### Database
```bash
# MariaDB/MySQL version
mysql -V
systemctl status mariadb

# Database info
mysql -u root -p -e "SHOW DATABASES;"
mysql -u root -p -e "SHOW VARIABLES LIKE '%version%';"
mysql -u root -p -e "SELECT User, Host FROM mysql.user;"
```

### Application
```bash
# Find web root
grep DocumentRoot /etc/httpd/conf/httpd.conf

# Application size
du -sh /var/www/html/
ls -lah /var/www/html/

# Count PHP files
find /var/www/html -name "*.php" | wc -l
```

---

## 💾 Backup Commands (Old Server)

### Database Backup
```bash
# Single database
mysqldump -u root -p database_name > backup-$(date +%Y%m%d).sql

# All databases
mysqldump --all-databases --single-transaction --quick --lock-tables=false \
  -u root -p > all-db-$(date +%Y%m%d).sql

# Compress
gzip backup-$(date +%Y%m%d).sql
```

### Files Backup
```bash
# Web files
tar -czf web-backup-$(date +%Y%m%d).tar.gz \
  --exclude='*.log' \
  --exclude='cache/*' \
  --exclude='tmp/*' \
  /var/www/html/

# Verify backup
tar -tzf web-backup-*.tar.gz | head -20
ls -lh web-backup-*.tar.gz
```

### Download to Windows
```powershell
# In PowerShell on Windows
scp root@172.31.21.197:/root/backups/*.sql.gz D:\archive.adgully.com\backups\
scp root@172.31.21.197:/root/backups/*.tar.gz D:\archive.adgully.com\backups\
```

---

## 🔍 Deprecation Scanning

### On Linux (Old Server or Git Bash)
```bash
# Scan for deprecated functions
grep -rn "mysql_connect\|mysql_query\|mysql_fetch" /path/to/code/
grep -rn "mcrypt_encrypt\|mcrypt_decrypt" /path/to/code/
grep -rn "\bereg\b|\beregi\b|\bsplit\b" /path/to/code/
grep -rn "each(" /path/to/code/

# Using script
bash scripts/validation/find-deprecated.sh /var/www/html/
```

### On Windows PowerShell
```powershell
# Search for deprecated functions
$patterns = @('mysql_connect', 'mysql_query', 'mcrypt_encrypt', 'ereg(')
Get-ChildItem -Path "D:\path\to\code" -Filter "*.php" -Recurse | 
  Select-String -Pattern $patterns |
  Format-Table Path, LineNumber, Line -AutoSize
```

---

## 🏗️ New Server Installation (Ubuntu 22.04)

### System Update
```bash
# Update system
apt update && apt upgrade -y
apt autoremove -y

# Set hostname
hostnamectl set-hostname archive.adgully.com
```

### Install LEMP Stack
```bash
# Nginx
apt install -y nginx
systemctl enable nginx
systemctl start nginx

# PHP 8.2
apt install -y php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl \
  php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-opcache \
  php8.2-redis php8.2-mongodb php8.2-tidy php8.2-intl
systemctl enable php8.2-fpm
systemctl start php8.2-fpm

# MariaDB 10.11
apt install -y mariadb-server mariadb-client
systemctl enable mariadb
systemctl start mariadb
mysql_secure_installation
```

### Install Security Tools
```bash
# Firewall
apt install -y ufw
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Fail2ban
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# SSL
apt install -y certbot python3-certbot-nginx
```

---

## ⚙️ Configuration Commands (New Server)

### Nginx Setup
```bash
# Test configuration
nginx -t

# Reload/Restart
systemctl reload nginx
systemctl restart nginx

# Enable site
ln -s /etc/nginx/sites-available/archive.adgully.com /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
```

### PHP-FPM Setup
```bash
# Test configuration
php-fpm8.2 -t

# Restart
systemctl restart php8.2-fpm

# Check status
systemctl status php8.2-fpm

# Check socket
ls -la /run/php/php8.2-fpm.sock
```

### MariaDB Setup
```bash
# Create database
mysql -u root -p
CREATE DATABASE archive_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'archive_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON archive_db.* TO 'archive_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import database
mysql -u root -p archive_db < backup.sql

# Verify
mysql -u root -p -e "USE archive_db; SHOW TABLES;"
```

### SSL Certificate
```bash
# Install Let's Encrypt certificate
certbot --nginx -d archive.adgully.com -d www.archive.adgully.com

# Test renewal
certbot renew --dry-run

# Manual renewal
certbot renew
```

---

## 📦 File Deployment

### Upload Files
```bash
# Create directory
mkdir -p /var/www/archive.adgully.com
cd /var/www/archive.adgully.com

# Upload via SCP (from Windows)
# scp -r local/path/* root@server:/var/www/archive.adgully.com/
```

### Set Permissions
```bash
# Set ownership
chown -R www-data:www-data /var/www/archive.adgully.com

# Set permissions
find /var/www/archive.adgully.com -type d -exec chmod 755 {} \;
find /var/www/archive.adgully.com -type f -exec chmod 644 {} \;

# Writable directories
chmod -R 775 /var/www/archive.adgully.com/uploads
chmod -R 775 /var/www/archive.adgully.com/cache
```

---

## 🔧 Maintenance Commands

### Service Management
```bash
# Check all services
systemctl status nginx
systemctl status php8.2-fpm
systemctl status mariadb
systemctl status fail2ban

# Restart services
systemctl restart nginx
systemctl restart php8.2-fpm
systemctl restart mariadb

# Enable on boot
systemctl enable nginx
systemctl enable php8.2-fpm
systemctl enable mariadb
```

### Log Monitoring
```bash
# Real-time logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
tail -f /var/log/php8.2-fpm.log
tail -f /var/log/mysql/error.log

# Recent errors
tail -100 /var/log/nginx/error.log
grep -i "error\|critical" /var/log/nginx/error.log | tail -50
grep -i "error\|warning" /var/log/php8.2-fpm.log | tail -50
```

### Resource Monitoring
```bash
# CPU, Memory, Processes
htop
top
free -m
df -h

# Network
netstat -tulpn
ss -tulpn

# Disk I/O
iostat -x 1 10
```

---

## 🔐 Security Commands

### Firewall (UFW)
```bash
# Status
ufw status verbose

# Allow/Deny
ufw allow 80/tcp
ufw deny 3306/tcp

# Reset
ufw reset
```

### Fail2ban
```bash
# Status
fail2ban-client status

# Check jail
fail2ban-client status sshd
fail2ban-client status nginx-http-auth

# Unban IP
fail2ban-client set sshd unbanip 1.2.3.4
```

### SSH Hardening
```bash
# Edit SSH config
nano /etc/ssh/sshd_config

# Change:
# Port 22 -> Port 2222 (optional)
# PermitRootLogin yes -> PermitRootLogin no
# PasswordAuthentication yes -> PasswordAuthentication no (after setting up keys)

# Restart SSH
systemctl restart sshd
```

---

## 🧪 Testing Commands

### Website Testing
```bash
# HTTP response
curl -I https://archive.adgully.com

# Full page
curl -L https://archive.adgully.com

# Response time
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://archive.adgully.com

# Test with specific host (before DNS change)
curl -H "Host: archive.adgully.com" http://YOUR_NEW_SERVER_IP/
```

### Health Checks
```bash
# Run health check script
bash scripts/validation/health-check.sh

# Test website script
bash scripts/validation/test-website.sh archive.adgully.com

# Manual checks
systemctl is-active nginx
systemctl is-active php8.2-fpm
systemctl is-active mariadb
```

### Database Testing
```bash
# Test connection
mysql -u archive_user -p -e "SELECT 1;"

# Query performance
mysql -u root -p -e "SHOW PROCESSLIST;"
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"

# Slow queries
tail -50 /var/log/mysql/slow-query.log
```

---

## 🌐 DNS Commands

### Check DNS
```powershell
# Windows
nslookup archive.adgully.com
ping archive.adgully.com

# Check specific DNS server
nslookup archive.adgully.com 8.8.8.8
```

```bash
# Linux
dig archive.adgully.com
host archive.adgully.com

# Check TTL
dig archive.adgully.com +noall +answer
```

### Hosts File Testing
```powershell
# Windows - Edit as Administrator
notepad C:\Windows\System32\drivers\etc\hosts

# Add for testing:
# YOUR_NEW_SERVER_IP archive.adgully.com

# Flush DNS cache
ipconfig /flushdns
```

---

## 📊 Performance Tuning

### PHP-FPM Optimization
```bash
# Check PHP-FPM status
systemctl status php8.2-fpm

# View pool configuration
cat /etc/php/8.2/fpm/pool.d/archive.conf

# Monitor pool
watch -n 1 'ps aux | grep php-fpm | wc -l'

# Restart pool
systemctl restart php8.2-fpm
```

### MySQL Optimization
```bash
# Check variables
mysql -u root -p -e "SHOW VARIABLES LIKE 'max_connections';"
mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"

# Check status
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"
mysql -u root -p -e "SHOW STATUS LIKE 'Questions';"

# Optimize tables
mysql -u root -p -e "OPTIMIZE TABLE archive_db.table_name;"
```

### Nginx Optimization
```bash
# Test configuration
nginx -t

# Check worker processes
ps aux | grep nginx

# Access log analysis
tail -1000 /var/log/nginx/access.log | awk '{print $9}' | sort | uniq -c | sort -rn
```

---

## 🔄 Backup Automation

### Cron Jobs Setup
```bash
# Edit crontab
crontab -e

# Daily database backup (2 AM)
0 2 * * * /root/scripts/migration/backup-database.sh >> /var/log/backup.log 2>&1

# Weekly files backup (Sunday 3 AM)
0 3 * * 0 /root/scripts/migration/backup-files.sh >> /var/log/backup.log 2>&1

# Health check every 15 minutes
*/15 * * * * /root/scripts/validation/health-check.sh >> /var/log/health.log 2>&1

# List cron jobs
crontab -l
```

---

## 🆘 Emergency Commands

### Quick Restart Everything
```bash
systemctl restart nginx php8.2-fpm mariadb
```

### Emergency Maintenance Mode
```bash
# Create maintenance page
cat > /var/www/archive.adgully.com/maintenance.html <<'EOF'
<!DOCTYPE html>
<html><head><title>Maintenance</title></head>
<body><h1>Under Maintenance</h1><p>Back soon!</p></body>
</html>
EOF

# Redirect all traffic (create .htaccess or nginx config)
```

### Quick Log Check
```bash
# Last 50 errors
tail -50 /var/log/nginx/error.log
tail -50 /var/log/php8.2-fpm.log

# Count error lines
grep -c "error" /var/log/nginx/error.log
```

### Rollback DNS (Emergency)
```bash
# In DNS control panel:
# Change A record back to old IP: 172.31.21.197
# With 300s TTL, propagation takes 5-10 minutes
```

---

## 📋 Status Checks

### Quick Health Check
```bash
# One-liner status check
echo "Nginx: $(systemctl is-active nginx) | PHP: $(systemctl is-active php8.2-fpm) | MariaDB: $(systemctl is-active mariadb) | Disk: $(df -h / | awk 'NR==2 {print $5}')"

# Detailed check
systemctl status nginx php8.2-fpm mariadb --no-pager
```

### Port Check
```bash
# Check listening ports
netstat -tulpn | grep -E '(:80|:443|:3306|:22)'
ss -tulpn | grep -E '(:80|:443|:3306|:22)'

# Test port connectivity (from another machine)
telnet YOUR_SERVER_IP 80
nc -zv YOUR_SERVER_IP 80
```

---

## 🎯 Common Tasks Workflow

### Deploy Code Update
```bash
# 1. Backup current code
cd /var/www/archive.adgully.com
tar -czf ../backup-$(date +%Y%m%d-%H%M).tar.gz .

# 2. Upload new files (via SCP from Windows)

# 3. Set permissions
chown -R www-data:www-data .
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

# 4. Clear cache (if applicable)
rm -rf cache/* tmp/*

# 5. Restart PHP-FPM
systemctl restart php8.2-fpm

# 6. Test
curl -I https://archive.adgully.com
```

### Update Configuration
```bash
# 1. Backup current config
cp /etc/nginx/sites-available/archive.adgully.com{,.backup}

# 2. Edit config
nano /etc/nginx/sites-available/archive.adgully.com

# 3. Test configuration
nginx -t

# 4. Reload if OK
systemctl reload nginx
```

### Database Maintenance
```bash
# 1. Backup database
mysqldump archive_db -u root -p > backup-$(date +%Y%m%d).sql

# 2. Run query or update schema
mysql -u root -p archive_db < update.sql

# 3. Optimize tables
mysql -u root -p -e "USE archive_db; OPTIMIZE TABLE table1, table2;"

# 4. Verify
mysql -u root -p -e "USE archive_db; SHOW TABLES;"
```

---

## 📞 Quick Reference Scripts

All scripts located in: `D:\archive.adgully.com\scripts\`

### Installation
- `scripts/install/full-install.sh` - Complete server setup

### Migration
- `scripts/migration/backup-database.sh` - Database backup
- `scripts/migration/backup-files.sh` - Files backup

### Validation
- `scripts/validation/find-deprecated.sh` - Find deprecated PHP code
- `scripts/validation/health-check.sh` - Server health monitoring
- `scripts/validation/test-website.sh` - Website functionality test
- `scripts/validation/server-audit.sh` - Remote server audit

### Configuration
- `configs/nginx/archive.adgully.com.conf` - Nginx server block
- `configs/php/php-custom.ini` - Custom PHP settings
- `configs/php/archive-pool.conf` - PHP-FPM pool
- `configs/mariadb/mariadb-custom.cnf` - MariaDB optimization
- `configs/security/ufw-rules.sh` - Firewall rules
- `configs/security/fail2ban-jail.local` - Fail2ban config

---

## 💡 Pro Tips

### Useful Aliases (Add to ~/.bashrc)
```bash
alias ll='ls -lah'
alias logs='cd /var/log'
alias www='cd /var/www/archive.adgully.com'
alias nginx-reload='nginx -t && systemctl reload nginx'
alias php-restart='systemctl restart php8.2-fpm'
alias tail-nginx='tail -f /var/log/nginx/error.log'
alias tail-php='tail -f /var/log/php8.2-fpm.log'
alias check-services='systemctl status nginx php8.2-fpm mariadb --no-pager'
```

### Quick Fixes
```bash
# PHP session permission issue
chown -R www-data:www-data /var/lib/php/sessions

# Nginx 502 error
systemctl restart php8.2-fpm

# Database connection issue
systemctl restart mariadb

# Clear OPcache
systemctl restart php8.2-fpm

# Fix file permissions
cd /var/www/archive.adgully.com && chown -R www-data:www-data . && find . -type d -exec chmod 755 {} \; && find . -type f -exec chmod 644 {} \;
```

---

**Keep this file open during migration for quick command access!** 📋

---

*Last Updated: January 11, 2026*
