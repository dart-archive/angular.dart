/**
 * The [animate] library makes it easier to build animations that affect the
 * lifecycle of dom elements. The cononical example of this is animating the
 * removal of an element from the dom. In order to do this,
 * one must know about the duration of the animation, and immediatly perform
 * changes in the backing data model. The animation library uses computed css
 * styles to calculate the total duration of animation and handles the addition
 * and removal of elements for the dom for elements that are manipulated by
 * block level directives such as `ng-if`, `ng-repeat`, `ng-hide`, and more.
 *
 * To use, install the NgAnimateModule into your main module:
 *
 *    var module = new Module()
 *       ..install(new NgAnimateModule());
 *
 * Once this is installed, all block level dom manipulations will be routed
 * through the [CssAnimate] implementation instead of the default [NgAnimate]
 * class.
 *
 * For dom manipulations, this will add the `.ng-enter` class to a new dom
 * element, and then read the computed style. If there is a transition or
 * keyframe animation, the animation duration will be read,
 * and the animation will be performed. The `.ng-enter-active` class will be
 * added to set the target state for transition based animations. For
 * removing elements from the dom, a simliar pattern is followed. The
 * `.ng-leave` class will be added to an element, the transition and / or
 * keyframe animation duration will be computed, and if it is non-zero the
 * animation will be run by adding the `.ng-leave-active` class,
 * and the element will be physically removed after the animation completes.
 *
 * The same set of steps is run for each of the following types of dom
 * manipulation:
 *
 * * `.ng-enter`
 * * `.ng-leave`
 * * `.ng-move`
 * * `.{cssclass}-add`
 * * `.{cssclasss}-remove`
 *
 * When writing the css for animating a component you should avoid putting
 * css transitions on elements that might be animated, otherwise there may be
 * unintended pauses or side effects when an element is removed.
 *
 * Fade out example:
 *
 * HTML:
 *     <div class="goodby" ng-if="ctrl.visible">
 *       Goodby world!
 *     </div>
 *
 * CSS:
 *     .goodby.ng-leave {
 *       opacity: 1;
 *       transition: opacity 1s;
 *     }
 *     .goodby.ng-leave.ng-leave-active {
 *       opacity: 0;
 *     }
 *
 * This will perform a fade out animation on the 'goodby' div when the
 * `ctrl.visible` property goes from `true` to `false`.
 *
 * The [CssAnimate] will also do optimizations on running animations by
 * preventing child dom animations with the [AnimationOptimizer]. This
 * prevents transitions on child elements while the parent is animating,
 * but will not stop running transitions once they have started.
 *
 * Finally, it's possible to change the behavior of the [AnimationOptimizer]
 * by using the `ng-animate` and `ng-animate-children` with the options
 * `never`, `always`, or `auto`. `ng-animate` works only on the specific
 * element it is applied too and will override other optimizations if `never`
 * or `always` is specified. `ng-animate` defaults to `auto` which will
 * defer to the `ng-animate-children` on a parent element or the currently
 * running animation check.
 *
 * `ng-animate-children` allows animation to be controlled on large chunks of
 * dom. It only affects child elements, and allows the `always`, `never`,
 * and `auto` values to be specified. Always will always attempt animations
 * on child dom directives, never will always prevent them (except in the
 * case where a given element has `ng-animate="always"` specified),
 * and `auto` will defer the decision to the currently running animation
 * check.
 */

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