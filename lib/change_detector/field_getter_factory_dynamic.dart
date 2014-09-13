library field_getter_factory.dynamic;

import 'change_detector.dart' show
    FieldGetter,
    FieldGetterFactory;

/**
 * We are using mirrors, but there is no need to import anything.
 */
@MirrorsUsed(targets: const [DynamicFieldGetterFactory], metaTargets: const [] )
import 'dart:mirrors';

class DynamicFieldGetterFactory implements FieldGetterFactory {
  FieldGetter getter(Object object, String name) {
    Symbol symbol = new Symbol(name);
    InstanceMirror instanceMirror = reflect(object);
    return (Object object) => instanceMirror.getField(symbol).reflectee;
  }
}
