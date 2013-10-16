library angular.bootstrap;

import 'dart:html' as dom;
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:perf_api/perf_api.dart';

import 'core/module.dart';
import 'core_dom/module.dart';
import 'directive/module.dart';
import 'filter/module.dart';
import 'perf/module.dart';

/**
 * This is the top level module which describes the whole of angular.
 *
 * The Module is made up or
 *
 * - [NgCoreModule]
 * - [NgCoreDomModule]
 * - [NgFilterModule]
 * - [NgPerfModule]
 */
class AngularModule extends Module {
  AngularModule() {
    install(new NgCoreModule());
    install(new NgCoreDomModule());
    install(new NgDirectiveModule());
    install(new NgFilterModule());
    install(new NgPerfModule());
  }
}

Injector _defaultInjectorFactory(List<Module> modules) =>
    new DynamicInjector(modules: modules);

// helper for bootstrapping angular
bootstrapAngular(modules, [rootElementSelector = '[ng-app]',
    Injector injectorFactory(List<Module> modules) = _defaultInjectorFactory]) {
  var allModules = new List.from(modules);
  List<dom.Node> topElt = dom.query(rootElementSelector).nodes.toList();
  assert(topElt.length > 0);

  // The injector must be created inside the zone, so we create the
  // zone manually and give it back to the injector as a value.
  Zone zone = new Zone();
  allModules.add(new Module()..value(Zone, zone));

  return zone.run(() {
    Injector injector = injectorFactory(allModules);
    injector.get(Compiler)(topElt)(injector, topElt);
    return injector;
  });
}

