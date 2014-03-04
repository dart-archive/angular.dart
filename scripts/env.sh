#!/bin/sh
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

export CHROME_CANARY_BIN=${CHROME_CANARY_BIN:-"$DARTIUM"}
export CHROME_BIN=${CHROME_BIN:-"google-chrome"}
export DART_FLAGS='--enable_type_checks --enable_asserts'
export PATH=$PATH:$DARTSDK/bin
