#!/bin/bash

cd ../
node ./server.js --compile lib/isf.js
node ./node_modules/.bin/uglifyjs lib/isf.js -o lib/isf.min.js
cd bin
