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

echo Fetch Dart channel: $CHANNEL

URL_PREFIX=https://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest
DART_SDK_URL=$URL_PREFIX/sdk/dartsdk-linux-x64-release.zip
if [[ "${BROWSERS,,}" =~ "dartium" ]]; then
  DARTIUM_URL=$URL_PREFIX/dartium/dartium-linux-x64-release.zip
fi

parallel_get() {(
  _download_and_unzip() {
    # TODO(chirayu):  Hack to run npm in parallel.  Better to refactor and run
    # both npm install and pub install in parallel.  Both must be run AFTER any
    # rebasing onto g3v1x.  Also "pub install" can only happen after the Dart
    # SDK is unzipped and the path has been updated.
    if [[ "$1" == "npm" ]]; then
      npm install
      return
    fi

    ZIPFILE=${1/*\//}
    curl -O -L $1 && unzip -q $ZIPFILE && rm $ZIPFILE
  }
  export -f _download_and_unzip

  echo "$@" | xargs -d ' ' -n 1 -P 2 -I URL bash -c '_download_and_unzip URL'
)}

parallel_get npm $DART_SDK_URL $DARTIUM_URL

echo Fetched new dart version $(<dart-sdk/version)

if [[ -n $DARTIUM_URL ]]; then
  mv dartium-* chromium
fi

sh -e /etc/init.d/xvfb start
