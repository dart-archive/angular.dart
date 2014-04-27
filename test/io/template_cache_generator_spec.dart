library ng.tool.template_cache_generator_spec;

import 'dart:async';
import 'dart:io';

import 'package:angular/tools/template_cache_generator.dart' as generator;

import 'package:guinness/guinness.dart';

void main() {
  describe('template_cache_generator', () {

    it('should correctly generate the templates cache file (template)', () {
      var tmpDir = Directory.systemTemp.createTempSync();
      Future flush;
      try {
        flush = generator.main([
            '--out=${tmpDir.path}/generated.dart',
            '--url-rewrites=/test/io/test_files,rewritten',
            '--skip-classes=MyComponent3',
            'test/io/test_files/templates/main.dart',
            'generated']);
      } catch(_) {
        tmpDir.deleteSync(recursive: true);
        rethrow;
      }
      return flush.then((_) {
        expect(new File('${tmpDir.path}/generated.dart').readAsStringSync(),
            '// GENERATED, DO NOT EDIT!\n'
            'library generated;\n'
            '\n'
            'import \'package:angular/angular.dart\';\n'
            '\n'
            'primeTemplateCache(TemplateCache tc) {\n'
            'tc.put("rewritten/templates/main.html", new HttpResponse(200, r"""Hello World!"""));\n'
            '}');
      }).whenComplete(() {
        tmpDir.deleteSync(recursive: true);
      });
    });

    it('should correctly generate the templates cache file (css)', () {
      var tmpDir = Directory.systemTemp.createTempSync();
      Future flush;
      try {
        flush = generator.main([
            '--out=${tmpDir.path}/generated.dart',
            '--url-rewrites=/test/io/test_files,rewritten',
            '--skip-classes=MyComponent3',
            'test/io/test_files/cssUrls/main.dart',
            'generated']);
      } catch(_) {
        tmpDir.deleteSync(recursive: true);
        rethrow;
      }
      return flush.then((_) {
        expect(new File('${tmpDir.path}/generated.dart').readAsStringSync(),
            '// GENERATED, DO NOT EDIT!\n'
            'library generated;\n'
            '\n'
            'import \'package:angular/angular.dart\';\n'
            '\n'
            'primeTemplateCache(TemplateCache tc) {\n'
            'tc.put("rewritten/cssUrls/one.css", new HttpResponse(200, r"""body {}"""));\n'
            'tc.put("rewritten/cssUrls/three.css", new HttpResponse(200, r"""body {}"""));\n'
            'tc.put("rewritten/cssUrls/two.css", new HttpResponse(200, r"""body {}"""));\n'
            '}');
      }).whenComplete(() {
        tmpDir.deleteSync(recursive: true);
      });
    });


  });
}
