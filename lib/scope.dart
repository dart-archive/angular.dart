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
      var parsed = Parser.parse(expr);
      watches.add(() => reactionFn(parsed(this.properties, null)));
    } else if (expr is DirectiveValue) {
      $watch(expr.value, reactionFn);
    } else {
      watches.add(() => expr(this));
    }
  }

  $digest() {
    watches.forEach((fn) => fn());
  }

  noSuchMethod(Invocation invocation) {
    var name = MirrorSystem.getName(invocation.memberName);
    if (invocation.isGetter) {
      return properties[name];
    } else if (invocation.isSetter) {
      var value = invocation.positionalArguments[0];
      name = name.substring(0, name.length - 1);
      properties[name] = value;
      return value;
    } else {
      throw new ArgumentError('only getters/setters supported');
    }
  }

}
