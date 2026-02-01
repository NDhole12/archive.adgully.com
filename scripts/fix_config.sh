#!/bin/bash
CONFIG=/var/www/archive2.adgully.com/config.php

# Fix database name in both blocks
sed -i 's/config_db_db = "adgully";/config_db_db = "archive_adgully";/g' $CONFIG
sed -i 's/config_db_db = "archive_user";/config_db_db = "archive_adgully";/g' $CONFIG

echo "Config updated"
grep 'config_db_' $CONFIG | head -10
