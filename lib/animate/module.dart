library angular.animate;

import 'dart:async';
import 'dart:html' as dom;

import 'package:angular/core/module.dart';
import 'package:logging/logging.dart';
import 'package:perf_api/perf_api.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/time.dart';
import 'package:di/di.dart';

part 'animate.dart';
part 'animation.dart';
part 'animation_runner.dart';
part 'css_animation.dart';
part 'css_animate.dart';
part 'no_animate.dart';

final Logger _logger = new Logger('ng.animate');

class NgAnimateModule extends Module {
  NgAnimateModule.css() {
    value(Clock, new Clock());
    value(dom.Window, dom.window);
    type(AnimationRunner);
    type(NoAnimate);
    type(Animate, implementedBy: CssAnimate);
  }

  NgAnimateModule.none() {
    type(Animate, implementedBy: NoAnimate);
  }
}