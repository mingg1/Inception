#!/bin/sh

set -eu

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"
LOGDIR="/var/log/mysql"
CONFIG_FILE="/etc/my.cnf.d/mariadb_config.cnf"

echo "[DEBUG]Root password: ${WORDPRESS_DATABASE_USER_PASSWORD}"
echo "[DEBUG]User password: ${WORDPRESS_DATABASE_PASSWORD}"
echo "[DEBUG]Database: ${WORDPRESS_DATABASE_NAME}"
echo "[DEBUG]User: ${WORDPRESS_DATABASE_USER}"

echo "🔧 Setting up MariaDB directories"

mkdir -p "${DATADIR}" "${RUNDIR}" "${LOGDIR}"
chown -R mysql:mysql "${DATADIR}" "${RUNDIR}" "${LOGDIR}"
chmod -R 755 "${DATADIR}"

if [ ! -d "${DATADIR}/mysql" ]; then
	echo "Initializing MariaDB system tables"
	mariadb-install-db --basedir=/usr --user=mysql --datadir=/var/lib/mysql
else
	echo "MariaDB is already installed. Database and users are configured."
fi

echo "Creating Wordpress database and user"
mysqld --user=mysql --skip-networking --bootstrap --datadir="${DATADIR}" << EOF

USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY "${MYSQL_ROOT_PASSWORD}";
CREATE DATABASE IF NOT EXISTS \`${WORDPRESS_DATABASE_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS \`${WORDPRESS_DATABASE_USER}\`@'%' IDENTIFIED BY "${WORDPRESS_DATABASE_PASSWORD}";
GRANT ALL PRIVILEGES ON \`${WORDPRESS_DATABASE_NAME}\`.* TO \`${WORDPRESS_DATABASE_USER}\`@'%';
FLUSH PRIVILEGES;

EOF

echo "🚀 Starting MariaDB server"
exec mysqld --defaults-file="${CONFIG_FILE}" --console