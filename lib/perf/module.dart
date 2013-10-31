library angular.perf;

import 'dart:html' as dom;

import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';

part 'dev_tools_timeline.dart';

class NgPerfModule extends Module {
  NgPerfModule() {
    type(Profiler, implementedBy: Profiler);
  }
}
