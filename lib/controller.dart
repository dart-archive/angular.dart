library angular.module;

import 'dart:mirrors';
import 'package:di/di.dart';
import 'registry.dart';

/**
 * Used to annotate
 */
class NgController {
  final String name;

  const NgController({String this.name});

  int get hashCode => name.hashCode;
  bool operator==(other) => this.name == other.name;

  toString() => name;
}

class ControllerMap extends AnnotationMap<NgController> {
  ControllerMap(Injector injector) : super(NgController, injector);
  where(annotation) => annotation is NgController;
}
