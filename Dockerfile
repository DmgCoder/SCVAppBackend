FROM node:22-alpine3.19 AS builder

RUN apk add g++ make py3-pip

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

RUN npm i -g @nestjs/cli

COPY . .

RUN npm run build


FROM node:22-alpine3.19 AS runner

WORKDIR /app

COPY --from=builder /app/package.json /app/package-lock.json ./

RUN npm ci --omit=dev

COPY --from=builder /app/dist ./dist

COPY --from=builder /app/src ./src

# COPY --from=builder /app/.env.production ./.env

RUN touch .env

ARG FCM_CERT
ARG JWT_PRIVATE_KEY
ARG JWT_PUBLIC_KEY

# For Firebase Cloud Messaging to work
RUN mkdir ./src/certs
RUN echo -e "$FCM_CERT" | base64 -d > ./src/certs/fcm-cert.json
#For public and private key to work
RUN echo -e "$JWT_PRIVATE_KEY" | base64 -d > ./src/certs/jwtRS256.key
RUN echo -e "$JWT_PUBLIC_KEY" | base64 -d > ./src/certs/jwtRS256.key.pub
#

EXPOSE 5050

ENV NODE_ENV=production

CMD ["node" , "dist/main.js"]
