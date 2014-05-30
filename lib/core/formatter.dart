library angular.core_internal.formatter_map;

import 'package:di/di.dart';
import 'package:angular/core/annotation_src.dart';
import 'package:angular/core/registry.dart';

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
    var formatter = new Formatter(name: name);
    var formatterType = this[formatter];
    return _injector.get(formatterType);
  }
}

