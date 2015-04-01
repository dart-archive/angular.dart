library angular_spec;

import 'dart:mirrors';

import '_specs.dart';
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

    it('should not export unknown symbols from touch', () {
      LibraryInfo libraryInfo;
      try {
        libraryInfo = getSymbolsFromLibrary("angular.touch");
      } on UnimplementedError catch (e) {
        return; // Not implemented, quietly skip.
      }

      var ALLOWED_NAMES = [
        "angular.touch.NgSwipeLeft",
        "angular.touch.NgSwipeRight",
        "angular.touch.TouchModule"
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
        "angular.cache.CacheRegister",
        "angular.cache.CacheRegisterStats",
        "angular.core.annotation.ShadowRootAware",
        "angular.core.annotation_src.AttachAware",
        "angular.core.annotation_src.Component",
        "angular.core.annotation_src.Decorator",
        "angular.core.annotation_src.DetachAware",
        "angular.core.annotation_src.Directive",
        "angular.core.annotation_src.DirectiveAnnotation",
        "angular.core.annotation_src.DirectiveBinder",
        "angular.core.annotation_src.DirectiveBinderFn",
        "angular.core.annotation_src.Formatter",
        "angular.core.annotation_src.NgAttr",
        "angular.core.annotation_src.NgCallback",
        "angular.core.annotation_src.NgOneWay",
        "angular.core.annotation_src.NgOneWayOneTime",
        "angular.core.annotation_src.NgTwoWay",
        "angular.core.annotation_src.Visibility",
        "angular.core.dom_internal.Animate",
        "angular.core.dom_internal.Animation",
        "angular.core.dom_internal.AnimationResult",
        "angular.core.dom_internal.BoundViewFactory",
        "angular.core.dom_internal.BrowserCookies",
        "angular.core.dom_internal.Compiler",
        "angular.core.dom_internal.CompilerConfig",
        "angular.core.dom_internal.Cookies",
        "angular.core.dom_internal.DirectiveMap",
        "angular.core.dom_internal.ElementProbe",
        "angular.core.dom_internal.EventHandler",
        "angular.core.dom_internal.Http",
        "angular.core.dom_internal.HttpBackend",
        "angular.core.dom_internal.HttpConfig",
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
        "angular.core_dom.resource_url_resolver.ResourceResolverConfig",
        "angular.core_dom.resource_url_resolver.ResourceUrlResolver",
        "angular.core.dom_internal.ResponseError",
        "angular.core.dom_internal.TemplateCache",
        "angular.core.dom_internal.UrlRewriter",
        "angular.core.dom_internal.View",
        "angular.core.dom_internal.ViewFactoryCache",
        "angular.core.dom_internal.ViewFactory",
        "angular.core.dom_internal.ViewPort",
        "angular.core.parser.Parser",
        "angular.core.parser.ClosureMap",
        "angular.core_internal.ExceptionHandler",
        "angular.core_internal.Interpolate",
        "angular.core_internal.RootScope",
        "angular.core_internal.Scope",
        "angular.core_internal.ScopeAware",
        "angular.core_internal.ScopeDigestTTL",
        "angular.core_internal.ScopeEvent",
        "angular.core_internal.ScopeStats",
        "angular.core_internal.ScopeStatsConfig",
        "angular.core_internal.ScopeStatsEmitter",
        "angular.core_internal.VmTurnZone",
        "angular.core.parser.ClosureMap",
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
        "angular.directive.NgModelColorValidator",
        "angular.directive.NgModelConverter",
        "angular.directive.NgModelEmailValidator",
        "angular.directive.NgModelMaxLengthValidator",
        "angular.directive.NgModelMaxNumberValidator",
        "angular.directive.NgModelMinLengthValidator",
        "angular.directive.NgModelMinNumberValidator",
        "angular.directive.NgModelNumberValidator",
        "angular.directive.NgModelOptions",
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
        "angular.formatter_internal.Arrayify",
        "angular.formatter_internal.Currency",
        "angular.formatter_internal.Date",
        "angular.formatter_internal.Filter",
        "angular.formatter_internal.FormatterModule",
        "angular.formatter_internal.Json",
        "angular.formatter_internal.LimitTo",
        "angular.formatter_internal.Lowercase",
        "angular.formatter_internal.Number",
        "angular.formatter_internal.OrderBy",
        "angular.formatter_internal.Stringify",
        "angular.formatter_internal.Uppercase",
        "angular.introspection.getTestability",
        "angular.introspection.ngDirectives",
        "angular.introspection.ngInjector",
        "angular.introspection.ngProbe",
        "angular.introspection.ngQuery",
        "angular.introspection.ngScope",
        "angular.node_injector.DirectiveInjector",
        "angular.routing.NgBindRoute",
        "angular.routing.NgRouteCfg",
        "angular.routing.NgRoutingHelper",
        "angular.routing.NgRoutingUsePushState",
        "angular.routing.NgView",
        "angular.routing.RouteInitializer",
        "angular.routing.RouteInitializerFn",
        "angular.routing.RouteProvider",
        "angular.routing.RouteViewFactory",
        "angular.routing.RoutingModule",
        "angular.routing.ngRoute",
        "angular.tracing.traceAsyncEnd",
        "angular.tracing.traceAsyncStart",
        "angular.tracing.traceCreateScope",
        "angular.tracing.traceDetectWTF",
        "angular.tracing.traceEnabled",
        "angular.tracing.traceEnter",
        "angular.tracing.traceEnter1",
        "angular.tracing.traceLeave",
        "angular.tracing.traceLeaveVal",
        "angular.watch_group.ContextLocals",
        "angular.watch_group.PrototypeMap",
        "angular.watch_group.ReactionFn",
        "angular.watch_group.Watch",
        "change_detection.AvgStopwatch",
        "change_detection.FieldGetterFactory",
        "di.annotations.Injectable",
        "di.annotations.Injectables",
        "di.errors.CircularDependencyError",
        "di.errors.DynamicReflectorError",
        "di.errors.NoGeneratedTypeFactoryError",
        "di.errors.NoProviderError",
        "di.errors.ResolvingError",
        "di.injector.Injector",
        "di.injector.ModuleInjector",
        "di.key.Key",
        "di.key.key",
        "di.module.Binding",
        "di.module.DEFAULT_VALUE",
        "di.module.Module",
        "di.reflector.TypeReflector",
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
        "route.client.RoutePreLeaveEvent",
        "route.client.RoutePreLeaveEventHandler",
        "route.client.RouteStartEvent",
        "route.client.Router",
        "url_matcher.UrlMatch",
        "url_matcher.UrlMatcher"
      ];

      assertSymbolNamesAreOk(ALLOWED_NAMES, libraryInfo);
    });
  });
}
