part of angular.core.dom_internal;

@Injectable()
class DirectiveMap extends AnnotationsMap<Directive> {
  DirectiveSelectorFactory _directiveSelectorFactory;
  FormatterMap _formatters;
  DirectiveSelector _selector;
  DirectiveSelector get selector {
    if (_selector != null) return _selector;
    return _selector = _directiveSelectorFactory.selector(this, _formatters);
  }

  DirectiveMap(Injector injector,
               this._formatters,
               MetadataExtractor metadataExtractor,
               this._directiveSelectorFactory)
      : super(injector, metadataExtractor);
}
