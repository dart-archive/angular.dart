library field_getter_factory.static;

import 'change_detector.dart' show
    FieldGetter,
    FieldGetterFactory;

class StaticFieldGetterFactory implements FieldGetterFactory {
  Map<String, FieldGetter> getters;

  StaticFieldGetterFactory(this.getters);

  FieldGetter getter(Object object, String name) {
    var getter = getters[name];
    if (getter == null) throw "Missing getter: (o) => o.$name";
    return getter;
  }
}
