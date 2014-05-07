#!/bin/bash

set -exv

sh -e /etc/init.d/xvfb start
sudo apt-get update -qq
sudo apt-get install libxss1

shopt -s nocasematch

case $( uname -s ) in
  Linux)
    DARTIUM_ZIP=dartium-linux-x64-release.zip
    ;;
  Darwin)
    DARTIUM_ZIP=dartium-macos-ia32-release.zip
    ;;
esac

if [[ $BROWSER =~ "chrome" ]]; then
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -I google-chrome*.deb
  sudo dpkg -i google-chrome*.deb
  sudo chmod u+s /opt
fi

if [[ $BROWSER =~ "firefox" ]]; then
  sudo mkdir -p /usr/local/firefox-29.0
  sudo chmod u+s /usr/local/firefox-29.0
  wget -O /tmp/firefox.tar.bz2 http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/29.0/linux-x86_64/en-US/firefox-29.0.tar.bz2
  cd /usr/local/firefox-29.0
  sudo tar xf /tmp/firefox.tar.bz2
  sudo ln -sf /usr/local/firefox-29.0/firefox/firefox /usr/local/bin/firefox
  sudo ln -sf /usr/local/firefox-29.0/firefox/firefox-bin /usr/local/bin/firefox-bin
  export FIREFOX_BIN=/usr/local/bin/firefox
fi

if [[ $BROWSER =~ "dartium" ]]; then
  echo http://storage.googleapis.com/dart-archive/channels/$CHANNEL/raw/latest/dartium/$DARTIUM_ZIP
  curl http://storage.googleapis.com/dart-archive/channels/$CHANNEL/raw/latest/dartium/$DARTIUM_ZIP > $DARTIUM_ZIP
  unzip $DARTIUM_ZIP > /dev/null
  rm -rf dartium
  rm $DARTIUM_ZIP
  mv dartium-* dartium
fi
