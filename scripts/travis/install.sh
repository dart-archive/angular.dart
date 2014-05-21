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

if [[ $BROWSERS =~ "chrome" ]]; then
  echo "Installing Chrome from $CHROME_DEB"
  wget $CHROME_DEB
  dpkg -I google-chrome*.deb
  sudo dpkg -i google-chrome*.deb
  sudo chmod u+s /opt
fi

if [[ $BROWSERS =~ "firefox" ]]; then
  echo "Installing Firefox from $FF_TAR"
  sudo mkdir -p /usr/local/firefox-$FIREFOX_VERSION
  sudo chmod u+s /usr/local/firefox-$FIREFOX_VERSION
  wget -O /tmp/firefox.tar.bz2 $FF_TAR
  cd /usr/local/firefox-$FIREFOX_VERSION
  sudo tar xf /tmp/firefox.tar.bz2
  sudo ln -sf /usr/local/firefox-$FIREFOX_VERSION/firefox/firefox /usr/local/bin/firefox
  sudo ln -sf /usr/local/firefox-$FIREFOX_VERSION/firefox/firefox-bin /usr/local/bin/firefox-bin
  export FIREFOX_BIN=/usr/local/bin/firefox
fi