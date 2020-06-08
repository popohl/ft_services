FROM alpine
LABEL Paul OHL <pohl@student.42.fr>

RUN apk update && apk upgrade
RUN apk add nginx php-fpm php-cli

# nginx configuration
RUN rm /etc/nginx/conf.d/default.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf
RUN mkdir /run/nginx && echo 2 > /run/nginx/nginx.pid
RUN mkdir -p /usr/share/nginx/html

# Wordpress configuration
RUN mkdir -p /var/www/html
RUN wget -O wordpress.zip https://wordpress.org/latest.zip
RUN unzip wordpress.zip -d /var/www/
# RUN chown -R www-data:www-data /var/www/* \
# 	&& chmod -R 755 /var/www/*

EXPOSE 80

CMD nginx -g 'daemon off;'
