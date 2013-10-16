library angular.perf;

import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';

class NgPerfModule extends Module {
  NgPerfModule() {
    type(Profiler);
  }
}
