library registry_spec;

import '../_specs.dart';
import 'package:angular/application_factory.dart';

main() {
  describe('RegistryMap', () {
    it('should allow for multiple registry keys to be added', () {
      var module = new Module()
          ..bind(MyMap)
          ..bind(A1)
          ..bind(A2);

      var injector = applicationFactory().addModule(module).createInjector();
      expect(() {
        injector.get(MyMap);
      }).not.toThrow();
    });

    it('should iterate over all types', () {
      var module = new Module()
          ..bind(MyMap)
          ..bind(A1);

      var injector = applicationFactory().addModule(module).createInjector();
      var keys = [];
      var types = [];
      var map = injector.get(MyMap);
      map.forEach((k, t) { keys.add(k); types.add(t); });
      expect(keys).toEqual([new MyAnnotation('A'), new MyAnnotation('B')]);
      expect(types).toEqual([A1, A1]);
    });

    it('should safely ignore typedefs', () {
      var module = new Module()
          ..bind(MyMap)
          ..bind(MyTypedef, toValue: (String _) => null);

      var injector = applicationFactory().addModule(module).createInjector();
      expect(() => injector.get(MyMap), isNot(throws));
    });
  });
}

typedef void MyTypedef(String arg);

class MyMap extends AnnotationMap<MyAnnotation> {
  MyMap(Injector injector, MetadataExtractor metadataExtractor)
      : super(injector, metadataExtractor);
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
