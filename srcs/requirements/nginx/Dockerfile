FROM alpine:3.23.3

RUN apk update && apk add --no-cache nginx openssl \
	&& rm -rf /var/cache/apk/*

RUN mkdir -p /etc/nginx/ssl

COPY ./conf/nginx.cnf /etc/nginx/http.d/nginx.cnf
RUN chmod 644 /etc/nginx/http.d/nginx.cnf

COPY ./tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/init.sh"]

