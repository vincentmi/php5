#!/bin/sh

docker run --rm -i -t --name tcc -v `pwd`/tcc:/var/www/public \
-v `pwd`/log:/var/log/nginx -p 30080:80 php5tcc