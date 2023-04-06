#!/bin/bash

mkdir -p /build_out
cp -r dist/* /build_out/
sed -E -i "s|RANDOM_NONCE|$(uuid)|g" /build_out/index.html
elm make --optimize --output=/build_out/main.js src/Main.elm