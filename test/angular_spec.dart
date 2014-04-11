library angular_spec;

import '_specs.dart';
import 'package:angular/utils.dart';
import 'dart:mirrors';

main() {
  describe('angular.dart unittests', () {
    it('should run in checked moded only', () {
      expect(() {
        dynamic v = 6;
        String s = v;
      }).toThrow();
    });
  });

  describe('relaxFnApply', () {
    it('should work with 6 arguments', () {
      var sixArgs = [1, 1, 2, 3, 5, 8];
      expect(relaxFnApply(() => "none", sixArgs)).toEqual("none");
      expect(relaxFnApply((a) => a, sixArgs)).toEqual(1);
      expect(relaxFnApply((a, b) => a + b, sixArgs)).toEqual(2);
      expect(relaxFnApply((a, b, c) => a + b + c, sixArgs)).toEqual(4);
      expect(relaxFnApply((a, b, c, d) => a + b + c + d, sixArgs)).toEqual(7);
      expect(relaxFnApply((a, b, c, d, e) => a + b + c + d + e, sixArgs)).toEqual(12);
    });

    it('should work with 0 arguments', () {
      var noArgs = [];
      expect(relaxFnApply(() => "none", noArgs)).toEqual("none");
      expect(relaxFnApply(([a]) => a, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b]) => b, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c]) => c, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c, d]) => d, noArgs)).toEqual(null);
      expect(relaxFnApply(([a, b, c, d, e]) => e, noArgs)).toEqual(null);
    });

    it('should fail with not enough arguments', () {
      expect(() {
        relaxFnApply((required, alsoRequired) => "happy", [1]);
      }).toThrow('Unknown function type, expecting 0 to 5 args.');
    });
  });

  describe('angular symbols', () {
    it('should not export symbols that we do not know about', () {
      // Test is failing? Add new symbols to the "ALLOWED_NAMES" list below.
      // But make sure that you intend to export the symbol!
      // Questions?  Talk to @jbdeboer

      var _SYMBOL_NAME = new RegExp('"(.*)"');
      _unwrapSymbol(sym) => _SYMBOL_NAME.firstMatch(sym.toString()).group(1);

      _getSymbolsFromLibrary(String libraryName) {
        // Set this to true to see how symbols are exported from angular.
        var SHOULD_PRINT_SYMBOL_TREE = false;

        // TODO(deboer): Add types once Dart VM 1.2 is deprecated.
        List extractSymbols(/* LibraryMirror */ lib, [String printPrefix = ""]) {
          var names = [];

          if (SHOULD_PRINT_SYMBOL_TREE) print(printPrefix + _unwrapSymbol(lib.qualifiedName));
          printPrefix += "  ";
          lib.declarations.forEach((symbol, _) {
            if (SHOULD_PRINT_SYMBOL_TREE) print(printPrefix + _unwrapSymbol(symbol));
            names.add([symbol, lib.qualifiedName]);
          });

          lib.libraryDependencies.forEach((/* LibraryDependencyMirror */ libDep) {
            LibraryMirror target = libDep.targetLibrary;
            if (!libDep.isExport) return;

            var childNames = extractSymbols(target, printPrefix);

            // If there was a "show" or "hide" on the exported library, filter the results.
            // This API needs love :-(
            var showSymbols = [], hideSymbols = [];
            libDep.combinators.forEach((/* CombinatorMirror */ c) {
              if (c.isShow) {
                showSymbols.addAll(c.identifiers);
              }
              if (c.isHide) {
                hideSymbols.addAll(c.identifiers);
              }
            });

            // I don't think you can show and hide from the same library
            assert(showSymbols.isEmpty || hideSymbols.isEmpty);
            if (!showSymbols.isEmpty) {
              childNames = childNames.where((List symAndLib) {
                return showSymbols.contains(symAndLib[0]);
              });
            }
            if (!hideSymbols.isEmpty) {
              childNames = childNames.where((List symAndLib) {
                return !hideSymbols.contains(symAndLib[0]);
              });
            }

            names.addAll(childNames);
          });
          return names;
        };

        var lib = currentMirrorSystem().findLibrary(new Symbol(libraryName));
        return extractSymbols(lib);
      }

      var names;
      try {  // Not impleneted in Dart VM 1.2
        names = _getSymbolsFromLibrary("angular");
      } on UnimplementedError catch (e) {
        return; // Not implemented, quietly skip.
      } catch (e) {
        print("Error: $e");
        return; // On VMes <1.2, quietly skip.
      }

      var ALLOWED_PREFIXES = [
        "_"
      ];

      var ALLOWED_NAMES = [
        "angular.app.AngularModule",
        "angular.app.Application",
        "angular.core.annotation_src.AttachAware",
        "angular.core.annotation_src.Component",
        "angular.core.annotation_src.Controller",
        "angular.core.annotation_src.Decorator",
        "angular.core.annotation_src.DetachAware",
        "angular.core.annotation_src.Injectable",
        "angular.core.dom_internal.Animate",
        "angular.core.dom_internal.Animation",
        "angular.core.dom_internal.AnimationResult",
        "angular.core.dom_internal.BrowserCookies",
        "angular.core.dom_internal.Compiler",
        "angular.core.dom_internal.Cookies",
        "angular.core.dom_internal.ElementProbe",
        "angular.core.dom_internal.EventHandler",
        "angular.core.dom_internal.Http",
        "angular.core.dom_internal.HttpBackend",
        "angular.core.dom_internal.HttpDefaultHeaders",
        "angular.core.dom_internal.HttpDefaults",
        "angular.core.dom_internal.HttpInterceptor",
        "angular.core.dom_internal.HttpInterceptors",
        "angular.core.dom_internal.HttpResponse",
        "angular.core.dom_internal.HttpResponseConfig",
        "angular.core.dom_internal.NoOpAnimation",
        "angular.core.dom_internal.NullTreeSanitizer",
        "angular.core.dom_internal.RequestErrorInterceptor",
        "angular.core.dom_internal.RequestInterceptor",
        "angular.core.dom_internal.Response",
        "angular.core.dom_internal.ResponseError",
        "angular.core.dom_internal.TemplateCache",
        "angular.core.dom_internal.View",
        "angular.core.dom_internal.ViewFactory",
        "angular.core.dom_internal.ViewPort",
        "angular.core_internal.CacheStats",
        "angular.core_internal.ExceptionHandler",
        "angular.core_internal.Interpolate",
        "angular.core_internal.RootScope",
        "angular.core_internal.Scope",
        "angular.core_internal.ScopeDigestTTL",
        "angular.core_internal.ScopeEvent",
        "angular.core_internal.ScopeStats",
        "angular.core_internal.ScopeStatsConfig",
        "angular.core_internal.ScopeStatsEmitter",
        "angular.core_internal.VmTurnZone",
        "angular.directive.AHref",
        "angular.directive.ContentEditable",
        "angular.directive.InputCheckbox",
        "angular.directive.InputDateLike",
        "angular.directive.InputNumberLike",
        "angular.directive.InputRadio",
        "angular.directive.InputSelect",
        "angular.directive.InputTextLike",
        "angular.directive.NgAttribute",
        "angular.directive.NgBind",
        "angular.directive.NgBindHtml",
        "angular.directive.NgBindTemplate",
        "angular.directive.NgBooleanAttribute",
        "angular.directive.NgClass",
        "angular.directive.NgClassEven",
        "angular.directive.NgClassOdd",
        "angular.directive.NgCloak",
        "angular.directive.NgControl",
        "angular.directive.NgEvent",
        "angular.directive.NgFalseValue",
        "angular.directive.NgForm",
        "angular.directive.NgHide",
        "angular.directive.NgIf",
        "angular.directive.NgInclude",
        "angular.directive.NgModel",
        "angular.directive.NgModelEmailValidator",
        "angular.directive.NgModelMaxLengthValidator",
        "angular.directive.NgModelMaxNumberValidator",
        "angular.directive.NgModelMinLengthValidator",
        "angular.directive.NgModelMinNumberValidator",
        "angular.directive.NgModelNumberValidator",
        "angular.directive.NgModelPatternValidator",
        "angular.directive.NgModelRequiredValidator",
        "angular.directive.NgModelUrlValidator",
        "angular.directive.NgNonBindable",
        "angular.directive.NgPluralize",
        "angular.directive.NgRepeat",
        "angular.directive.NgShow",
        "angular.directive.NgSource",
        "angular.directive.NgStyle",
        "angular.directive.NgSwitch",
        "angular.directive.NgSwitchDefault",
        "angular.directive.NgSwitchWhen",
        "angular.directive.NgTemplate",
        "angular.directive.NgTrueValue",
        "angular.directive.NgUnless",
        "angular.directive.NgValue",
        "angular.directive.OptionValue",
        "angular.formatter_internal.Currency",
        "angular.formatter_internal.Date",
        "angular.formatter_internal.Filter",
        "angular.formatter_internal.Json",
        "angular.formatter_internal.LimitTo",
        "angular.formatter_internal.Lowercase",
        "angular.formatter_internal.Number",
        "angular.formatter_internal.OrderBy",
        "angular.formatter_internal.Stringify",
        "angular.formatter_internal.Uppercase",
        "angular.routing.RouteInitializer",
        "angular.routing.RouteInitializerFn",
        "angular.routing.RouteProvider",
        "angular.routing.RouteViewFactory",
        "angular.watch_group.PrototypeMap",
        "angular.watch_group.Watch",
        "di.CircularDependencyError",
        "di.FactoryFn",
        "di.Injector",
        "di.InvalidBindingError",
        "di.Key",  // common name, should be removed.
        "di.Module",
        "di.NoProviderError",
        "di.ObjectFactory",
        "di.TypeFactory",
        "di.Visibility",
        "route.client.Routable",
        "route.client.Route",
        "route.client.RouteEnterEvent",
        "route.client.RouteEnterEventHandler",
        "route.client.RouteEvent",
        "route.client.RouteHandle",
        "route.client.RouteImpl",
        "route.client.RouteLeaveEvent",
        "route.client.RouteLeaveEventHandler",
        "route.client.RoutePreEnterEvent",
        "route.client.RoutePreEnterEventHandler",
        "route.client.RouteStartEvent",
        "route.client.Router",
        "url_matcher.UrlMatch",
        "url_matcher.UrlMatcher",
      ];

      var _nameMap = {};
      ALLOWED_NAMES.forEach((x) => _nameMap[x] = true);

      var exported = [];
      assertSymbolNameIsOk(List nameInfo) {
        String name = _unwrapSymbol(nameInfo[0]);
        String libName = _unwrapSymbol(nameInfo[1]);

        if (ALLOWED_PREFIXES.any((prefix) => name.startsWith(prefix))) return;

        var key = "$libName.$name";
        if (_nameMap.containsKey(key)) {
          _nameMap[key] = false;
          return;
        }

        exported.add(key);
      };
      if (exported.isNotEmpty) {
        throw "These symbols are exported thru the angular library, but it shouldn't be:\n"
              "${exported.join('\n')}";
      }

      names.forEach(assertSymbolNameIsOk);

      // If there are keys that no longer need to be in the ALLOWED_NAMES list, complain.
      var keys = [];
      _nameMap.forEach((k,v) {
        if (v) keys.add(k);
      });
      if (keys.isNotEmpty) {
        throw "Missing symbols:\n${keys.join('\n')}";
      }
    });
  });
}
