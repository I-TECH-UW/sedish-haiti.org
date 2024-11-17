# Stage 1: Build the application
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json yarn.lock ./

RUN yarn install
COPY . .

RUN yarn build

# Stage 2: Run the application
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY package.json yarn.lock ./


RUN yarn install --production

EXPOSE 3030

CMD ["yarn", "start:prod"]