FROM node:20.11.0

WORKDIR /usr/src/app

COPY . .

RUN npm install
RUN npm run build

ENTRYPOINT ["npm", "start"]