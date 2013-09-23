#!/bin/sh

# OS-specific Dartium path defaults
case $( uname -s ) in
  Darwin)
    CHROME_CANARY_BIN=${CHROME_CANARY_BIN:-"/Applications/dart/chromium/Chromium.app/Contents/MacOS/Chromium"};;
esac
if [ ! -x "$CHROME_CANARY_BIN" ]; then
  echo "Unable to determine path to Dartium browser. To correct:"
  echo "export CHROME_CANARY_BIN=path/to/dartium"
  exit 1;
fi
export CHROME_CANARY_BIN
export DART_FLAGS="--enable-type-checks --enable-asserts"

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

./analyze.sh && node "$KARMA_PATH" start karma.conf \
  --reporters=junit,dots --port=8765 --runner-port=8766 \
  --browsers=ChromeCanary --single-run --no-colors --no-color

