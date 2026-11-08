FROM node:22-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json ./
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm ci --legacy-peer-deps

COPY . .
ENV VUE_APP_BACKEND_URL=http://localhost:8099/api/
ENV VUE_APP_AUTH_URL=http://localhost:6060/api/
ENV VUE_APP_CHAT_URL=http://localhost:4099
RUN npm run build

FROM nginx:1.27-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
