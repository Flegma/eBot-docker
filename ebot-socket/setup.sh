#!/bin/bash
set -e

# Check if the .installed file exists
if [ ! -f .installed ]; then

    git clone https://github.com/deStrO/eBot-CSGO.git temp

    cp -n -R temp/* eBot-CSGO && rm -rf temp

    cd eBot-CSGO

    npm install

    composer install

    cd ..

    touch .installed
fi

cd eBot-CSGO

echo "Waiting for MySQL to be ready..."
until php -r "new mysqli('mysqldb', '${MYSQL_USER}', '${MYSQL_PASSWORD}', '${MYSQL_DATABASE}');" 2>/dev/null; do
    echo "MySQL not ready, retrying in 3s..."
    sleep 3
done
echo "MySQL is ready."

php bootstrap.php
