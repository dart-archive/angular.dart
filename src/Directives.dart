part of angular;


class Directives {
  Map<String, Type> _directives = new Map();

  Directives() {}

  register(String name, Type directiveType) {
    _directives[name] = directiveType;
  }

  operator [](String selector) {
    return _directives[selector];
  }

}
