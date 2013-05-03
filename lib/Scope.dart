part of angular;

class Scope {
  Map<String, Object> properties = {};
  List watches = [];

  Scope();

  $apply() {
    $digest();
  }

  operator []=(String name, value) => properties[name] = value;
  operator [](String name) => properties[name];

  $watch(expr, [reactionFn]) {
    if (expr is String) {
      dump('\$watch ' + expr);
      watches.add(() => reactionFn(this[expr]));
    } else {
      watches.add(() => expr(this));
    }
  }

  $digest() {
    watches.forEach((fn) => fn());
  }


}
