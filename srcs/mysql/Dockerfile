FROM alpine

RUN apk add --update mysql mysql-client && \
	rm -f /var/cache/apk/*

COPY my.cnf /etc/mysql/my.cnf
COPY db.sql /db.sql

RUN mkdir /app
RUN mysql_install_db --user=root > /dev/null
RUN mkdir -p /run/mysqld

RUN /usr/bin/mysqld --user=root --bootstrap --verbose=0 < /db.sql

EXPOSE 3306

CMD exec /usr/bin/mysqld --user=root --console
