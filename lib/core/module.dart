/**
 * Core functionality for angular.dart, a web framework for Dart.
 *
 *
 * You must import the angular library to use it with Dart, like so:
 *
 *      import 'package:angular/core/module.dart';
 *
 * The angular.core library includes Angular's Directive and Filter classes:
 *
 *  - [angular.directive](#angular/angular-directive) lists all the basic directives
 *  - [angular.filter] (#angular/angular-filter) lists all the basic filters
 *
 * You might also want to optionally import the following Angular libraries:
 *
 *   - [angular.animate](#angular/angular-animate) supports CSS animations that modify the
 *   lifecycle of a DOM
 *   element
 *   - [angular.mock](#angular/angular-mock) provides classes and utilities for testing and
 *   prototyping
 *   - [angular.perf](#angular/angular-perf) provides classes to help evaluate performance in your
 *   app
 *
 *
 * Further reading:
 *
 *   - AngularDart [Overview](http://www.angulardart.org)
 *   - [Tutorial](https://angulardart.org/tutorial/)
 *   - [Mailing List](http://groups.google.com/d/forum/angular-dart?hl=en)
 *
 */
library angular.core;


export "package:angular/core/parser/parser.dart" show
    Parser;

export "package:angular/core/parser/dynamic_parser.dart" show
    ClosureMap;

export "package:angular/change_detection/change_detection.dart" show
    AvgStopwatch,
    FieldGetterFactory;

export "package:angular/core_dom/module_internal.dart" show
    Animation,
    AnimationResult,
    BrowserCookies,
    Cache,
    Compiler,
    Cookies,
    BoundViewFactory,
    DirectiveMap,
    ElementProbe,
    EventHandler,
    Http,
    HttpBackend,
    HttpDefaultHeaders,
    HttpDefaults,
    HttpInterceptor,
    HttpInterceptors,
    HttpResponse,
    HttpResponseConfig,
    LocationWrapper,
    NoOpAnimation,
    NullTreeSanitizer,
    NgAnimate,
    NgElement,
    RequestErrorInterceptor,
    RequestInterceptor,
    Response,
    ResponseError,
    UrlRewriter,
    TemplateCache,
    View,
    ViewCache,
    ViewFactory,
    ViewPort;

export "package:angular/core/module_internal.dart" show
    CacheStats,
    ExceptionHandler,
    FilterMap,
    Interpolate,
    NgZone,
    PrototypeMap,
    RootScope,
    Scope,
    ScopeDigestTTL,
    ScopeEvent,
    ScopeStats,
    ScopeStatsConfig,
    ScopeStatsEmitter,
    Watch;
