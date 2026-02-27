FROM php:7.4-fpm

WORKDIR /app

RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql

RUN apt-get update && apt-get install -y git gettext-base rsync && apt-get clean

RUN echo 'date.timezone = Europe/Paris' >> /usr/local/etc/php/conf.d/timezone.ini

# Clone web panel to staging path (not the volume mount point)
RUN git config --global http.sslverify false \
    && git clone https://github.com/Flegma/eBot-CSGO-Web.git eBot-CSGO-Web-src

# Patch Symfony 1.4 for PHP 7.4
COPY patch-symfony.php ./
RUN php patch-symfony.php eBot-CSGO-Web-src

# Prepare dirs
RUN mkdir -p eBot-CSGO-Web-src/cache eBot-CSGO-Web-src/log \
    && chown -R www-data:www-data eBot-CSGO-Web-src/cache eBot-CSGO-Web-src/log

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
