part of angular.core_internal;

/**
 * Registry of filters at runtime.
 */
@NgInjectableService()
class FilterMap extends AnnotationMap<NgFilter> {
  final Injector _injector;

  FilterMap(Injector injector, MetadataExtractor extractMetadata)
      : this._injector = injector,
        super(injector, extractMetadata);

  Function call(String name) {
    var filter = new NgFilter(name: name);
    var filterType = this[filter];
    return _injector.get(filterType);
  }
}

