FROM alpine:latest
LABEL Paul OHL <pohl@student.42.fr>

RUN apk update && apk upgrade
RUN apk add nginx php-fpm php-cli php7-mysqli

# RUN docker-php-ext-install mysqli

# Setup nginx
RUN mkdir /run/nginx && echo 2 > /run/nginx/nginx.pid \
	&& mkdir -p /usr/share/nginx/html \
	&& rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Setup Wordpress
RUN wget -O wordpress.zip https://wordpress.org/latest.zip
RUN mkdir -p /var/www/html /var/www/info \
	&& unzip /wordpress.zip -d /var/www/ \
	&& rm wordpress.zip \
	&& rm -rf /var/www/wordpress/wp-config.php
COPY wp-config.php /var/www/wordpress/wp-config.php

# Start php
# try without this at some point
# RUN mkdir -p /run/openrc/
# RUN touch /run/openrc/softlevel 
# RUN rc-service php-fpm7 start

# Create user
RUN printf "hello\nhello\n" | adduser bonjour \
	&& chown -R bonjour:bonjour /var/www/* \
	&& chmod -R 755 /var/www/*

EXPOSE 80

CMD php-fpm7 && nginx -g 'daemon off;'
