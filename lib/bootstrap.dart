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
    value(NgApp, new NgApp(dom.window.document.documentElement));
  }
}

Injector _defaultInjectorFactory(List<Module> modules) =>
    new DynamicInjector(modules: modules);

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
 *   - [module] Option application module to add to the [Injector].
 *   - [modules] Optional list of [Module]s to add to the [Injector] (if more than one is needed).
 *   - [element] Optional root element of the application. If non specified, the
 *     the root element is looked up using the [selector]. If selector can not
 *     identify a root, the root [HTTML] element is used for bootstraping.
 *   - [selector] Optional CSS selector used to locate the root element for the application.
 *   - [injectorFactor] Optional factory responsible for creating the injector.
 *
 *
 *
 * # A typical way to boostrap an Angular application:
 *
 *     Module myAppModule = new Module();
 *     myAppModule.type(MyType);
 *     ....
 *     Injector injector = ngBootstrap(module: myAppModule);
 */
Injector ngBootstrap({
        Module module: null,
        List<Module> modules: null,
        dom.Element element: null,
        String selector: '[ng-app]',
        Injector injectorFactory(List<Module> modules): _defaultInjectorFactory}) {
  _publishToJavaScript();

  var ngModules = [new AngularModule()];
  if (module != null) ngModules.add(module);
  if (modules != null) ngModules.addAll(modules);
  if (element == null) {
    element = dom.querySelector(selector);
    var document = dom.window.document;
    if (element == null) element = document.childNodes.firstWhere((e) => e is dom.Element);
  }

  // The injector must be created inside the zone, so we create the
  // zone manually and give it back to the injector as a value.
  NgZone zone = new NgZone();
  ngModules.add(new Module()
      ..value(NgZone, zone)
      ..value(NgApp, new NgApp(element)));

  return zone.run(() {
    var rootElements = [element];
    Injector injector = injectorFactory(ngModules);
    injector.get(Compiler)(rootElements)(injector, rootElements);
    return injector;
  });
}

/// Holds a reference to the root of the application used by ngBootstrap.
class NgApp {
  final dom.Element root;
  NgApp(this.root);
}
