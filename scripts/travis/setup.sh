#!/bin/bash

set -e -o pipefail


echo Fetch Dart channel: $CHANNEL

DART_SDK_ZIP=dartsdk-linux-x64-release.zip

echo http://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/sdk/$DART_SDK_ZIP
curl -L http://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/sdk/$DART_SDK_ZIP > $DART_SDK_ZIP
echo Fetched new dart version $(unzip -p $DART_SDK_ZIP dart-sdk/version)
rm -rf dart-sdk
unzip $DART_SDK_ZIP > /dev/null

if [ "$USE_G3" = "YES" ]; then
  echo =============================================================================
  echo "Rebasing onto g3v1x branch"
  git config --global user.email "travis@travis"
  git config --global user.name "AngularDart on Travis"
  git remote add upstream https://github.com/angular/angular.dart.git
  git fetch upstream
  git rebase --onto upstream/g3v1x upstream/g3v1x-master
fi

echo =============================================================================
. ./scripts/env.sh
$DART --version
$PUB install

# Record dart version for tests.
echo $'import "dart:js";\n\nmain() {\n  context["DART_VERSION"] = \''"$($DART --version 2>&1)"$'\';\n}' > test/dart_version.dart
