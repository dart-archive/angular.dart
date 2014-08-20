#!/bin/bash

set -e -o pipefail

# Fail fasts.

git merge-base --is-ancestor 44577768e6bd4ac649703f6172c2490bce4f9132 HEAD && \
  G3V1X_LINEAGE=1 || G3V1X_LINEAGE=0

if [[ "$USE_G3" == "YES" && "$G3V1X_LINEAGE" == "1" ]]; then
  exec > >(tee SKIP_TRAVIS_TESTS)
  echo '==================================================================='
  echo '== SKIPPING script: The current SHA is already a descendent of   =='
  echo '== g3v1x making USE_G3 redundant.                                =='
  echo '==================================================================='
  exit 0
fi

AVAILABLE_DART_VERSION=$(curl "https://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/VERSION" | python -c \
    'import sys, json; print(json.loads(sys.stdin.read())["version"])')

# g3v1x and Dart 1.5.8
# --------------------
# Skip tests for branches based on the g3v1x channel with Dart 1.5.8.
# g3v1x uses dependency overrides that cannot be satisfied by the pub tool
# shipper in Dart version 1.5.8.
#
# Ref: https://travis-ci.org/angular/angular.dart/jobs/33106780
# 
#   Dart VM version: 1.5.8 (Tue Jul 29 07:05:41 2014) on "linux_x64"
#   Resolving dependencies... 
#   Incompatible version constraints on barback:
#   - angular 0.13.0 depends on version 0.14.1+3
#   - pub itself depends on version >=0.13.0 <0.14.1
if [[ "$USE_G3" == "YES" && "$AVAILABLE_DART_VERSION" == "1.5.8" ]]; then
  exec > >(tee SKIP_TRAVIS_TESTS)
  echo '==================================================================='
  echo '== SKIPPING script: The g3stable job is rebased on the g3v1x     =='
  echo '== branch.  The g3v1x branch cannot be tested with Dart          =='
  echo '== version 1.5.8.  The dependency overrides require a newer      =='
  echo '== version of Dart.                                              =='
  echo '== Ref: https://travis-ci.org/angular/angular.dart/jobs/33106780 =='
  echo '==================================================================='
  exit 0
fi

DARTIUM_ZIP=http://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/dartium/dartium-linux-x64-release.zip

shopt -s nocasematch

if [[ $BROWSERS =~ "dartium" ]]; then
  echo "Installing Dartium from $DARTIUM_ZIP"
  curl -L $DARTIUM_ZIP > dartium.zip
  unzip dartium.zip > /dev/null
  rm -rf dartium
  rm dartium.zip
  mv dartium-* chromium
fi

echo Fetch Dart channel: $CHANNEL

DART_SDK_ZIP=dartsdk-linux-x64-release.zip

# TODO(chirayu): Remove this once issue 1350 is fixed.
SVN_REVISION=latest
if [[ "$AVAILABLE_DART_VERSION" == "1.6.0-dev.8.0" ]]; then
  SVN_REVISION=38831  # Use prior working version (1.6.0-dev.7.0)
fi

URL=https://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/$SVN_REVISION/sdk/$DART_SDK_ZIP
echo $URL
curl -L -O $URL

echo Fetched new dart version $(unzip -p $DART_SDK_ZIP dart-sdk/version)
unzip -q $DART_SDK_ZIP

sh -e /etc/init.d/xvfb start
