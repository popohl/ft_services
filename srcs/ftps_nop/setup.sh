#!/bin/sh

echo -e "$PASSWORD\n$PASSWORD" | adduser -h ftp/$USER -s /sbin/nologin $USER
mkdir -p ftp/$USER
chown $USER:$USER ftp/$USER

exec /usr/sbin/vsftpd -opasv_min_port=21000 -opasv_max_port=21000 -opasv_address=172.17.0.3 /etc/vsftpd/vsftpd.conf
