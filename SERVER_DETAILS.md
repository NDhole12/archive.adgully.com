# Server Details - Archive.adgully.com Migration

## 📋 Server Inventory

### 🔴 Source Server (OLD - CentOS 7.9)
```
IP Address:     172.31.21.197
Hostname:       mail.colepal.com (archive2.adgully.com)
OS:             CentOS Linux 7.9 (Core) - EOL
SSH User:       root
SSH Password:   byCdgzMr5AHx
Status:         PRODUCTION - DO NOT MODIFY

Current Stack:
- Web Server:   Apache with mod_php
- PHP:          5.6.40 (Remi repository)
- Database:     MariaDB/MySQL
- Extensions:   17 PHP extensions (including deprecated)
```

**⚠️ WARNING: Read-only audit only! Never modify this server!**

---

### 🟢 Destination Server (NEW - Ubuntu 22.04)
```
IP Address:     31.97.233.171
Hostname:       (To be configured: archive.adgully.com)
OS:             Ubuntu 22.04 LTS (Fresh installation)
SSH User:       root
SSH Password:   z(P5ts@wdsESLUjMPVXs
Status:         READY FOR SETUP

Target Stack:
- Web Server:   Nginx 1.18+ with PHP-FPM
- PHP:          8.2 (Latest stable)
- Database:     MariaDB 10.11+ LTS
- Security:     UFW, Fail2ban, Let's Encrypt SSL
```

**✅ This is your migration target - follow MIGRATION_EXECUTION_PLAN.md**

---

## � Database & phpMyAdmin Credentials

### phpMyAdmin Access
```
URL:            https://pma.archive2.adgully.com/
Status:         Active with SSL (Let's Encrypt)
```

### Database Credentials

**Root User (Full Access):**
```
Username:       root
Password:       Admin@2026MsIhJgArhSg8x
Host:           localhost
Access:         ALL PRIVILEGES
```

**phpMyAdmin System User (Limited):**
```
Username:       phpmyadmin
Password:       JgArMsIhSg8x
Database:       phpmyadmin
Host:           localhost
Access:         Configuration storage only
```

**⚠️ SECURITY WARNINGS:**
- Root password is strong - keep it secure
- Change passwords periodically
- Never commit this file to public repositories
- Use separate users for each application/database
- Root access should only be used for admin tasks

---

## �🔐 Security Notes

### Credentials Storage
- ✅ Store these credentials securely (password manager)
- ✅ Change root passwords after initial setup
- ✅ Setup SSH key authentication
- ✅ Disable password authentication once keys are configured
- ✅ Never commit credentials to Git (already in .gitignore)

### Immediate Security Tasks (After Initial Setup)
```bash
# On NEW server (31.97.233.171)
# 1. Change root password
passwd

# 2. Create non-root admin user
adduser admin
usermod -aG sudo admin

# 3. Setup SSH keys (from your Windows machine)
# Generate key if you don't have one:
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id root@31.97.233.171

# 4. Disable root password login (after testing key access)
# Edit /etc/ssh/sshd_config:
# PermitRootLogin prohibit-password
# PasswordAuthentication no
```

---

## 🚀 Quick Start Commands

### Connect to OLD Server (Audit Only)
```powershell
# Windows PowerShell
ssh root@172.31.21.197
# When prompted, enter password: byCdgzMr5AHx

# REMEMBER: Read-only! Don't modify anything!
```

### Connect to NEW Server (Setup Target)
```powershell
# Windows PowerShell
ssh root@31.97.233.171
# When prompted, enter password: z(P5ts@wdsESLUjMPVXs

# This is your migration target - follow setup guide
```

---

## 📅 Migration Progress Tracker

### Current Phase: Pre-Migration → Server Setup Transition

**Completed:**
- [x] Documentation complete (all 30 files)
- [x] Source server identified (172.31.21.197)
- [x] Destination server provisioned (31.97.233.171)
- [x] Credentials secured

**Next Immediate Actions:**
1. **Complete Days 1-3 on OLD server (if not done):**
   - [ ] Complete server audit (Day 1)
   - [ ] Create comprehensive backups (Day 2)
   - [ ] Scan code for deprecated functions (Day 3)

2. **Start Day 4 on NEW server:**
   - [ ] Connect to 31.97.233.171
   - [ ] Verify Ubuntu 22.04 installation
   - [ ] Update system packages
   - [ ] Run full-install.sh OR follow INSTALLATION_GUIDE.md

---

## 🎯 Your Next Actions (Right Now!)

### Step 1: Verify NEW Server Access (5 minutes)
```powershell
# In Windows PowerShell
ssh root@31.97.233.171
# Enter password when prompted: z(P5ts@wdsESLUjMPVXs

# Once connected, verify:
cat /etc/*release          # Confirm Ubuntu 22.04
hostname                   # Check current hostname
free -m                    # Check RAM
df -h                      # Check disk space
ip addr                    # Verify IP is 31.97.233.171
```

### Step 2: Initial NEW Server Setup (10 minutes)
```bash
# On NEW server (31.97.233.171)

# 1. Update system first
apt update && apt upgrade -y

# 2. Set hostname
hostnamectl set-hostname archive.adgully.com
echo "127.0.0.1 archive.adgully.com" >> /etc/hosts

# 3. Check system resources
echo "=== SYSTEM INFO ==="
cat /etc/*release
echo "=== RESOURCES ==="
free -m
df -h
echo "=== NETWORK ==="
ip addr
```

### Step 3: Choose Installation Method

**Option A: Automated (Recommended for beginners)**
```bash
# On NEW server
cd /root

# Upload full-install.sh from your Windows machine:
# scp D:\archive.adgully.com\scripts\install\full-install.sh root@31.97.233.171:/root/

# Make executable and run
chmod +x full-install.sh
./full-install.sh
```

**Option B: Manual Step-by-Step**
```bash
# Follow: INSTALLATION_GUIDE.md
# This gives you more control over each step
```

### Step 4: Track Your Progress
```bash
# On your Windows machine
# Open: D:\archive.adgully.com\MIGRATION_TRACKER.md
# Check off each task as you complete it
```

---

## 📊 Server Specifications to Verify

### Check NEW Server Specs
```bash
# On NEW server (31.97.233.171)

# CPU cores
nproc

# Total RAM
free -h

# Disk space
df -h

# Network speed (optional)
apt install -y speedtest-cli
speedtest-cli
```

### Minimum Recommended Specs
```
CPU:        2+ cores
RAM:        4GB minimum (8GB recommended)
Disk:       50GB minimum (100GB+ recommended)
Network:    100 Mbps minimum
```

---

## 🔒 Firewall Setup (Priority #1 After Installation)

**CRITICAL: Setup firewall before exposing to internet!**

```bash
# On NEW server (31.97.233.171)

# Install UFW
apt install -y ufw

# Allow SSH first (IMPORTANT!)
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw --force enable

# Verify
ufw status verbose
```

**⚠️ If you upload firewall script from configs/security/ufw-rules.sh, review it first!**

---

## 📝 Quick Reference

### File Locations (After Setup)

**Nginx:**
- Config: `/etc/nginx/sites-available/archive.adgully.com`
- Enabled: `/etc/nginx/sites-enabled/archive.adgully.com`
- Logs: `/var/log/nginx/`

**PHP:**
- Config: `/etc/php/8.2/fpm/conf.d/99-custom.ini`
- Pool: `/etc/php/8.2/fpm/pool.d/archive.conf`
- Logs: `/var/log/php8.2-fpm.log`

**MariaDB:**
- Config: `/etc/mysql/mariadb.conf.d/99-custom.cnf`
- Logs: `/var/log/mysql/`

**Application:**
- Root: `/var/www/archive.adgully.com/`
- Owner: `www-data:www-data`

---

## 🆘 Emergency Information

### If You Lose Access to NEW Server
```
1. Contact hosting provider
2. Use their console/VNC access
3. Server IP: 31.97.233.171
4. Root password: z(P5ts@wdsESLUjMPVXs
```

### If You Lock Yourself Out (UFW/SSH)
```
1. Access via hosting provider console
2. Check: ufw status
3. If SSH blocked: ufw allow 22/tcp
4. Restart SSH: systemctl restart sshd
```

### Rollback to OLD Server (Emergency)
```
- OLD server is still running at 172.31.21.197
- No DNS change yet, so no impact
- Safe to experiment on NEW server
- Can rebuild NEW server if needed
```

---

## 📋 Pre-Installation Checklist for NEW Server

Before running installation, verify:

**System Checks:**
- [ ] Connected to 31.97.233.171 successfully
- [ ] Confirmed Ubuntu 22.04 LTS
- [ ] System updated (apt update && apt upgrade)
- [ ] Minimum 4GB RAM available
- [ ] Minimum 50GB disk space available
- [ ] Internet connectivity working

**Preparation:**
- [ ] All scripts uploaded from `D:\archive.adgully.com\scripts\`
- [ ] All configs uploaded from `D:\archive.adgully.com\configs\`
- [ ] MIGRATION_TRACKER.md open to track progress
- [ ] COMMAND_REFERENCE.md bookmarked
- [ ] TROUBLESHOOTING.md ready in case of issues

**Security:**
- [ ] Firewall plan ready (UFW rules)
- [ ] SSL certificate method chosen (Let's Encrypt)
- [ ] Strong password for database user prepared
- [ ] SSH key authentication planned

---

## 🎯 Where You Are in the Migration

```
MIGRATION PROGRESS:
┌─────────────────────────────────────────────────────┐
│ Phase 1: Pre-Migration (Days 1-3)                  │
│   ├─ Day 1: Audit OLD server        ⏳ In Progress │
│   ├─ Day 2: Create backups          ⏳ Pending     │
│   └─ Day 3: Scan code                ⏳ Pending     │
│                                                     │
│ Phase 2: Server Setup (Days 4-5)    ← YOU ARE HERE │
│   ├─ Day 4: Provision NEW server    ✅ READY!     │
│   └─ Day 5: Configure everything    ⏳ Next        │
│                                                     │
│ Phase 3: Migration (Days 6-8)       ⏳ Waiting     │
│ Phase 4: Testing (Days 9-10)        ⏳ Waiting     │
│ Phase 5: Go Live (Days 11-12)       ⏳ Waiting     │
│ Phase 6: Post-Launch (Days 13-14+)  ⏳ Waiting     │
└─────────────────────────────────────────────────────┘
```

**Current Status:**
- ✅ Documentation Complete
- ✅ OLD server identified
- ✅ NEW server provisioned ← **YOU JUST COMPLETED THIS!**
- ⏳ NEW server installation (Next step)

---

## 📞 Commands for Both Servers

### Connect to Servers
```powershell
# OLD Server (Read-Only Audit)
ssh root@172.31.21.197

# NEW Server (Setup Target)
ssh root@31.97.233.171
```

### Transfer Files Between Servers
```powershell
# From Windows to NEW server
scp D:\archive.adgully.com\scripts\install\full-install.sh root@31.97.233.171:/root/

# From OLD server to NEW server (direct transfer)
# First, on OLD server, create backup
# Then from NEW server:
scp root@172.31.21.197:/root/backups/database-backup.sql.gz /root/
```

### Upload All Scripts at Once
```powershell
# From Windows PowerShell
scp -r D:\archive.adgully.com\scripts\* root@31.97.233.171:/root/scripts/
scp -r D:\archive.adgully.com\configs\* root@31.97.233.171:/root/configs/
```

---

## ✅ Action Items Summary

**Immediate (Next 30 minutes):**
1. ✅ Connect to NEW server: `ssh root@31.97.233.171`
2. ✅ Verify Ubuntu 22.04 installation
3. ✅ Update system: `apt update && apt upgrade -y`
4. ✅ Set hostname: `hostnamectl set-hostname archive.adgully.com`

**Today (Next 2-4 hours):**
5. ⏳ Upload scripts and configs to NEW server
6. ⏳ Run full-install.sh OR follow INSTALLATION_GUIDE.md
7. ⏳ Configure firewall (UFW)
8. ⏳ Verify all services running

**This Week:**
9. ⏳ Complete OLD server audit and backups (Days 1-3)
10. ⏳ Deploy application to NEW server
11. ⏳ Import database
12. ⏳ Fix PHP compatibility issues
13. ⏳ Test in staging

---

## 🎉 YOU'RE READY TO START!

**You now have both servers ready:**
- ✅ OLD server for audit and backup (172.31.21.197)
- ✅ NEW server for installation and setup (31.97.233.171)

**Next Step:**
Open **[MIGRATION_EXECUTION_PLAN.md](MIGRATION_EXECUTION_PLAN.md)** and start with:
- If not done: Days 1-3 on OLD server
- Then immediately: Day 4 on NEW server

**Track everything in [MIGRATION_TRACKER.md](MIGRATION_TRACKER.md)**

---

**Good luck! You've got all the tools and documentation you need! 🚀**

---

*Last Updated: January 11, 2026*  
*Status: Ready for Day 4 - New Server Installation*
