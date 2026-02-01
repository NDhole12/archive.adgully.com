<?php
// Fix nginx config for fastcgi buffer size

$file = '/etc/nginx/sites-enabled/archive2.adgully.com.conf';
$content = file_get_contents($file);

$old = "location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php5.6-fpm.sock;";

$new = "location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php5.6-fpm.sock;
        
        # Fix for big headers
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;";

$content = str_replace($old, $new, $content);
file_put_contents($file, $content);
echo "Done!\n";
