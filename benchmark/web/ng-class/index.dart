import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/change_detection/ast_parser.dart';

import 'dart:js' as js;

@Component(selector: 'classy', templateUrl: 'classy.html')
class Classy {}

@Component(selector: 'baseline', templateUrl: 'baseline.html')
class Baseline {}

@Decorator(selector: '[silly-class]')
class SillyClass {
  final NgElement element;

  SillyClass(this.element);

  @NgOneWay('silly-class')
  set className(value) {
    element.addClass(value);
  }
}

// Main function runs the benchmark.
main() {
  var cleanup, createDom;

  var module = new Module()
    ..bind(Classy)
    ..bind(Baseline)
    ..bind(SillyClass)
    ..bind(CompilerConfig,
        toValue: new CompilerConfig.withOptions(elementProbeEnabled: false));

  var injector = applicationFactory().addModule(module).run();
  assert(injector != null);

  // Set up ASTs
  var parser = injector.get(ASTParser);
  VmTurnZone zone = injector.get(VmTurnZone);
  Scope scope = injector.get(Scope);

  scope.context['initData'] = {
    "value": "top",
    "right": {"value": "right"},
    "left": {"value": "left"}
  };

  buildTree(maxDepth, values, curDepth) {
    if (maxDepth == curDepth) return {};
    return {
      "value": values[curDepth],
      "right": buildTree(maxDepth, values, curDepth + 1),
      "left": buildTree(maxDepth, values, curDepth + 1)
    };
  }
  cleanup = (_) => zone.run(() {
    scope.context['running'] = false;
  });

  var count = 0;
  createDom = (_) => zone.run(() {
    scope.context['running'] = true;
  });

  js.context['benchmarkSteps'].add(new js.JsObject.jsify(
      {"name": "cleanup", "fn": new js.JsFunction.withThis(cleanup)}));
  js.context['benchmarkSteps'].add(new js.JsObject.jsify(
      {"name": "createDom", "fn": new js.JsFunction.withThis(createDom)}));
}
