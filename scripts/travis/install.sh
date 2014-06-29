#!/bin/bash

set -e

sh -e /etc/init.d/xvfb start

DARTIUM_ZIP=http://storage.googleapis.com/dart-archive/channels/$CHANNEL/release/latest/dartium/dartium-linux-x64-release.zip
FF_TAR=http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2
CHROME_DEB=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

shopt -s nocasematch

if [[ $BROWSERS =~ "dartium" ]]; then
  echo "Installing Dartium from $DARTIUM_ZIP"
  curl -L $DARTIUM_ZIP > dartium.zip
  unzip dartium.zip > /dev/null
  rm -rf dartium
  rm dartium.zip
  mv dartium-* dartium
fi

