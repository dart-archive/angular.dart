part of angular.core.dom_internal;

@Injectable()
class DirectiveMap extends AnnotationsMap<Directive> {
  final DirectiveSelectorFactory _directiveSelectorFactory;
  DirectiveSelector _selector;
  DirectiveSelector get selector {
    if (_selector == null) {
      _selector = _directiveSelectorFactory.selector(this);
    }
    return _selector;
  }

  DirectiveMap(Injector injector,
               MetadataExtractor metadataExtractor,
               this._directiveSelectorFactory)
      : super(injector, metadataExtractor);
}
