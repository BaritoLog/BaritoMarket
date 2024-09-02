# https://github.com/vercel/next.js/blob/939251bf65633c6b330bdcd6476e651bbc16efa2/examples/with-docker-compose/next-app/dev.Dockerfile
FROM node:20.16.0-alpine3.20 AS base

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

COPY next.config.mjs .
COPY tsconfig.json .
COPY src ./src
COPY public ./public

FROM base AS development
WORKDIR /app
COPY --from=base /app /app
CMD npm run dev

FROM base AS build
WORKDIR /app
COPY --from=base /app /app
RUN npm run build

FROM nginx:1.27.1-alpine3.20 AS final-image
COPY --from=build /app/out /usr/share/nginx/html
