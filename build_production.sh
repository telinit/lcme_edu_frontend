#!/bin/bash

mkdir -p /build_out
cp -r assets/* /build_out/
sed -E -i "s|RANDOM_NONCE|$RANDOM$RANDOM$RANDOM$RANDOM|g" /build_out/index.html
elm make --optimize --output=/build_out/main.js src/Main.elm