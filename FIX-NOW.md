## 🔴 SITE DOWN - HTTP 500 ERROR

### ROOT CAUSE CONFIRMED:
PHP 8.2-FPM is NOT installed on server 31.97.233.171

---

## ✅ INSTANT FIX (Copy & Run)

### Open PowerShell and paste this ENTIRE command:

```powershell
ssh root@31.97.233.171 "apt update && apt install -y software-properties-common && add-apt-repository -y ppa:ondrej/php && apt update && DEBIAN_FRONTEND=noninteractive apt install -y php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip && systemctl start php8.2-fpm && systemctl restart nginx && echo 'DONE!'"
```

**When prompted for password, paste:** `z(P5ts@wdsESLUjMPVXs`

**Installation time:** 2-3 minutes

---

## After Installation Completes:

The site will be working at: **https://archive2.adgully.com/**

---

## Alternative: Manual SSH

1. `ssh root@31.97.233.171`
2. Password: `z(P5ts@wdsESLUjMPVXs`
3. Paste:

```bash
apt update && apt install -y software-properties-common && add-apt-repository -y ppa:ondrej/php && apt update && DEBIAN_FRONTEND=noninteractive apt install -y php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip && systemctl start php8.2-fpm && systemctl restart nginx
```

**That's it! Site will be fixed!**
