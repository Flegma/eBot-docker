#!/bin/bash
set -e

# Check if the .installed file exists
if [ ! -f eBot-CSGO-Web/.installed ]; then

    git config --global http.sslverify false

    git clone https://github.com/deStrO/eBot-CSGO-Web.git temp

    cp -n -R temp/* eBot-CSGO-Web && rm -rf temp

    # Patch Symfony 1.4 for PHP 7.4 compatibility
    php /app/patch-symfony.php eBot-CSGO-Web

    cd eBot-CSGO-Web

    mkdir -p cache log

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
    chown -R www-data:www-data cache log

    cd ..

    echo "Setup complete."
    php-fpm
else
    echo "eBot Web is already installed. Skipping setup."
    cd eBot-CSGO-Web
    rm -rf cache/*
    php symfony cc
    chown -R www-data:www-data cache log
    echo "Cache cleared."

    php-fpm
fi
