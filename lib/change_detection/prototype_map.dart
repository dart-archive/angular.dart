part of angular.watch_group;

// todo(vicb) rename to ContextLocals + rename the file
class LocalContext {
  // todo(vicb) _parentContext
  final Object parent;
  final Map _locals = <String, Object>{};

  LocalContext(this.parent, [Map<String, Object> locals = null]) {
    if (locals != null) _locals.addAll(locals);
    _locals[r'$parent'] = parent;
  }

  static LocalContext wrapper(context, Map<String, Object> locals) =>
      new LocalContext(context, locals);

  bool hasProperty(String prop) => _locals.containsKey(prop);

  void operator[]=(String prop, value) {
    _locals[prop] = value;
  }

  dynamic operator[](String prop) {
    assert(hasProperty(prop));
    return _locals[prop];
  }
}
