part of angular.core.dom_internal;

class DirectiveTypeTuple {
  final Directive directive;
  final Type type;
  DirectiveTypeTuple(this.directive, this.type);
  String toString() => '@$directive#$type';
}

@Injectable()
class DirectiveMap {
  final Map<String, List<DirectiveTypeTuple>> map = new HashMap<String, List<DirectiveTypeTuple>>();
  final DirectiveSelectorFactory _directiveSelectorFactory;
  FormatterMap _formatters;
  DirectiveSelector _selector;
  Injector _injector;

  DirectiveMap(Injector this._injector,
               this._formatters,
               MetadataExtractor metadataExtractor,
               this._directiveSelectorFactory) {
    (_injector as ModuleInjector).types.forEach((type) {
      metadataExtractor(type)
          .where((annotation) => annotation is Directive)
          .forEach((Directive dir) {
            map.putIfAbsent(dir.selector, () => []).add(new DirectiveTypeTuple(dir, type));
          });
    });
  }

  DirectiveSelector get selector {
    if (_selector != null) return _selector;
    return _selector = _directiveSelectorFactory.selector(this, _injector, _formatters);
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
