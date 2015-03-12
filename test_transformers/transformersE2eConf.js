/**
 * Environment Variables affecting this config.
 * --------------------------------------------
 *
 * DARTIUM: The full path to the Dartium binary.
 *
 * TEST_TRANSFORMERS_BASEURL: Overrides the default baseUrl to one of
 *     your choosing.  (The default is http://localhost:8080 which is the
 *     correct if you simply run "pub serve" inside the example folder of the
 *     AngularDart repo.)
 */

// TODO(chirayu/diana): Relocate shared configQuery.js
var configQuery = require('../test_e2e/configQuery.js');

var config = {
    seleniumAddress: 'http://127.0.0.1:4444/wd/hub',

    specs: ['relative_uris_spec.dart'],

    baseUrl: configQuery.getBaseUrl({
      envVar: "TEST_TRANSFORMERS_BASEURL"
    }),

    jasmineNodeOpts: {
      isVerbose: true, // display spec names.
      showColors: true, // print colors to the terminal.
      includeStackTrace: true, // include stack traces in failures.
      defaultTimeoutInterval: 80000 // wait time in ms before failing a test.
    }
};

configQuery.updateConfigForBrowsers(config, process.env.BROWSERS.split(","), 1);
config.multiCapabilities.forEach(function(capability) {
	capability['name'] = 'AngularDart Transformers E2E Suite';
});

exports.config = config;
