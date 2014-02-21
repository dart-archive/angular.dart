library angular.animate;

import 'dart:async';
import 'dart:html' as dom;

import 'package:angular/core/module.dart';
import 'package:logging/logging.dart';
import 'package:perf_api/perf_api.dart';
import 'package:quiver/collection.dart';
import 'package:di/di.dart';

part 'animate.dart';
part 'animation.dart';
part 'animation_handle.dart';
part 'animation_runner.dart';
part 'css_animation.dart';
part 'css_animate.dart';
part 'dom_tools.dart';
part 'no_animate.dart';

final Logger _logger = new Logger('ng.animate');

/**
 * Installing the NgAnimateModule will enable the [CssAnimate] animation
 * implementation in your application. This will change the behavior of block
 * construction and allow you to add and define css keyframe animations and
 * transitions in the styles of your elements.
 * 
 *   Example html:
 *
 *     <div ng-if="ctrl.myBoolean" class="magic">...</div>
 *   
 *   Example css defining an opacity transition over .5 seconds using the
 *   `.ng-insert` and `.ng-remove` css classes:
 *
 *     magic.ng-insert {
 *       transition: all 500ms;
 *       opacity: 0;
 *     }
 *     magic.ng-insert-active {
 *       opacity: 1;
 *     }
 *     
 *     magic.ng-remove {
 *       transition: all 500ms;
 *       opacity: 1;
 *     }
 *     magic.ng-insert-active {
 *       opacity: 0;
 *     }
 */
class NgAnimateModule extends Module {
  NgAnimateModule() {
    value(dom.Window, dom.window);
    type(AnimationRunner);
    type(NoAnimate);
    type(NgAnimate, implementedBy: CssAnimate);
  }

  NgAnimateModule.noOp() {
    type(NgAnimate, implementedBy: NoAnimate);
  }
}