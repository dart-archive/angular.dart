#!/bin/sh

set -e

. $(dirname $0)/env.sh

OUT=tmp/all.dart
mkdir -p tmp

$DARTANALYZER --version

echo // generated file > $OUT

for FILE in $(ls lib/angular.dart perf/*_perf.dart test/*_spec.dart test/*/*_spec.dart)
do
  echo export \'../$FILE\' hide main, NestedRouteInitializer\; >> $OUT
done

$(dirname $0)/generate-expressions.sh

$DARTANALYZER $OUT
