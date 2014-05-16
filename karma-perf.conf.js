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
      'benchmark/dom/*.dart',
      'benchmark/*_perf.dart',
      'test/config/init_guinness.dart',
      {pattern: '**/*.dart', watched: true, included: false, served: true},
      'packages/browser/dart.js'
    ],

    autoWatch: false,

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 5000,

    plugins: [
      'karma-dart',
      'karma-chrome-launcher',
      'karma-script-launcher',
      'karma-junit-reporter',
      '../../../karma-parser-getter-setter'
    ],

    karmaDartImports: {
      guinness: 'package:guinness/guinness_html.dart'
    },

    preprocessors: {
      'test/core/parser/generated_getter_setter.dart': ['parser-getter-setter']
    },

    junitReporter: {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    }
  });
};
