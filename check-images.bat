@echo off
.\tools\plink.exe -batch -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 "test -d /var/www/archive2.adgully.com/img && echo 'IMG DIR EXISTS' || echo 'IMG DIR NOT FOUND'"
.\tools\plink.exe -batch -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 "test -f /var/www/archive2.adgully.com/img/400x300/202202/rashmika_2.jpg && echo 'IMAGE FILE EXISTS' || echo 'IMAGE FILE NOT FOUND'"
.\tools\plink.exe -batch -pw "z(P5ts@wdsESLUjMPVXs" root@31.97.233.171 "ls -lh /var/www/archive2.adgully.com/ | grep img"
