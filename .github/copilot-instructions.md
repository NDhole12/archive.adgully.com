# Archive.adgully.com - Server Migration Project

## Project Overview
This workspace contains comprehensive documentation and automation scripts for migrating archive.adgully.com from a legacy CentOS 7.9 + Apache + PHP 5.6 server to a modern Ubuntu 22.04 + Nginx + PHP 8.2 production environment.

## Project Type
**Infrastructure Migration & Documentation**
- Documentation-driven migration project
- Server configuration templates
- Automation scripts (Bash)
- No build/compile required

## Key Components

### Documentation (docs/)
- **RULEBOOK.md** - Migration rules, standards, and best practices
- **PRE_MIGRATION_CHECKLIST.md** - Comprehensive pre-migration audit
- **INSTALLATION_GUIDE.md** - Step-by-step Ubuntu 22.04 setup
- **POST_MIGRATION_CHECKLIST.md** - Post-migration validation
- **PHP_COMPATIBILITY.md** - PHP 5.6 → 8.2 compatibility guide
- **TROUBLESHOOTING.md** - Common issues and solutions

### Configuration Templates (configs/)
- **nginx/** - Nginx server block with SSL, security headers
- **php/** - PHP 8.2-FPM pool and custom php.ini
- **mariadb/** - MariaDB 10.11 optimization settings
- **security/** - UFW firewall and Fail2ban rules

### Automation Scripts (scripts/)
- **install/** - Full server installation automation
- **migration/** - Database and file backup utilities
- **validation/** - Health checks, deprecated code scanner, website testing

## Usage Guidelines

### For Copilot Assistance
When working with this project, Copilot should:
1. **Prioritize safety** - Never suggest direct production changes
2. **Reference documentation** - Point users to relevant docs
3. **Validate commands** - Ensure bash commands are correct for Ubuntu/Debian
4. **Consider compatibility** - Remember PHP 5.6 → 8.2 breaking changes
5. **Emphasize testing** - Always recommend staging environment first

### Common Tasks
- **Review migration plan**: Start with README.md, then RULEBOOK.md
- **Pre-migration audit**: Follow PRE_MIGRATION_CHECKLIST.md
- **Server installation**: Use scripts/install/full-install.sh or INSTALLATION_GUIDE.md
- **Find deprecated code**: Run scripts/validation/find-deprecated.sh
- **Health monitoring**: Use scripts/validation/health-check.sh
- **Troubleshooting**: Consult TROUBLESHOOTING.md

### Technology Stack

**Current (Legacy)**:
- CentOS 7.9 (EOL)
- Apache 2.4
- PHP 5.6.40
- MySQL/MariaDB

**Target (Modern)**:
- Ubuntu 22.04 LTS
- Nginx 1.18+
- PHP 8.2-FPM
- MariaDB 10.11+
- Redis (optional)
- Let's Encrypt SSL

### Critical Compatibility Issues
The following must be addressed during migration:
- ❌ `mysql_*` functions → Use `mysqli_*` or PDO
- ❌ `mcrypt_*` functions → Use `openssl` or `sodium`
- ❌ `ereg*` functions → Use `preg_*` (PCRE)
- ❌ `each()` function → Use `foreach`
- ❌ `create_function()` → Use anonymous functions

## File Organization
- All scripts are executable bash (`.sh`)
- All configs have inline comments
- All docs use markdown format
- Follow naming convention: lowercase with hyphens

## Security Considerations
- Never commit passwords or secrets
- All scripts prompt for sensitive data
- Configuration templates use placeholders
- Follow principle of least privilege

## Project Status
✅ Documentation complete  
✅ Configuration templates created  
✅ Automation scripts written  
⏳ Awaiting actual server migration

## Getting Started
1. Read README.md for project overview
2. Review RULEBOOK.md for migration principles
3. Complete PRE_MIGRATION_CHECKLIST.md
4. Follow INSTALLATION_GUIDE.md for new server setup
5. Use scripts for automation where possible

---

**Last Updated**: January 11, 2026  
**Project Maintainer**: [To be specified]
