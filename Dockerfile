FROM centos:6.6
LABEL name="docker-php-5.3.3"
LABEL maintainer="Vincent Mi<miwenshu@gmail.com>"


RUN yum -y install nginx
