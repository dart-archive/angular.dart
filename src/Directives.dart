part of angular;

typedef Directive DirectiveFactory(dom.Element element, String value);

class Directives {
  Map<String, DirectiveFactory> _directives = new Map();

  Directives() {}

  register(String name, DirectiveFactory directiveType) {
    _directives[name] = directiveType;
  }

  DirectiveFactory operator [](String selector) {
    return _directives[selector];
  }

  List<String> enumerate() => new List.from(_directives.keys);

}
