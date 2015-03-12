library test_files.main;

import 'package:angular/core/annotation_src.dart';
import 'package:angular/routing/module.dart';
import 'package:di/di.dart';

@Decorator(
    selector:'[ng-if]',
    map: const {'.': '=>ngIfCondition'})
class NgIfDirective {
  bool ngIfCondition;
}

main() {
  var barRoute = ngRoute(
      path: '/bar',
      viewHtml: '<div ng-if="bar"></div>');
  var module = new Module()
      ..bind(RouteInitializerFn, toValue: (router, views) {
        views.configure({
          'foo': ngRoute(
              path: '/foo',
              viewHtml: '<div ng-if="foo"></div>'),
          'bar': barRoute,
        });
      });
}
