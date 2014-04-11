library angular_spec;

import '_specs.dart';
import 'package:angular/utils.dart';
import 'package:angular/tools/symbol_inspector/symbol_inspector.dart';

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
    iit('should not export symbols that we do not know about', () {
      // Test is failing? Add new symbols to the "ALLOWED_NAMES" list below.
      // But make sure that you intend to export the symbol!
      // Questions?  Talk to @jbdeboer

      LibraryInfo libraryInfo;
      var names;
      try {  // Not impleneted in Dart VM 1.2
        libraryInfo = getSymbolsFromLibrary("angular");
      } on UnimplementedError catch (e) {
        return; // Not implemented, quietly skip.
      } catch (e) {
        print("Error: $e");
        return; // On VMes <1.2, quietly skip.
      }

      names = libraryInfo.names;

      var ALLOWED_NAMES = [
        "angular.app.Application",
        "angular.app.AngularModule",
        "angular.core.annotation_src.NgAttachAware",
        "angular.core.annotation_src.NgComponent",
        "angular.core.annotation_src.NgController",
        "angular.core.annotation_src.NgDetachAware",
        "angular.core.annotation_src.NgDirective",
        "angular.core.annotation_src.NgInjectableService",
        "angular.core_internal.CacheStats",
        "angular.core_internal.ExceptionHandler",
        "angular.core_internal.Interpolate",
        "angular.core_internal.RootScope",
        "angular.core_internal.NgZone",
        "angular.core_internal.Scope",
        "angular.core_internal.ScopeDigestTTL",
        "angular.core_internal.ScopeEvent",
        "angular.core_internal.ScopeStats",
        "angular.core_internal.ScopeStatsConfig",
        "angular.core_internal.ScopeStatsEmitter",
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
        "angular.core.dom_internal.NgAnimate",
        "angular.core.dom_internal.RequestErrorInterceptor",
        "angular.core.dom_internal.RequestInterceptor",
        "angular.core.dom_internal.Response",
        "angular.core.dom_internal.ResponseError",
        "angular.core.dom_internal.TemplateCache",
        "angular.core.dom_internal.View",
        "angular.core.dom_internal.ViewFactory",
        "angular.core.dom_internal.ViewPort",
        "angular.directive.NgA",
        "angular.directive.NgBind",
        "angular.directive.NgBindTemplate",
        "angular.directive.NgBindHtml",
        "angular.directive.NgClass",
        "angular.directive.NgClassOdd",
        "angular.directive.NgClassEven",
        "angular.directive.NgCloak",
        "angular.directive.NgHide",
        "angular.directive.NgIf",
        "angular.directive.NgUnless",
        "angular.directive.NgInclude",
        "angular.directive.NgPluralize",
        "angular.directive.NgRepeat",
        "angular.directive.NgShow",
        "angular.directive.InputTextLike",
        "angular.directive.InputDateLike",
        "angular.directive.InputNumberLike",
        "angular.directive.InputRadio",
        "angular.directive.InputCheckbox",
        "angular.directive.InputSelect",
        "angular.directive.OptionValue",
        "angular.directive.ContentEditable",
        "angular.directive.NgModel",
        "angular.directive.NgValue",
        "angular.directive.NgTrueValue",
        "angular.directive.NgFalseValue",
        "angular.directive.NgSwitch",
        "angular.directive.NgSwitchWhen",
        "angular.directive.NgSwitchDefault",
        "angular.directive.NgBooleanAttribute",
        "angular.directive.NgSource",
        "angular.directive.NgAttribute",
        "angular.directive.NgEvent",
        "angular.directive.NgStyle",
        "angular.directive.NgNonBindable",
        "angular.directive.NgTemplate",
        "angular.directive.NgControl",
        "angular.directive.NgForm",
        "angular.directive.NgModelRequiredValidator",
        "angular.directive.NgModelUrlValidator",
        "angular.directive.NgModelEmailValidator",
        "angular.directive.NgModelNumberValidator",
        "angular.directive.NgModelMaxNumberValidator",
        "angular.directive.NgModelMinNumberValidator",
        "angular.directive.NgModelPatternValidator",
        "angular.directive.NgModelMinLengthValidator",
        "angular.directive.NgModelMaxLengthValidator",
        "angular.filter.Currency",
        "angular.filter.Date",
        "angular.filter.Filter",
        "angular.filter.Json",
        "angular.filter.LimitTo",
        "angular.filter.Lowercase",
        "angular.filter.Number",
        "angular.filter.OrderBy",
        "angular.filter.Stringify",
        "angular.filter.Uppercase",
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
      var _qualifiedNameMap = {};

      ALLOWED_NAMES.forEach((x) => _nameMap[x] = true);

      names.forEach((x) => _qualifiedNameMap[x.qualified] = true);

      var usedButNotExported = {};

      var exported = [];
      assertSymbolNameIsOk(QualifiedSymbol nameInfo) {
        String name = unwrapSymbol(nameInfo.qualified);
        String libName = unwrapSymbol(nameInfo.libraryName);

        var key = "$name";
        if (_nameMap.containsKey(key)) {
          _nameMap[key] = false;

          // Check that all the exposed types are also exported
          assert(libraryInfo.symbolsUsedForName.containsKey(nameInfo.qualified));
          libraryInfo.symbolsUsedForName[nameInfo.qualified].forEach((usedSymbol) {
            if ("$usedSymbol".contains('"dart.')) return;
            if ("$usedSymbol" == 'Symbol("dynamic")') return;
            if ("$usedSymbol" == 'Symbol("void")') return;

            if (!_qualifiedNameMap.containsKey(usedSymbol)) {
              usedButNotExported.putIfAbsent(usedSymbol, () => []);
              usedButNotExported[usedSymbol].add(nameInfo.qualified);
            }
          });
          return;
        }

        exported.add(key);
      };
      if (exported.isNotEmpty) {
        throw "These symbols are exported thru the angular library, but it shouldn't be:\n"
              "${exported.join('\n')}";
      }


      names.forEach(assertSymbolNameIsOk);

      usedButNotExported.forEach((used, locs) {
        print("${unwrapSymbol(used)} : unexported, used from:");
        locs.forEach((l) {
          print("    ${unwrapSymbol(l)}");
        });
        print("");
      });

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

