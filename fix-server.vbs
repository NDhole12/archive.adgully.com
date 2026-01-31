Set WshShell = CreateObject("WScript.Shell")

' Server details
server = "31.97.233.171"
user = "root"
password = "z(P5ts@wdsESLUjMPVXs"

' Commands to run
commands = "systemctl restart php8.2-fpm nginx mariadb && sleep 3 && systemctl is-active php8.2-fpm nginx mariadb && chown -R www-data:www-data /var/www/archive2.adgully.com && curl -I http://localhost | head -5 && echo '' && tail -20 /var/log/nginx/error.log"

' Execute SSH
WScript.Echo "Connecting to server..."
WScript.Echo "Server: " & server
WScript.Echo "User: " & user
WScript.Echo ""

' Run SSH command
sshCmd = "ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no " & user & "@" & server & " """ & commands & """"

WScript.Echo "Command: " & sshCmd
WScript.Echo ""
WScript.Echo "When prompted for password, enter: " & password
WScript.Echo ""

' Execute
WshShell.Run "cmd /k " & sshCmd, 1, False

WScript.Echo "Script launched in new window"
