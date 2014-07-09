library angular.core.registry;

import 'package:di/di.dart' show Injector, ModuleInjector;

abstract class MetadataExtractor {
  Iterable call(Type type);
}
