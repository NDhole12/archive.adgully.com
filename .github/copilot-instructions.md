# Archive.adgully.com - Server Migration Project

## Project Status
✅ **MIGRATION COMPLETE** - Site is live at https://archive2.adgully.com/

## Current Production Server
- **IP**: 31.97.233.171
- **OS**: Ubuntu 22.04 LTS
- **Web Server**: Nginx 1.24.0
- **PHP**: 5.6.40 (legacy code compatibility)
- **Database**: MariaDB 10.11.13
- **SSL**: Let's Encrypt (expires April 2026)

## Project Type
**Completed Server Migration**
- Server configuration templates
- Automation scripts (Bash)
- Reference documentation

## Key Components

### Configuration Templates (configs/)
- **nginx/** - Nginx server blocks with SSL (PHP 5.6-FPM)
- **php/** - PHP 5.6-FPM pool and custom php.ini
- **mariadb/** - MariaDB 10.11 optimization settings
- **security/** - UFW firewall and Fail2ban rules

### Automation Scripts (scripts/)
- **install/** - Server installation automation
- **migration/** - Database and file backup utilities
- **validation/** - Health checks, website testing

## Usage Guidelines

### For Copilot Assistance
When working with this project, Copilot should:
1. **Understand migration is COMPLETE** - Site is live and working
2. **Note PHP 5.6** - Legacy PHP version used intentionally
3. **Reference credentials** - See SERVER_DETAILS.md for access info
4. **Use plink/pscp** - For Windows-based SSH access to server

### Quick Server Access
```powershell
# SSH via plink
.\tools\plink.exe -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171

# File transfer via pscp
.\tools\pscp.exe -pw "z(P5ts@wdsESLUjMPVXs" localfile root@31.97.233.171:/remote/path
```

### Technology Stack (LIVE)
- Ubuntu 22.04 LTS
- Nginx 1.24.0
- PHP 5.6.40-FPM
- MariaDB 10.11.13
- Let's Encrypt SSL

## Database Info
- **Database**: archive_adgully
- **Tables**: 96
- **Root password**: Admin@2026MsIhJgArhSg8x
- **App user**: archive_user / ArchiveUser@2026Secure

## File Organization
- All scripts are executable bash (`.sh`)
- All configs have inline comments
- All docs use markdown format

## Security Considerations
- Credentials in SERVER_DETAILS.md (do not commit to public repo)
- SSH access via root with password

---

**Last Updated**: January 31, 2026  
**Status**: Migration Complete - Site Live---

**Last Updated**: January 11, 2026  
**Project Maintainer**: [To be specified]
