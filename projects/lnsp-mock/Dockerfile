# Stage 1: Build the application
FROM node:14-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Run the application
FROM node:14-alpine

WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY package*.json ./

RUN npm install --only=production

EXPOSE 3030

CMD ["node", "dist/main"]
