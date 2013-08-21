fs = require('fs');

var generateParser = function(logger) {
  var log = logger.create('generate-parser');
  log.info('hello');
  return function(content, file, done) {
    log.info('Generating parser for parser test: %s', file.originalPath);

    fs.readFile(file.originalPath, function(err, data) {
      if (err) throw err;
      done(data + '\n\nclass GeneratedParser implements Parser {\n' +
          '  GeneratedParser(Profiler x);\n' +
          '  call(String t) { return new Expression((_, [__]) => 1); }\n' +
          '}' +
          '\n' +
          'generatedMain() {\n' +
          '  describe(\'generated parser\', () {' +
          '    beforeEach(module((AngularModule module) {\n' +
          '      module.type(Parser, GeneratedParser);\n' +
          '    }));\n' +
          '    main();\n' +
          '  });' +
          '}\n'
      );
    });
  }
}

module.exports = generateParser;
