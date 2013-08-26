library angular;

import "dart:mirrors";
import "dart:async" as async;
import "dart:json" as json;
import 'dart:html' as dom;
import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';
import 'debug.dart';
import 'relax_fn_apply.dart';
import 'parser/parser_library.dart';

part 'block.dart';
part 'cache.dart';
part 'compiler.dart';
part 'directive.dart';
part 'directives/ng_bind.dart';
part 'directives/ng_class.dart';
part 'directives/ng_click.dart';
part 'directives/ng_cloak.dart';
part 'directives/ng_controller.dart';
part 'directives/ng_disabled.dart';
part 'directives/ng_hide.dart';
part 'directives/ng_if.dart';
part 'directives/ng_include.dart';
part 'directives/ng_model.dart';
part 'directives/ng_mustache.dart';
part 'directives/ng_repeat.dart';
part 'directives/ng_show.dart';
part 'dom_utilities.dart';
part 'exception_handler.dart';
part 'http.dart';
part 'interface_typing.dart';
part 'interpolate.dart';
part 'mirrors.dart';
part 'node_cursor.dart';
part 'scope.dart';
part 'selector.dart';
part 'string_utilities.dart';
part 'zone.dart';

ASSERT(condition) {
  if (!condition) {
    throw new AssertionError();
  }
}

num id = 0;

nextUid() {
  return '_${id++}';
}

noop() {}

toJson(obj) {
  try {
    return json.stringify(obj);
  } catch(e) {
    return "NOT-JSONABLE (see toJson(obj) in angular.dart)";
  }
}

class AngularModule extends Module {
  DirectiveRegistry _directives = new DirectiveRegistry();

  AngularModule() {
    value(DirectiveRegistry, _directives);
    type(Compiler, Compiler);
    type(ExceptionHandler, ExceptionHandler);
    type(Scope, Scope);
    type(Parser, Parser);
    type(Lexer, Lexer);
    type(ExpressionFactory, ExpressionFactory);
    type(Interpolate, Interpolate);
    type(CacheFactory, CacheFactory);
    type(Http, Http);
    type(UrlRewriter, UrlRewriter);
    type(HttpBackend, HttpBackend);
    type(BlockCache, BlockCache);
    type(TemplateCache, TemplateCache);
    type(Profiler, _NoOpProfiler);

    value(ScopeDigestTTL, new ScopeDigestTTL(5));

    directive(NgTextMustacheDirective);
    directive(NgAttrMustacheDirective);

    directive(NgBindAttrDirective);
    directive(NgClassAttrDirective);
    directive(NgClickAttrDirective);
    directive(NgCloakAttrDirective);
    directive(NgControllerAttrDirective);
    directive(NgDisabledAttrDirective);
    directive(NgHideAttrDirective);
    directive(NgIfAttrDirective);
    directive(NgIncludeAttrDirective);
    directive(NgRepeatAttrDirective);
    directive(NgShowAttrDirective);

    directive(InputTextDirective);
    directive(InputCheckboxDirective);
    directive(NgModel);
  }

  directive(Type directive) {
    _directives.register(directive);
    return this;
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
    Injector injector = new Injector(allModules);

    injector.invoke((Compiler $compile) {
      $compile(topElt)(injector, topElt);
    });
  });

}

bool understands(obj, symbol) {
  if (symbol is String) symbol = new Symbol(symbol);
  return reflect(obj).type.methods.containsKey(symbol);
}

class _NoOpProfiler extends Profiler {
  void markTime(String name, [String extraData]) { }

  int startTimer(String name, [String extraData]) => null;

  void stopTimer(idOrName) { }
}
