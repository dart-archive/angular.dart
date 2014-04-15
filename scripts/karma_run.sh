#!/bin/bash

. $(dirname $0)/env.sh

# Check for node
if [ -z "$(which node)" ]; then
  echo "node.js does not appear to be on the path."
  echo "You can obtain it from http://nodejs.org"
  exit 1;
fi

# Check for karma
KARMA_PATH="$NGDART_BASE_DIR/node_modules/karma/bin/karma"
if [ ! -e "$KARMA_PATH" ]; then
  echo "karma does not appear to be installed. Installing:"
  cd $NGDART_BASE_DIR
  npm install
fi

$DARTANALYZER $NGDART_BASE_DIR/lib/angular.dart && node $KARMA_PATH run --port=8765
