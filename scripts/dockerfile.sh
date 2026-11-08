#!/bin/bash
# Vi du build image apache don gian.
# Cap nhat 2026: ubuntu:14.04 da het ho tro -> dung ubuntu:24.04; MAINTAINER da deprecated -> dung LABEL
mkdir -p apache && cd apache

cat << 'EOF' > Dockerfile
FROM ubuntu:24.04

LABEL maintainer="tannt"

RUN apt-get update \
    && apt-get install -y --no-install-recommends apache2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EOF

docker build -t apache_test .
