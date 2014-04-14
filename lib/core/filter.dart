part of angular.core_internal;


/**
 * Registry of formatters at runtime.
 */
@Injectable()
class FormatterMap extends AnnotationMap<Formatter> {
  Injector _injector;
  FormatterMap(Injector injector, MetadataExtractor extractMetadata)
      : this._injector = injector,
        super(injector, extractMetadata);

  call(String name) {
    var filter = new Formatter(name: name);
    var filterType = this[filter];
    return _injector.get(filterType);
  }
}

