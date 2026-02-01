<?php
// Fix config.php for new server - handle tabs and spaces

$file = '/var/www/archive2.adgully.com/config.php';
$content = file_get_contents($file);

// Fix db name - handle tabs with regex
$content = preg_replace('/\$config_db_db\s*=\s*"adgully"/', '$config_db_db = "archive_adgully"', $content);
$content = preg_replace('/\$config_db_db\s*=\s*"adgully_test"/', '$config_db_db = "archive_adgully"', $content);

file_put_contents($file, $content);
echo "Done!\n";
