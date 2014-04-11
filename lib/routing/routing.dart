part of angular.routing;

/**
 * A factory of route to template bindings.
 */
class RouteViewFactory {
  NgRoutingHelper locationService;

  RouteViewFactory(this.locationService);

  call(String templateUrl) =>
      (RouteEnterEvent event) => _enterHandler(event, templateUrl);

  _enterHandler(RouteEnterEvent event, String templateUrl,
                [List<Module> modules]) =>
      locationService._route(event.route, templateUrl, fromEvent: true,
          modules: modules);

  configure(Map<String, NgRouteCfg> config) =>
      _configure(locationService.router.root, config);

  _configure(Route route, Map<String, NgRouteCfg> config) {
    config.forEach((name, cfg) {
      var moduledCalled = false;
      List<Module> newModules;
      route.addRoute(
          name: name,
          path: cfg.path,
          defaultRoute: cfg.defaultRoute,
          enter: (RouteEnterEvent e) {
            if (cfg.view != null) {
              _enterHandler(e, cfg.view, newModules);
            }
            if (cfg.enter != null) {
              cfg.enter(e);
            }
          },
          preEnter: (RoutePreEnterEvent e) {
            if (cfg.modules != null && !moduledCalled) {
              moduledCalled = true;
              var modules = cfg.modules();
              if (modules is Future) {
                e.allowEnter(modules.then((List<Module> m) {
                  newModules = m;
                  return true;
                }));
              } else {
                newModules = modules;
              }
            }
            if (cfg.preEnter != null) {
              cfg.preEnter(e);
            }
          },
          leave: cfg.leave,
          mount: (Route mountRoute) {
            if (cfg.mount != null) {
              _configure(mountRoute, cfg.mount);
            }
          });
    });
  }
}

NgRouteCfg ngRoute({String path, String view, Map<String, NgRouteCfg> mount,
    modules(), bool defaultRoute: false, RoutePreEnterEventHandler preEnter,
    RouteEnterEventHandler enter, RouteLeaveEventHandler leave}) =>
        new NgRouteCfg(path: path, view: view, mount: mount, modules: modules,
            defaultRoute: defaultRoute, preEnter: preEnter, enter: enter,
            leave: leave);

class NgRouteCfg {
  final String path;
  final String view;
  final Map<String, NgRouteCfg> mount;
  final Function modules;
  final bool defaultRoute;
  final RouteEnterEventHandler enter;
  final RoutePreEnterEventHandler preEnter;
  final RouteLeaveEventHandler leave;

  NgRouteCfg({this.view, this.path, this.mount, this.modules, this.defaultRoute,
      this.enter, this.preEnter, this.leave});
}

/**
 * An interface that must be implemented by the user of routing library and
 * should include the route initialization.
 *
 * The [init] method will be called by the framework once the router is
 * instantiated but before [NgBindRouteDirective] and [NgViewDirective].
 *
 * Deprecated: use RouteInitializerFn instead.
 */
@deprecated
abstract class RouteInitializer {
  void init(Router router, RouteViewFactory viewFactory);
}

/**
 * An typedef that must be implemented by the user of routing library and
 * should include the route initialization.
 *
 * The function will be called by the framework once the router is
 * instantiated but before [NgBindRouteDirective] and [NgViewDirective].
 */
typedef void RouteInitializerFn(Router router, RouteViewFactory viewFactory);

/**
 * A singleton helper service that handles routing initialization, global
 * events and view registries.
 */
@Injectable()
class NgRoutingHelper {
  final Router router;
  final Application _ngApp;
  List<NgView> portals = <NgView>[];
  Map<String, _View> _templates = new Map<String, _View>();

  NgRoutingHelper(RouteInitializer initializer, Injector injector, this.router,
                  this._ngApp) {
    // TODO: move this to constructor parameters when di issue is fixed:
    // https://github.com/angular/di.dart/issues/40
    RouteInitializerFn initializerFn = injector.get(RouteInitializerFn);
    if (initializer == null && initializerFn == null) {
      window.console.error('No RouteInitializer implementation provided.');
      return;
    };

    if (initializerFn != null) {
      initializerFn(router, new RouteViewFactory(this));
    } else {
      initializer.init(router, new RouteViewFactory(this));
    }
    router.onRouteStart.listen((RouteStartEvent routeEvent) {
      routeEvent.completed.then((success) {
        if (success) {
          portals.forEach((NgView p) => p._maybeReloadViews());
        }
      });
    });

    router.listen(appRoot: _ngApp.element);
  }

  _reloadViews({Route startingFrom}) {
    var alreadyActiveViews = [];
    var activePath = router.activePath;
    if (startingFrom != null) {
      activePath = activePath.skip(_routeDepth(startingFrom));
    }
    for (Route route in activePath) {
      var viewDef = _templates[_routePath(route)];
      if (viewDef == null) continue;
      var templateUrl = viewDef.template;

      NgView view = portals.lastWhere((NgView v) {
        return _routePath(route) != _routePath(v._route) &&
            _routePath(route).startsWith(_routePath(v._route));
      }, orElse: () => null);
      if (view != null && !alreadyActiveViews.contains(view)) {
        view._show(templateUrl, route, viewDef.modules);
        alreadyActiveViews.add(view);
        break;
      }
    }
  }

  _route(Route route, String template, {bool fromEvent, List<Module> modules}) {
    _templates[_routePath(route)] = new _View(template, modules);
  }

  _registerPortal(NgView ngView) {
    portals.add(ngView);
  }

  _unregisterPortal(NgView ngView) {
    portals.remove(ngView);
  }
}

class _View {
  final String template;
  final List<Module> modules;

  _View(this.template, this.modules);
}

String _routePath(Route route) {
  var path = [];
  var p = route;
  while (p.parent != null) {
    path.insert(0, p.name);
    p = p.parent;
  }
  return path.join('.');
}

int _routeDepth(Route route) {
  var depth = 0;
  var p = route;
  while (p.parent != null) {
    depth++;
    p = p.parent;
  }
  return depth;
}
