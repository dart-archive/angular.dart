library angular.directive.ng_controller;

import 'dart:html' as dom;
import 'package:di/di.dart';
import '../dom/directive.dart';
import '../dom/block.dart';
import '../dom/block_factory.dart';
import '../scope.dart';
import '../parser/parser_library.dart';
import '../controller.dart';

@NgDirective(
    transclude: true,
    selector:'[ng-controller]',
    map: const {'.': '@.expression'})
class NgControllerAttrDirective {
  static RegExp CTRL_REGEXP = new RegExp(r'^(\S+)(\s+as\s+(\w+))?$');

  BoundBlockFactory boundBlockFactory;
  BlockHole blockHole;
  Injector injector;
  Scope scope;
  ControllerMap controllers;

  String alias;

  set expression(value) {
    var match = CTRL_REGEXP.firstMatch(value);

    Type ctrlType = controllers[new NgController(name: match.group(1))];
    alias = match.group(3);

    scope.$evalAsync(() {
      var childScope = scope.$new();

      // attach the child scope
      boundBlockFactory(childScope).insertAfter(blockHole);

      // instantiate the controller
      var controller = injector
          .createChild([new Module()..value(Scope, childScope)],
                       forceNewInstances: [ctrlType]).get(ctrlType);

      // publish the controller into the scope
      if (alias != null) {
        childScope[alias] = controller;
      }
    });
  }

  NgControllerAttrDirective(BoundBlockFactory this.boundBlockFactory,
                            BlockHole this.blockHole,
                            Injector this.injector,
                            Scope this.scope,
                            ControllerMap this.controllers);
}
