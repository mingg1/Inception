#!/bin/sh

set -eu

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"
LOGDIR="/var/log/mysql"
CONFIG_FILE="/etc/my.cnf.d/mariadb_config.cnf"
INIT_FILE="${DATADIR}/init.sql"

echo "🔧 Setting up MariaDB directories"
mkdir -p "${DATADIR}" "${RUNDIR}" "${LOGDIR}"
chown -R mysql:mysql "${DATADIR}" "${RUNDIR}" "${LOGDIR}"
# chmod -R 755 "${DATADIR}"

if [ ! -d "${DATADIR}/mysql" ]; then
	echo "🗄️ Initializing MariaDB system tables"
	mariadb-install-db --basedir=/usr --user=mysql --datadir="${DATADIR}" --skip-test-db
fi

# echo "Creating Wordpress database and user"
# mysqld --user=mysql --skip-networking --bootstrap --datadir="${DATADIR}" << EOF
# USE mysql;
# FLUSH PRIVILEGES;
echo "📝 Preparing init SQL"
cat > "${INIT_FILE}" << EOF

ALTER USER 'root'@'localhost' IDENTIFIED BY "${MYSQL_ROOT_PASSWORD}";
CREATE DATABASE IF NOT EXISTS \`${WORDPRESS_DATABASE_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS \`${WORDPRESS_DATABASE_USER}\`@'%' IDENTIFIED BY "${WORDPRESS_DATABASE_PASSWORD}";
GRANT ALL PRIVILEGES ON \`${WORDPRESS_DATABASE_NAME}\`.* TO \`${WORDPRESS_DATABASE_USER}\`@'%';
FLUSH PRIVILEGES;
EOF
chown mysql:mysql "${INIT_FILE}"

echo "🚀 Starting MariaDB server"
exec mariadbd --defaults-file="${CONFIG_FILE}" --init-file="${INIT_FILE}" --console