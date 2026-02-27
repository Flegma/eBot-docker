# ── Build stage ──
FROM node:18 AS builder

WORKDIR /app

RUN git clone https://github.com/Flegma/ebot-project.git .

RUN npm install

RUN npx tsc -p tsconfig.json

# Copy JSON schema files that tsc doesn't emit
RUN cp src/logs-receiver/config-schema.json dist/logs-receiver/ \
    && cp src/logs-receiver/plugins/logger.schema.json dist/logs-receiver/plugins/

# ── Runtime stage ──
FROM node:18-slim

WORKDIR /app/ebot-project

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

CMD ["node", "dist/logs-receiver.js", "./configs/config.json"]
