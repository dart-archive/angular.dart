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


function updateConfigForBrowsers(config, browsers, shards) {
  shards = (shards == null) ? 1 : shards;
  if (!browsers) {
    throw new Error("updateConfigForBrowsers requires a list of browsers.");
  }
  if (browsers.length == 1 && browsers[0] == "DartiumWithWebPlatform") {
    config.multiCapabilities = [{
      browserName: 'chrome',
      chromeOptions: {
        binary: getDartiumBinary()
      },
      count: shards
    }];
    return;
  }

  // We can either test with local browsers or those on SauceLabs but not both.
  var localBrowser = false, sauceBrowser = false;
  config.multiCapabilities = [];
  browsers.forEach(function(browser) {
    if (browser.indexOf("SL_") == 0) {
      sauceBrowser = true;
      browser = browser.substr(3).toLowerCase();
    } else {
      localBrowser = true;
      browser = browser.toLowerCase();
    }
    if (localBrowser && sauceBrowser) {
      throw new Error(
          "You can either tests against local browsers or sauce " +
          "browsers but not both.");
    }
    var capability = { browserName: browser };
    if (browser == "chrome") {
      capability.chromeOptions = {
        // Ref: https://github.com/travis-ci/travis-ci/issues/938
        //      https://sites.google.com/a/chromium.org/chromedriver/help/chrome-doesn-t-start
        args: ['no-sandbox=true']
      };
      if (localBrowser && env.CHROME_BIN) {
        capability.chromeOptions.binary = env.CHROME_BIN;
      }
    }
    config.multiCapabilities.push(capability);
  });

  if (sauceBrowser) {
    config.seleniumAddress = null;
    config.sauceUser = env.SAUCE_USERNAME;
    config.sauceKey = env.SAUCE_ACCESS_KEY;
    config.multiCapabilities.forEach(function(capability) {
      capability['tunnel-identifier'] = env.TRAVIS_JOB_NUMBER;
      capability['build'] = env.TRAVIS_BUILD_NUMBER;
    });
  }
}

exports.getBaseUrl = getBaseUrl;
exports.updateConfigForBrowsers = updateConfigForBrowsers;
