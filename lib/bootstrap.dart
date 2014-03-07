part of angular;

/**
 * This is the top level module which describes the whole of angular.
 *
 * The Module is made up of
 *
 * - [NgCoreModule]
 * - [NgCoreDomModule]
 * - [NgDirectiveModule]
 * - [NgFilterModule]
 * - [NgPerfModule]
 * - [NgRoutingModule]
 */
class AngularModule extends Module {
  AngularModule() {
    install(new NgCoreModule());
    install(new NgCoreDomModule());
    install(new NgDirectiveModule());
    install(new NgFilterModule());
    install(new NgPerfModule());
    install(new NgRoutingModule());

    type(MetadataExtractor);
    value(Expando, _elementExpando);
  }
}

/**
 * This method is the main entry point to an angular application.
 *
 * # The [ngBootstrap] is responsible for:
 *
 *   1. Locating the root element of the application,
 *   2. Creating Angular [NgZone]
 *   3. Inside the [NgZone] create an injector
 *   4. Retrieve the [Compiler] and compile the root eleement
 *
 *
 * # Parameters:
 *
 *   - [module] Optional application module to add to the [Injector].
 *   - [modules] Optional list of [Module]s to add to the [Injector] (when more
 *     than one is needed).
 *   - [element] Optional root element of the application. If non specified, the
 *     the root element is looked up using the [selector]. If the selector can
 *     not identify a root, the root [HTML] element is used.
 *   - [selector] Optional CSS selector used to locate the root element for the
 *     application.
 *   - [injectorFactory] Optional factory responsible for creating the injector.
 *
 *
 *
 * # A typical way to boostrap an Angular application:
 *
 *     var myAppModule = new Module();
 *     myAppModule.type(MyType);
 *     ....
 *     Injector injector = ngBootstrap(module: myAppModule);
 */

abstract class NgApp {
  static _find(String selector, [dom.Element defaultElement]) {
    var element = dom.window.document.querySelector(selector);
    if (element == null) element = defaultElement;
    if (element == null)throw "Could not find application element '$selector'.";
    return element;
  }

  final NgZone zone = new NgZone();
  final AngularModule ngModule = new AngularModule();
  final List<Module> modules = <Module>[];
  dom.Element element;

  dom.Element selector(String selector) => element = _find(selector);

  NgApp(): element = _find('[ng-app]', dom.window.document.documentElement) {
    modules.add(ngModule);
    ngModule
      ..value(NgZone, zone)
      ..value(NgApp, this)
      ..factory(dom.Node, (i) => i.get(NgApp).element);
  }

  Injector injector;

  NgApp addModule(Module module) {
    modules.add(module);
    return this;
  }

  Injector run() {
    _publishToJavaScript();
    return zone.run(() {
      var rootElements = [element];
      Injector injector = createInjector();
      ExceptionHandler exceptionHandler = injector.get(ExceptionHandler);
      initializeDateFormatting(null, null).then((_) {
        try {
          var compiler = injector.get(Compiler);
          var blockFactory = compiler(rootElements, injector.get(DirectiveMap));
          blockFactory(injector, rootElements);
        } catch (e, s) {
          exceptionHandler(e, s);
        }
      });
      return injector;
    });
  }

  Injector createInjector();
}
