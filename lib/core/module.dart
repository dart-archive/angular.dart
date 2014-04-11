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
 *  - [angular.formatter] (#angular/angular-formatter) lists all the basic formatters
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


export "package:angular/core_dom/module_internal.dart" show
    Animation,
    AnimationResult,
    BrowserCookies,
    Compiler,
    Cookies,
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
    NoOpAnimation,
    NullTreeSanitizer,
    Animate,
    RequestErrorInterceptor,
    RequestInterceptor,
    Response,
    ResponseError,
    TemplateCache,
    View,
    ViewFactory,
    ViewPort;
export "package:angular/core/module_internal.dart" show
    CacheStats,
    ExceptionHandler,
    Interpolate,
    VmTurnZone,
    PrototypeMap,
    RootScope,
    Scope,
    ScopeDigestTTL,
    ScopeEvent,
    ScopeStats,
    ScopeStatsConfig,
    ScopeStatsEmitter,
    Watch;
