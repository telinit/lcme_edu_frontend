FROM node:latest

RUN npm install -g elm
COPY . /src
WORKDIR /src