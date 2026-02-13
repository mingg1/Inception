FROM alpine:3.23.3

RUN apk update && apk add --no-cache mariadb mariadb-client \
	&& rm -rf /var/cache/apk/*

COPY ./conf/mariadb_config.cnf /etc/my.cnf.d/mariadb_config.cnf
RUN chmod 644 /etc/my.cnf.d/mariadb_config.cnf

COPY ./tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init.sh"]