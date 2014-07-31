#!/bin/bash

# Run E2E / Protractor tests.
#
# Usage (from the angular.dart root folder):
#
#   # 1. Run all e2e tests.
#   ./scripts/run-e2e-test.sh
#   ./scripts/run-e2e-test.sh example transformers # same as previous

#   # 2. E2E test for the examples.
#   ./scripts/run-e2e-test.sh example
#
#   # 3. E2E test for transformers.
#   ./scripts/run-e2e-test.sh transformers

set -eE -o pipefail

. $(dirname $0)/env.sh

SIGNALS=(ERR HUP INT QUIT PIPE TERM EXIT)
export SIGNALS


_onSignal() {
  trap - "${SIGNALS[@]}"  # disable signals so we don't capture them again.
  # Kill all child processes (running servers.)  On Travis, kill 0 hangs for some
  # reason but I can't get it to repro on any other machine.  We don't need
  # cleanup on Travis anyway since the VM will be shutdown.
  if [[ -z $TRAVIS ]]; then
    kill 0
  fi
  # Need to explicitly kill ourselves to let the caller know we died from a
  # signal.  Ref: http://www.cons.org/cracauer/sigint.html
  sig=$1
  if [[ "$sig" != "ERR" ]]; then
    kill -$sig $$
  fi
  exit $EXIT_CODE
}
export -f _onSignal

_initSignals() {
  for s in "${SIGNALS[@]}" ; do
    trap "EXIT_CODE=$? ; _onSignal $s" $s
  done
}
export -f _initSignals

_initSignals


PLATFORM="$(uname -s)"

case "$PLATFORM" in
  (Darwin)
    parallelize_shell_cmd() {
      xargs -n 1 -P 4 -I ARG bash -c "set -vx; _initSignals; $*"
    }
    CHROMEDRIVER_ZIP="chromedriver_mac32.zip"
    ;;
  (Linux)
    parallelize_shell_cmd() {
      xargs -d ' ' -n 1 -P 4 -I ARG bash -c "set -vx; _initSignals; $*"
    }
    CHROMEDRIVER_ZIP="chromedriver_linux64.zip"
    ;;
  (*)
    echo Unsupported platform $PLATFORM.  Exiting ... >&2
    exit 3
    ;;
esac


install_deps() {(
  SELENIUM_ZIP="selenium-server-standalone-$SELENIUM_VERSION.0.jar"

  mkdir -p e2e_bin && cd e2e_bin
  if [[ ! -e "$SELENIUM_ZIP" ]]; then
    curl -O "http://selenium-release.storage.googleapis.com/$SELENIUM_VERSION/$SELENIUM_ZIP"
  fi
  if [[ ! -e "$CHROMEDRIVER_ZIP" ]]; then
    curl -O "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/$CHROMEDRIVER_ZIP"
    unzip "$CHROMEDRIVER_ZIP"
  fi
)}


function start_all_servers() {(
  local TEST_TYPES=("$@")

  build_app_and_serve() {(
    local TEST_TYPE=$1
    local APP_ROOT_VAR=TEST_${TEST_TYPE}_APP_ROOT
    cd ${!APP_ROOT_VAR}
    pub install
    pub build
    rsync -rl --exclude packages web/ build/web/
    rm -rf build/web/packages
    ln -s $PWD/packages build/web/packages

    # now serve it.
    local PORT_VAR=TEST_${TEST_TYPE}_PORT
    (cd build/web && python -m SimpleHTTPServer ${!PORT_VAR}) >/dev/null 2>&1 &
  )}
  export -f build_app_and_serve

  echo ${TEST_TYPES[@]} | parallelize_shell_cmd 'build_app_and_serve ARG'

  # Allow chromedriver to be found on the system path.
  export PATH=$PATH:$PWD/e2e_bin

  # Start selenium.  Kill all output - selenium is extremely noisy.
  java -jar ./e2e_bin/selenium-server-standalone-2.42.0.jar >/dev/null 2>&1 &

  sleep 4 # wait for selenium startup
)}


# Config

export TEST_EXAMPLE_PORT=28000
export TEST_EXAMPLE_APP_ROOT=example
export TEST_EXAMPLE_CONF=test_e2e/examplesConf.js
export TEST_EXAMPLE_BASEURL=http://127.0.0.1:$TEST_EXAMPLE_PORT

export TEST_TRANSFORMERS_PORT=28100
export TEST_TRANSFORMERS_APP_ROOT=test_transformers
export TEST_TRANSFORMERS_CONF=test_transformers/transformersE2eConf.js
export TEST_TRANSFORMERS_BASEURL=http://127.0.0.1:$TEST_TRANSFORMERS_PORT


# Main

if [[ ${#@} == "0" ]]; then
  set -- example transformers
fi
TEST_TYPES=($(echo "$@" | tr '[:lower:]' '[:upper:]'))

install_deps
start_all_servers ${TEST_TYPES[@]}

echo pstree after starting servers
if which pstree ; then
  pstree $$
fi


# TODO: REFACTOR.
(cd test_e2e && pub install)
(cd test_transformers && pub install)

run_protractor() {(
  local TEST_TYPE=$1
  local SPEC_FILE_VAR=TEST_${TEST_TYPE}_CONF
  ./node_modules/.bin/protractor_dart ${!SPEC_FILE_VAR}
)}
export -f run_protractor

echo ${TEST_TYPES[@]} | parallelize_shell_cmd 'run_protractor ARG'
