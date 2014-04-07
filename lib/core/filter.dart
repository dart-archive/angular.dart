part of angular.core_internal;


/**
 * Registry of filters at runtime.
 */
@NgInjectableService()
class FilterMap extends AnnotationMap<NgFilter> {
  Injector _injector;
  FilterMap(Injector injector, MetadataExtractor extractMetadata)
      : this._injector = injector,
        super(injector, extractMetadata);

  call(String name) {
    var filter = new NgFilter(name: name);
    var filterType = this[filter];
    return _injector.get(filterType);
  }
}

