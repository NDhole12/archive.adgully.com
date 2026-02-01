# Upload updated Nginx configuration
Write-Host "Uploading Nginx configuration..." -ForegroundColor Cyan
.\tools\pscp.exe -batch -pw "z(P5ts@wdsESLUjMPVXs" `
    .\configs\nginx\archive2.adgully.com.conf `
    root@31.97.233.171:/etc/nginx/sites-available/archive2.adgully.com.conf

# Test and reload Nginx
Write-Host "Testing Nginx configuration..." -ForegroundColor Cyan
.\tools\plink.exe -batch -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 "nginx -t && systemctl reload nginx && echo 'Nginx reloaded successfully'"

Write-Host "Done! Images should now load from www.adgully.com via proxy" -ForegroundColor Green
