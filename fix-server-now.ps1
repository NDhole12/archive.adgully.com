# Automated Server Fix Script
$server = "31.97.233.171"
$user = "root"
$pass = 'z(P5ts@wdsESLUjMPVXs'

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  FIXING SERVER NOW" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check for plink
$plinkPath = "C:\Program Files\PuTTY\plink.exe"
$plinkExists = Test-Path $plinkPath

if ($plinkExists) {
    Write-Host "Using PuTTY plink..." -ForegroundColor Green
    
    $fixScript = @"
systemctl restart php8.2-fpm nginx mariadb && sleep 3 && echo 'Services restarted' && systemctl is-active php8.2-fpm nginx mariadb && chown -R www-data:www-data /var/www/archive2.adgully.com 2>/dev/null && echo 'Permissions fixed' && curl -I http://localhost 2>&1 | head -5 && echo '' && echo 'Recent errors:' && tail -15 /var/log/nginx/error.log
"@
    
    & $plinkPath -ssh $user@$server -pw $pass -batch $fixScript
    
} else {
    Write-Host "PuTTY not found. Using SSH with expect simulation..." -ForegroundColor Yellow
    Write-Host ""
    
    # Create a temporary expect-like script
    $tempScript = [System.IO.Path]::GetTempFileName()
    
    $expectScript = @"
Set-StrictMode -Off
`$password = '$pass'
`$server = '$server'

`$pinfo = New-Object System.Diagnostics.ProcessStartInfo
`$pinfo.FileName = "ssh"
`$pinfo.Arguments = "-o StrictHostKeyChecking=no -o PubkeyAuthentication=no -o PreferredAuthentications=password `$user@`$server systemctl restart php8.2-fpm nginx mariadb; sleep 3; systemctl is-active php8.2-fpm nginx mariadb; chown -R www-data:www-data /var/www/archive2.adgully.com; curl -I http://localhost | head -5; tail -15 /var/log/nginx/error.log"
`$pinfo.UseShellExecute = `$false
`$pinfo.RedirectStandardInput = `$true
`$pinfo.RedirectStandardOutput = `$true
`$pinfo.RedirectStandardError = `$true

`$process = New-Object System.Diagnostics.Process
`$process.StartInfo = `$pinfo
`$process.Start() | Out-Null

Start-Sleep -Milliseconds 500
`$process.StandardInput.WriteLine(`$password)
`$process.StandardInput.Close()

`$output = `$process.StandardOutput.ReadToEnd()
`$errors = `$process.StandardError.ReadToEnd()

Write-Host `$output
Write-Host `$errors -ForegroundColor Yellow

`$process.WaitForExit()
"@
    
    $expectScript | Out-File -FilePath $tempScript -Encoding UTF8
    
    try {
        & powershell -ExecutionPolicy Bypass -File $tempScript
    } finally {
        Remove-Item $tempScript -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Testing Site" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 2

try {
    $response = Invoke-WebRequest -Uri "https://archive2.adgully.com/" -TimeoutSec 15 -ErrorAction Stop
    Write-Host "SUCCESS! Site is UP!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode) {
        Write-Host "Site Status: HTTP $statusCode" -ForegroundColor $(if ($statusCode -eq 200) { "Green" } elseif ($statusCode -lt 400) { "Yellow" } else { "Red" })
    } else {
        Write-Host "Connection Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Fix completed!" -ForegroundColor Cyan
