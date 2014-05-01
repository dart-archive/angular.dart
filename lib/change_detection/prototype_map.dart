part of angular.watch_group;

// todo(vicb) rename the file
class ContextLocals {
  // todo(vicb) _parentContext
  final Object parent;
  Object _rootContext;
  final Map _locals = <String, Object>{};

  ContextLocals(this.parent, [Map<String, Object> locals = null]) {
    assert(parent != null);
    if (locals != null) _locals.addAll(locals);
    _locals[r'$parent'] = parent;
  }

  static ContextLocals wrapper(context, Map<String, Object> locals) =>
      new ContextLocals(context, locals);

  dynamic get rootContext {
    if (_rootContext == null) {
      _rootContext = parent is ContextLocals ?
          (parent as ContextLocals).rootContext :
          parent;
    }
    return _rootContext;
  }

  bool hasProperty(String prop) {
    return _locals.containsKey(prop) ||
           parent is ContextLocals && (parent as ContextLocals).hasProperty(prop);
  }

  void operator[]=(String prop, value) {
    _locals[prop] = value;
  }

  dynamic operator[](String prop) {
    assert(hasProperty(prop));
    var context = this;

    while (!context._locals.containsKey(prop)) {
      // todo(vicb) cache context where prop is defined
      context = context.parent;
    }
    return context._locals[prop];
  }
}
