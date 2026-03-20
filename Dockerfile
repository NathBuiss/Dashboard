FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production && \
    mkdir -p views public/css public/js public/images /config /data

EXPOSE 3000

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs && \
    chown -R nodejs:nodejs /app /config /data

USER nodejs

CMD ["node", "server.js"]
