#!/bin/bash

set -e

. $(dirname $0)/env.sh

# Check for node
if [ -z "$(which node)" ]; then
  echo "node.js does not appear to be on the path."
  echo "You can obtain it from http://nodejs.org"
  exit 1;
fi

# Run npm install so we are up-to-date
cd $NGDART_BASE_DIR
npm install

# Print the dart VM version to the logs
$DART --version

# run io tests
$DART --checked $NGDART_BASE_DIR/test/io/all.dart

# run transformer tests
$DART --checked $NGDART_BASE_DIR/test/tools/transformer/all.dart

# run expression extractor tests
$DART --checked $NGDART_BASE_DIR/test/tools/symbol_inspector/symbol_inspector_spec.dart

$NGDART_SCRIPT_DIR/analyze.sh &&
  $NGDART_BASE_DIR/node_modules/jasmine-node/bin/jasmine-node playback_middleware/spec/ &&
  node "node_modules/karma/bin/karma" start karma.conf \
    --reporters=junit,dots --port=8765 --runner-port=8766 \
    --browsers=Dartium,Chrome,Firefox --single-run --no-colors

