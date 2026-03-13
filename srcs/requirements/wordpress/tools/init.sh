#!/bin/sh

GREEN="\e[1;32m"
ENDCOLOR="\e[0m"

set -eu

echo "${GREEN}🪄 Initializing WordPress...${ENDCOLOR}"
echo "memory limit=512M" > /etc/php83/conf.d/custom.ini

cd /var/www/html

if [ ! -f /usr/local/bin/wp ]; then
    echo "${GREEN}Downloading WordPress Client and renaming wp-cli.phar to wp...${ENDCOLOR}"
    
    wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp || { echo "Failed to download wp-cli.phar"; exit 1; }
    chmod +x /usr/local/bin/wp
fi

echo "${GREEN}Checking if MariaDB is running and waiting for it to be ready...${ENDCOLOR}"
mariadb-admin ping --protocol=tcp -h mariadb -u "$WORDPRESS_DATABASE_USER" -p "$WORDPRESS_DATABASE_USER_PASSWORD" --wait=300 || { echo "MariaDB is not ready. Exiting."; exit 1; }

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "${GREEN}Downloading, Installing, Configuring WordPress files (core essentials)...${ENDCOLOR}"
    
    wp core download --allow-root
    
    wp config create \
        --dbname="$WORDPRESS_DATABASE_NAME" \
        --dbuser="$WORDPRESS_DATABASE_USER" \
        --dbpass="$WORDPRESS_DATABASE_USER_PASSWORD" \
        --dbhost=mariadb \
        --force

    wp core install --url="$DOMAIN_NAME" --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root \
        --skip-email \
        --path=/var/www/html

    echo "${GREEN}==> Creating a WordPress user...${ENDCOLOR}"
    wp user create \
        --allow-root \
        "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
        --user_pass="$WORDPRESS_USER_PASSWORD"
else
    echo "${GREEN}==> WordPress is already downloaded, installed, and configured.${ENDCOLOR}"
fi

chown -R nginx:nginx /var/www/html
chmod -R 755 /var/www/html/

echo "${GREEN}==> Running PHP-FPM in the foreground (to prevent the container from stopping)...${ENDCOLOR}"
exec php-fpm83 -F