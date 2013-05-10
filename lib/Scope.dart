part of angular;

RegExp _symbolRegexp = new RegExp(r'^Symbol\(\"([^=\"]*)\=?\"\)$');

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

  noSuchMethod(Invocation invocation) {
    var methodName = invocation.memberName.toString();
    var name = _symbolRegexp.firstMatch(methodName).group(1);
    if (invocation.isGetter) {
      return properties[name];
    } else if (invocation.isSetter) {
      var value = invocation.positionalArguments[0];
      properties[name] = value;
      return value;
    } else {
      throw new ArgumentError('only getters/setters supported');
    }
  }

}
