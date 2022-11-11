FROM node:latest

RUN npm install -g elm
COPY . /src
RUN elm make --optimize --output=/build_out/main.js src/Main.elm