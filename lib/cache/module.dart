library angular.cache;

import 'dart:collection';
import 'dart:async';

import 'package:di/di.dart';
import 'package:di/annotations.dart';

part "cache.dart";
part "cache_register.dart";

class CacheModule extends Module {
  CacheModule() {
    bind(CacheRegister);
  }
  CacheModule.withReflector(reflector): super.withReflector(reflector) {
    bind(CacheRegister);
  }
}
