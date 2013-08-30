module.exports = function(config) {
  config.set({
    basePath: '.',
    frameworks: ['dart-unittest'],

    // list of files / patterns to load in the browser
    // all tests must be 'included', but all other libraries must be 'served' and
    // optionally 'watched' only.
    files: [
      'test/parser/parser_spec.dart',
      'test/_specs.dart',
      'perf/*.dart',
      {pattern: '**/*.dart', watched: true, included: false, served: true},
      'packages/browser/dart.js',
      'packages/browser/interop.js'
    ],

    autoWatch: false,

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 5000,

    preprocessors: {
      'test/parser/parser_spec.dart': ['parser-generator']
    },

    plugins: [
      'karma-dart',
      'karma-chrome-launcher',
      'karma-script-launcher',
      'karma-junit-reporter',
      '../../../karma-parser-generator'
    ]
  });
};
