part of angular.core.dom;

@NgInjectableService()
class DirectiveMap extends AnnotationsMap<NgAnnotation> {
  DirectiveSelectorFactory _directiveSelectorFactory;
  DirectiveSelector _selector;
  DirectiveSelector get selector {
    if (_selector != null) return _selector;
    return _selector = _directiveSelectorFactory.selector(this);
  }

  DirectiveMap(Injector injector,
               MetadataExtractor metadataExtractor,
               this._directiveSelectorFactory)
      : super(injector, metadataExtractor);
}
