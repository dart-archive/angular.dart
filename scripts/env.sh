#!/bin/bash
set -e

if [ -n "$DART_SDK" ]; then
    DARTSDK=$DART_SDK
else
    echo "sdk=== $DARTSDK"
    DART=`which dart|cat` # pipe to cat to ignore the exit code
    DARTSDK=`which dart | sed -e 's/\/dart\-sdk\/.*$/\/dart-sdk/'`

    if [ "$DARTSDK" = "/Applications/dart/dart-sdk" ]; then
        # Assume we are a mac machine with standard dart setup
        export DARTIUM="/Applications/dart/chromium/Chromium.app/Contents/MacOS/Chromium"
    else
        DARTSDK="`pwd`/dart-sdk"
        case $( uname -s ) in
          Darwin)
            export DARTIUM=${DARTIUM:-./dartium/Chromium.app/Contents/MacOS/Chromium}
            ;;
          Linux)
            export DARTIUM=${DARTIUM:-./dartium/chrome}
            ;;
        esac
    fi
fi

export DART_SDK="$DARTSDK"
export DART=${DART:-"$DARTSDK/bin/dart"}
export PUB=${PUB:-"$DARTSDK/bin/pub"}
export DARTANALYZER=${DARTANALYZER:-"$DARTSDK/bin/dartanalyzer"}
export DARTDOC=${DARTDOC:-"$DARTSDK/bin/dartdoc"}
export DART_DOCGEN=${DART_DOCGEN:-"$DARTSDK/bin/docgen"}

export DARTIUM_BIN=${DARTIUM_BIN:-"$DARTIUM"}
export CHROME_BIN=${CHROME_BIN:-"google-chrome"}

export PATH=$PATH:$DARTSDK/bin

export NGDART_SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
export NGDART_BASE_DIR=$(dirname $NGDART_SCRIPT_DIR)

echo '*********'
echo '** ENV **'
echo '*********'
echo DART_SDK=$DART_SDK
echo DART=$DART
$DART --version
echo PUB=$PUB
echo DARTANALYZER=$DARTANALYZER
echo DARTDOC=$DARTDOC
echo DART_DOCGEN=$DART_DOCGEN
echo DARTIUM_BIN=$DARTIUM_BIN
echo CHROME_BIN=$CHROME_BIN
echo PATH=$PATH
echo NGDART_BASE_DIR=$NGDART_BASE_DIR
echo NGDART_SCRIPT_DIR=$NGDART_SCRIPT_DIR
