#!/bin/bash

# Run E2E / Protractor tests.

set -o errexit pipefail

. $(dirname $0)/env.sh

SIGNALS=(ERR HUP INT QUIT PIPE TERM)

_onSignal() {
  EXIT_CODE=$?
  # Kill all child processes (running servers.)
  kill 0
  # Need to explicitly kill ourselves to let the caller know we died from a
  # signal.  Ref: http://www.cons.org/cracauer/sigint.html
  sig=$1
  trap - "${SIGNALS[@]}"  # disable signals so we don't capture them again.
  if [[ "$sig" == "ERR" ]]; then
    exit $EXIT_CODE
  else
    kill -$sig $$
  fi
}

for s in "${SIGNALS[@]}" ; do
  trap "_onSignal $s" $s
done


install_deps() {(
  SELENIUM_VER="2.42"
  SELENIUM_ZIP="selenium-server-standalone-$SELENIUM_VER.0.jar"
  CHROMEDRIVER_VER="2.10"
  # chromedriver
  case "$(uname -s)" in
    (Darwin) CHROMEDRIVER_ZIP="chromedriver_mac32.zip" ;;
    (Linux)  CHROMEDRIVER_ZIP="chromedriver_linux64.zip" ;;
    (*) echo Unsupported OS >&2; exit 2 ;;
  esac
  mkdir -p e2e_bin && cd e2e_bin
  if [[ ! -e "$SELENIUM_ZIP" ]]; then
    curl -O "http://selenium-release.storage.googleapis.com/$SELENIUM_VER/$SELENIUM_ZIP"
  fi
  if [[ ! -e "$CHROMEDRIVER_ZIP" ]]; then
    curl -O "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VER/$CHROMEDRIVER_ZIP"
    unzip "$CHROMEDRIVER_ZIP"
  fi
)}


start_servers() {
  # Run examples.
  ( 
    cd example
    pub install
    pub build
    rsync -rl --exclude packages web/ build/web/
    rm -rf build/web/packages
    ln -s $PWD/packages build/web/packages
  )
  PORT=28000
  (cd example/build/web && python -m SimpleHTTPServer $PORT) >/dev/null 2>&1 &
  export NGDART_EXAMPLE_BASEURL=http://127.0.0.1:$PORT

  # Allow chromedriver to be found on the system path.
  export PATH=$PATH:$PWD/e2e_bin

  # Start selenium.  Kill all output - selenium is extremely noisy.
  java -jar ./e2e_bin/selenium-server-standalone-2.42.0.jar >/dev/null 2>&1 &

  sleep 4 # wait for selenium startup
}


# Main
install_deps
start_servers
(cd test_e2e && pub install)
./node_modules/.bin/protractor_dart test_e2e/examplesConf.js
