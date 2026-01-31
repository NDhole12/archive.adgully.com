# Server Migration Rulebook

## 🎯 Mission Statement

Migrate archive.adgully.com from a legacy CentOS 7.9 + Apache + PHP 5.6 environment to a modern, secure, and maintainable Ubuntu 22.04 + Nginx + PHP 8.2 stack with **zero data loss** and **minimal downtime**.

---

## 📜 Core Principles

### 1. Safety First
- ✅ **NEVER** make changes directly on production without testing
- ✅ **ALWAYS** maintain working backups before ANY change
- ✅ Test everything on staging environment first
- ✅ Have a rollback plan for every step

### 2. Documentation is Mandatory
- ✅ Document every configuration change
- ✅ Record all commands executed
- ✅ Note any deviations from the plan
- ✅ Update checklists as you progress

### 3. Incremental Migration
- ✅ Break work into small, testable chunks
- ✅ Validate each step before proceeding
- ✅ Don't skip validation steps "to save time"
- ✅ Use feature flags for gradual rollout if possible

### 4. Version Control Everything
- ✅ All configuration files in Git
- ✅ Scripts and automation code versioned
- ✅ Document environment-specific values separately
- ✅ Use `.env` files for secrets (never commit)

---

## 🚨 Critical Rules

### Database Rules
1. **NO direct production database access during business hours**
2. **ALWAYS** test database migrations on a copy first
3. **VERIFY** backup integrity before starting migration
4. **CHECK** character encoding compatibility (UTF-8)
5. **VALIDATE** all foreign keys and constraints post-migration

### Code Compatibility Rules
1. **IDENTIFY** all deprecated PHP functions before migration
2. **TEST** code on PHP 8.2 in development environment first
3. **FIX** strict type errors and warnings (don't suppress)
4. **REMOVE** all `mysql_*` function calls (use mysqli/PDO)
5. **REPLACE** mcrypt with openssl/sodium
6. **UPDATE** ereg functions to preg_* equivalents

### Security Rules
1. **NEVER** use default passwords
2. **ALWAYS** enable firewall (UFW) before going live
3. **ENFORCE** HTTPS/TLS for all connections
4. **DISABLE** root SSH login
5. **ENABLE** fail2ban on all public services
6. **RESTRICT** database access to localhost only (unless required)
7. **SET** proper file permissions (644 files, 755 dirs, 750 for configs)

### Testing Rules
1. **RUN** automated tests after each configuration change
2. **VERIFY** all critical application paths work
3. **CHECK** error logs after each deployment
4. **MONITOR** performance metrics (response time, CPU, memory)
5. **TEST** database connections and queries
6. **VALIDATE** file uploads and permissions

---

## 📋 Mandatory Checklists

### Before ANY Server Work
- [ ] Backups verified and tested
- [ ] Staging environment matches production
- [ ] All team members notified
- [ ] Maintenance window scheduled (if needed)
- [ ] Rollback plan documented

### Before Going Live
- [ ] All tests passing
- [ ] Performance benchmarks acceptable
- [ ] Security scan completed
- [ ] SSL certificates valid
- [ ] DNS records prepared (but not changed)
- [ ] Monitoring and alerts configured

### After Going Live
- [ ] Smoke tests completed
- [ ] Error logs reviewed
- [ ] Performance metrics normal
- [ ] User acceptance testing passed
- [ ] Old server kept online for 1 week minimum

---

## 🔧 Technical Standards

### Server Configuration
- **OS**: Ubuntu 22.04 LTS (latest patches)
- **Web Server**: Nginx 1.18+ (from Ubuntu repos)
- **PHP**: PHP 8.2-FPM (from ondrej/php PPA)
- **Database**: MariaDB 10.11+ (from MariaDB official repos)
- **SSL**: Let's Encrypt with auto-renewal

### PHP Configuration Standards
```ini
; Performance
memory_limit = 256M
max_execution_time = 300
max_input_time = 300
upload_max_filesize = 64M
post_max_size = 64M

; Security
expose_php = Off
display_errors = Off (production)
log_errors = On
error_log = /var/log/php/error.log

; OPcache
opcache.enable = 1
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 10000
opcache.revalidate_freq = 60
```

### Nginx Configuration Standards
- Use separate server blocks for each domain
- Enable gzip compression
- Set proper caching headers
- Configure rate limiting
- Use security headers (HSTS, X-Frame-Options, etc.)
- Proxy timeouts: 300s minimum for API calls

### Database Standards
- Use UTF-8 MB4 character set
- Enable slow query log
- Set max_connections appropriately
- Configure query cache (if using MySQL)
- Regular OPTIMIZE TABLE maintenance

---

## 🔐 Security Standards

### File Permissions
```bash
# Web root
chown -R www-data:www-data /var/www/html
find /var/www/html -type f -exec chmod 644 {} \;
find /var/www/html -type d -exec chmod 755 {} \;

# Configuration files
chmod 640 /etc/nginx/sites-available/*
chmod 640 /etc/php/8.2/fpm/pool.d/*
chown root:root /etc/nginx/nginx.conf

# Application config
chmod 640 /var/www/html/config/*.php
```

### Firewall Rules (UFW)
```bash
# Essential only
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw enable
```

### SSH Hardening
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
Port 22 (or custom)
```

---

## 📊 Performance Targets

| Metric | Target | Action if Exceeded |
|--------|--------|-------------------|
| Page Load Time | < 2s | Investigate bottlenecks |
| Time To First Byte | < 500ms | Optimize server/cache |
| Database Query Time | < 100ms avg | Optimize queries/indexes |
| Server Response Time | < 200ms | Check PHP-FPM workers |
| Memory Usage | < 70% | Scale resources |
| CPU Usage | < 60% | Optimize code/scale |

---

## 🚀 Deployment Process

### 1. Pre-Deployment
1. Code review completed
2. All tests passing
3. Staging validation complete
4. Backup verified
5. Team notified

### 2. Deployment Steps
1. Enable maintenance mode (if applicable)
2. Pull latest code
3. Run database migrations (if any)
4. Clear caches
5. Restart PHP-FPM
6. Reload Nginx
7. Disable maintenance mode
8. Run smoke tests

### 3. Post-Deployment
1. Monitor error logs (30 minutes)
2. Check performance metrics
3. Verify critical features
4. Update documentation
5. Notify team of completion

---

## 🆘 Rollback Procedures

### If Critical Issue Detected
1. **STOP** all deployment activity immediately
2. Enable maintenance mode
3. Restore from most recent backup
4. Revert DNS if changed
5. Document what went wrong
6. Schedule post-mortem

### Rollback Decision Matrix
| Severity | Response Time | Action |
|----------|--------------|--------|
| Critical (site down) | Immediate | Full rollback |
| High (major feature broken) | 15 minutes | Rollback or hotfix |
| Medium (minor issue) | 1 hour | Hotfix acceptable |
| Low (cosmetic) | Next deployment | Add to backlog |

---

## 📞 Escalation Path

1. **Level 1**: Check logs and documentation
2. **Level 2**: Review troubleshooting guide
3. **Level 3**: Consult team lead/senior dev
4. **Level 4**: Consider rollback
5. **Level 5**: Emergency vendor support (if applicable)

---

## ✅ Success Criteria

Migration is considered successful when:
- [ ] All application features working as expected
- [ ] Performance meets or exceeds old server
- [ ] No critical errors in logs for 24 hours
- [ ] All automated tests passing
- [ ] User acceptance testing completed
- [ ] Old server successfully decommissioned after retention period
- [ ] Documentation updated and complete
- [ ] Team trained on new infrastructure

---

## 🔄 Continuous Improvement

### Post-Migration Review (Required)
- What went well?
- What could be improved?
- Were time estimates accurate?
- Any unexpected issues?
- Documentation gaps identified?
- Update this rulebook based on learnings

---

**Version**: 1.0  
**Last Updated**: January 11, 2026  
**Status**: Active
