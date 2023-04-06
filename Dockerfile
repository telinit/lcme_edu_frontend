FROM node:latest

RUN npm install -g elm

COPY . /src
WORKDIR /src

RUN bash build_production.sh
