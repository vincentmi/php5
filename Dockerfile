FROM ubuntu:14.04
LABEL name="docker-php-5.3.3"
LABEL maintainer="Vincent Mi<miwenshu@gmail.com>"

RUN mkdir /var/www /var/www/public /var/backup /var/log/nginx && echo "<?php phpinfo();?>"   > /var/www/public/index.php && chmod -R 0777 /var/www

VOLUME /var/www/
VOLUME /var/log/nginx
VOLUME /var/backup

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install  -y  snmp nginx supervisor php5-cli php5-fpm \
 php5-sqlite php5-mysqlnd \
php5-json php5-curl php5-geoip php5-imagick php5-mcrypt php5-mongo \
php5-snmp php5-gd php5-xmlrpc php5-ldap php5-odbc \
php5-apcu

RUN /etc/init.d/php5-fpm stop && /etc/init.d/nginx stop

RUN { echo '[global]'; \
    echo 'pid = /var/run/php5-fpm.pid';\
    echo 'error_log = /var/log/nginx/php5-fpm.log';\
    echo 'daemonize = no';\
    echo '[www]';\
    echo 'user = www-data';\
    echo 'group = www-data';\
    echo 'listen = /var/run/php5-fpm.sock';\
    echo 'listen.owner = www-data';\
    echo 'listen.group = www-data';\
    echo 'pm = dynamic';\
    echo 'pm.max_children = 5';\
    echo 'pm.start_servers = 2';\
    echo 'pm.min_spare_servers = 1';\
    echo 'pm.max_spare_servers = 3';\
    echo ';pm.status_path = /status';\
    echo 'chdir = /';\
    echo ';include=/etc/php5/fpm/pool.d/*.conf';\
} > /etc/php5/fpm/php-fpm.conf

RUN { echo 'server {'; \
    echo '    listen 80 default_server;'; \
    echo '    listen [::]:80 default_server ipv6only=on;';\
    echo '    root /var/www/public;'; \
    echo '    index index.php index.html index.htm;';\
    echo '    server_name localhost;';\
    echo '    location / {';\
    echo '    #    try_files $uri $uri/ =404;'; \
    echo '        try_files $uri $uri/ /index.php?$query_string;'; \
    echo '    }';\
    echo '    error_page 404 /404.html;'; \
    echo '    location = /50x.html {';\
    echo '        root /usr/share/nginx/html;';\
    echo '    }';\
    echo '    location ~ \.php$ {'; \
    echo '        root /var/www/public;'; \
    echo '        fastcgi_pass unix:/var/run/php5-fpm.sock;'; \
    echo '        fastcgi_index index.php;'; \
    echo '        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;';\
    echo '        include fastcgi_params;'; \
    echo '    }'; \
    echo '    location ~ /\.ht {'; \
    echo '        deny all;'; \
    echo '    }'; \
    echo '}'; \
    } > /etc/nginx/sites-enabled/default

RUN { echo '[program:php5-fpm]'; \
    echo 'command=/usr/sbin/php5-fpm'; \
    echo 'stdout_logfile=/var/log/nginx/php5-fpm.out';\
    echo 'autostart=true';\
    echo 'autorestart=true';\
    echo 'startsecs=5';\
    echo 'priority=1';\
    echo 'stopasgroup=true';\
    echo 'killasgroup=true'; \
    } > /etc/supervisor/conf.d/php5-fpm.conf

RUN { echo '[program:nginx]'; \
    echo 'command=/usr/sbin/nginx -g "daemon off;"'; \
    echo 'stdout_logfile=/var/log/nginx/nginx.out';\
    echo 'autostart=true';\
    echo 'autorestart=true';\
    echo 'startsecs=5';\
    echo 'priority=1';\
    echo 'stopasgroup=true';\
    echo 'killasgroup=true';\
    } >  /etc/supervisor/conf.d/nginx.conf

EXPOSE 80

CMD ["supervisord" , "-n"]
