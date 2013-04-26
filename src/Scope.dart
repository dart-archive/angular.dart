part of angular;

class Scope {
  Map<String, Object> properties = {};
  List watches = [];

  Scope();

  $apply() {
    watches.forEach((fn) => fn());
  }

  operator []=(String name, value) => properties[name] = value;
  operator [](String name) => properties[name];

  $watch(expr, [reactionFn]) {
    watches.add(() => reactionFn(this[expr]));
  }


}
