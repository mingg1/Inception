FROM alpine:3.23.3

RUN apk add --no-cache \
	mariadb-client \
    php83 \
	php83-fpm \
	php83-phar \
	php83-curl \
	php83-mysqli \
	php83-iconv \
	php83-json \
	wget && rm -rf /var/cache/apk/*

COPY ./conf/www.conf /etc/php83/php-fpm.d/www.conf

RUN mkdir -p /var/www/wp /var/www/html

COPY ./tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 9000

RUN ln -s /usr/bin/php83 /usr/bin/php

ENTRYPOINT ["/usr/local/bin/init.sh"]
