#!/bin/bash

elm make src/Main.elm --output=out/main.js
# && (cd out || exit; python -m http.server 8000)