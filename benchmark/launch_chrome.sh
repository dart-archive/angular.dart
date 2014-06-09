#!/bin/bash

platform=`uname`
if [[ "$platform" == 'Linux' ]]; then
  `google-chrome --js-flags="--expose-gc"`
elif [[ "$platform" == 'Darwin' ]]; then
  `/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary --js-flags="--expose-gc"`
fi
