# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder
WORKDIR /site
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npx astro build

FROM nginx:alpine
COPY --from=builder /site/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
