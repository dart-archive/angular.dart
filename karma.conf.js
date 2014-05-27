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
      'test/*.dart',
      'test/**/*_spec.dart',
      'test/config/init_guinness.dart',
      {pattern: '**/*.dart', watched: true, included: false, served: true},
      'packages/browser/dart.js'
    ],

    exclude: [
      'test/io/**',
      'test/tools/transformer/**',
      'test/tools/symbol_inspector/**'
    ],

    autoWatch: false,

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 20000,
    // Time for dart2js to run on Travis... [ms]
    browserNoActivityTimeout: 1500000,

    plugins: [
      'karma-dart',
      'karma-chrome-launcher',
      'karma-firefox-launcher',
      'karma-script-launcher',
      'karma-junit-reporter',
      '../../../karma-parser-getter-setter'
    ],

    karmaDartImports: {
      guinness: 'package:guinness/guinness_html.dart'
    },

    customLaunchers: {
      ChromeNoSandbox: { base: 'Chrome', flags: ['--no-sandbox'] },
      // Only needed for Chrome 34.  These features are enabled by default in Chrome 35.
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
    }
  });
};
