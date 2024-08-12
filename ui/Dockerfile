# https://github.com/vercel/next.js/blob/939251bf65633c6b330bdcd6476e651bbc16efa2/examples/with-docker-compose/next-app/dev.Dockerfile
FROM node:20.16.0-alpine3.20

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

COPY src ./src
COPY public ./public
COPY next.config.mjs .
COPY tsconfig.json .
CMD npm run dev
