part of angular.core.dom_internal;

class DirectiveTypeTuple {
  final Directive directive;
  final Type type;
  DirectiveTypeTuple(this.directive, this.type);
  toString() => '@$directive#$type';
}

@Injectable()
class DirectiveMap {
  final Map<String, List<DirectiveTypeTuple>> map = new HashMap<String, List<DirectiveTypeTuple>>();
  DirectiveSelectorFactory _directiveSelectorFactory;
  FormatterMap _formatters;
  DirectiveSelector _selector;

  DirectiveMap(Injector injector,
               this._formatters,
               MetadataExtractor metadataExtractor,
               this._directiveSelectorFactory) {
    (injector as ModuleInjector).types.forEach((type) {
      metadataExtractor(type)
      .where((annotation) => annotation is Directive)
      .forEach((Directive directive) {
        map.putIfAbsent(directive.selector, () => []).add(new DirectiveTypeTuple(directive, type));
      });
    });
  }

  DirectiveSelector get selector {
    if (_selector != null) return _selector;
    return _selector = _directiveSelectorFactory.selector(this, _formatters);
  }

  List<DirectiveTypeTuple> operator[](String key) {
    var value = map[key];
    if (value == null) throw 'No Directive selector $key found!';
    return value;
  }

  void forEach(fn(K, Type)) {
    map.forEach((_, types) {
      types.forEach((tuple) {
        fn(tuple.directive, tuple.type);
      });
    });
  }
}
