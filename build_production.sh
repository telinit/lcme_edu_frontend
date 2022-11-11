#!/bin/bash

cp -r out/* /build_out/
elm make --optimize --output=/build_out/main.js src/Main.elm