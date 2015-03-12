#!/bin/bash

. $(dirname $0)/env.sh

# Check for node
if [ -z "$(which node)" ]; then
  echo "node.js does not appear to be on the path."
  echo "You can obtain it from http://nodejs.org"
  exit 1;
fi

if dart2js $NGDART_BASE_DIR/perf/mirror_perf.dart -o $NGDART_BASE_DIR/perf/mirror_perf.dart.js > /dev/null ; then
	echo DART:
	$DART $NGDART_BASE_DIR/perf/mirror_perf.dart
	echo JavaScript:
	node $NGDART_BASE_DIR/perf/mirror_perf.dart.js
fi