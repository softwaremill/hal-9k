FROM node:8.12.0-alpine

RUN apk add python \
    && apk add make \
    && apk add g++ \
    && apk add tzdata

RUN cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
RUN echo "Europe/Warsaw" > /etc/timezone

RUN adduser -h /hubot -s /bin/bash -S hubot
USER  hubot
WORKDIR /hubot

COPY scripts ./scripts
COPY external-scripts.json ./
COPY package-lock.json ./
COPY package.json ./


RUN npm install
ENV PATH="/hubot/node_modules/.bin:/hubot/node_modules/hubot/node_modules/.bin:$PATH"

ENTRYPOINT ["node_modules/.bin/hubot", "-a", "slack"]
