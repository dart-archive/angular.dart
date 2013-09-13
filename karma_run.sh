#!/bin/sh

# OS-specific Dartium path defaults
case $( uname -s ) in
  Darwin)
    CHROME_CANARY_BIN=${CHROME_CANARY_BIN:-"/Applications/dart/chromium/Chromium.app/Contents/MacOS/Chromium"};;
esac

# Check for node
if [ -z "$(which node)" ]; then
  echo "node.js does not appear to be on the path."
  echo "You can obtain it from http://nodejs.org"
  exit 1;
fi

# Check for karma
KARMA_PATH="node_modules/karma/bin/karma"
if [ ! -e "$KARMA_PATH" ]; then
  echo "karma does not appear to be installed. Installing:"
  npm install
fi

dartanalyzer lib/angular.dart && node $KARMA_PATH run --port=8765
