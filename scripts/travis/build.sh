#!/bin/bash

set -e -o pipefail
. "$(dirname $0)/../env.sh"

echo '==========='
echo '== BUILD =='
echo '==========='

SIZE_TOO_BIG_COUNT=0

export SAUCE_ACCESS_KEY=`echo $SAUCE_ACCESS_KEY | rev`

function checkSize() {
  file=$1
  if [[ ! -e $file ]]; then
    echo Could not find file: $file
    SIZE_TOO_BIG_COUNT=$((SIZE_TOO_BIG_COUNT + 1));
  else
    expected=$2
    actual=`cat $file | gzip | wc -c`
    if (( 100 * $actual >= 105 * $expected )); then
      echo ${file} is too large expecting ${expected} was ${actual}.
      SIZE_TOO_BIG_COUNT=$((SIZE_TOO_BIG_COUNT + 1));
    fi
  fi
}


# E2E tests only?
if [[ $JOB == e2e-* ]]; then
  echo '---------------------------'
  echo '-- E2E TEST: AngularDart --'
  echo '---------------------------'
  $NGDART_BASE_DIR/scripts/run-e2e-test.sh
  exit 0
fi


#ckck# if [[ $TESTS == "dart2js" ]]; then
#ckck#   # skip auxiliary tests if we are only running dart2js
#ckck#   echo '------------------------'
#ckck#   echo '-- BUILDING: examples --'
#ckck#   echo '------------------------'
#ckck# 
#ckck#   if [[ $CHANNEL == "DEV" ]]; then
#ckck#     $DART "$NGDART_BASE_DIR/bin/pub_build.dart" -p example \
#ckck#         -e "$NGDART_BASE_DIR/example/expected_warnings.json"
#ckck#   else
#ckck#     ( cd example; pub build )
#ckck#   fi
#ckck# 
#ckck#   (
#ckck#     echo '-----------------------------------'
#ckck#     echo '-- BUILDING: verify dart2js size --'
#ckck#     echo '-----------------------------------'
#ckck#     cd $NGDART_BASE_DIR/example
#ckck#     checkSize build/web/animation.dart.js 208021
#ckck#     checkSize build/web/bouncing_balls.dart.js 202325
#ckck#     checkSize build/web/hello_world.dart.js 199919
#ckck#     checkSize build/web/todo.dart.js 203121
#ckck#     if ((SIZE_TOO_BIG_COUNT > 0)); then
#ckck#       exit 1
#ckck#     else
#ckck#       echo Generated JavaScript file size check OK.
#ckck#     fi
#ckck#   )
#ckck# else
#ckck#   echo '--------------'
#ckck#   echo '-- TEST: io --'
#ckck#   echo '--------------'
#ckck#   $DART --checked $NGDART_BASE_DIR/test/io/all.dart
#ckck# 
#ckck#   echo '----------------------------'
#ckck#   echo '-- TEST: symbol extractor --'
#ckck#   echo '----------------------------'
#ckck#   $DART --checked $NGDART_BASE_DIR/test/tools/symbol_inspector/symbol_inspector_spec.dart
#ckck# 
#ckck#   $NGDART_SCRIPT_DIR/generate-expressions.sh
#ckck#   $NGDART_SCRIPT_DIR/analyze.sh
#ckck# 
#ckck#   echo '-----------------------'
#ckck#   echo '-- TEST: transformer --'
#ckck#   echo '-----------------------'
#ckck#   $DART --checked $NGDART_BASE_DIR/test/tools/transformer/all.dart
#ckck# 
#ckck#   echo '---------------------'
#ckck#   echo '-- TEST: changelog --'
#ckck#   echo '---------------------'
#ckck#   $NGDART_BASE_DIR/node_modules/jasmine-node/bin/jasmine-node \
#ckck#         $NGDART_SCRIPT_DIR/changelog/;
#ckck# 
#ckck#   (
#ckck#     echo '---------------------'
#ckck#     echo '-- TEST: benchmark --'
#ckck#     echo '---------------------'
#ckck#     cd $NGDART_BASE_DIR/benchmark
#ckck#     $PUB install
#ckck# 
#ckck#     for file in *_perf.dart; do
#ckck#       echo ======= $file ========
#ckck#       $DART $file
#ckck#     done
#ckck#   )
#ckck# fi

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
    export NUM_KARMA_SHARDS=4
    echo {0..3} | xargs -d ' ' -n 1 -P $NUM_KARMA_SHARDS -I SHARD_ID bash -c '_run_once SHARD_ID'
  else
    _run_once
  fi
)}

_run_karma_tests

echo '-------------------------'
echo '-- DOCS: Generate Docs --'
echo '-------------------------'
if [[ $TESTS == "dart2js" ]]; then
  echo $NGDART_SCRIPT_DIR/generate-documentation.sh;
  $NGDART_SCRIPT_DIR/generate-documentation.sh;
fi
