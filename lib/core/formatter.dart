part of angular.core_internal;


/**
 * Registry of formatters at runtime.
 */
@Injectable()
class FormatterMap extends AnnotationMap<Formatter> {
  Injector _injector;
  FormatterMap(Injector injector, MetadataExtractor extractMetadata)
      : _injector = injector,
        super(injector, extractMetadata);

  Function call(String name) {
    var formatter = new Formatter(name: name);
    var formatterType = this[formatter];
    return _injector.get(formatterType);
  }
}

