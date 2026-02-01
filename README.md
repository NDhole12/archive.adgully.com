# Archive.adgully.com - Server Migration

> **Status:** ✅ **MIGRATION COMPLETE - SITE LIVE**  
> **Completed:** January 31, 2026

## Current Production Server

| Component | Value |
|-----------|-------|
| **Live URL** | https://archive2.adgully.com/ |
| **Server IP** | 31.97.233.171 |
| **OS** | Ubuntu 22.04 LTS |
| **Web Server** | Nginx 1.24.0 |
| **PHP** | 5.6.40 (legacy code compatibility) |
| **Database** | MariaDB 10.11.13 |
| **SSL** | Let's Encrypt (expires April 20, 2026) |

## Quick Access

| Resource | URL/Command |
|----------|-------------|
| **Website** | https://archive2.adgully.com/ |
| **phpMyAdmin** | https://pma.archive2.adgully.com/ |
| **SSH** | `ssh root@31.97.233.171` |

## Database Info

- **Database Name:** `archive_adgully`
- **Tables:** 96
- **Character Set:** UTF8MB4

## 📚 Documentation

### Essential Guides
- **[COMPLETE_DOMAIN_MIGRATION_GUIDE.md](COMPLETE_DOMAIN_MIGRATION_GUIDE.md)** - Ultra-detailed guide for domain changes (use this for migrations!)
- **[DOMAIN_MIGRATION_CHECKLIST.md](DOMAIN_MIGRATION_CHECKLIST.md)** - Step-by-step checklist (print and check off items)
- **[REROUTING_LOGIC_DOCUMENTATION.md](REROUTING_LOGIC_DOCUMENTATION.md)** - Complete URL routing system explanation

### Reference Documentation
- **[SERVER_DETAILS.md](SERVER_DETAILS.md)** - Server credentials & access info
- **[MIGRATION_STATUS_REPORT.md](MIGRATION_STATUS_REPORT.md)** - Final migration status
- **[DOMAIN_DATABASE_CHANGE_GUIDE.md](DOMAIN_DATABASE_CHANGE_GUIDE.md)** - Database and domain change reference
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick commands and reference

### For Next Domain Migration
**👉 START HERE:** [COMPLETE_DOMAIN_MIGRATION_GUIDE.md](COMPLETE_DOMAIN_MIGRATION_GUIDE.md)

This guide covers:
- All files that need changes
- Step-by-step migration procedure
- Testing checklist
- Troubleshooting guide
- SSL certificate setup
- Rerouting logic explanation

## Project Structure

```
archive.adgully.com/
├── README.md                              # This file
├── SERVER_DETAILS.md                      # Server credentials & access info
├── MIGRATION_STATUS_REPORT.md             # Final migration status
│
├── COMPLETE_DOMAIN_MIGRATION_GUIDE.md     # 🔥 Complete domain migration guide
├── DOMAIN_MIGRATION_CHECKLIST.md          # 📋 Printable checklist for migrations
├── REROUTING_LOGIC_DOCUMENTATION.md       # 🔍 URL routing system explained
├── DOMAIN_DATABASE_CHANGE_GUIDE.md        # Database config reference
├── QUICK_REFERENCE.md                     # Quick commands
│
├── configs/                               # Production configurations (in use)
│   ├── nginx/                             # Nginx server blocks
│   │   ├── archive.adgully.com.conf
│   │   ├── archive2.adgully.com.conf
│   │   └── pma.archive2.adgully.com.conf
│   ├── php/                               # PHP-FPM pool config
│   │   ├── archive-pool.conf
│   │   └── php-custom.ini
│   ├── mariadb/                           # MariaDB optimization
│   │   └── mariadb-custom.cnf
│   └── security/                          # UFW & Fail2ban rules
│       ├── ufw-rules.sh
│       └── fail2ban-jail.local
│
├── scripts/                     # Utility scripts
│   ├── install/                 # Server installation
│   ├── migration/               # Backup utilities
│   └── validation/              # Health check scripts
│
├── docs/                        # Reference documentation
│   ├── INSTALLATION_GUIDE.md
│   ├── TROUBLESHOOTING.md
│   └── ...
│
├── tools/                       # CLI tools (plink, pscp)
└── backups/                     # Local backups
```

## Key Credentials

See [SERVER_DETAILS.md](SERVER_DETAILS.md) for all credentials including:
- SSH access
- Database root password
- Application database user
- phpMyAdmin access

## What Was Done

1. ✅ Ubuntu 22.04 LTS server provisioned (31.97.233.171)
2. ✅ Nginx + PHP 5.6-FPM + MariaDB 10.11 installed
3. ✅ SSL certificates installed (Let's Encrypt)
4. ✅ Website files uploaded from old server
5. ✅ Database imported (96 tables, 570 MB SQL file)
6. ✅ Site verified working (HTTP 200 OK)

## Important Notes

### PHP Version
Using **PHP 5.6.40** to maintain compatibility with legacy code. The original application was built for PHP 5.6 and the decision was made to keep the same PHP version rather than rewrite code for PHP 8.x compatibility.

### Old Server (Reference Only)
- **IP:** 172.31.21.197
- **OS:** CentOS 7.9 (EOL)
- **Status:** Archived, do not use

## Maintenance

### SSL Renewal
Automatic via certbot. Check expiry: April 20, 2026

### Backups
Ensure automated backups are configured for:
- Database (daily)
- Website files (weekly)

### Health Check
```bash
# SSH to server
ssh root@31.97.233.171

# Check services
systemctl status nginx php5.6-fpm mariadb

# Check website
curl -I https://archive2.adgully.com/
```

---

**Migration completed successfully. Site is live and operational.**
