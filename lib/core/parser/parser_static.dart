library angular.core.parser_static;

import 'package:angular/core/parser/parser.dart';


class DynamicClosureMap implements ClosureMap {
  Getter lookupGetter(String name) {
  }

  Setter lookupSetter(String name) {
  }

  MethodClosure lookupFunction(String name, CallArguments arguments) {
  }
}

/**
 * The [AccessFast] mixin is used to share code between access expressions
 * where we have a pair of pre-compiled getter and setter functions that we
 * use to do the access the field.
 */
abstract class AccessFast {
  String get name;
  Getter get getter;
  Setter get setter;

  _eval(holder) {
    if (holder == null) return null;
    return (holder is Map) ? holder[name] : getter(holder);
  }

  _assign(scope, holder, value) {
    if (holder == null) {
      _assignToNonExisting(scope, value);
      return value;
    } else {
      return (holder is Map) ? (holder[name] = value) : setter(holder, value);
    }
  }

  // By default we don't do any assignments to non-existing holders. This
  // is overwritten for access to members.
  _assignToNonExisting(scope, value) => null;
}
