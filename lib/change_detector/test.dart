import 'package:angular/core/module_internal.dart';
import 'package:angular/core/parser/dynamic_closure_map.dart';
import 'package:angular/core/parser/dynamic_parser.dart';
import 'package:angular/core/registry_dynamic.dart';

import 'package:angular/change_detector/ast_parser.dart';
import 'package:angular/change_detector/change_detector.dart';
import 'package:angular/change_detector/field_getter_factory_dynamic.dart';

import 'package:angular/core/parser/parser.dart';

import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:angular/cache/module.dart';

class MyModule extends Module {
  MyModule() {
    install(new CoreModule());
    bind(MetadataExtractor, toImplementation: DynamicMetadataExtractor);
    bind(FieldGetterFactory, toImplementation: DynamicFieldGetterFactory);
    bind(CacheRegister);
    bind(ClosureMap, toValue: new DynamicClosureMap());
  }
}

Function rfnLog(msg) => (v, p) => print('$msg: $p -> $v');


main() {
  Injector inj = new DynamicInjector(modules: [new CoreModule(), new MyModule()]);

  var parser = inj.get(Parser);

  ASTParser parse = new ASTParser(parser, null);

  ChangeDetector detector = new ChangeDetector(inj.get(FieldGetterFactory));

  var context = {
      'a': {'b' : {'c': 0}},
      'c': [1],
      'd': 0,
      's1': 5,
      's2': 10,
      'list': [1, 2, 3],
      'map': {'a': 'a'},
      'add': (a, b) => a+b
  };

  var g0 = detector.createWatchGroup(context);

  var ws1;

  ws1 = g0.watch(parse('s1'), (v, p) {
    print('s1 $p->$v');
    ws1.remove();
  });

  g0.watch(parse('s2'), (v, p) => print('s2 $p->$v'));

  g0.processChanges();




}
