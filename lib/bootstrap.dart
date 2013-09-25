library angular.bootstrap;

import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:perf_api/perf_api.dart';

import 'dart:html' as dom; // TODO(misko): to be deleted

import 'controller.dart';
import 'directive.dart';
import 'cache.dart';
import 'exception_handler.dart';
import 'interpolate.dart';
import 'dom/http.dart';
import 'dom/template_cache.dart';
import 'scope.dart';
import 'zone.dart';
import 'filter.dart';
import 'registry.dart';

import 'parser/parser_library.dart';
import 'dom/all.dart';
import 'dom/http.dart';
import 'directives/all.dart';
import 'filters/all.dart';


class AngularModule extends Module {
  AngularModule() {
    type(ControllerMap);
    type(DirectiveMap);
    type(MetadataExtractor);
    type(FilterMap);
    type(Compiler);
    type(ExceptionHandler);
    type(Scope);
    type(Parser, implementedBy: DynamicParser);
    type(DynamicParser);
    type(Lexer);
    type(ParserBackend);
    type(Interpolate);
    type(Http);
    type(UrlRewriter);
    type(HttpBackend);
    type(HttpDefaultHeaders);
    type(HttpDefaults);
    type(BlockCache);
    type(TemplateCache);
    type(GetterSetter);
    type(Profiler);
    type(ScopeDigestTTL);
    type(dom.NodeTreeSanitizer, implementedBy: NullTreeSanitizer);

    registerDirectives(this);
    registerFilters(this);
  }
}


// helper for bootstrapping angular
bootstrapAngular(modules, [rootElementSelector = '[ng-app]']) {
  var allModules = new List.from(modules);
  List<dom.Node> topElt = dom.query(rootElementSelector).nodes.toList();
  assert(topElt.length > 0);

  // The injector must be created inside the zone, so we create the
  // zone manually and give it back to the injector as a value.
  Zone zone = new Zone();
  allModules.add(new Module()..value(Zone, zone));

  zone.run(() {
    Injector injector = new DynamicInjector(modules: allModules);
    injector.get(Compiler)(topElt)(injector, topElt);
  });
}

