library dirty_checking_change_detector_dynamic;

import 'package:angular/change_detection/change_detection.dart';

/**
 * We are using mirrors, but there is no need to import anything.
 */
@MirrorsUsed(targets: const [], metaTargets: const [])
import 'dart:mirrors';

class DynamicFieldGetterFactory implements FieldGetterFactory {
  final isMethodInvoke = true;

  bool isMethod(Object object, String name) {
    try {
      return method(object, name) != null;
    } catch (e, s) {
      print('isMethod($object, $name) => false\n$s');
      return false;
    }
  }

  Function method(Object object, String name) {
    Symbol symbol = new Symbol(name);
    InstanceMirror instanceMirror = reflect(object);
    return (List args, Map namedArgs) {
      return instanceMirror.invoke(symbol, args, namedArgs).reflectee;
    };
  }

  FieldGetter getter(Object object, String name) {
    Symbol symbol = new Symbol(name);
    InstanceMirror instanceMirror = reflect(object);
    return (Object object) {
      return instanceMirror.getField(symbol).reflectee;
    };
  }
}
