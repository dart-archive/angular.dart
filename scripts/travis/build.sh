#!/bin/bash

set -evx
. ./scripts/env.sh

# skip auxiliary tests if we are only running dart2js
if [[ $TESTS == "dart2js" ]]; then
  cd example
  pub build
  cd ..
else
  # run io tests
  dart -c test/io/all.dart

  ./scripts/generate-expressions.sh
  ./scripts/analyze.sh

  ./node_modules/jasmine-node/bin/jasmine-node ./scripts/changelog/;
fi

BROWSERS=Dartium,ChromeNoSandbox
if [[ $TESTS == "dart2js" ]]; then
  BROWSERS=ChromeNoSandbox;
elif [[ $TESTS == "vm" ]]; then
  BROWSERS=Dartium;
fi

./node_modules/jasmine-node/bin/jasmine-node playback_middleware/spec/ &&
  node "node_modules/karma/bin/karma" start karma.conf \
    --reporters=junit,dots --port=8765 --runner-port=8766 \
    --browsers=$BROWSERS --single-run --no-colors

if [[ $TESTS != "dart2js" ]]; then
  ./scripts/generate-documentation.sh;
fi
