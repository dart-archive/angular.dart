#!/bin/bash

set -e -o pipefail


echo Fetch Dart channel: $CHANNEL

DART_SDK_ZIP=dartsdk-linux-x64-release.zip

# TODO(chirayu): Remove this once issue 1350 is fixed.
SVN_REVISION=latest
if [[ "$CHANNEL" == "dev" ]]; then
  issue_1350_state=$(curl 'https://api.github.com/repos/angular/angular.dart/issues/1020' | python -c \
                     'import sys, json; print(json.loads(sys.stdin.read())["state"])')
  if [[ "$issue_1350_state" == "open" ]]; then
    # Is there a newer dev SDK?
    latest_version=$(curl 'https://storage.googleapis.com/dart-archive/channels/dev/release/latest/VERSION' | python -c \
      'import sys, json; print(json.loads(sys.stdin.read())["version"])')
    if [[ "$latest_version" == "1.6.0-dev.8.0" ]]; then
      # Use prior working version (1.6.0-dev.7.0)
      SVN_REVISION=38831
    fi
  fi
fi

URL=https://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/$SVN_REVISION/sdk/$DART_SDK_ZIP
echo $URL
curl -L -O $URL

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
