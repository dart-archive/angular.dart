#!/bin/sh

set -e

export DART_SDK=`which dart | sed -e 's/\/dart\-sdk\/.*$/\/dart-sdk/'`

# OS-specific Dartium path defaults
case $( uname -s ) in
  Darwin)
    DARTIUM_BIN=${DARTIUM_BIN:-"/Applications/dart/chromium/Chromium.app/Contents/MacOS/Chromium"};;
esac
if [ ! -x "$DARTIUM_BIN" ]; then
  echo "Unable to determine path to Dartium browser. To correct:"
  echo "export DARTIUM_BIN=path/to/dartium"
  exit 1;
fi
export DARTIUM_BIN

# Check for node
if [ -z "$(which node)" ]; then
  echo "node.js does not appear to be on the path."
  echo "You can obtain it from http://nodejs.org"
  exit 1;
fi

# Run npm install so we are up-to-date
npm install

# Print the dart VM version to the logs
dart --version

# run io tests
dart --checked test/io/all.dart

# run transformer tests
dart --checked test/tools/transformer/all.dart

# run expression extractor tests
scripts/test-expression-extractor.sh

./scripts/analyze.sh &&
  node_modules/jasmine-node/bin/jasmine-node playback_middleware/spec/ &&
  node "node_modules/karma/bin/karma" start karma.conf \
    --reporters=junit,dots --port=8765 --runner-port=8766 \
    --browsers=Dartium,Chrome,Firefox --single-run --no-colors

