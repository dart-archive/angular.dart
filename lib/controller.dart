library angular.module;

import 'dart:mirrors';
import 'package:meta/meta.dart';
import 'package:di/di.dart';

class NgController {
  final String name;

  const NgController({String this.name});

  int get hashCode => name.hashCode;
  bool operator==(other) => this.name == other.name;

  toString() => name;
}

@proxy
class ControllerMap implements Map<NgController, Type> {
  Map<NgController, Type> _controllerMap = {};

  ControllerMap(Injector injector) {
    injector.types.forEach((type) {
      var meta = reflectClass(type).metadata;
      if (meta == null) return;
      var iterable = meta
        .where((InstanceMirror im) => im.reflectee is NgController)
        .map((InstanceMirror im) => im.reflectee);
      if (iterable.isEmpty) return;
      _controllerMap[iterable.first] = type;
    });
  }

  Type operator[](NgController annotation) {
    Type type = _controllerMap[annotation];
    if (type == null) throw "Controller ${annotation} does not exist in ${_controllerMap.keys.toList()}.";
    return type;
  }

  forEach(fn) => _controllerMap.forEach(fn);

  noSuchMethod(Invocation invocation) => mirror.reflect(_controllerMap).delegate(invocation);
}

