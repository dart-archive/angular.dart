var env = process.env;

function getClientArgs() {
  if (env.TRAVIS == null || env.TESTS != "dart2js" ||
      env.NUM_KARMA_SHARDS == null || env.KARMA_SHARD_ID == "") {
    return null;
  }
  return {
    travis: {
      numKarmaShards: parseInt(env.NUM_KARMA_SHARDS),
      karmaShardId: parseInt(env.KARMA_SHARD_ID)
    }
  };
}


module.exports = function(config) {
  config.set({
    //logLevel: config.LOG_DEBUG,
    basePath: '.',
    frameworks: ['dart-unittest'],

    // list of files / patterns to load in the browser
    // all tests must be 'included', but all other libraries must be 'served' and
    // optionally 'watched' only.
    files: [
      'packages/web_components/platform.js',
      'packages/web_components/dart_support.js',
      'test/core_dom/web_components_support.js',
      'test/*.dart',
      'test/**/*_spec.dart',
      'test/config/init_guinness.dart',
      {pattern: 'packages/**/*.dart', watched: true, included: false, served: true},
      {pattern: 'test/**/*.dart', watched: true, included: false, served: true},
      {pattern: 'bin/**/*.dart', watched: true, included: false, served: true},
      {pattern: 'lib/**/*.dart', watched: true, included: false, served: true},
      'packages/browser/dart.js'
    ],

    client: {
      args: [],
      clientArgs: getClientArgs()
    },

    exclude: [
      'test/io/**',
      'test/tools/transformer/**',
      'test/tools/symbol_inspector/**'
    ],

    autoWatch: false,

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 120000,
    // Time for dart2js to run on Travis... [ms]
    browserNoActivityTimeout: 1500000,

    plugins: [
      'karma-dart',
      'karma-chrome-launcher',
      'karma-sauce-launcher',
      'karma-firefox-launcher',
      'karma-script-launcher',
      'karma-junit-reporter',
      '../../../karma-parser-getter-setter'
    ],

    karmaDartImports: {
      guinness: 'package:guinness/guinness_html.dart'
    },

    customLaunchers: {
      'SL_Chrome': {
          base: 'SauceLabs',
          browserName: 'chrome',
          version: '35'
      },
      'SL_Firefox': {
          base: 'SauceLabs',
          browserName: 'firefox',
          version: '30'
      },
      'SL_Safari6': {
          base: 'SauceLabs',
          browserName: 'safari',
          version: '6'
      },
      'SL_Safari7': {
          base: 'SauceLabs',
          browserName: 'safari',
          version: '7'
      },
      'SL_IE10': {
          base: 'SauceLabs',
          browserName: 'internet explorer',
          platform: 'Windows 8',
          version: '10'
      },
      'SL_IE11': {
          base: 'SauceLabs',
          browserName: 'internet explorer',
          platform: 'Windows 8.1',
          version: '11'
      },
      DartiumWithWebPlatform: {
        base: 'Dartium',
        flags: ['--enable-experimental-web-platform-features'] }
    },

    browsers: ['DartiumWithWebPlatform'],

    preprocessors: {
      'test/core/parser/generated_getter_setter.dart': ['parser-getter-setter']
    },

    junitReporter: {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    },
    sauceLabs: {
        testName: 'AngularDart',
        tunnelIdentifier: env.TRAVIS_JOB_NUMBER,
        startConnect: false,
        options:  {
            'selenium-version': '2.41.0',
            'max-duration': 2700
        }
    }
  });
};
