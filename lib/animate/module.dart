library angular.animate;

import 'dart:async';
import 'dart:html' as dom;

import 'package:angular/core/module.dart';
import 'package:angular/core_dom/module.dart';
import 'package:angular/core_dom/dom_util.dart' as util;
import 'package:logging/logging.dart';
import 'package:perf_api/perf_api.dart';
import 'package:di/di.dart';

part 'animations.dart';
part 'animation_loop.dart';
part 'animation_optimizer.dart';
part 'css_animate.dart';
part 'css_animation.dart';
part 'ng_animate.dart';

final Logger _logger = new Logger('ng.animate');

/**
 * Installing the NgAnimateModule will install a [CssAnimate] implementation of
 * the [NgAnimate] interface in your application. This will change the behavior
 * of view construction, and some of the native directives to allow you to add
 * and define css transition and keyframe animations for the styles of your
 * elements.
 * 
 *   Example html:
 *
 *     <div ng-if="ctrl.myBoolean" class="my-div">...</div>
 *   
 *   Example css defining an opacity transition over .5 seconds using the
 *   `.ng-enter` and `.ng-leave` css classes:
 *
 *     .my-div.ng-enter {
 *       transition: all 500ms;
 *       opacity: 0;
 *     }
 *     .my-div.ng-enter-active {
 *       opacity: 1;
 *     }
 *     
 *     .my-div.ng-leave {
 *       transition: all 500ms;
 *       opacity: 1;
 *     }
 *     .my-div.ng-leave-active {
 *       opacity: 0;
 *     }
 */
class NgAnimateModule extends Module {
  NgAnimateModule() {
    type(AnimationFrame);
    type(AnimationLoop);
    type(CssAnimationMap);
    type(AnimationOptimizer);
    type(NgAnimateDirective);
    type(NgAnimateChildrenDirective);
    type(NgAnimate, implementedBy: CssAnimate);
  }
}