library angular.module;

import 'dart:mirrors';
import 'package:di/di.dart';
import 'registry.dart';

/**
 * Used to annotate Controllers used by ng-controller
 */
class NgController {
  //TODO(misko): move this with ng-controler
  final String name;

  const NgController({String this.name});

  int get hashCode => name.hashCode;
  bool operator==(other) => this.name == other.name;

  toString() => name;
}

class ControllerMap extends AnnotationMap<NgController> {
  ControllerMap(Injector injector, MetadataExtractor metadataExtractor)
      : super(injector, metadataExtractor);
}
