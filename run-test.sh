#!/bin/sh
CHROME_CANARY_BIN=/Applications/dart/chromium/Chromium.app/Contents/MacOS/Chromium
DART_FLAGS="--enable-type-checks --enable-asserts"

export CHROME_CANARY_BIN
export DART_FLAGS

node node_modules/karma/bin/karma start karma.conf \
	--reporters=junit,dots --port=8765 --runner-port=8766 \
	--browsers=ChromeCanary --single-run --no-colors --no-color

