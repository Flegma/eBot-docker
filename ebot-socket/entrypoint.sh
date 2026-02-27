#!/bin/bash
set -e

# Generate config from template (every restart)
echo "Generating config.ini from template..."
envsubst < /app/templates/config.ini.template > /app/eBot-CSGO/config/config.ini

cd /app/eBot-CSGO

echo "Waiting for MySQL to be ready..."
until php -r "new mysqli('mysqldb', '${MYSQL_USER}', '${MYSQL_PASSWORD}', '${MYSQL_DATABASE}');" 2>/dev/null; do
    echo "MySQL not ready, retrying in 3s..."
    sleep 3
done
echo "MySQL is ready."

exec php bootstrap.php
