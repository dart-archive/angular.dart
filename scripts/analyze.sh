#!/bin/bash

set -e

. $(dirname $0)/env.sh

echo '============='
echo '== ANALYZE =='
echo '============='

OUT=tmp/all.dart
mkdir -p tmp

$DARTANALYZER --version

echo // generated file > $OUT

for FILE in $(ls lib/angular.dart \
                 benchmark/*_perf.dart \
                 test/*_spec.dart \
                 test/*/*_spec.dart \
                 lib/change_detection/change_detection.dart \
                 lib/change_detection/dirty_checking_change_detector.dart \
                 lib/change_detection/watch_group.dart \
             )
do
  echo export \'../$FILE\' hide main, NestedRouteInitializer\; >> $OUT
done

$NGDART_SCRIPT_DIR/generate-expressions.sh

$DARTANALYZER --no-hints $OUT
