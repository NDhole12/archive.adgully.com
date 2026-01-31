# Quick Start Guide - Archive.adgully.com Migration

This is your quickstart guide to begin the server migration process.

---

## 📋 Overview

**What you're migrating:**
- **From**: CentOS 7.9 + Apache + PHP 5.6 (EOL, insecure)
- **To**: Ubuntu 22.04 + Nginx + PHP 8.2 (Modern, secure, supported)

**Timeline estimate:** 7-14 days (depending on application complexity)

---

## 🚀 Getting Started (First Steps)

### Step 1: Read the Documentation (30 minutes)
Start here, in this order:
1. **[README.md](README.md)** - Project overview
2. **[RULEBOOK.md](docs/RULEBOOK.md)** - Critical migration rules
3. **[PRE_MIGRATION_CHECKLIST.md](docs/PRE_MIGRATION_CHECKLIST.md)** - What you need to do first

### Step 2: Audit Your Current Server (2-4 hours)
Complete the **PRE_MIGRATION_CHECKLIST.md**:
- [ ] Document current server configuration
- [ ] Create full backups (database + files)
- [ ] Scan code for PHP compatibility issues
- [ ] Set up staging environment

**Run this script on old server:**
```bash
# Collect server info
uname -a
cat /etc/*release
php -v
php -m
mysql -V
```

**Scan your code for compatibility issues:**
```bash
# On your local machine (after downloading code)
bash scripts/validation/find-deprecated.sh /path/to/your/code
```

### Step 3: Set Up New Server (2-4 hours)
Follow **[INSTALLATION_GUIDE.md](docs/INSTALLATION_GUIDE.md)** or use automation:

**Option A: Automated Installation (Recommended)**
```bash
# On your NEW Ubuntu 22.04 server
wget https://raw.githubusercontent.com/[your-repo]/archive.adgully.com/main/scripts/install/full-install.sh
sudo bash full-install.sh
```

**Option B: Manual Installation**
Follow each step in INSTALLATION_GUIDE.md

### Step 4: Deploy to Staging (1-2 days)
- Upload your application files
- Import database
- Fix PHP compatibility issues
- Test thoroughly

### Step 5: Go Live (1 day)
Follow **[POST_MIGRATION_CHECKLIST.md](docs/POST_MIGRATION_CHECKLIST.md)**:
- Final testing
- DNS cutover
- Monitor for issues
- Keep old server available for rollback

---

## 📁 Key Files You'll Need

### Documentation
| File | Purpose | When to Use |
|------|---------|-------------|
| [RULEBOOK.md](docs/RULEBOOK.md) | Migration rules & standards | Before starting, reference throughout |
| [PRE_MIGRATION_CHECKLIST.md](docs/PRE_MIGRATION_CHECKLIST.md) | Pre-migration audit | Before touching anything |
| [INSTALLATION_GUIDE.md](docs/INSTALLATION_GUIDE.md) | Server setup steps | When provisioning new server |
| [POST_MIGRATION_CHECKLIST.md](docs/POST_MIGRATION_CHECKLIST.md) | Post-migration validation | After deployment, before DNS change |
| [PHP_COMPATIBILITY.md](docs/PHP_COMPATIBILITY.md) | PHP 5.6 → 8.2 guide | When fixing code compatibility |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common problems | When something breaks |

### Configuration Templates
| File | Copy To | Purpose |
|------|---------|---------|
| `configs/nginx/archive.adgully.com.conf` | `/etc/nginx/sites-available/` | Nginx server block |
| `configs/php/php-custom.ini` | `/etc/php/8.2/fpm/conf.d/` | PHP settings |
| `configs/mariadb/mariadb-custom.cnf` | `/etc/mysql/mariadb.conf.d/` | Database optimization |
| `configs/security/fail2ban-jail.local` | `/etc/fail2ban/` | Security rules |

### Automation Scripts
| Script | Purpose | When to Run |
|--------|---------|-------------|
| `scripts/install/full-install.sh` | Complete server setup | Once on new server |
| `scripts/migration/backup-database.sh` | Database backup | Before migration, regularly |
| `scripts/migration/backup-files.sh` | Files backup | Before migration, regularly |
| `scripts/validation/find-deprecated.sh` | Find PHP issues | On old server codebase |
| `scripts/validation/health-check.sh` | Server health | Regularly on new server |
| `scripts/validation/test-website.sh` | Test website | After deployment |

---

## ⚠️ Critical Warnings

### Before You Start
- ❌ **DO NOT** make changes directly on production
- ❌ **DO NOT** proceed without verified backups
- ❌ **DO NOT** skip the staging environment
- ❌ **DO NOT** delete old server for 30 days minimum

### PHP Compatibility (MUST FIX)
Your code **will break** if it uses:
- `mysql_connect()` → Use `mysqli_connect()` or PDO
- `mcrypt_encrypt()` → Use `openssl_encrypt()`
- `ereg()` → Use `preg_match()`

**Run the deprecation scanner** before migrating!

### Security
- ✅ **ALWAYS** use strong passwords
- ✅ **ENABLE** firewall before going live
- ✅ **INSTALL** SSL certificate (Let's Encrypt)
- ✅ **DISABLE** root SSH login

---

## 🎯 Success Checklist

Migration is successful when:
- [ ] All website features work correctly
- [ ] No critical errors in logs (24 hours)
- [ ] Performance meets or exceeds old server
- [ ] SSL certificate valid and auto-renewing
- [ ] All security measures in place
- [ ] Backups automated and tested
- [ ] Old server successfully decommissioned

---

## 📞 Need Help?

### Common Issues
Check **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** first.

### Emergency Rollback
1. Enable maintenance mode
2. Change DNS back to old server
3. Wait for propagation
4. Investigate issues

### Resources
- [PHP Migration Guides](https://www.php.net/manual/en/appendices.php)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

---

## 📅 Recommended Timeline

### Week 1: Planning & Preparation
- Day 1-2: Read documentation, audit current server
- Day 3-4: Scan code for compatibility issues
- Day 5-7: Create and test backups

### Week 2: Implementation
- Day 1-2: Set up new server
- Day 3-5: Deploy to staging, fix issues
- Day 6-7: Testing and validation

### Week 3: Go Live (if ready)
- Day 1: Final staging tests
- Day 2: DNS cutover, monitoring
- Day 3-7: Monitor and fine-tune

---

## 💡 Pro Tips

1. **Reduce DNS TTL 48 hours before cutover** (to 300 seconds)
2. **Schedule migration during low-traffic hours**
3. **Have rollback plan ready** (documented)
4. **Monitor logs actively** for first 24 hours
5. **Keep old server running** for at least 1 week
6. **Test backups** by actually restoring them

---

## 🎬 Next Action

**Right now, do this:**
1. ✅ Open [PRE_MIGRATION_CHECKLIST.md](docs/PRE_MIGRATION_CHECKLIST.md)
2. ✅ Start documenting your current server
3. ✅ Create comprehensive backups
4. ✅ Run the deprecation scanner on your code

**Don't proceed to installation until pre-migration checklist is 100% complete!**

---

**Good luck with your migration! 🚀**

---

*Last Updated: January 11, 2026*
