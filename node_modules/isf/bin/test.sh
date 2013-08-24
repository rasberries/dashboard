#!/bin/bash

cd ../
node ./node_modules/.bin/mocha --compilers coffee:coffee-script ./spec/*
cd bin
