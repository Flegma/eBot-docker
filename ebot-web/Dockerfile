FROM php:7.4-fpm

WORKDIR /app

RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql

RUN apt-get update && apt-get install -y git gettext-base && apt-get clean

RUN echo 'date.timezone = Europe/Paris' >> /usr/local/etc/php/conf.d/timezone.ini

# Clone web panel at build time
RUN git config --global http.sslverify false \
    && git clone https://github.com/Flegma/eBot-CSGO-Web.git eBot-CSGO-Web

# Patch Symfony 1.4 for PHP 7.4
COPY patch-symfony.php ./
RUN php patch-symfony.php eBot-CSGO-Web

# Prepare dirs
RUN mkdir -p eBot-CSGO-Web/cache eBot-CSGO-Web/log \
    && chown -R www-data:www-data eBot-CSGO-Web/cache eBot-CSGO-Web/log

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
