#!/bin/bash

set -e -o pipefail
. "$(dirname $0)/../env.sh"

echo '==========='
echo '== BUILD =='
echo '==========='

SIZE_UNEXPECTED_COUNT=0

export SAUCE_ACCESS_KEY=`echo $SAUCE_ACCESS_KEY | rev`

function checkSize() {
  file=$1
  if [[ ! -e $file ]]; then
    echo Could not find file: $file
    SIZE_UNEXPECTED_COUNT=$((SIZE_UNEXPECTED_COUNT + 1));
  else
    expected=$2
    actual=`cat $file | gzip | wc -c`
    if (( 100 * $actual >= 105 * $expected )); then
      echo ${file} is too large expecting ${expected} was ${actual}.
      SIZE_UNEXPECTED_COUNT=$((SIZE_UNEXPECTED_COUNT + 1));
    fi
    if (( 100 * $actual <= 95 * $expected )); then
      echo ${file} is too small expecting ${expected} was ${actual}.
      echo Please update scripts/travis/build.sh with the correct value.
      SIZE_UNEXPECTED_COUNT=$((SIZE_UNEXPECTED_COUNT + 1));
    fi
  fi
}

function checkAllSizes() {(
    echo '-----------------------------------'
    echo '-- BUILDING: verify dart2js size --'
    echo '-----------------------------------'
    cd $NGDART_BASE_DIR/example
    checkSize build/web/animation.dart.js 224697
    checkSize build/web/bouncing_balls.dart.js 223927
    checkSize build/web/hello_world.dart.js 221838
    checkSize build/web/todo.dart.js 224414
    if ((SIZE_UNEXPECTED_COUNT > 0)); then
      exit 1
    else
      echo Generated JavaScript file size check OK.
    fi
)}

# E2E tests only?
if [[ $JOB == e2e-* ]]; then
  echo '---------------------------'
  echo '-- E2E TEST: AngularDart --'
  echo '---------------------------'
  $NGDART_BASE_DIR/scripts/run-e2e-test.sh
  exit 0
fi


if [[ $TESTS == "dart2js" ]]; then
  # skip auxiliary tests if we are only running dart2js
  echo '------------------------'
  echo '-- BUILDING: examples --'
  echo '------------------------'

  if [[ $CHANNEL == "DEV" ]]; then
    ($DART "$NGDART_BASE_DIR/bin/pub_build.dart" -p example \
        -e "$NGDART_BASE_DIR/example/expected_warnings.json"
     checkAllSizes
    ) &
  else
    (cd example; pub build ; checkAllSizes) &
  fi

else
  echo '--------------'
  echo '-- TEST: io --'
  echo '--------------'
  $DART --checked $NGDART_BASE_DIR/test/io/all.dart

  echo '----------------------------'
  echo '-- TEST: symbol extractor --'
  echo '----------------------------'
  $DART --checked $NGDART_BASE_DIR/test/tools/symbol_inspector/symbol_inspector_spec.dart

  $NGDART_SCRIPT_DIR/generate-expressions.sh
  $NGDART_SCRIPT_DIR/analyze.sh

  echo '-----------------------'
  echo '-- TEST: transformer --'
  echo '-----------------------'
  $DART --checked $NGDART_BASE_DIR/test/tools/transformer/all.dart

  echo '---------------------'
  echo '-- TEST: changelog --'
  echo '---------------------'
  $NGDART_BASE_DIR/node_modules/jasmine-node/bin/jasmine-node \
        $NGDART_SCRIPT_DIR/changelog/;

  (
    echo '---------------------'
    echo '-- TEST: benchmark --'
    echo '---------------------'
    cd $NGDART_BASE_DIR/benchmark
    $PUB install

    for file in *_perf.dart; do
      echo ======= $file ========
      $DART $file
    done
  )
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

echo '-------------------------'
echo '-- DOCS: Generate Docs --'
echo '-------------------------'
if [[ ${TRAVIS_JOB_NUMBER:(-2)} == ".1" ]]; then
  echo $NGDART_SCRIPT_DIR/generate-documentation.sh;
  $NGDART_SCRIPT_DIR/generate-documentation.sh;
fi
