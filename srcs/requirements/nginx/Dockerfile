FROM alpine:3.23.3

RUN apk update && apk add --no-cache nginx openssl \
	&& rm -rf /var/cache/apk/*

RUN mkdir -p /etc/nginx/ssl

COPY ./conf/nginx.conf /etc/nginx/http.d/nginx.conf
RUN chmod 644 /etc/nginx/http.d/nginx.conf

COPY ./tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/init.sh"]