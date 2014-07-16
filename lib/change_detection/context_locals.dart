part of angular.watch_group;

class ContextLocals {
  final Map _locals = <String, Object>{};

  final Object _parentContext;
  Object get parentContext => _parentContext;

  ContextLocals(this._parentContext, [Map<String, Object> locals = null]) {
    assert(_parentContext != null);
    if (locals != null) _locals.addAll(locals);
  }

  static ContextLocals wrapper(context, Map<String, Object> locals) =>
      new ContextLocals(context, locals);

  bool hasProperty(String prop) => _locals.containsKey(prop);

  void operator[]=(String prop, value) {
    _locals[prop] = value;
  }

  dynamic operator[](String prop) => _locals[prop];
}
