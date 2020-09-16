FROM node:current-alpine

ARG ENV
ENV NODE_ENV ${ENV}

RUN mkdir /frontend
WORKDIR /frontend

COPY package*.json ./
RUN yarn install

COPY . . 

RUN yarn build

EXPOSE 3000

CMD ["yarn", "start"]
