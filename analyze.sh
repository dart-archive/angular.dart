#!/bin/sh

# OS-specific Dartium path defaults
case $( uname -s ) in
  Darwin)
    DART_SDK=/Applications/dart/dart-sdk
esac



OUT=tmp/all.dart
mkdir -p tmp

echo // generated file > $OUT

for FILE in $(ls lib/angular.dart perf/*_perf.dart test/*_spec.dart test/*/*_spec.dart)
do
  echo import \'../$FILE\'\; >> $OUT
done

./generate.sh && $DART_SDK/bin/dartanalyzer $OUT
