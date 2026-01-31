# Troubleshooting Guide

Common issues and solutions during server migration and operation.

---

## 🔴 Critical Issues

### 1. Website Not Loading (502 Bad Gateway)

**Symptoms**:
- Nginx returns 502 error
- "Bad Gateway" message

**Diagnosis**:
```bash
# Check PHP-FPM status
sudo systemctl status php8.2-fpm

# Check PHP-FPM error logs
sudo tail -50 /var/log/php/fpm-error.log

# Check if socket exists
ls -la /run/php/php8.2-fpm.sock
```

**Common Causes**:
1. **PHP-FPM not running**
   ```bash
   # Start PHP-FPM
   sudo systemctl start php8.2-fpm
   ```

2. **Socket permission issues**
   ```bash
   # Check nginx user matches PHP-FPM config
   ps aux | grep nginx
   
   # Fix permissions in /etc/php/8.2/fpm/pool.d/www.conf
   sudo vim /etc/php/8.2/fpm/pool.d/www.conf
   # Ensure: listen.owner = www-data, listen.group = www-data
   
   sudo systemctl restart php8.2-fpm
   ```

3. **PHP-FPM crashed due to memory**
   ```bash
   # Increase memory in php.ini
   sudo vim /etc/php/8.2/fpm/php.ini
   # Set: memory_limit = 256M (or higher)
   
   sudo systemctl restart php8.2-fpm
   ```

---

### 2. Database Connection Failed

**Symptoms**:
- "Could not connect to database" error
- "Access denied for user" error

**Diagnosis**:
```bash
# Test database connection
mysql -u archive_user -p archive_db

# Check MySQL is running
sudo systemctl status mariadb

# Check error logs
sudo tail -50 /var/log/mysql/error.log
```

**Solutions**:

1. **Wrong credentials**
   ```php
   // Verify config.php or .env file has correct credentials
   // Check: username, password, database name, host
   ```

2. **User doesn't have permissions**
   ```sql
   -- Login as root
   sudo mysql -u root -p
   
   -- Grant permissions
   GRANT ALL PRIVILEGES ON archive_db.* TO 'archive_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

3. **MariaDB not running**
   ```bash
   sudo systemctl start mariadb
   sudo systemctl enable mariadb
   ```

4. **Can't connect to socket**
   ```bash
   # Check socket location
   mysql_config --socket
   
   # Update php.ini
   sudo vim /etc/php/8.2/fpm/php.ini
   # Add: mysqli.default_socket = /var/run/mysqld/mysqld.sock
   
   sudo systemctl restart php8.2-fpm
   ```

---

### 3. 500 Internal Server Error

**Symptoms**:
- Blank page or generic error
- "Internal Server Error" message

**Diagnosis**:
```bash
# Check Nginx error log
sudo tail -50 /var/log/nginx/error.log
sudo tail -50 /var/www/archive.adgully.com/logs/error.log

# Check PHP error log
sudo tail -50 /var/log/php/error.log

# Check application log (if exists)
sudo tail -50 /var/www/archive.adgully.com/public_html/logs/app.log
```

**Common Causes**:

1. **PHP syntax error**
   ```bash
   # Check PHP files for errors
   php -l /var/www/archive.adgully.com/public_html/index.php
   ```

2. **Missing PHP extension**
   ```bash
   # Check loaded extensions
   php -m
   
   # Install missing extension (example)
   sudo apt install php8.2-gd
   sudo systemctl restart php8.2-fpm
   ```

3. **Permission denied**
   ```bash
   # Fix permissions
   sudo chown -R www-data:www-data /var/www/archive.adgully.com/public_html
   sudo find /var/www/archive.adgully.com/public_html -type f -exec chmod 644 {} \;
   sudo find /var/www/archive.adgully.com/public_html -type d -exec chmod 755 {} \;
   ```

4. **.htaccess directives not working**
   ```bash
   # Convert .htaccess rules to Nginx format
   # See section below on .htaccess conversion
   ```

---

### 4. SSL Certificate Issues

**Symptoms**:
- "Your connection is not private" warning
- Certificate expired or invalid

**Diagnosis**:
```bash
# Check certificate status
sudo certbot certificates

# Check certificate expiry
openssl x509 -in /etc/letsencrypt/live/archive.adgully.com/cert.pem -noout -dates

# Test SSL configuration
openssl s_client -connect archive.adgully.com:443 -servername archive.adgully.com
```

**Solutions**:

1. **Certificate expired**
   ```bash
   # Renew certificate
   sudo certbot renew
   
   # Force renew
   sudo certbot renew --force-renewal
   
   # Reload Nginx
   sudo systemctl reload nginx
   ```

2. **Auto-renewal not working**
   ```bash
   # Check certbot timer
   sudo systemctl status certbot.timer
   
   # Enable timer
   sudo systemctl enable certbot.timer
   sudo systemctl start certbot.timer
   
   # Test renewal
   sudo certbot renew --dry-run
   ```

3. **Certificate for wrong domain**
   ```bash
   # Delete old certificate
   sudo certbot delete --cert-name archive.adgully.com
   
   # Obtain new certificate
   sudo certbot --nginx -d archive.adgully.com -d www.archive.adgully.com
   ```

---

## 🟠 Common Issues

### 5. Slow Page Load Times

**Diagnosis**:
```bash
# Check server resources
htop
free -h
df -h

# Check PHP-FPM status
sudo systemctl status php8.2-fpm

# Check slow query log
sudo tail -50 /var/log/mysql/mysql-slow.log

# Test page load time
time curl -s https://archive.adgully.com/ > /dev/null
```

**Solutions**:

1. **Increase PHP-FPM workers**
   ```bash
   sudo vim /etc/php/8.2/fpm/pool.d/www.conf
   
   # Adjust these values:
   pm.max_children = 50
   pm.start_servers = 10
   pm.min_spare_servers = 5
   pm.max_spare_servers = 20
   
   sudo systemctl restart php8.2-fpm
   ```

2. **Enable OPcache** (should already be enabled)
   ```bash
   # Verify OPcache is enabled
   php -i | grep opcache.enable
   
   # If not, enable it
   sudo vim /etc/php/8.2/fpm/conf.d/99-custom.ini
   # Add: opcache.enable = 1
   
   sudo systemctl restart php8.2-fpm
   ```

3. **Optimize database queries**
   ```sql
   -- Find slow queries
   SELECT * FROM mysql.slow_log ORDER BY query_time DESC LIMIT 10;
   
   -- Add indexes to frequently queried columns
   ALTER TABLE table_name ADD INDEX idx_column_name (column_name);
   ```

4. **Enable query caching** (if using Redis)
   ```bash
   # Install Redis
   sudo apt install redis-server
   
   # Configure application to use Redis for caching
   # (depends on your application framework)
   ```

---

### 6. File Upload Not Working

**Symptoms**:
- Upload fails silently
- "File too large" error
- Permission denied

**Diagnosis**:
```bash
# Check PHP upload settings
php -i | grep -E 'upload_max_filesize|post_max_size|max_file_uploads'

# Check upload directory permissions
ls -la /var/www/archive.adgully.com/public_html/uploads/

# Check Nginx client_max_body_size
grep -r "client_max_body_size" /etc/nginx/
```

**Solutions**:

1. **Increase upload limits**
   ```bash
   sudo vim /etc/php/8.2/fpm/conf.d/99-custom.ini
   
   # Add or modify:
   upload_max_filesize = 64M
   post_max_size = 64M
   max_file_uploads = 20
   
   sudo systemctl restart php8.2-fpm
   ```

2. **Increase Nginx limit**
   ```bash
   sudo vim /etc/nginx/nginx.conf
   
   # Add in http block:
   client_max_body_size 64M;
   
   sudo nginx -t
   sudo systemctl reload nginx
   ```

3. **Fix upload directory permissions**
   ```bash
   sudo chown -R www-data:www-data /var/www/archive.adgully.com/public_html/uploads/
   sudo chmod 775 /var/www/archive.adgully.com/public_html/uploads/
   ```

---

### 7. Session Not Persisting

**Symptoms**:
- Users logged out immediately
- Session data not saved

**Diagnosis**:
```bash
# Check session directory
ls -la /var/lib/php/sessions/

# Check PHP session settings
php -i | grep -E 'session.save_path|session.gc_'

# Check logs for session errors
sudo grep -i session /var/log/php/error.log
```

**Solutions**:

1. **Fix session directory permissions**
   ```bash
   sudo chown -R www-data:www-data /var/lib/php/sessions/
   sudo chmod 1733 /var/lib/php/sessions/
   ```

2. **Configure session in php.ini**
   ```bash
   sudo vim /etc/php/8.2/fpm/conf.d/99-custom.ini
   
   # Add:
   session.save_path = "/var/lib/php/sessions"
   session.gc_maxlifetime = 1440
   session.cookie_lifetime = 0
   session.cookie_httponly = 1
   
   sudo systemctl restart php8.2-fpm
   ```

3. **Use Redis for sessions** (better for load balancing)
   ```bash
   # Install Redis PHP extension
   sudo apt install php8.2-redis
   
   # Configure session handler
   sudo vim /etc/php/8.2/fpm/conf.d/99-custom.ini
   
   # Add:
   session.save_handler = redis
   session.save_path = "tcp://127.0.0.1:6379"
   
   sudo systemctl restart php8.2-fpm
   ```

---

### 8. Emails Not Sending

**Symptoms**:
- Contact form not working
- No email notifications

**Diagnosis**:
```bash
# Check mail logs
sudo tail -50 /var/log/mail.log

# Test mail function
php -r "mail('test@example.com', 'Test', 'Test message');"

# Check if mail service is running
sudo systemctl status postfix  # or sendmail
```

**Solutions**:

1. **Install mail server**
   ```bash
   # Install Postfix
   sudo apt install postfix
   
   # Configure as "Internet Site"
   sudo dpkg-reconfigure postfix
   
   # Start service
   sudo systemctl start postfix
   sudo systemctl enable postfix
   ```

2. **Use SMTP instead** (recommended)
   ```php
   // Use PHPMailer or similar library
   // Don't rely on PHP's mail() function
   
   // Example with PHPMailer:
   $mail = new PHPMailer();
   $mail->isSMTP();
   $mail->Host = 'smtp.gmail.com';
   $mail->SMTPAuth = true;
   $mail->Username = 'your-email@gmail.com';
   $mail->Password = 'your-password';
   $mail->SMTPSecure = 'tls';
   $mail->Port = 587;
   ```

---

### 9. Cron Jobs Not Running

**Symptoms**:
- Scheduled tasks not executing
- Database cleanup not happening

**Diagnosis**:
```bash
# List cron jobs
crontab -l
sudo crontab -l  # root cron

# Check cron logs
sudo tail -50 /var/log/syslog | grep CRON

# Check if cron service is running
sudo systemctl status cron
```

**Solutions**:

1. **Install cron jobs**
   ```bash
   # Edit user crontab
   crontab -e
   
   # Add jobs (example):
   # Run every day at 2 AM
   0 2 * * * /usr/bin/php /var/www/archive.adgully.com/public_html/cron/daily.php
   
   # Run every hour
   0 * * * * /usr/bin/php /var/www/archive.adgully.com/public_html/cron/hourly.php
   ```

2. **Fix PHP path in cron**
   ```bash
   # Find PHP path
   which php
   
   # Use full path in crontab
   0 2 * * * /usr/bin/php8.2 /path/to/script.php
   ```

3. **Add logging to cron jobs**
   ```bash
   # Redirect output to log file
   0 2 * * * /usr/bin/php /path/to/script.php >> /var/log/cron-daily.log 2>&1
   ```

---

## 🟡 PHP 8.2 Compatibility Issues

### 10. "Call to undefined function mysql_connect()"

**Solution**: See [PHP Compatibility Guide](PHP_COMPATIBILITY.md#mysql-extension)

Replace all `mysql_*` functions with `mysqli_*` or PDO.

---

### 11. "Call to undefined function ereg()"

**Solution**: See [PHP Compatibility Guide](PHP_COMPATIBILITY.md#ereg-extension)

Replace with `preg_match()`:
```php
// Old
if (ereg("pattern", $string)) { }

// New
if (preg_match("/pattern/", $string)) { }
```

---

### 12. "Undefined variable" Warnings

**Diagnosis**:
```bash
# Enable error reporting temporarily
sudo vim /etc/php/8.2/fpm/conf.d/99-custom.ini

# Add:
display_errors = On
error_reporting = E_ALL

sudo systemctl restart php8.2-fpm
```

**Solution**:
```php
// Old (PHP 5.6 tolerates)
echo $maybe_undefined;

// New (PHP 8.2 requires)
echo $maybe_undefined ?? 'default';

// Or
if (isset($maybe_undefined)) {
    echo $maybe_undefined;
}
```

---

## 🔧 Nginx Configuration Issues

### 13. .htaccess Rules Not Working

**Problem**: Apache `.htaccess` files don't work with Nginx

**Solution**: Convert rules to Nginx format

**Common Conversions**:

1. **Rewrite rules**:
   ```apache
   # .htaccess (Apache)
   RewriteEngine On
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule ^(.*)$ index.php?url=$1 [QSA,L]
   ```
   
   ```nginx
   # Nginx equivalent
   location / {
       try_files $uri $uri/ /index.php?url=$uri&$args;
   }
   ```

2. **Deny access to files**:
   ```apache
   # .htaccess
   <Files "config.php">
       Deny from all
   </Files>
   ```
   
   ```nginx
   # Nginx equivalent
   location ~ /config\.php$ {
       deny all;
   }
   ```

3. **Custom error pages**:
   ```apache
   # .htaccess
   ErrorDocument 404 /404.php
   ```
   
   ```nginx
   # Nginx equivalent
   error_page 404 /404.php;
   ```

---

## 📊 Performance Issues

### 14. High Memory Usage

**Diagnosis**:
```bash
# Check memory usage
free -h

# Check which process uses memory
ps aux --sort=-%mem | head -10

# Check PHP-FPM memory
ps aux | grep php-fpm | awk '{sum+=$6} END {print sum/1024 " MB"}'
```

**Solutions**:

1. **Reduce PHP-FPM workers**:
   ```bash
   sudo vim /etc/php/8.2/fpm/pool.d/www.conf
   
   pm.max_children = 20  # Reduce from 50
   pm.start_servers = 3
   pm.min_spare_servers = 2
   pm.max_spare_servers = 5
   
   sudo systemctl restart php8.2-fpm
   ```

2. **Increase swap**:
   ```bash
   # Create 2GB swap file
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   
   # Make permanent
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

---

### 15. High CPU Usage

**Diagnosis**:
```bash
# Monitor CPU
htop

# Find CPU-intensive processes
ps aux --sort=-%cpu | head -10

# Check MariaDB
mysqladmin -u root -p processlist
```

**Solutions**:

1. **Optimize database queries** (see slow query log)
2. **Enable OPcache** (should already be enabled)
3. **Reduce PHP-FPM request handling**:
   ```bash
   sudo vim /etc/php/8.2/fpm/pool.d/www.conf
   
   pm.max_requests = 200  # Reduce from 500
   
   sudo systemctl restart php8.2-fpm
   ```

---

## 🆘 Emergency Procedures

### Complete Service Restart
```bash
# Restart all services
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
sudo systemctl restart mariadb
sudo systemctl restart redis  # if installed

# Check status
sudo systemctl status nginx php8.2-fpm mariadb
```

### Enable Maintenance Mode
```bash
# Create maintenance.html
sudo tee /var/www/archive.adgully.com/public_html/maintenance.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Maintenance Mode</title>
</head>
<body>
    <h1>Site Under Maintenance</h1>
    <p>We'll be back soon!</p>
</body>
</html>
EOF

# Update Nginx to serve maintenance page
sudo vim /etc/nginx/sites-available/archive.adgully.com

# Add at top of server block:
# if (-f /var/www/archive.adgully.com/public_html/maintenance.html) {
#     return 503;
# }
# error_page 503 @maintenance;
# location @maintenance {
#     rewrite ^(.*)$ /maintenance.html break;
# }

sudo systemctl reload nginx

# To disable: remove or rename maintenance.html
```

### Rollback to Old Server
```bash
# 1. Update DNS back to old IP
# 2. Wait for propagation
# 3. Investigate issues on new server
```

---

## 📞 Getting Help

If issues persist:

1. **Check documentation**: Review all guides in `docs/`
2. **Review logs**: Check all error logs systematically
3. **Search online**: PHP/Nginx/MariaDB documentation
4. **Community forums**: Stack Overflow, ServerFault
5. **Professional support**: Consider hiring a sysadmin

---

**Version**: 1.0  
**Last Updated**: January 11, 2026
