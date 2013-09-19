var fs = require('fs');
var sys = require('sys');
var exec = require('child_process').exec;

var generateParser = function(logger) {
  var log = logger.create('generate-parser');
  return function(content, file, done) {
    log.info('Generating parser for parser test: %s', file.originalPath);

    fs.readFile(file.originalPath, function(err, data) {
      if (err) throw err;

      exec(
          'dart --checked bin/parser_generator_for_spec.dart getter-setter',
          function(err, stdout, stderr) {
            if (err) throw err;
            data = data.toString();
            data = data.replace(/^.* \/\/ REMOVE$/m, '');
            data = data.replace(/_template;/, '_generated;');
            done(data + '\n\n' + stdout);
          });
    });
  }
}

module.exports = generateParser;
