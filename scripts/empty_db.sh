#!/bin/bash
# Empty the archive_adgully database on new server

mysql -u archive_user -pArchiveUser@2026Secure <<EOF
DROP DATABASE archive_adgully;
CREATE DATABASE archive_adgully;
EOF

echo "Database archive_adgully emptied successfully"
mysql -u archive_user -pArchiveUser@2026Secure archive_adgully -e "SHOW TABLES;" 2>&1 | wc -l
