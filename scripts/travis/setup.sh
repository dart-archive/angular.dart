#!/bin/bash

set -e


echo Fetch Dart channel: $CHANNEL

DART_SDK_ZIP=dartsdk-linux-x64-release.zip

echo http://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/sdk/$DART_SDK_ZIP
curl -L http://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/sdk/$DART_SDK_ZIP > $DART_SDK_ZIP
echo Fetched new dart version $(unzip -p $DART_SDK_ZIP dart-sdk/version)
rm -rf dart-sdk
unzip $DART_SDK_ZIP > /dev/null

echo =============================================================================
. ./scripts/env.sh
$DART --version
$PUB install
