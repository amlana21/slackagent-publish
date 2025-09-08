# dockerfile for a nodejs app
FROM  --platform=linux/amd64 public.ecr.aws/docker/library/node:20.19.2-slim

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

CMD ["node", "index.js"]