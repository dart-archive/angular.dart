library registry_spec;

import '_specs.dart';
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';

main() => describe('RegistryMap', () {
  it('should throw error on identical keys', () {
    var module = new Module()
        ..type(MyMap)
        ..type(A1)
        ..type(A2);

    var injector = new DynamicInjector(modules: [module]);
    expect(() {
      injector.get(MyMap);
    }).toThrow("Duplicate annotation found: MyAnnotation: A. Exisitng:");
  });

  it('should iterate over all types', () {
    var module = new Module()
      ..type(MyMap)
      ..type(A1);

    var injector = new DynamicInjector(modules: [module]);
    var keys = [];
    var types = [];
    var map = injector.get(MyMap);
    map.forEach((k, t) { keys.add(k); types.add(t); });
    expect(keys).toEqual([new MyAnnotation('A'), new MyAnnotation('B')]);
    expect(types).toEqual([A1, A1]);
  });
});

class MyMap extends AnnotationMap<MyAnnotation> {
  MyMap(Injector injector) : super(injector);
}


class MyAnnotation {
  final String name;

  const MyAnnotation(String this.name);

  toString() => name;
  get hashCode => name.hashCode;
  operator==(other) => this.name == other.name;
}

@MyAnnotation('A') @MyAnnotation('B') class A1 {}
@MyAnnotation('A') class A2 {}
