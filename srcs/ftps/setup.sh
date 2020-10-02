#!/bin/sh
mkdir -p /ftps/$FTP_USER

openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -subj "/C=FR/ST=denial/L=Paris/O=42/CN=pohl" -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
chmod 600 /etc/ssl/private/pure-ftpd.pem

adduser -h /ftps/$FTP_USER -D $FTP_USER
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

/usr/sbin/pure-ftpd -j -Y 2 -p 21000:21000 -P $START_FTPS_IP &
while true; do
	if ! pgrep pure-ftpd > /dev/null; then
		/usr/sbin/pure-ftpd -j -Y 2 -p 21000:21000 -P $START_FTPS_IP &
	fi
	sleep 10
done
