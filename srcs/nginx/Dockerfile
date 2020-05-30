FROM alpine
LABEL Paul OHL <pohl@student.42.fr>

RUN apk update && apk upgrade
RUN apk add openssl openssh nginx

RUN rm /etc/nginx/conf.d/default.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf
RUN mkdir /run/nginx && echo 2 > /run/nginx/nginx.pid
RUN mkdir -p /usr/share/nginx/html
RUN wget -O /usr/share/nginx/html/index.html https://raw.githubusercontent.com/nginx/nginx/master/docs/html/index.html
RUN openssl req -x509 -newkey rsa:4096 -keyout /etc/nginx/certificate.key -out /etc/nginx/certificate.pem -days 365 -subj '/C=FR/ST=Denial/L=Paris/O=42/CN=localhost' -nodes
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ''
# RUN mkdir /run/openrc && touch /run/openrc/softlevel
RUN printf "hello\nhello\n" | adduser bonjour
RUN chown -R bonjour:bonjour /usr/share/nginx

EXPOSE 80 443 22

CMD /usr/sbin/sshd ; nginx -g 'daemon off;'
