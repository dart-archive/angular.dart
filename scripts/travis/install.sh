#!/bin/bash

set -e -o pipefail

sh -e /etc/init.d/xvfb start

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
