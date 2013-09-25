#!/bin/sh

DART_ANALYSER_BIN=`which dartanalyzer`

# OS-specific Dartium path defaults
if [ -z $DART_ANALYSER_BIN ]; then
  case $( uname -s ) in
    Darwin)
      DART_ANALYSER_BIN=/Applications/dart/dart-sdk/bin/dartanalyzer
    ;;
    Linux)
      DART_ANALYSER_BIN=/opt/dart-sdk/bin/dartanalyzer
  esac
fi

OUT=tmp/all.dart
mkdir -p tmp

echo // generated file > $OUT

for FILE in $(ls lib/angular.dart perf/*_perf.dart test/*_spec.dart test/*/*_spec.dart)
do
  echo import \'../$FILE\'\; >> $OUT
done

./generate.sh && $DART_ANALYSER_BIN $OUT
