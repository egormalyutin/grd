FROM alpine

RUN apk add --no-cache wine nodejs
RUN npm i -g gulp-cli

ADD ./ /game/
WORKDIR /game

RUN npm i
RUN gulp

