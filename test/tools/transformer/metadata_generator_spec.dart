library angular.test.tools.transformer.metadata_generator_spec;

import 'dart:async';

import 'package:angular/tools/transformer/options.dart';
import 'package:angular/tools/transformer/metadata_generator.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart' as tests;

import 'package:unittest/unittest.dart' hide expect;
import 'package:guinness/guinness.dart';

main() {
  describe('MetadataGenerator', () {
    var options = new TransformOptions(sdkDirectory: dartSdkDirectory);

    var resolvers = new Resolvers(dartSdkDirectory);

    var phases = [
      [new MetadataGenerator(options, resolvers)]
    ];

    it('should extract member metadata', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Decorator(selector: r'[*=/{{.*}}/]')
                class Engine {
                  @NgOneWay('another-expression')
                  String anotherExpression;

                  @NgCallback('callback')
                  set callback(Function) {}

                  set twoWayStuff(String abc) {}
                  @NgTwoWay('two-way-stuff')
                  String get twoWayStuff => null;
                }
                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.Decorator(selector: r\'[*=/{{.*}}/]\', '
                'map: const {'
                '\'another-expression\': \'=>anotherExpression\', '
                '\'callback\': \'&callback\', '
                '\'two-way-stuff\': \'<=>twoWayStuff\''
                '})',
            ]
          });
    });

    it('should extract member metadata from superclass', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                class Engine {
                  @NgOneWay('another-expression')
                  String anotherExpression;

                  @NgCallback('callback')
                  set callback(Function) {}

                  set twoWayStuff(String abc) {}
                  @NgTwoWay('two-way-stuff')
                  String get twoWayStuff => null;
                }

                @Decorator(selector: r'[*=/{{.*}}/]')
                class InternalCombustionEngine extends Engine {
                  @NgOneWay('ice-expression')
                  String iceExpression;
                }
                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.InternalCombustionEngine': [
              'const import_1.Decorator(selector: r\'[*=/{{.*}}/]\', '
                'map: const {'
                '\'ice-expression\': \'=>iceExpression\', '
                '\'another-expression\': \'=>anotherExpression\', '
                '\'callback\': \'&callback\', '
                '\'two-way-stuff\': \'<=>twoWayStuff\''
                '})',
            ]
          });
    });

    it('should warn on multiple annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @DummyAnnotation("parse attribute annotations")
                class Engine {
                  @NgCallback('callback')
                  @NgOneWay('another-expression')
                  set callback(Function) {}
                }
                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
              'import_0.Engine': [
                  'const import_1.DummyAnnotation("parse attribute annotations")',
              ]
          },
          messages: ['warning: callback can only have one annotation. '
              '(web/main.dart 4 18)']);
    });

    it('should warn on duplicated annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Decorator(map: {'another-expression': '=>anotherExpression'})
                class Engine {
                  @NgOneWay('another-expression')
                  set anotherExpression(Function) {}
                }
                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.Decorator(map: const {'
                '\'another-expression\': \'=>anotherExpression\'})',
            ]
          },
          messages: ['warning: Directive @NgOneWay(\'another-expression\') '
              'already contains an entry for \'another-expression\' '
              '(web/main.dart 2 16)'
          ]);
    });

    it('should merge member annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Directive(
                    selector: 'first',
                    map: {'first-expression': '=>anotherExpression'})
                @Directive(
                    selector: 'second',
                    map: {'second-expression': '=>anotherExpression'})
                class Engine {
                  set anotherExpression(Function) {}

                  set twoWayStuff(String abc) {}
                  @NgTwoWay('two-way-stuff')
                  String get twoWayStuff => null;
                }
                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.Directive(selector: \'first\', '
                'map: const {'
                '\'first-expression\': \'=>anotherExpression\', '
                '\'two-way-stuff\': \'<=>twoWayStuff\'})',
              'const import_1.Directive(selector: \'second\', '
                'map: const {'
                '\'second-expression\': \'=>anotherExpression\', '
                '\'two-way-stuff\': \'<=>twoWayStuff\'})',
            ]
          });
    });

    it('should warn on multiple annotations (across getter/setter)', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @DummyAnnotation("parse attribute annotations")
                class Engine {
                  @NgCallback('callback')
                  set callback(Function) {}

                  @NgOneWay('another-expression')
                  get callback => null;
                }
                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
              'import_0.Engine': [
                  'const import_1.DummyAnnotation("parse attribute annotations")',
              ]
          },
          messages: ['warning: callback can only have one annotation. '
              '(web/main.dart 4 18)']);
    });

    it('should extract map arguments', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Decorator(map: const {'ng-value': '&ngValue', 'key': 'value'})
                class Engine {}

                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.Decorator(map: const {\'ng-value\': '
              '\'&ngValue\', \'key\': \'value\'})',
            ]
          });
    });

    it('should extract list arguments', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Decorator(exportExpressions: ['one', 'two'])
                class Engine {}

                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              "const import_1.Decorator(exportExpressions: "
                  "const ['one','two',])",
            ]
          });
    });

    it('should extract primitive literals', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @DummyAnnotation(true)
                @DummyAnnotation(1.0)
                @DummyAnnotation(1)
                @DummyAnnotation(null)
                class Engine {}

                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.DummyAnnotation(true)',
              'const import_1.DummyAnnotation(1.0)',
              'const import_1.DummyAnnotation(1)',
              'const import_1.DummyAnnotation(null)',
            ]
          });
    });

    it('should extract formatter', () {
      return generates(phases,
      inputs: {
          'angular|lib/angular.dart': libAngular,
          'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Formatter()
                class Engine {}

                main() {}
                '''
      },
      imports: [
          'import \'main.dart\' as import_0;',
          'import \'package:angular/angular.dart\' as import_1;',
      ],
      classes: {
          'import_0.Engine': [
              'const import_1.Formatter()',
          ]
      });
    });

    it('should skip and warn on unserializable annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Decorator(module: MissingType.module)
                class Car {
                }

                main() {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Car': [
              'null',
            ]
          },
          messages: [
            // 'warning: Unable to serialize annotation @NgFoo. '
            //     '(web/main.dart 2 16)',
            'warning: Unable to serialize annotation '
                '@Decorator(module: MissingType.module). '
                '(web/main.dart 2 16)',
          ]);
    });

    it('should extract types across libs', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';
                import 'package:a/b.dart';

                @Decorator(module: Car.module)
                class Engine {
                }

                main() {}
                ''',
            'a|lib/b.dart': '''
                class Car {
                  static module() => null;
                }
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
            'import \'package:a/b.dart\' as import_2;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.Decorator(module: import_2.Car.module)',
            ]
          });
    });

    it('should not gather non-member annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                class Engine {
                  Engine() {
                    @Decorator()
                    print('something');
                  }
                }
                main() {}
                ''',
          });
    });

    it('properly escapes strings', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': r'''
                import 'package:angular/angular.dart';

                @DummyAnnotation('foo\' \\')
                class Engine {
                }

                main() {}
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              r'''const import_1.DummyAnnotation('foo\' \\')''',
            ]
          });
    });

    it('maintains string formatting', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': r'''
                import 'package:angular/angular.dart';

                @DummyAnnotation(r"""multiline
                string""")
                class Engine {
                }

                main() {}
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              r'''const import_1.DummyAnnotation(r"""multiline
                string""")''',
            ]
          });
    });

    it('should reference static and global properties', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Decorator(visibility: Directive.CHILDREN_VISIBILITY)
                @Decorator(visibility: CONST_VALUE)
                class Engine {}

                const int CONST_VALUE = 2;

                main() {}
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.Decorator(visibility: '
                  'import_1.Directive.CHILDREN_VISIBILITY)',
              'const import_1.Decorator(visibility: import_0.CONST_VALUE)',
            ]
          });
    });

    it('should reference static methods', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Decorator(module: Engine.module)
                class Engine {
                  static module() => null;
                }

                main() {}
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.Decorator(module: import_0.Engine.module)'
            ]
          });
    });

    it('should not extract private annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @_Foo()
                @_foo
                class Engine {
                }

                class _Foo {
                  const _Foo();
                }
                const _Foo _foo = const _Foo();

                main() {}
                ''',
          },
          messages: [
            'warning: Annotation @_Foo() is not public. (web/main.dart 2 16)',
            'warning: Annotation @_foo is not public. (web/main.dart 2 16)',
          ]);
    });

    it('supports named constructors', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @NgFoo.bar()
                @NgFoo._private()
                class Engine {
                }

                class NgFoo extends Directive {
                  const NgFoo.bar();
                  const NgFoo._private();
                }

                main() {}
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
          ],
          classes: {
            'import_0.Engine': [
              '''const import_0.NgFoo.bar()''',
            ]
          },
          messages: [
            'warning: Annotation @NgFoo._private() is not public. '
                '(web/main.dart 2 16)',
          ]);
    });

    it('skips non-Ng* annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @proxy
                @Foo()
                class Engine {}

                class Foo {}

                main() {}
                ''',
          },
          imports: [],
          classes: {});
    });

    it('does not modify annotations in-place', () {
      var main = '''
          import 'package:angular/angular.dart';
          import 'second.dart';

          @Decorator(map: {})
          class Engine {
            @NgTwoWay('two-way-stuff')
            String get twoWayStuff => null;
          }
          main() {}
          ''';
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': main,
            'a|web/second.dart': '''library second;'''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.Decorator(map: const {'
                '\'two-way-stuff\': \'<=>twoWayStuff\'})',
            ]
          }).then((_) => generates(phases,
              inputs: {
                'angular|lib/angular.dart': libAngular,
                'a|web/main.dart': main,
                'a|web/second.dart': '''library a.second;'''
              },
              imports: [
                'import \'main.dart\' as import_0;',
                'import \'package:angular/angular.dart\' as import_1;',
              ],
              classes: {
                'import_0.Engine': [
                  'const import_1.Decorator(map: const {'
                    '\'two-way-stuff\': \'<=>twoWayStuff\'})',
                ]
              }));
    });
  });
}

Future generates(List<List<Transformer>> phases,
    {Map<String, String> inputs, Iterable<String> imports: const [],
    Map classes: const {},
    Iterable<String> messages: const []}) {

  var buffer = new StringBuffer();
  buffer.write('$header\n');
  for (var i in imports) {
    buffer.write('$i\n');
  }
  buffer.write('$boilerPlate\n');
  for (var className in classes.keys) {
    buffer.write('  $className: const [\n');
    for (var annotation in classes[className]) {
      buffer.write('    $annotation,\n');
    }
    buffer.write('  ],\n');
  }

  buffer.write('$footer\n');

  return tests.applyTransformers(phases,
      inputs: inputs,
      results: {
        'a|web/main_static_metadata.dart': buffer.toString()
      },
      messages: messages);
}

const String header = '''
library a.web.main.generated_metadata;

import 'package:angular/core/registry.dart' show MetadataExtractor;
import 'package:di/di.dart' show Module;
''';

const String boilerPlate = '''
Module get metadataModule => new Module()
    ..bind(MetadataExtractor, toValue: new _StaticMetadataExtractor());

class _StaticMetadataExtractor implements MetadataExtractor {
  Iterable call(Type type) {
    var annotations = typeAnnotations[type];
    if (annotations != null) {
      return annotations;
    }
    return [];
  }
}

final Map<Type, Object> typeAnnotations = {''';

const String footer = '''
};''';


const String libAngular = '''
library angular.core.annotation_src;

class Formatter {};

class Directive {
  Directive({map: const {}});
  static const int CHILDREN_VISIBILITY = 1;
}

class Decorator extends Directive {
  const Decorator({selector, module, map, visibility, exportExpressions}) :
      super(map: map);
}

class DummyAnnotation extends Directive {
  const DummyAnnotation(object);
}

class NgOneWay {
  const NgOneWay(arg);
}

class NgTwoWay {
  const NgTwoWay(arg);
}

class NgCallback {
  const NgCallback(arg);
}

class NgAttr {
  const NgAttr(arg);
}

class NgOneWayOneTime {
  const NgOneWayOneTime(arg);
}
''';
