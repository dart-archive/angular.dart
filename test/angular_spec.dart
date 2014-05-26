library angular_spec;

import 'dart:mirrors';

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

  describe('symbols', () {
    it('should not export unknown symbols from animate', () {
      LibraryInfo libraryInfo;
      try {
        libraryInfo = getSymbolsFromLibrary("angular.animate");
      } on UnimplementedError catch (e) {
        return; // Not implemented, quietly skip.
      }

      var ALLOWED_NAMES = [
          "angular.animate.AbstractNgAnimate",
          "angular.animate.AnimationLoop",
          "angular.animate.AnimationModule",
          "angular.animate.AnimationOptimizer",
          "angular.animate.CssAnimate",
          "angular.animate.CssAnimationMap",
          "angular.animate.NgAnimate",
          "angular.animate.NgAnimateChildren",
          "angular.animate.CssAnimation",
          "angular.animate.AnimationFrame",
          "angular.animate.AnimationList",
          "angular.animate.LoopedAnimation"
      ];
      assertSymbolNamesAreOk(ALLOWED_NAMES, libraryInfo);

    });

    it('should not export unknown symbols from angular', () {
      // Test is failing? Add new symbols to the "ALLOWED_NAMES" list below.
      // But make sure that you intend to export the symbol!
      // Questions?  Talk to @jbdeboer

      // There is a bug at the intersection of the angular library,
      // dart2js and findLibrary().  http://dartbug.com/18302
      try {
        currentMirrorSystem().findLibrary(const Symbol("angular"));
      } catch (e) {
        return;
      }

      LibraryInfo libraryInfo;
      try {
        libraryInfo = getSymbolsFromLibrary("angular");
      } on UnimplementedError catch (e) {
        return; // Not implemented, quietly skip.
      }

      var ALLOWED_NAMES = [
        "angular.app.AngularModule",
        "angular.app.Application",
        "angular.core.annotation.ShadowRootAware",
        "angular.core.annotation_src.AttachAware",
        "angular.core.annotation_src.Component",
        "angular.core.annotation_src.Controller",
        "angular.core.annotation_src.Decorator",
        "angular.core.annotation_src.DetachAware",
        "angular.core.annotation_src.Directive",
        "angular.core.annotation_src.DirectiveAnnotation",
        "angular.core.annotation_src.Formatter",
        "angular.core.annotation_src.Injectable",
        "angular.core.annotation_src.NgAttr",
        "angular.core.annotation_src.NgCallback",
        "angular.core.annotation_src.NgOneWay",
        "angular.core.annotation_src.NgOneWayOneTime",
        "angular.core.annotation_src.NgTwoWay",
        "angular.core.dom_internal.Animate",
        "angular.core.dom_internal.Animation",
        "angular.core.dom_internal.AnimationResult",
        "angular.core.dom_internal.BoundViewFactory",
        "angular.core.dom_internal.BrowserCookies",
        "angular.core.dom_internal.Compiler",
        "angular.core.dom_internal.Cookies",
        "angular.core.dom_internal.DirectiveMap",
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
        "angular.core.dom_internal.LocationWrapper",
        "angular.core.dom_internal.NgElement",
        "angular.core.dom_internal.NoOpAnimation",
        "angular.core.dom_internal.NullTreeSanitizer",
        "angular.core.dom_internal.RequestErrorInterceptor",
        "angular.core.dom_internal.RequestInterceptor",
        "angular.core.dom_internal.Response",
        "angular.core.dom_internal.ResponseError",
        "angular.core.dom_internal.TemplateCache",
        "angular.core.dom_internal.UrlRewriter",
        "angular.core.dom_internal.View",
        "angular.core.dom_internal.ViewCache",
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
        "angular.core.parser.dynamic_parser.ClosureMap",
        "angular.core.parser.Parser",
        "angular.directive.AHref",
        "angular.directive.ContentEditable",
        "angular.directive.DirectiveModule",
        "angular.directive.InputCheckbox",
        "angular.directive.InputDateLike",
        "angular.directive.InputNumberLike",
        "angular.directive.InputRadio",
        "angular.directive.InputSelect",
        "angular.directive.InputTextLike",
        "angular.directive.NgAttribute",
        "angular.directive.NgBaseCss",
        "angular.directive.NgBind",
        "angular.directive.NgBindHtml",
        "angular.directive.NgBindTemplate",
        "angular.directive.NgBindTypeForDateLike",
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
        "angular.directive.NgModelOptions",
        "angular.directive.NgModelConverter",
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
        "angular.directive.NgNullControl",
        "angular.directive.NgNullForm",
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
        "angular.directive.NgValidator",
        "angular.directive.NgValue",
        "angular.directive.OptionValue",
        "angular.formatter_internal.FormatterModule",
        "angular.formatter_internal.Currency",
        "angular.formatter_internal.Date",
        "angular.formatter_internal.Filter",
        "angular.formatter_internal.FormatterModule",
        "angular.formatter_internal.Json",
        "angular.formatter_internal.LimitTo",
        "angular.formatter_internal.Lowercase",
        "angular.formatter_internal.Arrayify",
        "angular.formatter_internal.Number",
        "angular.formatter_internal.OrderBy",
        "angular.formatter_internal.Stringify",
        "angular.formatter_internal.Uppercase",
        "angular.introspection.ngDirectives",
        "angular.introspection.ngInjector",
        "angular.introspection.ngProbe",
        "angular.introspection.ngQuery",
        "angular.introspection.ngScope",
        "angular.routing.NgBindRoute",
        "angular.routing.ngRoute",
        "angular.routing.NgRouteCfg",
        "angular.routing.NgRoutingHelper",
        "angular.routing.NgRoutingUsePushState",
        "angular.routing.NgView",
        "angular.routing.RouteInitializer",
        "angular.routing.RouteInitializerFn",
        "angular.routing.RouteProvider",
        "angular.routing.RouteViewFactory",
        "angular.routing.RoutingModule",
        "angular.watch_group.PrototypeMap",
        "angular.watch_group.ReactionFn",
        "angular.watch_group.Watch",
        "change_detection.AvgStopwatch",
        "change_detection.FieldGetterFactory",
        "di.CircularDependencyError",
        "di.FactoryFn",
        "di.Injector",
        "di.InvalidBindingError",
        "di.key.Key",
        "di.Module",
        "di.NoProviderError",
        "di.TypeFactory",
        "di.Visibility",
        "route.client.Routable",
        "route.client.Route",
        "route.client.RouteEnterEvent",
        "route.client.RouteEnterEventHandler",
        "route.client.RouteEvent",
        "route.client.RouteHandle",
        "route.client.RouteImpl",
        "route.client.RoutePreLeaveEvent",
        "route.client.RoutePreLeaveEventHandler",
        "route.client.RouteLeaveEvent",
        "route.client.RouteLeaveEventHandler",
        "route.client.RoutePreEnterEvent",
        "route.client.RoutePreEnterEventHandler",
        "route.client.RoutePreLeaveEvent",
        "route.client.RoutePreLeaveEventHandler",
        "route.client.Router",
        "route.client.RouteStartEvent",
        "url_matcher.UrlMatch",
        "url_matcher.UrlMatcher"
      ];

      assertSymbolNamesAreOk(ALLOWED_NAMES, libraryInfo);
    });
  });
}

