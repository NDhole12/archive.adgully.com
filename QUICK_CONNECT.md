# 🔌 Quick Connection Guide

## Server Access Information

### 🔴 OLD Server (Source - Read Only!)
```
IP:         172.31.21.197
User:       root
Password:   byCdgzMr5AHx
Purpose:    Audit and backup only - DO NOT MODIFY
```

**Connect:**
```powershell
ssh root@172.31.21.197
```

**Use For:**
- Day 1: Server audit
- Day 2: Creating backups
- Day 3: Downloading application code
- Reference during migration

**⚠️ CRITICAL: Never modify anything on this server!**

---

### 🟢 NEW Server (Destination - Setup Target)
```
IP:         31.97.233.171
User:       root
Password:   z(P5ts@wdsESLUjMPVXs
Purpose:    Migration target - install and configure
```

**Connect:**
```powershell
ssh root@31.97.233.171
```

**Use For:**
- Day 4: Ubuntu installation and package setup
- Day 5: Configuration (Nginx, PHP, MariaDB)
- Day 6-8: Application deployment
- Day 9-10: Testing
- Day 12+: Production server

**✅ This is where you'll do all your setup work**

---

## 🚀 Quick Start Commands

### 1. Verify NEW Server (Run This First!)
```powershell
# In PowerShell on Windows
cd D:\archive.adgully.com
.\verify-new-server.ps1
```

This will:
- Connect to new server
- Check OS version (should be Ubuntu 22.04)
- Check system resources
- Check what's installed
- Save report to backups folder

---

### 2. First-Time NEW Server Setup
```powershell
# Connect to NEW server
ssh root@31.97.233.171
# Enter password: z(P5ts@wdsESLUjMPVXs
```

```bash
# Once connected, run these commands:

# 1. Update system
apt update && apt upgrade -y

# 2. Set hostname
hostnamectl set-hostname archive.adgully.com
echo "127.0.0.1 archive.adgully.com" >> /etc/hosts

# 3. Check system info
cat /etc/os-release
free -h
df -h
nproc

# 4. Exit
exit
```

---

### 3. Upload Installation Scripts
```powershell
# From Windows PowerShell
# Upload main installation script
scp D:\archive.adgully.com\scripts\install\full-install.sh root@31.97.233.171:/root/

# Upload all scripts (optional - for manual control)
scp -r D:\archive.adgully.com\scripts root@31.97.233.171:/root/

# Upload all configs
scp -r D:\archive.adgully.com\configs root@31.97.233.171:/root/
```

---

### 4. Run Automated Installation
```bash
# On NEW server (after uploading scripts)
cd /root
chmod +x full-install.sh
./full-install.sh
```

**This will install:**
- Nginx
- PHP 8.2 with all 17 required extensions
- MariaDB 10.11
- UFW Firewall
- Fail2ban
- Let's Encrypt tools

**Time:** 10-20 minutes

---

### 5. Manual Installation (Alternative)
```bash
# If you prefer step-by-step control
# Follow: INSTALLATION_GUIDE.md

# Phase 1: System preparation
# Phase 2: Repository setup
# Phase 3: PHP 8.2 installation
# Phase 4: Nginx installation
# Phase 5: MariaDB installation
# Phase 6: Additional tools
# Phase 7: SSL certificate
# Phase 8: Security (UFW, Fail2ban)
# Phase 9: SSH hardening
# Phase 10: Verification
```

---

## 📋 Connection Troubleshooting

### Can't Connect to NEW Server?
```powershell
# Test connectivity
ping 31.97.233.171

# Test SSH port
Test-NetConnection -ComputerName 31.97.233.171 -Port 22

# Check firewall on your Windows machine
# Ensure no VPN/firewall blocking port 22
```

### Wrong Password?
```
Password: z(P5ts@wdsESLUjMPVXs
(Note: Contains special characters: ( ) @ )
Copy-paste it carefully!
```

### SSH Fingerprint Warning?
```
Type: yes
Press: Enter
(This is normal for first connection)
```

---

## 🔐 Security Recommendations

### Change Root Password (After Initial Setup)
```bash
# On NEW server
passwd
# Enter new strong password
# Store in password manager
```

### Create Non-Root User
```bash
# On NEW server
adduser admin
usermod -aG sudo admin

# Test new user
su - admin
sudo apt update  # Should work
exit
```

### Setup SSH Keys (Recommended)
```powershell
# On Windows (if you don't have SSH key)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to NEW server
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh root@31.97.233.171 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Test key-based login
ssh root@31.97.233.171
# Should not ask for password!
```

### Disable Password Authentication (After Keys Setup)
```bash
# On NEW server
nano /etc/ssh/sshd_config

# Change these lines:
# PermitRootLogin prohibit-password
# PasswordAuthentication no

# Restart SSH
systemctl restart sshd
```

---

## 📊 Server Comparison

| Feature | OLD Server | NEW Server |
|---------|-----------|------------|
| **IP** | 172.31.21.197 | 31.97.233.171 |
| **OS** | CentOS 7.9 (EOL) | Ubuntu 22.04 LTS |
| **PHP** | 5.6.40 | 8.2 (to be installed) |
| **Web** | Apache | Nginx (to be installed) |
| **Access** | Read-only audit | Full setup access |
| **Status** | Production (old) | Setup target (new) |

---

## 🎯 What to Do Next

### If You Haven't Done Days 1-3:
1. Connect to **OLD server** (172.31.21.197)
2. Complete server audit (Day 1)
3. Create backups (Day 2)
4. Scan code for deprecated functions (Day 3)
5. **Then** proceed to NEW server setup

### If Days 1-3 Are Complete:
1. Run `verify-new-server.ps1` to check NEW server
2. Connect to **NEW server** (31.97.233.171)
3. Run system update
4. Upload installation scripts
5. Run `full-install.sh`
6. Configure services (Day 5)

### Track Everything:
- Open: **MIGRATION_TRACKER.md**
- Check off each task as completed
- Document any issues or deviations

---

## 🆘 Emergency Access

### Lost Connection to NEW Server?
```
1. Contact your hosting provider
2. Use their web console/VNC
3. Check SSH service: systemctl status sshd
4. Check firewall: ufw status
5. If needed, allow SSH: ufw allow 22/tcp
```

### Locked Out by Firewall?
```
1. Access via hosting provider console
2. Disable UFW temporarily: ufw disable
3. Fix rules: ufw allow 22/tcp
4. Re-enable: ufw enable
```

### Need to Start Over?
```
1. OLD server is untouched - all data safe
2. NEW server can be rebuilt from scratch
3. No DNS changes yet - no production impact
4. Safe to experiment and learn
```

---

## 📞 Quick Reference

### Connect Commands
```powershell
# OLD server (audit/backup)
ssh root@172.31.21.197

# NEW server (setup)
ssh root@31.97.233.171
```

### File Transfer Commands
```powershell
# Windows → NEW server
scp local_file.txt root@31.97.233.171:/root/

# OLD server → Windows
scp root@172.31.21.197:/root/backup.sql.gz D:\archive.adgully.com\backups\

# OLD server → NEW server (direct)
# From NEW server:
scp root@172.31.21.197:/root/backup.sql.gz /root/
```

### Verification Scripts
```powershell
# Verify NEW server
.\verify-new-server.ps1

# Audit OLD server (if not run yet)
.\run-server-audit.ps1
```

---

## ✅ Connection Checklist

Before proceeding with installation:

- [ ] Successfully connected to NEW server (31.97.233.171)
- [ ] Verified Ubuntu 22.04 LTS
- [ ] System updated (apt update && apt upgrade)
- [ ] Hostname set to archive.adgully.com
- [ ] Firewall plan understood (UFW)
- [ ] Installation method chosen (automated/manual)
- [ ] MIGRATION_TRACKER.md open for tracking
- [ ] COMMAND_REFERENCE.md bookmarked

---

**You're now ready to start Day 4 installation!** 🚀

**Follow: [MIGRATION_EXECUTION_PLAN.md](MIGRATION_EXECUTION_PLAN.md) - Day 4**

---

*Last Updated: January 11, 2026*
