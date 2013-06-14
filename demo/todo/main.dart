import 'package:angular/debug.dart';
import 'package:angular/angular.dart';
import 'package:di/di.dart';
import 'dart:html' as dom;

import 'todo.dart';


// helper for bootstrapping angular
bootstrapAngular(modules, [rootElementSelector = '[ng-app]']) {
  List<dom.Node> topElt = dom.query(rootElementSelector).nodes.toList();
  assert(topElt.length > 0);

  Injector injector = new Injector(modules);

  injector.invoke((Compiler $compile, Scope $rootScope) {
    $compile(topElt)(injector, topElt);
    $rootScope.$digest();
  });
}



main() {
  bootstrapAngular([new AngularModule()]);
}
