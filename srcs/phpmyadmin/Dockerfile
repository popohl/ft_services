FROM phpmyadmin/phpmyadmin:fpm-alpine

RUN apk update && \
	apk add nginx && \
	rm -f /var/cache/apk/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint /entrypoint

ENTRYPOINT sh /entrypoint
