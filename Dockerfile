FROM node:latest

RUN npm install -g elm

COPY . /src
WORKDIR /src

RUN cp -r out/* /build_out/
RUN elm make --optimize --output=/build_out/main.js src/Main.elm
