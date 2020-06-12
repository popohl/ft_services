FROM alpine:latest
LABEL Paul OHL <pohl@student.42.fr>

RUN apk update && apk upgrade
RUN apk add mysql mysql-client && \
	rm -f /var/cache/apk/*

COPY my.cnf /etc/mysql/my.cnf
COPY entrypoint /entrypoint

RUN mkdir /app

EXPOSE 3306

CMD sh /entrypoint

