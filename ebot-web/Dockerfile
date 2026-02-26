FROM php:7.4-fpm

WORKDIR /app

RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql

RUN apt-get update && apt-get install -y git && apt-get clean

RUN echo 'date.timezone = Europe/Paris' >> /usr/local/etc/php/conf.d/timezone.ini

COPY setup.sh patch-symfony.php ./

RUN chmod +x setup.sh

CMD ["./setup.sh"]
