library angular.test.tools.transformer.template_cache_generator;

import 'dart:async';

import 'package:angular/tools/transformer/template_cache_generator.dart';
import 'package:angular/tools/transformer/options.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart' as tests;

import 'package:guinness/guinness.dart';

main() {
  describe('TemplateCacheGenerator', () {
    var htmlContent1 = "<div></div>";
    var htmlContent2 = "<span></span>";

    it('should cache templateURL', () {
      return generates(setupPhases(),
          inputs: {
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';
                import 'dir/foo.dart';

                @Component(templateUrl: "test1.html")
                class A {}

                main() {}
            ''',
            'a|web/dir/foo.dart': '''
                import 'package:angular/angular.dart';

                @Component(templateUrl: "test2.html")
                class B {}
            ''',
            'a|test1.html': htmlContent1,
            'a|test2.html': htmlContent2,
            'angular|lib/angular.dart': libAngular,
          },
          cacheContent: {
            'test1.html': htmlContent1,
            'test2.html': htmlContent2,
          });
    });

    it('should cache cssURLs', () {
      var cssContent1 = '#id {color: red}';
      var cssContent2 = '#id2 {color: blue}';
      return generates(setupPhases(),
      inputs: {
          'a|web/main.dart': '''
                import 'package:angular/angular.dart';
                import 'dir/foo.dart';

                @Component(cssUrl: "test1.css")
                class A {}

                main() {}
                ''',
          'a|web/dir/foo.dart': '''
                import 'package:angular/angular.dart';

                @Component(cssUrl: ["test2.css"])
                class B {}
            ''',
          'a|test1.css': cssContent1,
          'a|test2.css': cssContent2,
          'angular|lib/angular.dart': libAngular,
      },
      cacheContent: {
          'test1.css': cssContent1,
          'test2.css': cssContent2,
      });
    });

    it('should handle multiline content', () {
      var multiLineContent1 = """'''<div>
        </div>
      '''""";
      var multiLineContent2 = '''"""
        #id {
          color: red;
        }
      """''';
      return generates(setupPhases(),
          inputs: {
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Component(
                    templateUrl: "multiline1.html", cssUrl: "multiline2.css")
                class A {}

                 main() {}
                 ''',
            'a|multiline1.html': multiLineContent1,
            'a|multiline2.css': multiLineContent2,
            'angular|lib/angular.dart': libAngular,
          },
          cacheContent: {
            'multiline1.html': multiLineContent1,
            'multiline2.css': multiLineContent2,
          });
    });

    it('should cache annotation', () {
      return generates(setupPhases(),
          inputs: {
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';
                import 'package:angular/angular_cache.dart';
                import 'dir/foo.dart';

                @NgTemplateCache(preCacheUrls: ["test1.html"])
                class A {}

                main() {}
            ''',
            'a|web/dir/foo.dart': '''
                import 'package:angular/angular.dart';
                import 'package:angular/angular_cache.dart';

                @NgTemplateCache(preCacheUrls: ["test2.html"])
                class B {}
            ''',
            'a|test1.html': htmlContent1,
            'a|test2.html': htmlContent2,
            'angular|lib/angular.dart': libAngular,
            'angular|lib/angular_cache.dart': libCacheAnnotation,
          },
          cacheContent: {
            'test1.html': htmlContent1,
            'test2.html': htmlContent2,
          });
    });

    it('should handle no cached values', () {
      return generates(setupPhases(),
          inputs: {
              'a|web/main.dart': '''
                    import 'package:angular/angular.dart';
                    import 'package:angular/template_cache.dart';

                    main() {}
                    ''',
              'angular|lib/angular.dart': libAngular,
              'angular|lib/template_cache.dart': libCacheAnnotation,
          });
    });

    it('should warn on no angular imports', () {
      return generates(setupPhases(),
          inputs: {
              'a|web/main.dart': '''
                    main() {}
                    ''',
              'angular|lib/angular.dart': libAngular,
          },
          messages: [
              'warning: Unable to resolve '
              'angular.core.annotation_src.Component.'
          ]);
      });

    it('should not generate template cache', () {
      return generates(setupPhases(generateTemplateCache: false),
          cacheGenerated: false,
          inputs: {
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';
                import 'dir/foo.dart';

                @Component(templateUrl: "test1.html", cssUrl: "test1.css")
                class A {}

                main() {}
            ''',
            'a|web/dir/foo.dart': '''
                import 'package:angular/angular.dart';

                @NgTemplateCache(preCacheUrls: ["test2.html"])
                class B {}
            ''',
          'angular|lib/angular.dart': libAngular,
          'angular|lib/template_cache.dart': libCacheAnnotation,
      });
    });
  });
}

Future generates(List<List<Transformer>> phases,
                 { Map<String, String> inputs,
                 Map<String, String> cacheContent: const {},
                 Iterable<String> messages: const [],
                 bool cacheGenerated: true}) {

  var buffer = new StringBuffer();
  buffer.write(header);
  cacheContent.forEach((uri, contents) {
    contents = contents.replaceAll("'''", r"\'\'\'");
    buffer.write("  r'$uri' : r'''$contents''',\n");
  });
  buffer.write('};\n');
  var results = !cacheGenerated ? {} :
      {'a|web/main_generated_template_cache.dart': buffer.toString()};

  return tests.applyTransformers(phases,
    inputs: inputs,
    results: results,
    messages: messages);
}

const String header = '''
library a.web.main.generated_template_cache;

import 'package:angular/angular.dart';
import 'package:di/di.dart' show Module;

Module get templateCacheModule =>
    new Module()..bind(TemplateCache, toFactory: () {
      var templateCache = new TemplateCache();
      _cache.forEach((key, value) {
        templateCache.put(key, new HttpResponse(200, value));
      });
      return templateCache;
    });

const Map<String, String> _cache = const <String, String> {
''';

const String libAngular = '''
library angular.core.annotation_src;

class Component {
  const Component({String templateUrl, Object cssUrl});
}
''';

const String libCacheAnnotation = '''
library angular.template_cache_annotation;

class NgTemplateCache {
  const NgTemplateCache({List preCacheUrls});
}
''';

List<List> setupPhases({generateTemplateCache: true}) {
  var options = new TransformOptions(
      sdkDirectory: dartSdkDirectory,
      generateTemplateCache: generateTemplateCache);
  var resolvers = new Resolvers(dartSdkDirectory);

  return [
      [new TemplateCacheGenerator(options, resolvers)]
  ];
}
