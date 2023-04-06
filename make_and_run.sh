#!/bin/bash

cp -r assets/* out/
sed -E -i "s|RANDOM_NONCE|$(uuid)|g" ./out/index.html
elm make src/Main.elm --output=out/main.js