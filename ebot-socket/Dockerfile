FROM creativeprojects/php-nodejs:7.4

WORKDIR /app

RUN apt-get update && apt-get install -y gettext-base && apt-get clean

# Clone bot at build time
RUN git clone https://github.com/Flegma/eBot-CSGO.git eBot-CSGO

# Install dependencies at build time
WORKDIR /app/eBot-CSGO
RUN composer install && npm install

WORKDIR /app

COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

CMD ["./entrypoint.sh"]
