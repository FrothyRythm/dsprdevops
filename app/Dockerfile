FROM node:18-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY src/package*.json ./
RUN npm ci --only=production
COPY src/ .
EXPOSE 3000
USER node
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/health || exit 1
CMD ["npm", "start"]