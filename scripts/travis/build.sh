#!/bin/bash

set -e -o pipefail
. "$(dirname $0)/../env.sh"

echo '==========='
echo '== BUILD =='
echo '==========='

SIZE_TOO_BIG_COUNT=0

export SAUCE_ACCESS_KEY=`echo $SAUCE_ACCESS_KEY | rev`

# E2E tests only?
if [[ $JOB == e2e-* ]]; then
  echo '---------------------------'
  echo '-- E2E TEST: AngularDart --'
  echo '---------------------------'
  $NGDART_BASE_DIR/scripts/run-e2e-test.sh
  exit 0
fi


echo '-----------------------'
echo '-- TEST: AngularDart --'
echo '-----------------------'
echo BROWSER=$BROWSERS

_run_karma_tests() {(
  $NGDART_BASE_DIR/node_modules/jasmine-node/bin/jasmine-node playback_middleware/spec/

  _run_once() {
    export KARMA_SHARD_ID=$1
    node "node_modules/karma/bin/karma" start karma.conf \
        --reporters=junit,dots --port=$((8765+KARMA_SHARD_ID)) \
        --browsers=$BROWSERS --single-run
  }
  export -f _run_once

  if [[ $TESTS == "dart2js" ]]; then
    # Ref: test/_specs.dart: _numKarma shards.
    # Prime the dart2jsaas cache.
    NUM_KARMA_SHARDS=0 BROWSERS=SL_Chrome _run_once 0
    # Run sharded karma tests.
    export NUM_KARMA_SHARDS=4
    seq 0 $((NUM_KARMA_SHARDS-1)) | xargs -n 1 -P $NUM_KARMA_SHARDS -I SHARD_ID \
      bash -c '_run_once SHARD_ID'
  else
    _run_once
  fi
)}

_run_karma_tests
