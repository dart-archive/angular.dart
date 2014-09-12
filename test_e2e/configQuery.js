var env = process.env,
    fs = require('fs'),
    path = require('path'),
    runningOnTravis = (env.TRAVIS !== undefined);


function getBaseUrl(configWithEnvKey) {
    if (env[configWithEnvKey.envVar]) {
      return env[configWithEnvKey.envVar];
    } else if (env.USER == 'chirayu') {
      return 'http://example.ngdart.localhost';
    } else {
      // Default host:port when you run "pub serve" from the example
      // subdirectory of the AngularDart repo.
      return 'http://localhost:8080';
    }
}


function getDartiumBinary() {
    function ensure(condition) {
      if (!condition) throw "Unable to locate Dartium.  Please set the DARTIUM environment variable.";
    };

    if (env.DARTIUM_BIN) {
      return env.DARTIUM_BIN;
    }
    var platform = require('os').platform();
    var DART_SDK = env.DART_SDK;
    if (DART_SDK) {
      // Locate the chromium directory as a sibling of the DART_SDK
      // directory.  (It's there if you unpacked the full Dart distribution.)
      var chromiumRoot = path.join(DART_SDK, "../chromium");
      ensure(fs.existsSync(chromiumRoot));
      var binary = path.join(chromiumRoot,
          (platform == 'darwin') ? 'Chromium.app/Contents/MacOS/Chromium' : 'chrome');
      ensure(fs.existsSync(binary));
      return binary;
    }
    // Last resort: Try the standard location on Macs for the AngularDart team.
    var binary = '/Applications/dart/chromium/Chromium.app/Contents/MacOS/Chromium';
    ensure(platform == 'darwin' && fs.existsSync(binary));
    return binary;
}


function getChromeOptions() {
    if (!runningOnTravis) {
      return {'binary': getDartiumBinary()};
    }
    // In Travis, the list of browsers to test is specified as a CSV in the
    // BROWSERS environment variable.
    // TODO(chirayu): Parse the BROWSERS csv so we also test on Firefox.
    if (env.TESTS == "vm") {
      return {'binary': env.DARTIUM_BIN};
    }
    if (env.TESTS == "dart2js") {
      return {
          'binary': env.CHROME_BIN,
          // Ref: https://github.com/travis-ci/travis-ci/issues/938
          //      https://sites.google.com/a/chromium.org/chromedriver/help/chrome-doesn-t-start
          'args': ['no-sandbox=true']
      };
    }
    throw new Error("Unknown Travis configuration specified by TESTS variable");
}


exports.getBaseUrl = getBaseUrl;
exports.getChromeOptions = getChromeOptions;
