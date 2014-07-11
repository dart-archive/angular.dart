library angular.core_internal.formatter_map;

import 'dart:collection';
import 'package:di/di.dart';
import 'package:di/annotations.dart';
import 'package:angular/core/annotation_src.dart';
import 'package:angular/core/registry.dart';

/**
 * Registry of formatters at runtime.
 */
@Injectable()
class FormatterMap {
  final Map<String, Type> _map = new HashMap<String, Type>();
  final Injector _injector;

  FormatterMap(this._injector, MetadataExtractor extractMetadata) {
    (_injector as ModuleInjector).types.forEach((type) {
      extractMetadata(type)
      .where((annotation) => annotation is Formatter)
      .forEach((Formatter formatter) {
        _map[formatter.name] = type;
      });
    });
  }

  call(String name) => _injector.get(this[name]);

  Type operator[](String name) {
    Type formatterType = _map[name];
    if (formatterType == null) throw "No formatter '$name' found!";
    return formatterType;
  }

  void forEach(fn(K, Type)) {
    _map.forEach(fn);
  }
}

