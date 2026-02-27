#!/bin/bash
set -e

# Sync code from image to volume (updates code on rebuild, preserves runtime state)
echo "Syncing web panel code..."
rsync -a --exclude='.installed' --exclude='/cache/' --exclude='/log/' \
    /app/eBot-CSGO-Web-src/ /app/eBot-CSGO-Web/
mkdir -p /app/eBot-CSGO-Web/cache /app/eBot-CSGO-Web/log

cd /app/eBot-CSGO-Web

# Generate config files from templates (every restart)
echo "Generating config files from templates..."
envsubst < /app/templates/databases.yml.template > config/databases.yml
envsubst < /app/templates/app_user.yml.template > config/app_user.yml

if [ ! -f .installed ]; then
    echo "Waiting for MySQL to be ready..."
    until php -r "new PDO('mysql:host=mysqldb', 'root', getenv('MYSQL_ROOT_PASSWORD'));" 2>/dev/null; do
        echo "MySQL not ready, retrying in 3s..."
        sleep 3
    done
    echo "MySQL is ready."

    php symfony cc

    echo "Running doctrine:build..."
    echo y | php symfony doctrine:build --all --no-confirmation
    echo "doctrine:build completed successfully."

    php symfony guard:create-user --is-super-admin $EBOT_ADMIN_EMAIL $EBOT_ADMIN_LOGIN $EBOT_ADMIN_PASSWORD

    rm -rf web/installation

    touch .installed
    echo "Setup complete."
else
    echo "eBot Web already installed. Clearing cache..."
    rm -rf cache/*
    php symfony cc
fi

chown -R www-data:www-data cache log

exec php-fpm
