FROM node:latest

RUN npm install -g elm

COPY . /src
WORKDIR /src

RUN mkdir /build_out
RUN cp -r out/* /build_out/
RUN elm make --optimize --output=/build_out/main.js src/Main.elm
