# eBot Docker

## Overview
It is a containerized version of eBot, which is a full managed server-bot written in PHP and nodeJS. eBot features easy match creation and tons of player and matchstats. Once it's setup, using the eBot is simple and fast.

## How to run it

### Production mode
Clones the web panel code from GitHub during the Docker build. Use this for deployments.

```bash
cp .env.sample .env
# Edit .env with your configuration
docker compose build
docker compose up -d
```

### Development mode
Bind-mounts your local repositories into the containers so code changes are reflected immediately without rebuilding.

Requires all repositories to be cloned alongside `eBot-docker`:
```
parent/
  eBot-CSGO/          # Bot core (PHP + Node.js)
  eBot-CSGO-Web/      # Web panel (Symfony/PHP)
  ebot-project/       # Logs receiver (TypeScript)
  eBot-docker/
```

```bash
cp .env.sample .env
# Edit .env with your configuration
docker compose -f docker-compose.yml -f docker-compose.dev.yml build
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

How changes are picked up per service:
- **eBot-CSGO-Web** (PHP) — instant, just refresh the browser
- **eBot-CSGO** (PHP) — instant, but requires a container restart for the bot process: `docker restart ebot-docker-ebot-socket-1`
- **ebot-project** (TypeScript) — requires a container restart: `docker restart ebot-docker-ebot-logs-receiver-1`

To clear the Symfony cache after model/config changes in the web panel:
```bash
docker exec ebot-docker-ebot-web-1 bash -c "cd /app/eBot-CSGO-Web && php symfony cc"
```

## What needs to be changed
To ensure everything works correctly, you must configure the external addresses for the web and socket services.

### Web
To configure the web service, navigate to etc/eBotWeb and update the ebot_ip property with your external address.

## Socket
To configure the socket service, go to etc/eBotSocket and update the LOG_ADDRESS_SERVER property with your external address.

## Security
To improve security, you should set the web socket secret key in two specific configuration files:

For the web service, go the etc/eBotWeb directory and open the app_user.yml file. Inside this file, locate the WEBSOCKET_SECRET_KEY parameter and replace its value with a strong and unique secret key

For the socket service, navigate to the etc/eBotSocket directory and open the config.ini file. Within this file, find the websocket_secret_key property and update its value with the same key used for the web service. 
