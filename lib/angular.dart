library angular;

import "dart:mirrors";
import "dart:async" as async;
import "dart:json" as json;
import 'dart:html' as dom;
import 'package:di/di.dart';
import 'package:perf_api/perf_api.dart';
import 'debug.dart';

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
part 'parser.dart';
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


typedef FnWith0Args();
typedef FnWith1Args(a0);
typedef FnWith2Args(a0, a1);
typedef FnWith3Args(a0, a1, a2);
typedef FnWith4Args(a0, a1, a2, a3);
typedef FnWith5Args(a0, a1, a2, a3, a4);

relaxFnApply(Function fn, List args) {
  // Check the args.length to support functions with optional parameters.
  var argsLen = args.length;
  if (fn is Function && fn != null) {
    if (fn is FnWith5Args && argsLen > 4) {
      return fn(args[0], args[1], args[2], args[3], args[4]);
    } else if (fn is FnWith4Args && argsLen > 3) {
      return fn(args[0], args[1], args[2], args[3]);
    } else if (fn is FnWith3Args&& argsLen > 2 ) {
      return fn(args[0], args[1], args[2]);
    } else if (fn is FnWith2Args && argsLen > 1 ) {
      return fn(args[0], args[1]);
    } else if (fn is FnWith1Args && argsLen > 0) {
      return fn(args[0]);
    } else if (fn is FnWith0Args) {
      return fn();
    } else {
      throw "Unknown function type, expecting 0 to 5 args.";
    }
  } else {
    throw "Missing function.";
  }
}

_relaxFnArgs(Function fn) {
  return ([a0, a1, a2, a3, a4]) {
    if (fn is FnWith5Args) {
      return fn(a0, a1, a2, a3, a4);
    } else if (fn is FnWith4Args) {
      return fn(a0, a1, a2, a3);
    } else if (fn is FnWith3Args) {
      return fn(a0, a1, a2);
    } else if (fn is FnWith2Args) {
      return fn(a0, a1);
    } else if (fn is FnWith1Args) {
      return fn(a0);
    } else if (fn is FnWith0Args) {
      return fn();
    } else {
      throw "Unknown function type, expecting 0 to 5 args.";
    }
  };
}



class AngularModule extends Module {
  DirectiveRegistry _directives = new DirectiveRegistry();

  AngularModule() {
    value(DirectiveRegistry, _directives);
    type(Compiler, Compiler);
    type(ExceptionHandler, ExceptionHandler);
    type(Scope, Scope);
    type(Parser, Parser);
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
