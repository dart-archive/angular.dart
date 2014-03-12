#!/bin/bash

set -exv

sh -e /etc/init.d/xvfb start
sudo apt-get update -qq
sudo apt-get install -qq unzip chromium-browser
sudo apt-get install libxss1

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome*.deb
sudo chmod u+s /opt
