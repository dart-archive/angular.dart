/**
 * Touch related functionality for AngularDart apps.
 * 
 * To use, install the TouchModule into your main module:
 *
 *     var module = new Module()
 *       ..install(new TouchModule());
 * 
 * Once the module is installed, you can use decorators such
 * as ng-swipe-left or ng-swipe right
 */

library angular.touch;

import 'dart:html' as dom;
import 'package:di/di.dart';
import 'package:angular/core/annotation.dart';

part 'ng_swipe.dart';

class TouchModule extends Module {
  TouchModule() {
    bind(NgSwipeLeft, toValue: null);
    bind(NgSwipeRight, toValue: null);
  }
}
 