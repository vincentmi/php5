FROM ubuntu:14.04
LABEL name="docker-php-5.3.3"
LABEL maintainer="Vincent Mi<miwenshu@gmail.com>"

RUN mkdir /var/www /var/www/public /var/backup /var/log/nginx && echo "<?php phpinfo();?>"   > /var/www/public/index.php && chmod -R 0777 /var/www

VOLUME /var/www/public
VOLUME /var/log/nginx
VOLUME /var/backup
# VOLUME /var/www/public/user_uploads
# VOLUME /var/www/public/temp
# VOLUME /var/www/public/cache

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install  -y  snmp nginx supervisor php5-cli php5-fpm \
 php5-sqlite php5-mysqlnd \
php5-json php5-curl php5-geoip php5-imagick php5-mcrypt php5-mongo \
php5-snmp php5-gd php5-xmlrpc php5-ldap php5-odbc \
php5-apcu

RUN /etc/init.d/php5-fpm stop && /etc/init.d/nginx stop

COPY  conf/default /etc/nginx/sites-enabled/

COPY  conf/fpm.conf  conf/nginx.conf   /etc/supervisor/conf.d/

COPY  conf/php-fpm.conf /etc/php5/fpm/
COPY  conf/www.conf /etc/php5/fpm/pool.d/

EXPOSE 80

CMD ["supervisord" , "-n"]
